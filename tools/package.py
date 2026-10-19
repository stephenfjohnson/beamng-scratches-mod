"""
Build the distributable scratches_mod.zip.

The shipped mod is exactly two directory trees — `lua/` and `art/` — and they
must sit at the ZIP ROOT, not inside a `scratches_mod/` folder. BeamNG mounts
the archive as a virtual filesystem overlay, so a mis-rooted zip installs
cleanly and then does nothing at all: no error, no painter, no scratches. That
failure mode is the whole reason this script exists instead of a prose step.

`docs/`, `investigations/`, `tools/`, `reference/` and `README.md` are repo-only
and are never included — the include list below is an allow-list, so anything
new in the repo root stays out until someone adds it here deliberately.

Preflight: every .lua under lua/ is syntax-checked with `luac -p` when a luac
is on PATH (skipped with a warning when it isn't), and every decal brush PNG
is checked for its `.dynDecalTexture.json` sidecar — a brush without one stamps
invisibly in game.

Run: python tools/package.py            -> dist/scratches_mod.zip
     python tools/package.py -o out.zip
"""

import argparse
import os
import shutil
import subprocess
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))

# Allow-list of trees that make up the mod. Paths are repo-relative and are
# written into the zip with exactly these prefixes.
INCLUDE_DIRS = ["lua", "art"]

# Brush textures need a sidecar to load; these are ordinary material maps and
# do not (see restoreFactoryMR in paint.lua).
SIDECAR_EXEMPT = {"_paint_roughness.png"}

# Never ship editor/OS debris even from inside an included tree.
EXCLUDE_NAMES = {".DS_Store", "Thumbs.db", "desktop.ini", ".gitkeep"}
EXCLUDE_SUFFIXES = (".bak", ".orig", ".rej", "~")


def collect_files() -> list[tuple[str, str]]:
    """Return (absolute path, zip arcname) pairs, sorted for a stable archive."""
    found: list[tuple[str, str]] = []
    for top in INCLUDE_DIRS:
        top_abs = os.path.join(ROOT, top)
        if not os.path.isdir(top_abs):
            sys.exit(f"error: expected directory '{top}/' at the repo root")
        for dirpath, dirnames, filenames in os.walk(top_abs):
            dirnames[:] = sorted(d for d in dirnames if d != "__pycache__")
            for name in sorted(filenames):
                if name in EXCLUDE_NAMES or name.endswith(EXCLUDE_SUFFIXES):
                    continue
                abs_path = os.path.join(dirpath, name)
                rel = os.path.relpath(abs_path, ROOT)
                # Forward slashes: zip entries are POSIX paths regardless of host.
                found.append((abs_path, rel.replace(os.sep, "/")))
    return found


def check_lua_syntax(files: list[tuple[str, str]]) -> None:
    luac = shutil.which("luac") or shutil.which("luac5.1")
    lua_files = [abs_path for abs_path, arc in files if arc.endswith(".lua")]
    if not lua_files:
        return
    if not luac:
        print("warn: no luac on PATH - skipping Lua syntax preflight")
        return
    result = subprocess.run([luac, "-p", *lua_files],
                            capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit("error: Lua syntax check failed\n" + (result.stderr or result.stdout))
    print(f"  luac -p: {len(lua_files)} file(s) OK")


def check_brush_sidecars(files: list[tuple[str, str]]) -> None:
    """Every decal brush PNG needs a .png.dynDecalTexture.json next to it."""
    arcnames = {arc for _, arc in files}
    missing = []
    for arc in sorted(arcnames):
        if not arc.startswith("art/dynamicDecals/textures/") or not arc.endswith(".png"):
            continue
        if os.path.basename(arc) in SIDECAR_EXEMPT:
            continue
        if arc + ".dynDecalTexture.json" not in arcnames:
            missing.append(arc)
    if missing:
        sys.exit("error: brush PNG(s) with no .dynDecalTexture.json sidecar "
                 "(they would stamp invisibly in game):\n  " + "\n  ".join(missing))
    print("  brush sidecars: OK")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.strip().splitlines()[1])
    parser.add_argument("-o", "--output", default=os.path.join(ROOT, "dist", "scratches_mod.zip"),
                        help="output zip path (default: dist/scratches_mod.zip)")
    args = parser.parse_args()

    files = collect_files()
    if not files:
        sys.exit("error: nothing to package")

    print(f"packaging {len(files)} file(s) from {ROOT}")
    check_lua_syntax(files)
    check_brush_sidecars(files)

    out = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for abs_path, arc in files:
            zf.write(abs_path, arc)

    size_kb = os.path.getsize(out) / 1024.0
    roots = sorted({arc.split("/", 1)[0] for _, arc in files})
    print(f"wrote {out} ({size_kb:.1f} KB)")
    print(f"  zip root entries: {', '.join(roots)}")


if __name__ == "__main__":
    main()
