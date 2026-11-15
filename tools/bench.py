"""
Scripted crash/scrape scenarios for tuning the mod, with per-frame timing.

Each run resets the player car (repaired, canvas wiped) at a fixed home pose,
launches it into a scenario, records every frame until it settles and the
painter's backlog drains, then screenshots the car from fixed angles with the
HUD hidden. The run folder gets:

  report.md     summary: marks, detector, painter cost, engine frame timing,
                worst frames, screenshots
  result.json   everything the game returned (counters, config, per-frame data)
  frames.csv    one row per frame: frame ms, painter ms, GE Lua, physics+VLUA,
                render, speed
  shot_*.jpg    the screenshots
  capture.opt   Optick capture of the run (with --optick; open it in Optick)

and a summary row is appended to bench/runs/index.csv for comparing tunings.

The background FPS limiter is lifted for the run (an unfocused game window is
otherwise capped at a few FPS) and restored afterwards. Needs the game running
with MCP on: `python tools/dev.py launch`.

Run: python tools/bench.py run sideslide
     python tools/bench.py run all --tag before
     python tools/bench.py run rollover --set paint.setProjectionBudget=3 --tag budget3
     python tools/bench.py run roofdrop --repeat 3 --optick
     python tools/bench.py list            compare the latest runs
     python tools/bench.py scenarios       describe the scenarios
     python tools/bench.py home --save     use the car's current pose as this level's home

--set takes paint.<fn>=args (GE painter) or detect.<fn>=args (vehicle
detector), e.g. detect.setThresholds=0.6,0.8,10. Overrides are undone after
the run (painter reload / vehicle reload) unless --keep is given.
"""

import argparse
import csv
import json
import os
import re
import shutil
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import dev  # noqa: E402

ROOT = dev.ROOT
BENCH_DIR = os.path.join(ROOT, "bench")
RUNS_DIR = os.path.join(BENCH_DIR, "runs")
INDEX = os.path.join(RUNS_DIR, "index.csv")
HOMES_FILE = os.path.join(BENCH_DIR, "homes.json")

# Where each run starts: the level's default spawn, measured. `home --save`
# adds or overrides entries in bench/homes.json.
HOMES = {
    "gridmap_v2": {"pos": {"x": 62.0871, "y": 20.8285, "z": 100.1934},
                   "dir": {"x": 0.00002, "y": 0.99998, "z": -0.00582},
                   "up": {"x": 0.00021, "y": 0.00582, "z": 0.99998}},
}

# offset/vel are in the home frame (fwd, right, up); euler in degrees.
SCENARIOS = {
    "sustained": dict(desc="assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions",
                      offset={"up": 1.3}, euler={"roll": 180}, vel={"fwd": 4},
                      sustainVelocity=True, settle=False, maxTime=30),
    "baseline": dict(desc="upright, coasting at 15 m/s - should leave no marks",
                     vel={"fwd": 15}, settle=False, maxTime=4),
    "roofdrop": dict(desc="dropped upside down from about 1 m - roof impacts",
                     offset={"up": 2.2}, euler={"roll": 180}, maxTime=8),
    "sideslide": dict(desc="on its side, sliding along the ground at 14 m/s - one long scrape",
                      offset={"up": 1.2}, euler={"roll": 90}, vel={"fwd": 14}, maxTime=10),
    "rollover": dict(desc="thrown sideways at 15 m/s, leaning 70 deg into the motion - tumbles over the roof",
                     offset={"up": 1.2}, euler={"roll": 70}, vel={"right": 15}, maxTime=12),
    "nosedive": dict(desc="pitched nose-down 40 deg, dropped from 1.6 m at 9 m/s",
                     offset={"up": 1.6}, euler={"pitch": -40}, vel={"fwd": 9}, maxTime=8),
}

# Photo angles in the car's own frame after it settles: az 0 = behind,
# 90 = its left, 180 = front, 270 = right; elev = degrees above horizontal.
SHOTS = [
    {"label": "left", "az": 90, "elev": 12, "dist": 4.5},
    {"label": "right", "az": 270, "elev": 12, "dist": 4.5},
    {"label": "front", "az": 180, "elev": 18, "dist": 5},
    {"label": "rear", "az": 0, "elev": 18, "dist": 5},
    {"label": "top", "az": 0, "elev": 88, "dist": 5.5},
]

INDEX_FIELDS = ["run", "scenario", "tag", "settled", "rolled", "seconds", "fps_avg", "frame_ms_p95",
                "frame_ms_max", "lua_ms_p95", "lua_ms_max", "phys_vlua_ms_p95", "painter_ms_avg",
                "painter_ms_p95", "painter_ms_max", "painter_frames_over4ms", "detect_us_per_contact",
                "detect_frame_ms_max", "contacts", "impacts", "streams", "projects", "bakes",
                "missed_pct", "jobs_dropped", "frames_deferred", "tuning"]


# ---------------------------------------------------------------- helpers --

def level_id() -> str:
    return dev.lua("return getCurrentLevelIdentifier and getCurrentLevelIdentifier() or ''")


def homes() -> dict:
    h = dict(HOMES)
    if os.path.isfile(HOMES_FILE):
        with open(HOMES_FILE, encoding="utf-8") as f:
            h.update(json.load(f))
    return h


def lua_long_string(s: str) -> str:
    eq = "="
    while f"]{eq}]" in s:
        eq += "="
    return f"[{eq}[{s}]{eq}]"


ARG_RE = re.compile(r"^(-?\d+(\.\d+)?|true|false)$")


def parse_tuning(sets: list[str]) -> list[dict]:
    out = []
    for item in sets or []:
        m = re.match(r"^(paint|detect)\.([A-Za-z_]\w*)=(.*)$", item)
        if not m:
            raise SystemExit(f"error: bad --set '{item}' (want paint.fn=args or detect.fn=args)")
        side, fn, raw = m.groups()
        args = [a.strip() for a in raw.split(",")] if raw.strip() else []
        if not all(ARG_RE.match(a) for a in args):
            raise SystemExit(f"error: --set '{item}': arguments must be numbers or true/false")
        call = f"{fn}({', '.join(args)})"
        if side == "paint":
            out.append({"vm": "ge", "code": f"scratches_paint.{call}"})
        else:
            out.append({"vm": "vehicle", "code": f"if scratches_detect then scratches_detect.{call} end"})
    return out


def pct(xs: list[float], p: float) -> float:
    if not xs:
        return 0.0
    s = sorted(xs)
    return s[min(len(s) - 1, int(round(p / 100.0 * (len(s) - 1))))]


def r3(x) -> float:
    return round(float(x or 0), 3)


# ---------------------------------------------------------------- summary --

def summarize(res: dict, run_id: str, name: str, tag: str, tuning: list[dict]) -> dict:
    f = res.get("frames") or {}
    n = len(f.get("t") or [])
    span = sum(f.get("frameMs") or []) / 1000.0 or 1e-9
    painter = res.get("painter") or {}
    stamp, perf = painter.get("stamp") or {}, painter.get("perf") or {}
    det, prof = res.get("detect") or {}, res.get("detectProf") or {}
    contacts = prof.get("contacts") or 0
    attempted = stamp.get("stampsAttempted") or 0
    pms = f.get("painterMs") or []
    return {
        "run": run_id, "scenario": name, "tag": tag or "",
        "settled": bool(res.get("settled")), "seconds": r3(res.get("runSeconds")),
        "min_up_z": r3(min(f.get("upZ") or [1])), "rolled": min(f.get("upZ") or [1]) < 0,
        "fps_avg": round(max(0, n - 1) / span, 1) if n else 0,
        "frame_ms_p50": r3(pct(f.get("frameMs"), 50)), "frame_ms_p95": r3(pct(f.get("frameMs"), 95)),
        "frame_ms_max": r3(max(f.get("frameMs") or [0])),
        "lua_ms_p95": r3(pct(f.get("Lua"), 95)), "lua_ms_max": r3(max(f.get("Lua") or [0])),
        "phys_vlua_ms_p95": r3(pct(f.get("PhysicsAndVLUA"), 95)),
        "phys_vlua_ms_max": r3(max(f.get("PhysicsAndVLUA") or [0])),
        "render_ms_p95": r3(pct(f.get("Render"), 95)),
        "painter_ms_avg": r3(perf.get("msTotal", 0) / perf["frames"]) if perf.get("frames") else 0,
        "painter_ms_p95": r3(pct(pms, 95)), "painter_ms_max": r3(perf.get("msMax")),
        "painter_frames_over4ms": int(perf.get("framesOver4ms") or 0),
        "painter_flush_ms_max": r3(perf.get("flushMsMax")),
        "painter_combine_ms_max": r3(perf.get("combineMsMax")),
        "detect_us_per_contact": r3(prof.get("contactMs", 0) * 1000 / contacts) if contacts else 0,
        "detect_ms_total": r3((prof.get("contactMs") or 0) + (prof.get("gfxMs") or 0)),
        "detect_frame_ms_max": r3(prof.get("frameMsMax")),
        "contacts": int(det.get("totalCalls") or 0), "filtered": int(det.get("filteredCalls") or 0),
        "impacts": int(det.get("impactEvents") or 0), "streams": int(det.get("streamsFlushed") or 0),
        "projects": int(stamp.get("projectsIssued") or 0), "bakes": int(stamp.get("bakesIssued") or 0),
        "stamps": attempted,
        "missed_pct": round(100.0 * (stamp.get("stampsSkippedMissed") or 0) / attempted, 1) if attempted else 0,
        "jobs_dropped": int(stamp.get("jobsDropped") or 0),
        "frames_deferred": int(stamp.get("framesDeferred") or 0),
        "aggregate_dropped": int(stamp.get("aggregateDropped") or 0),
        "tuning": "; ".join(t["code"] for t in tuning),
    }


def worst_frames(res: dict, k: int = 5) -> list[dict]:
    f = res.get("frames") or {}
    n = len(f.get("t") or [])
    idx = sorted(range(n), key=lambda i: f["frameMs"][i], reverse=True)[:k]
    return [{key: f[key][i] for key in f} for i in idx]


def write_report(out_dir: str, s: dict, res: dict, scenario: dict) -> None:
    f = res.get("frames") or {}
    keys = list(f.keys())
    with open(os.path.join(out_dir, "frames.csv"), "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(keys)
        for i in range(len(f.get("t") or [])):
            w.writerow([round(f[k][i], 4) for k in keys])
    det = res.get("detect") or {}
    L = [f"# {s['scenario']} - {s['run']}", "", f"_{scenario.get('desc', '')}_", ""]
    if res.get("error"):
        L += [f"**Run error:** `{res['error']}`", ""]
    queue = res.get("painter", {}).get("queue", {})
    L += ["Remaining queues: `" + json.dumps(queue, sort_keys=True) + "`", ""]
    if any(queue.values()):
        L += ["**Incomplete drain: rendering backlog remains. This run is not a latency acceptance pass.**", ""]
    if s["tuning"]:
        L += [f"Tuning: `{s['tuning']}`", ""]
    L += [f"Settled: {s['settled']} after {s['seconds']} s - {len(f.get('t') or [])} frames, "
          f"{s['fps_avg']} fps average from sampled wall intervals (background limiter lifted)",
          f"Went past upside down: {s['rolled']} (lowest up-vector z {s['min_up_z']})", ""]
    L += ["## Marks", "",
          "| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |",
          "|---|---|---|---|---|---|---|---|---|---|",
          f"| {s['contacts']} | {s['filtered']} | {s['impacts']} | {s['streams']} | {s['stamps']} | "
          f"{s['projects']} | {s['bakes']} | {s['missed_pct']}% | {s['jobs_dropped']} | {s['frames_deferred']} |", ""]
    rej = {k: v for k, v in det.items() if k.startswith("rej") and v}
    if rej:
        L += ["Rejected contacts: " + ", ".join(f"{k[3:]} {int(v)}" for k, v in sorted(rej.items(), key=lambda kv: -kv[1])), ""]
    for label, key in (("Body materials", "byBodyMat"), ("Surfaces", "bySurfaceMat")):
        m = det.get(key) or {}
        if m:
            L += [f"{label}: " + ", ".join(f"{k} {int(v)}" for k, v in sorted(m.items(), key=lambda kv: -kv[1])), ""]
    L += ["## Cost", "",
          "| | avg | p95 | max |", "|---|---|---|---|",
          f"| painter (GE), ms/frame | {s['painter_ms_avg']} | {s['painter_ms_p95']} | {s['painter_ms_max']} |",
          f"| whole frame, ms | {s['frame_ms_p50']} (p50) | {s['frame_ms_p95']} | {s['frame_ms_max']} |",
          f"| all GE Lua, ms | | {s['lua_ms_p95']} | {s['lua_ms_max']} |",
          f"| physics + vehicle Lua, ms | | {s['phys_vlua_ms_p95']} | {s['phys_vlua_ms_max']} |",
          f"| render, ms | | {s['render_ms_p95']} | |", "",
          f"- Painter frames over 4 ms: {s['painter_frames_over4ms']}; worst flush (project + bake) "
          f"{s['painter_flush_ms_max']} ms, worst composite {s['painter_combine_ms_max']} ms.",
          f"- Detector: {s['detect_us_per_contact']} us per contact, {s['detect_ms_total']} ms total, "
          f"worst frame {s['detect_frame_ms_max']} ms (profiled; the timer adds a little).", ""]
    wf = worst_frames(res)
    if wf:
        L += ["### Worst frames", "", "| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |",
              "|---|---|---|---|---|---|"]
        for w in wf:
            L.append(f"| {w['t']:.2f} | {w['frameMs']:.2f} | {w['painterMs']:.2f} | {w.get('Lua', 0):.2f} | "
                     f"{w.get('PhysicsAndVLUA', 0):.2f} | {w.get('Render', 0):.2f} |")
        L.append("")
    shots = sorted(n for n in os.listdir(out_dir) if n.endswith(".jpg"))
    if shots:
        L += ["## Screenshots", ""] + [f"![{n}]({n})" for n in shots] + [""]
    if res.get("optick"):
        L += ["Optick capture: `capture.opt` (open with Optick, Ctrl+Alt+O in game)", ""]
    with open(os.path.join(out_dir, "report.md"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(L))


def append_index(s: dict) -> None:
    if os.path.isfile(INDEX):
        with open(INDEX, encoding="utf-8") as fh:
            header = fh.readline().strip()
        if header != ",".join(INDEX_FIELDS):  # columns changed: keep the old file aside
            os.replace(INDEX, INDEX.replace(".csv", time.strftime("-%Y%m%d-%H%M%S.csv")))
    new = not os.path.isfile(INDEX)
    with open(INDEX, "a", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=INDEX_FIELDS, extrasaction="ignore")
        if new:
            w.writeheader()
        w.writerow(s)


# ------------------------------------------------------------------- runs --

def ensure_bench() -> None:
    dev.deploy(quiet_if_unchanged=True)
    ok = dev.lua("extensions.load('scratches_bench') "
                 "return tostring(scratches_bench ~= nil and scratches_paint ~= nil "
                 "and getPlayerVehicle(0) ~= nil)")
    if ok != "true":
        raise dev.DeployError("bench not ready (need a player vehicle and the painter loaded)")


def run_one(name: str, args, tuning: list[dict], home: dict, rep: int) -> dict:
    sc = SCENARIOS[name]
    run_id = time.strftime("%Y%m%d-%H%M%S") + f"_{name}" + (f"_{args.tag}" if args.tag else "") \
        + (f"_r{rep}" if args.repeat > 1 else "")
    user_rel = f"bench/{run_id}"
    user_abs = os.path.join(dev.user_dir(), "bench", run_id)
    os.makedirs(user_abs, exist_ok=True)
    cfg = {
        "name": name, "home": home, "tuning": tuning,
        "scenario": {k: v for k, v in sc.items() if k != "desc"},
        "shots": [] if args.no_shots else SHOTS, "shotDir": user_rel,
        "shotScale": args.shot_scale, "optick": args.optick,
        "optickPath": os.path.join(user_abs, "capture.opt").replace("\\", "/"),
    }
    cfg["scenario"]["drainTimeout"] = getattr(args, "drain_timeout", 3)
    started = dev.lua(f"return scratches_bench.start({lua_long_string(json.dumps(cfg))})")
    if started != "started":
        raise dev.DeployError(f"bench refused to start: {started}")
    deadline = time.time() + sc.get("maxTime", 10) + 90
    st = {}
    while time.time() < deadline:
        time.sleep(0.5)
        try:
            st = json.loads(dev.lua("return scratches_bench.status()", read_timeout=30))
        except (ConnectionError, dev.DeployError):
            continue
        if st.get("phase") in ("done", "idle"):
            break
        extra = f" shot {st.get('shot')}/{len(cfg['shots'])}" if st.get("phase") in ("aim", "shoot") else ""
        print(f"  {name}: {st.get('phase'):<11} t={st.get('t', 0):5.1f}s frames={st.get('frames', 0)}{extra}   ",
              end="\r", flush=True)
    else:
        dev.lua("return scratches_bench.abort()")
        raise dev.DeployError(f"{name}: timed out in phase {st.get('phase')}")
    print(" " * 70, end="\r")
    res = json.loads(dev.lua("return scratches_bench.result()", read_timeout=60) or "{}")

    out_dir = os.path.join(RUNS_DIR, run_id)
    os.makedirs(out_dir, exist_ok=True)
    for n in os.listdir(user_abs):
        shutil.move(os.path.join(user_abs, n), os.path.join(out_dir, n))
    os.rmdir(user_abs)
    with open(os.path.join(out_dir, "result.json"), "w", encoding="utf-8") as fh:
        json.dump(res, fh)
    s = summarize(res, run_id, name, args.tag, tuning)
    write_report(out_dir, s, res, sc)
    append_index(s)
    if res.get("error"):
        print(f"  {name}: run error: {res['error']}")
    print(f"  {name}: {'settled' if s['settled'] else 'timed out'} in {s['seconds']} s"
          f"{' (rolled)' if s['rolled'] else ''} | "
          f"marks: {s['impacts']} impacts, {s['streams']} streams, {s['projects']} projections | "
          f"painter avg {s['painter_ms_avg']} / max {s['painter_ms_max']} ms | "
          f"frame p95 {s['frame_ms_p95']} ms | detector {s['detect_us_per_contact']} us/contact")
    print(f"  -> {os.path.relpath(out_dir, ROOT)}{os.sep}report.md")
    return s


def restore_defaults(tuning: list[dict]) -> None:
    if any(t["vm"] == "ge" for t in tuning):
        dev.lua("extensions.reload('scratches_paint') return 'ok'")
    if any(t["vm"] == "vehicle" for t in tuning):
        dev.lua("core_vehicle_manager.reloadVehicle(0) return 'ok'")
    print("  tuning overrides undone (module reloaded)")


# --------------------------------------------------------------- commands --

def cmd_run(args) -> int:
    names = list(SCENARIOS) if args.scenarios == ["all"] else args.scenarios
    unknown = [n for n in names if n not in SCENARIOS]
    if unknown:
        print(f"error: unknown scenario(s) {', '.join(unknown)}; see `bench.py scenarios`", file=sys.stderr)
        return 1
    tuning = parse_tuning(args.set)
    try:
        ensure_bench()
        lvl = level_id()
        home = homes().get(lvl)
        if not home:
            print(f"error: no home pose for level '{lvl}'. Park the car somewhere open and flat, "
                  "then run `bench.py home --save`.", file=sys.stderr)
            return 1
        os.makedirs(RUNS_DIR, exist_ok=True)
        for name in names:
            for rep in range(1, args.repeat + 1):
                run_one(name, args, tuning, home, rep)
    except (ConnectionError, dev.DeployError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    finally:
        if tuning and not args.keep:
            try:
                restore_defaults(tuning)
            except (ConnectionError, dev.DeployError):
                pass
    return 0


def cmd_list(args) -> int:
    if not os.path.isfile(INDEX):
        print("no runs yet")
        return 0
    with open(INDEX, encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))
    if args.scenario:
        rows = [r for r in rows if r["scenario"] == args.scenario]
    rows = rows[-args.n:]
    cols = [("run", 30), ("tag", 10), ("seconds", 7), ("fps_avg", 7), ("frame_ms_p95", 9),
            ("painter_ms_avg", 9), ("painter_ms_max", 9), ("detect_us_per_contact", 8),
            ("impacts", 7), ("streams", 7), ("projects", 8), ("missed_pct", 6), ("jobs_dropped", 6)]
    heads = {"run": "run", "tag": "tag", "seconds": "secs", "fps_avg": "fps", "frame_ms_p95": "frame95",
             "painter_ms_avg": "paintAvg", "painter_ms_max": "paintMax", "detect_us_per_contact": "us/cont",
             "impacts": "impact", "streams": "stream", "projects": "proj", "missed_pct": "miss%",
             "jobs_dropped": "drop"}
    print("  ".join(heads[c].ljust(w) for c, w in cols))
    for r in rows:
        print("  ".join(str(r.get(c, ""))[:w].ljust(w) for c, w in cols))
    return 0


def cmd_scenarios(args) -> int:
    for n, sc in SCENARIOS.items():
        print(f"{n:<10} {sc['desc']}")
    return 0


def cmd_home(args) -> int:
    try:
        lvl = level_id()
        if args.save:
            dev.lua("extensions.load('scratches_bench') return 'ok'")
            pose = json.loads(dev.lua("return scratches_bench.currentPose()"))
            saved = {}
            if os.path.isfile(HOMES_FILE):
                with open(HOMES_FILE, encoding="utf-8") as fh:
                    saved = json.load(fh)
            saved[lvl] = pose
            os.makedirs(BENCH_DIR, exist_ok=True)
            with open(HOMES_FILE, "w", encoding="utf-8") as fh:
                json.dump(saved, fh, indent=2)
            print(f"saved home for {lvl}: {pose['pos']}")
        else:
            print(f"{lvl}: {json.dumps(homes().get(lvl))}")
    except (ConnectionError, dev.DeployError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    sub = p.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("run", help="run scenario(s)")
    r.add_argument("scenarios", nargs="+", help="scenario names, or 'all'")
    r.add_argument("--set", action="append", help="tuning override, e.g. paint.setProjectionBudget=3")
    r.add_argument("--tag", default="", help="label for the run (shows in `list`)")
    r.add_argument("--repeat", type=int, default=1)
    r.add_argument("--drain-timeout", type=float, default=3, help="maximum drain seconds; record remaining queues even on timeout")
    r.add_argument("--optick", action="store_true", help="save an Optick capture of each run")
    r.add_argument("--no-shots", action="store_true", help="skip screenshots")
    r.add_argument("--shot-scale", type=float, default=0.5, help="screenshot scale (default 0.5)")
    r.add_argument("--keep", action="store_true", help="leave --set overrides in place afterwards")
    ls = sub.add_parser("list", help="compare recent runs")
    ls.add_argument("-n", type=int, default=20)
    ls.add_argument("--scenario")
    sub.add_parser("scenarios", help="describe the scenarios")
    h = sub.add_parser("home", help="show or save this level's home pose")
    h.add_argument("--save", action="store_true")
    args = p.parse_args()
    return {"run": cmd_run, "list": cmd_list, "scenarios": cmd_scenarios, "home": cmd_home}[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
