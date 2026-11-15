"""Count D3D12 resource creations per native decal call type (diagnostic only).

Runs short user-provider ETW sessions (no elevation, Direct3D12 mask 0x484)
around isolated in-game loops: composite only, one-layer bakes, three-layer
bakes, and (optionally) legacy projections. Each loop runs while the car is
parked, using the painter's private ETK projection. Writes counts of
Direct3D12 resource-create events (id 91) by width/height/format for the game
process to docs/evidence/milestone5/<label>/alloc-counts.json. Raw ETLs stay in
bench/ (system-wide data). Counts are event observations, not allocator truth.

Run (game on D3D12, Police ETK ready):
    python tools/perf_alloc_probe.py --label synth-alloc-d3d12 --calls 20
"""
import argparse, collections, json, subprocess, time
from pathlib import Path
import dev

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--label', required=True)
p.add_argument('--calls', type=int, default=20)
p.add_argument('--with-projection', action='store_true', help='also loop legacy projections (can block for a long time behind deferred bake destruction)')
a = p.parse_args()
out = Path('docs/evidence/milestone5') / a.label
out.mkdir(parents=True, exist_ok=False)

SETUP = r'''
local function up(f,w) for i=1,80 do local n,v=debug.getupvalue(f,i) if not n then return end if n==w then return v end end end
local A=up(scratches_paint.onUpdate,"adapterModule"); local api=up(A.create,"privateApi")
_G.__allocDP=up(api.bakeLayers,"decalProjection"); _G.__allocAPI=api; _G.__allocApp=up(api.onUpdate_,"app")
_G.__allocLayer=function(y)
  local dp,api=_G.__allocDP,_G.__allocAPI
  local p=vec3(1.19,y,0.45); local fwd=vec3(-1,0,0); local cp=p+vec3(0.7,0,0)
  local r=vec3(0,0,1):cross(fwd):normalized(); local u=fwd:cross(r):normalized()
  local m=MatrixF(true); m:setColumn(0,r); m:setColumn(1,fwd); m:setColumn(2,u); m:setColumn(3,cp)
  api.setDecalTexturePath("color","/art/dynamicDecals/textures/shape_circle.png")
  api.setDecalTexturePath("alpha","/art/dynamicDecals/textures/_one.png")
  api.setDecalColor(Point4F(0.7,0.7,0.7,0.01)); api.setDecalScale(vec3(0.02,1,0.02)); api.setDecalRotation(0)
  local l=dp:getDecalData(m,getCameraProjMatrix()); api.setDecalLocalPos(l,p)
  l.decalPos=vec3(p.x,p.y,p.z); l.decalNorm=vec3(1,0,0); l.surfaceNormal=vec3(1,0,0)
  l.uid="alloc-"..tostring(math.random(1,1e9)); l.name="scratch"; l.enabled=true; l.locked=false; l.children={}
  return l, m
end
return tostring(_G.__allocDP~=nil)
'''
assert dev.lua(SETUP) == 'true', 'private projection not resolved'
pid = int(subprocess.check_output(['powershell', '-NoProfile', '-Command',
      '(Get-Process BeamNG.drive.x64 | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1).Id'], text=True))
LOOPS = {
    'idle': 'local t=os.clockhp() return tostring(os.clockhp()-t)',
    'combine': 'local t=os.clockhp() for i=1,N do _G.__allocDP:combineTextures(_G.__allocApp.textureSet) end return tostring(os.clockhp()-t)',
    'bake1': 'local t=os.clockhp() local v=getPlayerVehicle(0) for i=1,N do local l=_G.__allocLayer(0.2) _G.__allocDP:bakeLayers({l},v.JBeam) end return tostring(os.clockhp()-t)',
    'bake3': 'local t=os.clockhp() local v=getPlayerVehicle(0) for i=1,N do local a=_G.__allocLayer(0.1) local b=_G.__allocLayer(0.2) local c=_G.__allocLayer(0.3) _G.__allocDP:bakeLayers({a,b,c},v.JBeam) end return tostring(os.clockhp()-t)',
    'project': 'local t=os.clockhp() for i=1,N do local _,m=_G.__allocLayer(0.2) _G.__allocDP:projectDynamicDecals(m,getCameraProjMatrix()) end return tostring(os.clockhp()-t)',
}
results = {'pid': pid, 'callsPerLoop': a.calls, 'loops': {}}
if not a.with_projection:
    LOOPS.pop('project')
for name, code in LOOPS.items():
    etl = Path('bench') / f'{a.label}-{name}.etl'
    session = f'ScratchesAlloc{int(time.time())}'
    subprocess.run(['logman', 'start', session, '-p', 'Microsoft-Windows-Direct3D12', '0x484', '5',
                    '-o', str(etl), '-ets'], check=True, capture_output=True)
    time.sleep(1.0)
    seconds = float(dev.lua(code.replace('i=1,N', 'i=1,' + str(a.calls)), read_timeout=300))
    time.sleep(1.0)
    subprocess.run(['logman', 'stop', session, '-ets'], check=True, capture_output=True)
    query = (f"Get-WinEvent -Path '{etl.resolve()}' -Oldest | Where-Object {{ $_.ProcessId -eq {pid} -and ($_.Id -eq 91 -or $_.Id -eq 92) }} | "
             "ForEach-Object { $x=[xml]$_.ToXml(); $d=@{}; foreach($n in $x.Event.EventData.Data){ $d[$n.Name]=$n.'#text' }; "
             "'{0}|{1}|{2}|{3}|{4}' -f $_.Id,$d['Width'],$d['Height'],$d['Format'],$d['HeapType'] }")
    lines = subprocess.run(['powershell', '-NoProfile', '-Command', query], capture_output=True, text=True).stdout.split()
    counts = collections.Counter(lines)
    results['loops'][name] = {'luaSeconds': seconds, 'events': dict(counts)}
    print(name, round(seconds * 1000, 1), 'ms', dict(counts), flush=True)
dev.lua('scratches_paint.clearStamps() return true')
(out / 'alloc-counts.json').write_text(json.dumps(results, indent=2))
(out / 'README.md').write_text(
    '# Native allocation probe\n\nDirect3D12 resource-create (91) / destroy (92) events attributed to the game\n'
    'process during isolated loops of each native call type. Keys are `id|width|height|format|heapType`.\n'
    'The window includes ~2 s of idle frames (1 s before/after); the `idle` loop is the baseline for those.\n'
    'Diagnostic; not untraced performance evidence. Raw ETLs are local only.\n')
