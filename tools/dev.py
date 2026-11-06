"""
Dev loop: mirror the mod into BeamNG's mods/unpacked/ folder and hot-reload
exactly what changed in the running game.

The game half is driven through BeamNG's built-in MCP server (0.39+), a local
JSON-RPC endpoint on http://127.0.0.1:29292/mcp that can run GE Lua. It is off
by default: `launch`/`restart` start the game with -enablemcp, or turn on
Options > Advanced > "Enable MCP server" once.

Every deploy runs package.py's preflight first (luac -p, the stray-global
check, the mock harness, brush sidecars), so code that would crash in game
never reaches the mods folder. Only the shipped trees (lua/, art/) are copied,
using the same allow-list as the zip, so the dev mount behaves like a real
install.

What a change reloads:
  lua/ge/ (paint.lua)          extensions.reload('scratches_paint')
  lua/vehicle/ (detector)      player vehicle reload (Ctrl+R equivalent)
  input action .json           full GE Lua reload (Ctrl+L equivalent)
  art/ (brush PNGs)            painter reload (restart for edited brushes)
After reloading it tails beamng.log and prints the mod's lines and any errors.

Run: python tools/dev.py deploy      sync + hot-reload once (the default)
     python tools/dev.py watch       deploy on every save until Ctrl+C
     python tools/dev.py launch      start the game into a level, MCP on
     python tools/dev.py restart     quit the game and launch it again
     python tools/dev.py lua CODE    run GE Lua, print the result
     python tools/dev.py status      paths, game, MCP and mount state
     python tools/dev.py unmount     remove the dev mount from mods/unpacked

Overrides: BEAMNG_USER (versioned user folder), BEAMNG_GAME (install dir),
BEAMNG_MCP_PORT, BEAMNG_LEVEL (default gridmap_v2).
"""

import argparse
import configparser
import http.client
import json
import os
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import package  # noqa: E402  (preflight + the shipped-file allow-list)

ROOT = package.ROOT
MOD_NAME = "scratches_mod"
GAME_EXE = "BeamNG.drive.x64.exe"
MCP_PORT = int(os.environ.get("BEAMNG_MCP_PORT", "29292"))
MCP_PORT_TRIES = 4  # the server walks to the next port when its own is taken
DEFAULT_LEVEL = os.environ.get("BEAMNG_LEVEL", "gridmap_v2")

# Dev-only Lua copied into the mount but never into the release zip:
# (repo path, path inside the mount).
BENCH_ARC = "lua/ge/extensions/scratches/bench.lua"
DEV_EXTRAS = [("tools/ingame/scratches_bench.lua", BENCH_ARC)]
WATCH_DIRS = package.INCLUDE_DIRS + ["tools/ingame"]
# Engine globals the bench may touch, on top of the stdlib and GE lists in
# package.py. Anything else is a local used above its declaration or a typo.
BENCH_GLOBALS = {
    "Engine", "FS", "QuatF", "be", "core_camera", "core_vehicle_partmgmt", "core_vehicles",
    "createObject", "createScreenshot2", "createVehiclePaint", "jsonDecode", "jsonEncode",
    "loadstring", "quat", "quatFromAxisAngle", "quatFromDir", "scratches_paint",
    "setExtensionUnloadMode", "settings", "ui_visibility",
}

# Log lines that prove a reload actually re-ran the module's load hook.
PAINT_MARKER = "probes: scratches_paint."
DETECT_MARKER = "probes: scratches_detect."


class DeployError(Exception):
    pass


# ---------------------------------------------------------------- paths --

def beamng_ini() -> configparser.SectionProxy:
    ini = os.path.join(os.environ.get("LOCALAPPDATA", ""), "BeamNG", "BeamNG.drive.ini")
    cp = configparser.ConfigParser()
    if os.path.isfile(ini):
        with open(ini, encoding="utf-8-sig") as f:
            cp.read_string("[ini]\n" + f.read())
    else:
        cp.read_string("[ini]\n")
    return cp["ini"]


def user_dir() -> str:
    if os.environ.get("BEAMNG_USER"):
        return os.environ["BEAMNG_USER"]
    ini = beamng_ini()
    base = ini.get("userFolder") or os.path.join(
        os.environ.get("LOCALAPPDATA", ""), "BeamNG", "BeamNG.drive")
    # Since 0.37 the live versioned folder is always "current".
    return os.path.join(base, "current")


def game_dir() -> str:
    return os.environ.get("BEAMNG_GAME") or beamng_ini().get("installPath", "").rstrip("\\/")


def mount_dir() -> str:
    return os.path.join(user_dir(), "mods", "unpacked", MOD_NAME)


# ----------------------------------------------------------------- sync --

def mount_files() -> list[tuple[str, str]]:
    """The shipped files plus the dev-only extras, as (abs path, mount arcname)."""
    extras = [(os.path.join(ROOT, *src.split("/")), arc) for src, arc in DEV_EXTRAS]
    return package.collect_files() + [(p, a) for p, a in extras if os.path.isfile(p)]


def preflight() -> list[tuple[str, str]]:
    """package.py's checks; they sys.exit on failure, which we turn into an error.
    Dev extras get a syntax check only (they use engine globals freely)."""
    try:
        files = package.collect_files()
        package.check_lua_syntax(files)
        package.check_brush_sidecars(files)
    except SystemExit as e:
        msg = str(e.code) if e.code not in (None, 0) else "preflight failed"
        raise DeployError(msg.removeprefix("error: "))
    files = mount_files()
    luac = shutil.which("luac") or shutil.which("luac5.1")
    extras = [p for p, a in files if a == BENCH_ARC]
    if luac and extras:
        r = subprocess.run([luac, "-p", *extras], capture_output=True, text=True)
        if r.returncode != 0:
            raise DeployError("Lua syntax check failed" + chr(10) + (r.stderr or r.stdout))
        allowed = package.LUA_STDLIB_GLOBALS | package.ENGINE_GLOBALS["lua/ge/"] | BENCH_GLOBALS
        for path in extras:
            listing = subprocess.run([luac, "-l", "-p", path], capture_output=True, text=True).stdout
            bad = sorted({f"{op} {name}" for op, name in package.GLOBAL_RE.findall(listing)
                          if op == "SETGLOBAL" or name not in allowed})
            if bad:
                raise DeployError(f"unexpected Lua globals in {os.path.relpath(path, ROOT)} "
                                  "(a local used before its declaration, or a typo?): " + ", ".join(bad))
    return files


def out_of_date(files: list[tuple[str, str]]) -> bool:
    """True when the mount differs from the repo (cheap: stat only)."""
    dest_root = mount_dir()
    wanted = set()
    for src, arc in files:
        wanted.add(arc)
        try:
            s, d = os.stat(src), os.stat(os.path.join(dest_root, *arc.split("/")))
        except FileNotFoundError:
            return True
        if d.st_size != s.st_size or int(d.st_mtime) != int(s.st_mtime):
            return True
    for dirpath, _, filenames in os.walk(dest_root):
        for name in filenames:
            arc = os.path.relpath(os.path.join(dirpath, name), dest_root).replace(os.sep, "/")
            if arc not in wanted:
                return True
    return False


def sync(files: list[tuple[str, str]]) -> tuple[list[str], bool]:
    """Mirror `files` into the mount. Returns (changed arcnames, first_mount)."""
    dest_root = mount_dir()
    first_mount = not os.path.isdir(dest_root)
    changed = []
    wanted = set()
    for src, arc in files:
        wanted.add(arc)
        dst = os.path.join(dest_root, *arc.split("/"))
        s = os.stat(src)
        try:
            d = os.stat(dst)
            if d.st_size == s.st_size and int(d.st_mtime) == int(s.st_mtime):
                continue
        except FileNotFoundError:
            pass
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
        changed.append(arc)
    # Drop anything the repo no longer ships, so a deleted file can't linger in game.
    for dirpath, dirnames, filenames in os.walk(dest_root, topdown=False):
        for name in filenames:
            p = os.path.join(dirpath, name)
            arc = os.path.relpath(p, dest_root).replace(os.sep, "/")
            if arc not in wanted:
                os.remove(p)
                changed.append(arc)
        if dirpath != dest_root and not os.listdir(dirpath):
            os.rmdir(dirpath)
    return changed, first_mount


def conflicting_installs() -> list[str]:
    mods = os.path.join(user_dir(), "mods")
    hits = []
    for sub in ("", "repo"):
        d = os.path.join(mods, sub)
        if os.path.isdir(d):
            hits += [os.path.join(d, n) for n in os.listdir(d)
                     if n.lower().startswith("scratches") and n.lower().endswith(".zip")]
    return hits


# ------------------------------------------------------------------ game --

def game_running() -> bool:
    if os.name != "nt":
        return False
    out = subprocess.run(["tasklist", "/FI", f"IMAGENAME eq {GAME_EXE}", "/NH", "/FO", "CSV"],
                         capture_output=True, text=True).stdout
    return GAME_EXE.lower() in out.lower()


_port_cache = None


def mcp_call(tool: str, arguments: dict | None = None, read_timeout: float = 30.0):
    """Call one MCP tool. Returns (text, is_error); raises ConnectionError if no server."""
    global _port_cache
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": "tools/call",
                       "params": {"name": tool, "arguments": arguments or {}}})
    ports = [_port_cache] if _port_cache else [MCP_PORT + i for i in range(MCP_PORT_TRIES)]
    for port in ports:
        # Short connect timeout: a closed localhost port on Windows otherwise
        # takes ~2 s to refuse. The read can be slow (the game answers on its
        # next frame, and a level load stalls frames for seconds).
        conn = http.client.HTTPConnection("127.0.0.1", port, timeout=0.5)
        try:
            conn.connect()
        except OSError:
            conn.close()
            continue
        try:
            conn.sock.settimeout(read_timeout)
            conn.request("POST", "/mcp", body, {"Content-Type": "application/json",
                                                "Accept": "application/json, text/event-stream"})
            resp = json.loads(conn.getresponse().read().decode("utf-8"))
        except (OSError, ValueError, http.client.HTTPException) as e:
            # Connected but no answer: the game is busy or shutting down.
            # Another port won't help.
            raise ConnectionAbortedError(f"MCP on port {port} did not answer: {e}")
        finally:
            conn.close()
        _port_cache = port
        if "error" in resp:
            return resp["error"].get("message", "rpc error"), True
        res = resp.get("result", {})
        text = "".join(c.get("text", "") for c in res.get("content", []))
        return text, bool(res.get("isError"))
    _port_cache = None
    raise ConnectionError("no BeamNG MCP server (game not running, or MCP disabled)")


def lua(code: str, read_timeout: float = 30.0) -> str:
    text, err = mcp_call("run_lua", {"code": code}, read_timeout)
    if err:
        raise DeployError("GE Lua failed: " + text)
    return text


class LogTail:
    """Game log lines since construction, read through Engine.getFrameLog().

    beamng.log on disk is buffered and lags by seconds, too late to judge a
    reload. getFrameLog() hands back every line (GE and vehicle VMs) logged
    since its previous call, so draining it first gives a clean window. The
    in-game console drains the same buffer while its window is open, so with
    the console showing, reload output appears there instead of here."""

    DRAIN = ("local f = Engine.getFrameLog() or {} local o = {} "
             "for i, l in ipairs(f) do o[i] = string.format('%10.5f|%s|%s| %s', "
             "l[1] or 0, tostring(l[2]), tostring(l[3]), tostring(l[4])) end "
             "return #o > 0 and jsonEncode(o) or ''")

    def __init__(self):
        self.read()

    def read(self) -> list[str]:
        try:
            text = lua(self.DRAIN, read_timeout=10)
        except (ConnectionError, DeployError):
            return []  # mid-reload (Ctrl+L drops the server briefly); try again
        return json.loads(text) if text else []


def wait_for_markers(tail: LogTail, markers: set[str], timeout: float) -> tuple[list[str], set[str]]:
    lines, pending = [], set(markers)
    deadline = time.time() + timeout
    while pending and time.time() < deadline:
        time.sleep(0.25)
        lines += tail.read()
        pending = {m for m in pending if not any(m in ln for ln in lines)}
    time.sleep(0.5)  # let the load's own follow-up lines land
    return lines + tail.read(), pending


def report_lines(lines: list[str]) -> list[str]:
    """Print the mod's log lines; return the mod's errors. Errors from the game
    itself (shader compiles, level scans) are counted but don't fail a deploy."""
    errors, other = [], 0
    for ln in lines:
        first = ln.strip().splitlines()[0] if ln.strip() else ""
        ours = "scratches" in ln.lower()
        if "|E|" in ln and not ours:
            other += 1
            continue
        if ours:
            print("    " + first[:240])
            if "|E|" in ln:
                errors.append(ln.strip())
    if other:
        print(f"    ({other} error line(s) from the game itself, unrelated to the mod)")
    return errors


# --------------------------------------------------------------- reload --

def plan_reload(changed: list[str], first_mount: bool) -> dict:
    bench = BENCH_ARC in changed
    ge = any(a.startswith("lua/ge/") and a.endswith(".lua") and a != BENCH_ARC for a in changed)
    actions = any(a.startswith("lua/ge/extensions/core/input/") for a in changed)
    veh = any(a.startswith("lua/vehicle/") for a in changed)
    art = any(a.startswith("art/") for a in changed)
    return {"mount": first_mount, "ge_full": actions, "ge": ge or art, "art": art,
            "vehicle": veh or first_mount, "bench": bench}


def hot_reload(plan: dict) -> list[str]:
    """Apply `plan` in the running game. Returns error log lines."""
    tail = LogTail()
    markers, steps = set(), []
    if plan["mount"]:
        # The mod manager only scans mods/unpacked/ at startup.
        steps.append("mounted mod")
        lua("core_modmanager.initDB() "
            f"local m = core_modmanager.getModDB('{MOD_NAME}') "
            f"if m and not m.active then core_modmanager.activateMod('{MOD_NAME}') end "
            "return 'ok'", read_timeout=120)
    if plan["art"]:
        # Not reloadTextures(): it leaves the decal API's per-composite vehicle
        # sync ~2x slower for the rest of the session (measured 24 -> 55 ms,
        # compounding per call). New brush files load by path when baked;
        # an edited existing brush stays cached until the game restarts.
        print("  art changed: new brushes load on first use; edits to an existing "
              "brush need `dev.py restart`")
    if plan["ge_full"]:
        # Deferred to next frame by the engine, so this call still returns.
        steps.append("GE Lua (full)")
        lua("Lua:requestReload() return 'ok'")
        markers.add(PAINT_MARKER)
    elif plan["ge"]:
        steps.append("painter")
        lua("extensions.reload('scratches_paint') return 'ok'")
        markers.add(PAINT_MARKER)
    if plan.get("bench") and not plan["ge_full"]:
        steps.append("bench")
        lua("if extensions.isExtensionLoaded('scratches_bench') then "
            "extensions.reload('scratches_bench') end return 'ok'")
    if plan["vehicle"]:
        steps.append("player vehicle")
        has_vehicle = lua("return tostring(be:getPlayerVehicle(0) ~= nil)") == "true"
        if has_vehicle:
            lua("core_vehicle_manager.reloadVehicle(0) return 'ok'")
            markers.add(DETECT_MARKER)
        else:
            print("  no player vehicle - detector loads on next spawn")
    print("  reloaded: " + ", ".join(steps))
    lines, missing = wait_for_markers(tail, markers, timeout=20 if plan["ge_full"] else 10)
    errors = report_lines(lines)
    for m in sorted(missing):
        errors.append(f"reload never logged '{m}' - did the module fail to load?")
        print("  warn: " + errors[-1])
    return errors


def deploy(quiet_if_unchanged: bool = False, force_reload: bool = False) -> int:
    t0 = time.time()
    if not force_reload and not out_of_date(mount_files()):
        if not quiet_if_unchanged:
            print("  no changes")
        return 0
    files = preflight()
    for z in conflicting_installs():
        print(f"  warn: {z} is also installed; it will fight the dev mount. Remove it.")
    changed, first_mount = sync(files)
    if not changed and not force_reload:
        if not quiet_if_unchanged:
            print("  no changes")
        return 0
    if changed:
        print(f"  synced {len(changed)} file(s) -> {mount_dir()}")
        for a in changed[:8]:
            print("    " + a)
        if len(changed) > 8:
            print(f"    ... and {len(changed) - 8} more")
    plan = plan_reload(changed, first_mount)
    if force_reload:
        plan.update(ge=True, vehicle=True)
    if not game_running():
        print("  game not running - files are in place for next launch")
        return 0
    try:
        errors = hot_reload(plan)
    except ConnectionError:
        print("  game is running but MCP is off - enable Options > Advanced > "
              "'Enable MCP server', or use `dev.py restart`. Reload by hand: "
              "Ctrl+L (painter), Ctrl+R (detector).")
        return 0
    status = "FAILED" if errors else "ok"
    print(f"  {status} in {time.time() - t0:.1f}s")
    if errors:
        raise DeployError("errors in game log after reload:\n  " + "\n  ".join(errors[:20]))
    return 0


# ------------------------------------------------------------- commands --

def cmd_deploy(args) -> int:
    print(f"deploy {ROOT}")
    try:
        return deploy(force_reload=args.reload)
    except DeployError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1


def cmd_hook(args) -> int:
    """Claude Code Stop hook: deploy after each turn. Exit 2 feeds failures back
    to Claude so it fixes them; stop_hook_active prevents a retry loop."""
    try:
        event = json.load(sys.stdin)
    except ValueError:
        event = {}
    try:
        deploy(quiet_if_unchanged=True)
    except DeployError as e:
        if event.get("stop_hook_active"):
            return 0
        print(f"BeamNG dev deploy failed (tools/dev.py):\n{e}", file=sys.stderr)
        return 2
    except Exception as e:  # never wedge the session on a tooling bug
        print(f"dev.py hook error: {e}", file=sys.stderr)
    return 0


def snapshot(paths: list[str]) -> dict:
    out = {}
    for p in paths:
        for dirpath, _, filenames in os.walk(os.path.join(ROOT, p)):
            for n in filenames:
                fp = os.path.join(dirpath, n)
                try:
                    st = os.stat(fp)
                    out[fp] = (st.st_mtime_ns, st.st_size)
                except FileNotFoundError:
                    pass
    return out


def cmd_watch(args) -> int:
    print(f"watching {ROOT} (lua/, art/, tools/ingame/) - Ctrl+C to stop")
    try:
        deploy()
    except DeployError as e:
        print(f"error: {e}", file=sys.stderr)
    last = snapshot(WATCH_DIRS)
    try:
        while True:
            time.sleep(0.4)
            cur = snapshot(WATCH_DIRS)
            if cur == last:
                continue
            time.sleep(0.3)  # debounce: editors write in bursts
            last = snapshot(WATCH_DIRS)
            print(time.strftime("[%H:%M:%S] change detected"))
            try:
                deploy()
            except DeployError as e:
                print(f"error: {e}", file=sys.stderr)
    except KeyboardInterrupt:
        return 0


def wait_ready(timeout: float) -> bool:
    """Wait for MCP, a player vehicle, and the painter to be loaded."""
    deadline = time.time() + timeout
    probe = ("return tostring(be ~= nil and be:getPlayerVehicle(0) ~= nil) .. ',' "
             ".. tostring(scratches_paint ~= nil)")
    state = "waiting for MCP"
    while time.time() < deadline:
        try:
            if lua(probe, read_timeout=60) == "true,true":
                return True
            state = "waiting for vehicle + painter"
        except (ConnectionError, DeployError):
            pass
        print(f"  {state}...", end="\r", flush=True)
        time.sleep(2)
    print()
    return False


def cmd_launch(args) -> int:
    if game_running():
        print("game already running")
        return 0
    try:
        deploy()
    except DeployError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    exe = os.path.join(game_dir(), "Bin64", GAME_EXE)
    if not os.path.isfile(exe):
        print(f"error: no game binary at {exe} (set BEAMNG_GAME)", file=sys.stderr)
        return 1
    argv = [exe, "-enablemcp"]
    if args.level != "none":
        argv += ["-level", args.level]
    argv += args.game_args or []
    print("launching: " + " ".join(argv))
    flags = 0
    if os.name == "nt":
        flags = subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP
    subprocess.Popen(argv, cwd=game_dir(), creationflags=flags, close_fds=True,
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if args.no_wait or args.level == "none":
        return 0
    t0 = time.time()
    if wait_ready(args.timeout):
        print(f"ready in {time.time() - t0:.0f}s - car spawned, painter loaded")
        return 0
    print("error: game did not become ready in time (check beamng.log)", file=sys.stderr)
    return 1


def cmd_quit(args) -> int:
    if not game_running():
        print("game not running")
        return 0
    try:
        lua("quit() return 'ok'", read_timeout=5)
        print("asked the game to quit")
    except ConnectionAbortedError:
        print("asked the game to quit")  # it began shutting down before replying
    except (ConnectionError, DeployError):
        print("MCP unreachable - force-closing the game")
        subprocess.run(["taskkill", "/IM", GAME_EXE, "/F"], capture_output=True)
    deadline = time.time() + 30
    while game_running() and time.time() < deadline:
        time.sleep(0.5)
    if game_running():
        subprocess.run(["taskkill", "/IM", GAME_EXE, "/F"], capture_output=True)
        time.sleep(2)
    return 0


def cmd_restart(args) -> int:
    cmd_quit(args)
    return cmd_launch(args)


def cmd_lua(args) -> int:
    try:
        print(lua(" ".join(args.code)))
        return 0
    except (ConnectionError, DeployError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1


def cmd_status(args) -> int:
    print(f"repo         {ROOT}")
    print(f"game         {game_dir()}")
    print(f"user folder  {user_dir()}")
    print(f"dev mount    {mount_dir()} ({'present' if os.path.isdir(mount_dir()) else 'absent'})")
    for z in conflicting_installs():
        print(f"conflict     {z}")
    running = game_running()
    print(f"game         {'running' if running else 'not running'}")
    if running:
        try:
            print("in game      " + lua(
                "return 'vehicle=' .. tostring(be:getPlayerVehicle(0) ~= nil) .. "
                "' painter=' .. tostring(scratches_paint ~= nil) .. "
                f"' mod=' .. tostring(core_modmanager.getModDB('{MOD_NAME}') ~= nil)"))
            print(f"mcp          http://127.0.0.1:{_port_cache}/mcp")
        except (ConnectionError, DeployError) as e:
            print(f"mcp          unavailable ({e})")
    return 0


def cmd_unmount(args) -> int:
    d = mount_dir()
    if os.path.isdir(d):
        shutil.rmtree(d)
        print(f"removed {d} (takes effect on next game start)")
    else:
        print("no dev mount")
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    sub = p.add_subparsers(dest="cmd")
    d = sub.add_parser("deploy", help="sync + hot-reload once")
    d.add_argument("--reload", action="store_true", help="reload painter + vehicle even if nothing changed")
    sub.add_parser("watch", help="deploy on every change")
    sub.add_parser("hook", help="Claude Code Stop-hook entry point")
    for name in ("launch", "restart"):
        lp = sub.add_parser(name, help=f"{name} the game with MCP enabled")
        lp.add_argument("--level", default=DEFAULT_LEVEL, help="level to boot into, or 'none' for the main menu")
        lp.add_argument("--timeout", type=float, default=240, help="seconds to wait for the car + painter")
        lp.add_argument("--no-wait", action="store_true")
        lp.add_argument("--game-arg", dest="game_args", action="append", metavar="ARG",
                        help="extra game command-line argument (repeatable), e.g. --game-arg=-gfx --game-arg=vk")
    sub.add_parser("quit", help="quit the game")
    lp = sub.add_parser("lua", help="run GE Lua and print the result")
    lp.add_argument("code", nargs="+")
    sub.add_parser("status")
    sub.add_parser("unmount")
    args = p.parse_args()
    handlers = {"deploy": cmd_deploy, "watch": cmd_watch, "hook": cmd_hook, "launch": cmd_launch,
                "restart": cmd_restart, "quit": cmd_quit, "lua": cmd_lua, "status": cmd_status,
                "unmount": cmd_unmount}
    if args.cmd is None:
        args = p.parse_args(["deploy"])
    return handlers[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
