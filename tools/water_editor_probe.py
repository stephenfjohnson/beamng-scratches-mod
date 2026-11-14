"""Test an empty editor stack; refuses to replace existing user artwork."""
import time,json
from pathlib import Path
import dev
r={}
def lua(s):return dev.lua(s)
created=False
assert json.loads(lua('return jsonEncode(editor.active)')) is False, 'Close the editor first'
assert not json.loads(lua('return jsonEncode(editor_api_dynamicDecals.getLayerStack())')), 'Existing editor artwork; refusing test'
try:
 lua('editor.setEditorActive(true);return true');time.sleep(2)
 lua('editor_api_dynamicDecals.setup();return true');created=True;time.sleep(1)
 r['before']=json.loads(lua('return jsonEncode(editor_api_dynamicDecals.getLayerStack())'))
 lua('scratches_paint.clearStamps();extensions.reload("scratches_paint");return true');time.sleep(1)
 r['after']=json.loads(lua('return jsonEncode(editor_api_dynamicDecals.getLayerStack())'))
 assert r['before'] and r['before']==r['after']
finally:
 if created: lua('editor_api_dynamicDecals.clearLayerStack();return true')
 lua('editor.setEditorActive(false);return true')
 Path('docs/evidence/milestone3/editor-artwork.json').write_text(json.dumps(r,indent=2))
print('editor layers preserved')
