"""Multi-vehicle, multi-paint showcase + validation run, from the running game.

    python tools/showcase_fleet.py                  # the default fleet below
    python tools/showcase_fleet.py pickup:red vivace:blue bluebuck
    python tools/showcase_fleet.py --out docs/evidence/contact-patches/fleet-vulkan etk800:black

Each entry is `model[:paint]` (paint from PAINTS; omit it to keep the default
config's livery). For each: spawn the default config, apply the paint, wait for
the generic body adapter, check its clone preserves every original stage of the
source material, crash it with the bench `sideslide`, then capture HUD-free
matched damaged / original-stages pairs from both sides. Writes
docs/evidence/showcase/fleet/<model>-<paint>/ (2560x1440 q90) and a fleet.json summary.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import time
from pathlib import Path

import dev
import showcase_capture as cap
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "evidence" / "showcase" / "fleet"

# baseColor rgb, metallic, roughness
PAINTS = {
    "red": ([0.55, 0.03, 0.03], 0.3, 0.3),
    "blue": ([0.03, 0.12, 0.45], 0.7, 0.35),
    "white": ([0.85, 0.85, 0.83], 0.2, 0.3),
    "yellow": ([0.85, 0.62, 0.05], 0.3, 0.35),
    "gunmetal": ([0.18, 0.19, 0.20], 0.9, 0.35),
    "green": ([0.04, 0.20, 0.08], 0.6, 0.35),
    "black": ([0.02, 0.02, 0.02], 0.4, 0.3),
}
FLEET = ["pickup:red", "vivace:blue", "etki:white", "covet:yellow", "sunburst2:gunmetal",
         "moonhawk:green", "bluebuck", "scintilla", "citybus", "etk800"]


def wait_ready(model: str, timeout: float = 60) -> dict:
    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(2)
        try:
            c = json.loads(dev.lua("local v=getPlayerVehicle(0) local c=scratches_paint.getCompatibility() "
                                   "c.model=v and v.JBeam return jsonEncode(c)", read_timeout=30))
        except Exception:
            continue
        if c.get("model") == model and c.get("ready") and c.get("adapter"):
            return c
    raise RuntimeError(f"{model}: body adapter did not become ready")


def set_paint(name: str) -> None:
    rgb, metallic, rough = PAINTS[name]
    dev.lua("local cfg=core_vehicle_partmgmt.getConfig() for i,p in ipairs(cfg.paints) do if i<=2 then "
            f"p.baseColor={{{rgb[0]},{rgb[1]},{rgb[2]},1.2}} p.metallic={metallic} p.roughness={rough} "
            "p.clearcoat=1 p.clearcoatRoughness=0.05 end end "
            "core_vehicle_partmgmt.setConfigPaints(cfg.paints,true) return 'ok'")


def bench(tag: str) -> dict:
    # Keep the bench's own (small) shots: that step stands the car upright first.
    out = subprocess.run([sys.executable, str(ROOT / "tools" / "bench.py"), "run", "sideslide", "--tag", tag,
                          "--shot-scale", "0.25"], cwd=ROOT, capture_output=True, text=True, timeout=600)
    m = re.search(r"-> (bench[\\/]runs[\\/][^\s]+report\.md)", out.stdout)
    if not m:
        raise RuntimeError("bench failed: " + out.stdout[-400:] + out.stderr[-400:])
    report = (ROOT / m.group(1)).read_text(encoding="utf-8")
    row = re.search(r"\| contacts.*\n\|[-|]+\n\| (.+) \|", report)
    cells = [c.strip() for c in row.group(1).split("|")] if row else []
    keys = ["contacts", "passed", "impacts", "streams", "stamps", "projections", "bakes", "missed",
            "dropped", "deferred"]
    return {"report": m.group(1).replace("\\", "/"), **dict(zip(keys, cells)),
            **timing((ROOT / m.group(1)).parent)}


def timing(run_dir: Path) -> dict:
    """Frame and painter cost of one bench run, from its result.json."""
    result = json.loads((run_dir / "result.json").read_text(encoding="utf-8"))
    frames = sorted(result["frames"]["frameMs"])
    perf = result["painter"]["perf"]
    wear = (result["painter"].get("wear") or {}).get("patches") or {}
    return {"layersBaked": perf["bakeLayersTotal"], "bakeMsMax": round(perf["bakeMsMax"], 1),
            "painterMsMax": round(perf["msMax"], 1), "frameMsP95": round(frames[int(len(frames) * .95)], 1),
            "frameMsMax": round(frames[-1], 1), "framesOver25ms": sum(f > 25 for f in frames),
            "slidePatches": wear.get("slidePatches"), "impactPatches": wear.get("impactPatches")}


def run(entry: str) -> dict:
    model, _, paint = entry.partition(":")
    label = f"{model}-{paint or 'livery'}"
    print(f"== {label}", flush=True)
    dev.lua(f"core_vehicles.replaceVehicle({json.dumps(model)},{{}}) return 'ok'", read_timeout=60)
    wait_ready(model)
    if paint:
        set_paint(paint)
        time.sleep(3)
    compat = wait_ready(model)
    marks = bench("fleet-" + label)
    folder = OUT / label
    sides = {}
    for side, az in (("left", 90),):  # the bench sideslide always scrapes the left flank
        e = cap.matched(folder / side, lambda az=az: cap.aim_auto(az, 10))
        sides[side] = e.get("comparison")
        for jpg in (folder / side).glob("*.jpg"):  # 2560 q90 keeps the repo small
            Image.open(jpg).convert("RGB").resize((2560, 1440), Image.LANCZOS).save(jpg, quality=90)
    diffs = sum(len((c or {}).get("differences") or []) for c in sides.values())
    result = {"model": model, "paint": paint or None, "part": compat.get("part"), "source": compat.get("adapter"),
              "keys": compat.get("keys"), "stage": compat.get("stage"), "originalStageDifferences": diffs,
              "marks": marks}
    (folder / "state.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"   source={result['source']} keys={result['keys']} diffs={diffs} "
          f"impacts={marks.get('impacts')} streams={marks.get('streams')} layers={marks.get('layersBaked')} "
          f"patches={marks.get('slidePatches')}/{marks.get('impactPatches')} "
          f"painterMax={marks.get('painterMsMax')} frameMax={marks.get('frameMsMax')} "
          f"missed={marks.get('missed')}", flush=True)
    return result


def main() -> None:
    global OUT
    args = sys.argv[1:]
    if "--out" in args:  # keep an earlier run's evidence: write this one elsewhere
        i = args.index("--out")
        OUT = (ROOT / args[i + 1]).resolve()
        del args[i:i + 2]
    entries = args or FLEET
    results = []
    for entry in entries:
        try:
            results.append(run(entry))
        except Exception as exc:  # keep going; record the failure honestly
            print(f"   FAILED: {exc}", flush=True)
            results.append({"entry": entry, "error": str(exc)})
    OUT.mkdir(parents=True, exist_ok=True)
    summary = OUT / "fleet.json"
    old = json.loads(summary.read_text()) if summary.exists() else []
    keep = {r.get("model", r.get("entry")) + ":" + str(r.get("paint")): r for r in old}
    for r in results:
        keep[r.get("model", r.get("entry")) + ":" + str(r.get("paint"))] = r
    summary.write_text(json.dumps(list(keep.values()), indent=2) + "\n")


if __name__ == "__main__":
    main()
