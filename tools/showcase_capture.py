"""HUD-free close-up captures for the README showcase, from the running game.

    python tools/showcase_capture.py closeup NAME --fwd 2.0 --side -0.8 --up 0.0 \
        --az 35 --elev 10 --dist 2.2          # matched damaged/original pair
    python tools/showcase_capture.py panel NAME   # debug panel open over the car

Run a bench scenario (tools/bench.py run ...) first; this never adds damage.
"closeup" aims a free camera at a point given in the car's frame (metres
forward/left/up from the vehicle's reference node), hides the HUD, captures with the
damage stage on, then with only the original two material stages (same frame),
and restores everything. Output: docs/evidence/showcase/NAME/*.jpg + state.json.

The engine screenshot omits ImGui, so "panel" output shows only the scene; the
README panel image was grabbed from the desktop with the HUD visible, then cropped.
"""
from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

import dev
import livery_probe
from PIL import Image

OUT = Path(__file__).resolve().parents[1] / "docs" / "evidence" / "showcase"


def lua(code: str) -> str:
    return dev.lua(code)


def capture(path: Path) -> None:
    name = "/screenshots/showcase-" + str(time.time_ns())
    lua("createScreenshot2({filename=" + json.dumps(name) + ",writeJPG=false,rescaleFactor=1});return true")
    src = Path(dev.user_dir()) / (name[1:] + ".png")
    for _ in range(60):
        time.sleep(0.25)
        if src.exists():
            try:
                time.sleep(0.5)
                # q95 JPEG: showcase sources, not lossless measurement evidence.
                Image.open(src).convert("RGB").save(path, quality=95, subsampling=0)
                src.unlink()
                return
            except PermissionError:
                pass
    raise RuntimeError("capture timeout")


def aim(fwd: float, side: float, up: float, az: float, elev: float, dist: float) -> None:
    lua(f"""
simTimeAuthority.pause(true)
local v=getPlayerVehicle(0)
local c=v:getPosition()  -- ref node: unlike the world box, not stretched by debris
local d=v:getDirectionVector(); local f=vec3(d.x,d.y,0):normalized()
local u=vec3(0,0,1); local l=u:cross(f):normalized()
local t=c+f*{fwd}+l*{side}+u*{up}
local az,el=math.rad({az}),math.rad({elev})
local h=f*math.cos(az)+l*math.sin(az)
local p=t+(h*math.cos(el)+u*math.sin(el))*{dist}
core_camera.setByName(0,'free')
core_camera.globalCameraFunction('free','setPosition',p)
core_camera.globalCameraFunction('free','setRotation',quatFromDir((t-p):normalized(),u))
if ui_visibility then ui_visibility.set(false) end
return true""")
    time.sleep(1.0)


def aim_auto(az: float, elev: float, margin: float = 1.0) -> None:
    """Frame the whole car: target the body centre, back off by its length."""
    lua(f"""
simTimeAuthority.pause(true)
local v=getPlayerVehicle(0)
local d=v:getDirectionVector(); local f=vec3(d.x,d.y,0):normalized()
local u=vec3(0,0,1); local l=u:cross(f):normalized()
local len=math.min(v:getInitialLength() or 4.5, 14)
-- Median node position: unlike the world box, detached debris can't drag it off.
local xs,ys,zs={{}},{{}},{{}}
for i=0,v:getNodeCount()-1 do local q=v:getNodePosition(i); xs[#xs+1]=q.x; ys[#ys+1]=q.y; zs[#zs+1]=q.z end
local function med(t) table.sort(t) return t[math.floor(#t/2)+1] or 0 end
local t=v:getPosition()+vec3(med(xs),med(ys),med(zs))
local az,el=math.rad({az}),math.rad({elev})
local h=f*math.cos(az)+l*math.sin(az)
local p=t+(h*math.cos(el)+u*math.sin(el))*(len*0.72*{margin}+0.9)
core_camera.setByName(0,'free')
core_camera.globalCameraFunction('free','setPosition',p)
core_camera.globalCameraFunction('free','setRotation',quatFromDir((t-p):normalized(),u))
if ui_visibility then ui_visibility.set(false) end
return true""")
    time.sleep(1.0)


def restore() -> None:
    lua("if ui_visibility then ui_visibility.set(true) end;simTimeAuthority.pause(false);return true")


def set_damage_visible(on: bool) -> None:
    """Toggle the appended damage+soil stages on every clone this car owns."""
    lua(f"""
local v=getPlayerVehicle(0); local c=scratches_paint.getCompatibility()
local stage=tonumber(c.stage); assert(stage,'body adapter not active')
local prefix='scratches_'..v:getId()..'_'
for _,n in pairs(v:getMaterialNames()) do
  if n:sub(1,#prefix)==prefix then
    local m=scenetree.findObject(n)
    if m then m:setField('activeLayers',0,tostring(stage+({2 if on else 0}))); m:flush(); m:reload() end
  end
end
return true""")


def matched(folder: Path, aim_fn) -> dict:
    """Damaged and original-stages frames from one frozen camera."""
    folder.mkdir(parents=True, exist_ok=True)
    e = json.loads(lua(livery_probe.LUA))
    assert e["compatibility"].get("adapter"), "body adapter not active"
    try:
        aim_fn()
        for name, on in (("damaged", True), ("original-stages", False)):
            set_damage_visible(on)
            time.sleep(0.8)
            capture(folder / f"{name}.jpg")
    finally:
        set_damage_visible(True)
        restore()
    return e


def closeup(a: argparse.Namespace) -> None:
    folder = OUT / a.name
    e = matched(folder, lambda: aim(a.fwd, a.side, a.up, a.az, a.elev, a.dist))
    state = json.loads(lua("return jsonEncode({stats=scratches_paint.getStats(),camera=getCameraPosition()})"))
    state["camera_args"] = {k: getattr(a, k) for k in ("fwd", "side", "up", "az", "elev", "dist")}
    state["comparison"] = e.get("comparison")
    (folder / "state.json").write_text(json.dumps(state, indent=2) + "\n")
    print("wrote", folder)


def panel(a: argparse.Namespace) -> None:
    folder = OUT / a.name
    folder.mkdir(parents=True, exist_ok=True)
    try:
        aim(a.fwd, a.side, a.up, a.az, a.elev, a.dist)
        lua("scratches_paint.toggleUI();return true")
        time.sleep(1.5)
        capture(folder / "panel.jpg")
    finally:
        lua("scratches_paint.toggleUI();return true")
        restore()
    print("wrote", folder)


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("mode", choices=["closeup", "panel"])
    p.add_argument("name")
    for k, v in (("fwd", 0.0), ("side", 0.0), ("up", 0.0), ("az", 30.0), ("elev", 12.0), ("dist", 3.0)):
        p.add_argument("--" + k, type=float, default=v)
    args = p.parse_args()
    (closeup if args.mode == "closeup" else panel)(args)
