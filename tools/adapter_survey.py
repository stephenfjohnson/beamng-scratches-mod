"""Survey the generic body-material adapter across every stock vehicle.

    python tools/adapter_survey.py                 # all models with Dynamic Textures
    python tools/adapter_survey.py etk800 pessima  # just these
    python tools/adapter_survey.py --out docs/evidence/adapter-survey/survey.json

For each model: replace the player vehicle with its default configuration, wait
for the painter, and record which path it took (body adapter / legacy / skipped),
the paint design and skin it preserved, its body material keys and stage count,
and any rejection reason. Read-only apart from spawning vehicles.
"""
from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

import dev

MODELS_LUA = ("local o={} for k,m in pairs(core_vehicles.getModelList().models) do "
              "if (m.Type=='Car' or m.Type=='Truck') and FS:directoryExists('/vehicles/'..k..'/dynamicDecals') "
              "then o[#o+1]=k end end table.sort(o) return jsonEncode(o)")


def survey(model: str, timeout: float) -> dict:
    dev.lua(f"core_vehicles.replaceVehicle({json.dumps(model)},{{}}) return 'ok'", read_timeout=60)
    deadline = time.time() + timeout
    state: dict = {}
    while time.time() < deadline:
        time.sleep(2)
        try:
            state = json.loads(dev.lua("local v=getPlayerVehicle(0) local c=scratches_paint.getCompatibility() "
                                       "c.model=v and v.JBeam or nil return jsonEncode(c)", read_timeout=30))
        except Exception as exc:  # game busy constructing
            state = {"error": str(exc)}
            continue
        if state.get("model") == model and (state.get("ready") or state.get("skipped")
                                            or state.get("pending") is False):
            break
    path = ("body adapter" if state.get("adapter") else
            "legacy" if state.get("ready") else "skipped")
    return {"model": model, "path": path, "part": state.get("part"), "source": state.get("adapter"),
            "keys": state.get("keys"), "stage": state.get("stage"), "rejected": state.get("rejected"),
            "ready": state.get("ready")}


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("models", nargs="*")
    p.add_argument("--timeout", type=float, default=40)
    p.add_argument("--out", type=Path)
    a = p.parse_args()
    models = a.models or json.loads(dev.lua(MODELS_LUA))
    rows = []
    for m in models:
        row = survey(m, a.timeout)
        rows.append(row)
        print(f"{m:14} {row['path']:13} part={row['part']!s:32} keys={row['keys']} stage={row['stage']} "
              f"{'REJECTED: ' + row['rejected'] if row['rejected'] else ''}", flush=True)
    if a.out:
        a.out.parent.mkdir(parents=True, exist_ok=True)
        a.out.write_text(json.dumps(rows, indent=2) + "\n")
    print(f"\n{sum(r['path'] == 'body adapter' for r in rows)}/{len(rows)} on the body adapter")


if __name__ == "__main__":
    main()
