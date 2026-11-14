"""Lifecycle checks against real engine; leaves player in original vehicle."""
import time,json,subprocess
from pathlib import Path
import dev,livery_probe,soil_probe
out=Path('docs/evidence/milestone3');r={}
def lua(s):return dev.lua(s)
def snap(k):
    r[k]={'config':json.loads(lua(livery_probe.LUA)),'surface':json.loads(lua('return jsonEncode(scratches_paint.getSurfaceState())'))}
def memory():
    return int(subprocess.check_output(['powershell','-NoProfile','-Command','(Get-Process BeamNG.drive.x64 | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1).PrivateMemorySize64'],text=True).strip())
assert json.loads(lua('return jsonEncode(editor.active)')) is False, 'Close the editor first'
try:
    snap('start');r['reloads']=[]
    for i in range(5):
        lua('extensions.reload("scratches_paint");return true');time.sleep(1)
        r['reloads'].append({'privateBytes':memory(),'compat':json.loads(lua('return jsonEncode(scratches_paint.getCompatibility())'))})
    lua('getPlayerVehicle(0):reload();return true');time.sleep(3);snap('vehicleReload')
    lua('scratches_paint.clearStamps();return true');snap('reset')
    lua('editor.setEditorActive(true);return true');time.sleep(2);snap('editorActive')
    r['editorBefore']=lua('return jsonEncode(editor_api_dynamicDecals.getLayerStack())')
    lua('scratches_paint.clearStamps();extensions.reload("scratches_paint");return true');time.sleep(1)
    r['editorAfter']=lua('return jsonEncode(editor_api_dynamicDecals.getLayerStack())')
    lua('editor.setEditorActive(false);return true');time.sleep(2);snap('editorReturn')
    lua('m3original=getPlayerVehicle(0):getId();local v=getPlayerVehicle(0);core_vehicles.spawnNewVehicle("etk800",{config=core_vehicle_partmgmt.getConfig(),pos=v:getPosition()+vec3(5,0,0)});return true');time.sleep(4);snap('secondVehicle')
    r['inactive']=json.loads(lua('local m=scenetree.findObject("scratches_etk800_"..m3original.."_plain");return jsonEncode({name=m:getName(),layers=m:getField("activeLayers",0)})'))
    for i in range(3):
        lua('m3second=getPlayerVehicle(0):getId();be:enterVehicle(0,scenetree.findObjectById(m3original));return true');time.sleep(1);snap('return'+str(i))
        if i<2:lua('be:enterVehicle(0,scenetree.findObjectById(m3second));return true');time.sleep(1)
    soil_probe.shot(out/'two-vehicles.png')
finally:
    lua('if editor.active then editor.setEditorActive(false) end;return true')
    (out/'lifecycle.json').write_text(json.dumps(r,indent=2)+'\n')
print('saved lifecycle',[(x['privateBytes'],x['compat']['ready']) for x in r['reloads']])
