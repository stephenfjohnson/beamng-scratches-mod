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

# Everyday crashes modelled on the reference photos (bench/reference/): the
# car rolls in neutral into static obstacles, stays on its wheels, and the
# photos are close-ups aimed at where the painter laid marks.
# Obstacle offsets: home frame from the car's box center, plus fwdL/rightW
# multiples of its half-length/half-width (see scratches_bench spawnObstacles).
COLUMN = "/art/shapes/objects/modular_metal_roof_01/s_column_concrete_01.dae"  # 0.62 m square
# A row of these makes a flat vertical wall; the road barriers have sloped
# bases that only the tyres touch.
PILLAR = "/art/shapes/objects/modular_depot/s_depot_metal_column.dae"  # 1.0 m square
SITE_SHOTS = [
    {"label": "site1", "site": 1, "dist": 1.2, "elev": 10, "swing": 25},
    {"label": "site1_macro", "site": 1, "dist": 0.55, "distPerRadius": 0.25, "elev": 6, "swing": 12},
    {"label": "site1_wide", "site": 1, "dist": 3.0, "elev": 14, "swing": 40},
    {"label": "site2", "site": 2, "dist": 1.2, "elev": 10, "swing": -25},
    {"label": "site3", "site": 3, "dist": 1.2, "elev": 10, "swing": 25},
]
SCENARIOS.update({
    "cornerscuff": dict(desc="creeps at 4 m/s drifting 0.45 m/s right (6.5 deg), so the front-right bumper "
                             "corner clips a knee-high concrete bollard and drags past it (ref 1: scuffed bumper corner)",
                        vel={"fwd": 4.0, "right": 0.45}, coast=True, upright=False, shots=SITE_SHOTS,
                        maxTime=6, footage={"fwd": 2, "right": 6, "up": 3, "lookFwd": 3},
                        # The bumper corner sits ~0.12 m inside the box (mirrors,
                        # rounding) and drifts 0.23 m right over the 2 m run-up:
                        # it meets the bollard ~5 cm deep and rakes past (at
                        # 10 cm the bollard caught the corner and stopped it).
                        # The column (6.3 m) sunk to a 0.55 m bollard: at full
                        # height it met the headlight first and the bumper
                        # corner below barely touched.
                        obstacles=[{"shape": COLUMN, "fwdL": 1, "fwd": 2.31, "rightW": 1, "right": 0.345,
                                    "up": -5.75}]),
    "cornerpost": dict(desc="rolls at 6 m/s into a concrete column that catches the front-right bumper corner "
                            "(refs 1, 2: crushed, creased bumper corner)",
                       vel={"fwd": 6}, coast=True, upright=False, shots=SITE_SHOTS, maxTime=6,
                       footage={"fwd": 2, "right": 7, "up": 4, "lookFwd": 4},
                       obstacles=[{"shape": COLUMN, "fwdL": 1, "fwd": 3.0, "rightW": 1, "right": 0.05}]),
    "wallscrape": dict(desc="rolls at 10 m/s alongside a long flat wall (a ledge from 0.6 m up, above the tyres) on its right, angled 2 deg into it (positive yaw = right) - "
                            "a sideswipe (refs 2, 3: long horizontal streaks)",
                       vel={"fwd": 10}, euler={"yaw": 2}, coast=True, upright=False, shots=SITE_SHOTS,
                       maxTime=8, footage={"fwd": 3, "right": -6, "up": 6, "lookFwd": 8, "lookRight": 1},
                       obstacles=[{"shape": PILLAR, "fwd": -2.0 + 1.0 * i,
                                   "rightW": 1, "right": 0.62, "up": 0.6} for i in range(22)]),
    "poledoor": dict(desc="slides sideways at 11 m/s into a concrete column at the right front door "
                          "(ref 5: crushed door)",
                     vel={"right": 11}, coast=True, upright=False, shots=SITE_SHOTS, maxTime=6,
                     footage={"fwd": 7, "right": 1, "up": 4, "lookFwd": 0, "lookRight": 1.5},
                     obstacles=[{"shape": COLUMN, "fwd": 0.0, "rightW": 1, "right": 0.5}]),
    "rearpost": dict(desc="reverses at 5 m/s into a concrete column that catches the rear-left quarter "
                          "(ref 4: gouged rear quarter)",
                     vel={"fwd": -5}, coast=True, upright=False, shots=SITE_SHOTS, maxTime=6,
                     footage={"fwd": -2, "right": -7, "up": 4, "lookFwd": -4},
                     obstacles=[{"shape": COLUMN, "fwdL": -1, "fwd": -2.5, "rightW": -1, "right": 0.35}]),
})
# Car-on-car: the player car parked, another car driven into it.
SCENARIOS.update({
    "tbone": dict(desc="parked; a pickup hits the right front door square-on at 11 m/s (ref 5: crushed door)",
                  upright=False, shots=SITE_SHOTS, minTime=3, maxTime=6,
                  footage={"fwd": 6, "right": 6, "up": 4, "lookFwd": 0, "lookRight": 1},
                  strikers=[{"model": "pickup", "color": [0.85, 0.85, 0.82], "fwd": -0.2, "rightW": 1,
                             "right": 4.2, "yaw": -90, "speed": 11}]),
    "carswipe": dict(desc="parked; a pickup passes along the right side angled 7 deg in at 9 m/s "
                          "(ref 3: car-on-car side scrape, paint transfer)",
                     upright=False, shots=SITE_SHOTS, minTime=3, maxTime=6,
                     footage={"fwd": -6, "right": 6, "up": 4, "lookFwd": 0, "lookRight": 1},
                     strikers=[{"model": "pickup", "color": [0.08, 0.08, 0.09], "fwd": -7.5, "rightW": 1,
                                "right": 1.3, "yaw": -8, "speed": 9}]),
})
REF_SCENARIOS = ["cornerscuff", "cornerpost", "wallscrape", "poledoor", "rearpost", "tbone", "carswipe"]

# Test cars: model, config and one paint; matched to the reference photos.
CARS = {
    "etk800_blue": {"model": "etk800", "config": "vehicles/etk800/854_190_A.pc",
                    "color": [0.03, 0.06, 0.16], "metallic": 0.7, "roughness": 0.3,
                    "clearcoat": 1, "clearcoatRoughness": 0.03},
    "etk800_grey": {"model": "etk800", "config": "vehicles/etk800/854_190_A.pc",
                    "color": [0.16, 0.17, 0.18], "metallic": 0.8, "roughness": 0.35,
                    "clearcoat": 1, "clearcoatRoughness": 0.03},
    "etk800_silver": {"model": "etk800", "config": "vehicles/etk800/854_190_A.pc",
                      "color": [0.62, 0.62, 0.60], "metallic": 0.85, "roughness": 0.35,
                      "clearcoat": 1, "clearcoatRoughness": 0.03},
}
REFERENCE_DIR = os.path.join(BENCH_DIR, "reference")

# The gallery: detector events fed straight to the painter on the car's right
# side, front to back, light to heavy (fwd/up: m from the box center). Upper
# row impacts (force in N), lower row slides (dist = drag length in m).
GALLERY = [
    {"kind": "i", "fwd": 1.45, "up": 0.05, "force": 2500, "ts": 3, "label": "impact 2.5 kN, glancing"},
    {"kind": "i", "fwd": 0.75, "up": 0.10, "force": 7000, "ts": 4, "label": "impact 7 kN, glancing"},
    {"kind": "i", "fwd": 0.0, "up": 0.10, "force": 13000, "ts": 0, "label": "impact 13 kN, square-on"},
    {"kind": "i", "fwd": -0.8, "up": 0.10, "force": 21000, "ts": 5, "label": "impact 21 kN, glancing"},
    {"kind": "s", "fwd": 1.2, "up": -0.22, "force": 1500, "dist": 0.25, "label": "slide light"},
    {"kind": "s", "fwd": 0.25, "up": -0.22, "force": 6000, "dist": 0.9, "label": "slide medium"},
    {"kind": "s", "fwd": -0.75, "up": -0.22, "force": 16000, "dist": 2.0, "label": "slide heavy"},
    {"kind": "i", "fwd": -1.5, "up": 0.0, "force": 12000, "ts": 4, "ang": 45, "label": "impact 12 kN, 45 deg"},
    {"kind": "s", "fwd": 1.95, "up": -0.05, "force": 6000, "dist": 0.9, "ang": 45, "label": "slide medium, 45 deg"},
]

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
    span = (f["t"][-1] if n else 0) or 1e-9
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
        "fps_avg": round(n / span, 1) if n else 0,
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
    if s["tuning"]:
        L += [f"Tuning: `{s['tuning']}`", ""]
    L += [f"Settled: {s['settled']} after {s['seconds']} s - {len(f.get('t') or [])} frames, "
          f"{s['fps_avg']} fps average (background limiter lifted)",
          f"Went past upside down: {s['rolled']} (lowest up-vector z {s['min_up_z']})", ""]
    L += ["## Marks", "",
          "| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |",
          "|---|---|---|---|---|---|---|---|---|---|",
          f"| {s['contacts']} | {s['filtered']} | {s['impacts']} | {s['streams']} | {s['stamps']} | "
          f"{s['projects']} | {s['bakes']} | {s['missed_pct']}% | {s['jobs_dropped']} | {s['frames_deferred']} |", ""]
    rej = {k: v for k, v in det.items() if k.startswith("rej") and v}
    if rej:
        L += ["Rejected contacts: " + ", ".join(f"{k[3:]} {int(v)}" for k, v in sorted(rej.items(), key=lambda kv: -kv[1])), ""]
    st = (res.get("painter") or {}).get("stamp") or {}
    L += ["Placement: " + ", ".join(f"{k} {int(st.get(k) or 0)}" for k in (
              "stampsGapDeepened", "stampsSkippedGap", "stampsUnmeasured", "reaims", "reaimsHelped",
              "marksRetracted"))
          + f", lampSnapped {int(det.get('lampSnapped') or 0)}; overshoot front/<5/<10/<18/<25/hole cm "
          + "/".join(str(int(st.get(k) or 0)) for k in ("gapFront", "gapUnder5", "gapUnder10", "gapUnder18",
                                                          "gapUnder25", "gapHole")), ""]
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
        "scenario": {k: v for k, v in sc.items() if k not in ("desc", "shots", "upright", "footage")},
        "shots": [] if args.no_shots else sc.get("shots", SHOTS), "shotDir": user_rel,
        "upright": sc.get("upright", True), "tod": args.tod,
        "footage": None if args.no_shots or not args.footage or "footage" not in sc else
        {"every": 0.2, "scale": 0.25, "max": 45, "cam": sc["footage"]},
        "shotScale": args.shot_scale, "optick": args.optick,
        "optickPath": os.path.join(user_abs, "capture.opt").replace("\\", "/"),
    }
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
    sheet = make_sheet(out_dir, f"{name} {args.tag}".strip())
    make_footage(out_dir)
    if res.get("error"):
        print(f"  {name}: run error: {res['error']}")
    print(f"  {name}: {'settled' if s['settled'] else 'timed out'} in {s['seconds']} s"
          f"{' (rolled)' if s['rolled'] else ''} | "
          f"marks: {s['impacts']} impacts, {s['streams']} streams, {s['projects']} projections | "
          f"painter avg {s['painter_ms_avg']} / max {s['painter_ms_max']} ms | "
          f"frame p95 {s['frame_ms_p95']} ms | detector {s['detect_us_per_contact']} us/contact")
    print(f"  -> {os.path.relpath(out_dir, ROOT)}{os.sep}report.md")
    if sheet:
        print(f"  -> {os.path.relpath(sheet, ROOT)}")
    return s


def restore_defaults(tuning: list[dict]) -> None:
    if any(t["vm"] == "ge" for t in tuning):
        dev.lua("extensions.reload('scratches_paint') return 'ok'")
    if any(t["vm"] == "vehicle" for t in tuning):
        dev.lua("core_vehicle_manager.reloadVehicle(0) return 'ok'")
    print("  tuning overrides undone (module reloaded)")


# ----------------------------------------------------------------- cars --

def setup_car(name: str) -> None:
    """Spawn a test car, give it the scratches skin, wait for the painter."""
    car = CARS[name]
    dev.lua("extensions.load('scratches_bench') return 'ok'")
    dev.lua(f"return scratches_bench.spawnCar({lua_long_string(json.dumps(car))})")
    wait_for(lambda: dev.lua("local v = getPlayerVehicle(0) return v and v:getJBeamFilename() or ''")
             == car["model"], 60, f"{car['model']} to spawn")
    time.sleep(2)
    dev.lua("return scratches_bench.applySkin()")
    time.sleep(4)  # setSkin respawns the car
    wait_for(lambda: dev.lua("local v = getPlayerVehicle(0) return tostring(v ~= nil)") == "true",
             60, "the car to respawn")
    dev.lua("scratches_paint.kickSetup() return 'ok'")
    wait_for(lambda: dev.lua("return tostring(scratches_paint.getStats().ready)") == "true",
             60, "the painter to bind")
    print(f"  car: {name} ready")


def wait_for(pred, timeout: float, what: str) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            if pred():
                return
        except (ConnectionError, dev.DeployError):
            pass
        time.sleep(1)
    raise dev.DeployError(f"timed out waiting for {what}")


# ---------------------------------------------------------------- sheets --

def make_sheet(out_dir: str, title: str) -> str | None:
    """One image for review: the reference photos on top, the run's shots
    below. Returns its path, or None without PIL or shots."""
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        return None
    shots = sorted(n for n in os.listdir(out_dir) if n.startswith("shot_") and n.endswith(".jpg"))
    if not shots:
        return None
    refs = sorted(os.path.join(REFERENCE_DIR, n) for n in os.listdir(REFERENCE_DIR)
                  if n.lower().endswith((".png", ".jpg"))) if os.path.isdir(REFERENCE_DIR) else []
    width, cols, pad = 2400, 3, 8
    rows = []
    if refs:
        ims = [Image.open(p).convert("RGB") for p in refs]
        h = 320
        ims = [im.resize((max(1, int(im.width * h / im.height)), h)) for im in ims]
        scale = min(1.0, (width - pad * (len(ims) + 1)) / sum(im.width for im in ims))
        ims = [im.resize((max(1, int(im.width * scale)), max(1, int(h * scale)))) for im in ims]
        rows.append(("reference photos", ims))
    cw = (width - pad * (cols + 1)) // cols
    tiles = []
    for n in shots:
        im = Image.open(os.path.join(out_dir, n)).convert("RGB")
        im = im.resize((cw, int(im.height * cw / im.width)))
        ImageDraw.Draw(im).text((10, 10), n[:-4], fill=(255, 255, 0))
        tiles.append(im)
    for i in range(0, len(tiles), cols):
        rows.append(("in game" if i == 0 else "", tiles[i:i + cols]))
    label_h = 26
    total_h = pad + sum(label_h * bool(lbl) + max(im.height for im in ims) + pad for lbl, ims in rows) + 30
    sheet = Image.new("RGB", (width, total_h), (24, 24, 24))
    d = ImageDraw.Draw(sheet)
    d.text((pad, 8), title, fill=(255, 255, 255))
    y = 30
    for lbl, ims in rows:
        if lbl:
            d.text((pad, y + 6), lbl, fill=(200, 200, 200))
            y += label_h
        x = pad
        for im in ims:
            sheet.paste(im, (x, y))
            x += im.width + pad
        y += max(im.height for im in ims) + pad
    path = os.path.join(out_dir, "sheet.jpg")
    sheet.save(path, quality=88)
    return path


def make_footage(out_dir: str) -> str | None:
    """Tile the run's footage frames into footage.jpg (every other frame,
    in order) for review."""
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        return None
    frames = sorted(n for n in os.listdir(out_dir) if n.startswith("footage_") and n.endswith(".jpg"))
    if not frames:
        return None
    frames = frames[::2][:24]
    cols, tw = 4, 600
    tiles = []
    for n in frames:
        im = Image.open(os.path.join(out_dir, n)).convert("RGB")
        im = im.resize((tw, int(im.height * tw / im.width)))
        ImageDraw.Draw(im).text((8, 8), n[8:-4], fill=(255, 255, 0))
        tiles.append(im)
    th = tiles[0].height
    rows = (len(tiles) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * tw, rows * th), (24, 24, 24))
    for i, im in enumerate(tiles):
        sheet.paste(im, ((i % cols) * tw, (i // cols) * th))
    path = os.path.join(out_dir, "footage.jpg")
    sheet.save(path, quality=85)
    return path


# --------------------------------------------------------------- gallery --

def shoot(out_dir: str, name: str, cam: tuple, look: tuple, scale: float = 1.0) -> str:
    """Free camera at cam, aimed at look (both (fwd, right, up) m in the car's
    frame from its box center); screenshot with the HUD hidden."""
    dev.lua(f"""
local veh = getPlayerVehicle(0)
local cc = jsonDecode(scratches_bench.carCenter())
local c = vec3(cc.x, cc.y, cc.z)
local d = veh:getDirectionVector(); local fwd = vec3(d.x, d.y, 0):normalized()
local up = vec3(0, 0, 1); local right = fwd:cross(up):normalized()
local function at(f, r, u) return c + fwd * f + right * r + up * u end
local cam, tgt = at({cam[0]}, {cam[1]}, {cam[2]}), at({look[0]}, {look[1]}, {look[2]})
core_camera.setByName(0, 'free')
core_camera.globalCameraFunction('free', 'setPosition', cam)
core_camera.globalCameraFunction('free', 'setRotation', quatFromDir((tgt - cam):normalized(), up))
ui_visibility.set(false)
return 'ok'""")
    time.sleep(1.0)
    rel = f"bench/{name}"
    dev.lua(f"createScreenshot2({{filename='{rel}', writeJPG=true, superSampling=1, rescaleFactor={scale}}}) "
            "return 'ok'")
    src = os.path.join(dev.user_dir(), "bench", name + ".jpg")
    for _ in range(60):
        if os.path.isfile(src):
            break
        time.sleep(0.25)
    time.sleep(0.4)
    dst = os.path.join(out_dir, name + ".jpg")
    os.replace(src, dst)
    return dst


def cmd_gallery(args) -> int:
    try:
        if args.car:
            setup_car(args.car)
        ensure_bench()
        home = homes().get(level_id())
        if home:  # repaired, at rest, in the same spot every time
            dev.lua(f"return scratches_bench.placeHome({lua_long_string(json.dumps(home))})")
            time.sleep(2.5)
        run_id = time.strftime("%Y%m%d-%H%M%S") + "_gallery" + (f"_{args.tag}" if args.tag else "")
        out_dir = os.path.join(RUNS_DIR, run_id)
        os.makedirs(out_dir, exist_ok=True)
        # Fixed seed: the same brushes, jitter and tones every run.
        dev.lua(f"if scenetree.tod then scenetree.tod.time = {args.tod} scenetree.tod.play = false end "
                f"scratches_paint.clearStamps() scratches_paint.seedRandom({args.seed}) return 'ok'")
        time.sleep(1.5)
        items = [{k: v for k, v in it.items() if k != "label"} for it in GALLERY]
        print("  " + dev.lua(f"return scratches_bench.gallery({lua_long_string(json.dumps(items))})"))
        wait_for(lambda: dev.lua("local q = scratches_paint.getStats().queue "
                                 "return tostring(q.stamps + q.jobs + (q.bake or 0) == 0)") == "true",
                 60, "the painter to drain")
        time.sleep(1.0)
        shoot(out_dir, "shot_0_side", (0.0, 4.6, 0.35), (0.0, 0.0, 0.0), 0.5)
        for i, it in enumerate(GALLERY, 1):
            f, u = it["fwd"], it["up"]
            shoot(out_dir, f"shot_{i}_{it['kind']}{i}", (f + 0.3, 1.5, u + 0.12), (f, 0.8, u), 0.5)
        dev.lua("ui_visibility.set(true) core_camera.setByName(0, 'orbit') return 'ok'")
        with open(os.path.join(out_dir, "labels.json"), "w", encoding="utf-8") as fh:
            json.dump({f"shot_{i}": it["label"] for i, it in enumerate(GALLERY, 1)}, fh, indent=1)
        sheet = make_sheet(out_dir, f"gallery {args.tag}".strip())
        print(f"  -> {os.path.relpath(sheet or out_dir, ROOT)}")
    except (ConnectionError, dev.DeployError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


# --------------------------------------------------------------- commands --

def cmd_run(args) -> int:
    names = (list(SCENARIOS) if args.scenarios == ["all"]
             else REF_SCENARIOS if args.scenarios == ["ref"] else args.scenarios)
    unknown = [n for n in names if n not in SCENARIOS]
    if unknown:
        print(f"error: unknown scenario(s) {', '.join(unknown)}; see `bench.py scenarios`", file=sys.stderr)
        return 1
    tuning = parse_tuning(args.set)
    try:
        if args.car:
            setup_car(args.car)
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


def cmd_car(args) -> int:
    try:
        setup_car(args.name)
    except (ConnectionError, dev.DeployError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
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
    r.add_argument("--optick", action="store_true", help="save an Optick capture of each run")
    r.add_argument("--no-shots", action="store_true", help="skip screenshots")
    r.add_argument("--shot-scale", type=float, default=0.5, help="screenshot scale (default 0.5)")
    r.add_argument("--keep", action="store_true", help="leave --set overrides in place afterwards")
    r.add_argument("--car", choices=sorted(CARS), help="spawn this test car first (see `bench.py car`)")
    r.add_argument("--footage", action="store_true",
                   help="grab crash frames from a fixed camera (adds screenshot cost to the frame timings)")
    r.add_argument("--tod", type=float, default=0.1, help="time of day for the run (0.1 = late morning)")
    g = sub.add_parser("gallery", help="paint a fixed set of marks (no physics) and photograph them")
    g.add_argument("--tag", default="")
    g.add_argument("--car", choices=sorted(CARS))
    g.add_argument("--tod", type=float, default=0.1)
    g.add_argument("--seed", type=int, default=1234, help="painter random seed (same marks every run)")
    c = sub.add_parser("car", help="spawn a test car with the scratches skin")
    c.add_argument("name", choices=sorted(CARS))
    ls = sub.add_parser("list", help="compare recent runs")
    ls.add_argument("-n", type=int, default=20)
    ls.add_argument("--scenario")
    sub.add_parser("scenarios", help="describe the scenarios")
    h = sub.add_parser("home", help="show or save this level's home pose")
    h.add_argument("--save", action="store_true")
    args = p.parse_args()
    return {"run": cmd_run, "list": cmd_list, "scenarios": cmd_scenarios, "home": cmd_home,
            "car": cmd_car, "gallery": cmd_gallery}[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
