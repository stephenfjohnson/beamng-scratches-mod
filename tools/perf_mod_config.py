"""Probe the installed Scintilla GT3 config; restore its prior activation state."""
import json,time,hashlib
from pathlib import Path
import dev,livery_probe,damage_probe

out=Path('docs/evidence/milestone5/mod-config');out.mkdir(parents=True,exist_ok=False)
archive=Path(dev.user_dir())/'mods/repo/scintilla_gt3.zip'
prior=json.loads(dev.lua('return jsonEncode(core_modmanager.getMods()["scintilla_gt3"].active)'))
(out/'archive.json').write_text(json.dumps({'name':archive.name,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'previouslyActive':prior},indent=2))
try:
 if not prior:
  dev.lua('core_modmanager.activateMod("scintilla_gt3");return true');time.sleep(3)
 dev.lua('simTimeAuthority.pause(false);core_vehicles.replaceVehicle("scintilla",{config="vehicles/scintilla/gt3_balanced.pc"});return true');time.sleep(8)
 state=json.loads(dev.lua(livery_probe.LUA));(out/'state.json').write_text(json.dumps(state,indent=2))
 damage_probe.capture(out/'vehicle.png')
 print(json.dumps(state['compatibility']))
finally:
 dev.lua('core_vehicles.replaceVehicle("etk800",{config="vehicles/etk800/rennspecht_8r_A.pc"});return true');time.sleep(4)
 if not prior:dev.lua('core_modmanager.deactivateMod("scintilla_gt3");return true')
 dev.lua('core_vehicle_partmgmt.setSkin("police");return true');time.sleep(3)
 (out/'restored.json').write_text(dev.lua(livery_probe.LUA))
 (out/'activation-restored.json').write_text(dev.lua('return jsonEncode({active=core_modmanager.getMods()["scintilla_gt3"].active})'))
