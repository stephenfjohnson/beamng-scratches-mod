# Investigation #1 — Dynamic Decals API

**Build investigated:** 0.38.5.0 build 19602 (25/03/2026)
**Source root:** `E:\SteamLibrary\steamapps\common\BeamNG.drive\lua\ge\extensions\editor\`
**Status:** Reachable from gameplay-rate Lua. Not editor-locked. Free-roam compatible. Several plan-impacting nuances found — see "Plan deltas" at bottom.

---

## 0. Where the code actually lives

The plan said `lua\ge\extensions\util\dynamicDecals*`. Reality:

```
lua\ge\extensions\editor\dynamicDecalsTool.lua          # editor-side tool wrapper (the imgui UI)
lua\ge\extensions\editor\api\dynamicDecals.lua          # the public Lua API ← this is what mods call
lua\ge\extensions\editor\api\dynamicDecals\textures.lua # texture sidecar metadata
lua\ge\extensions\editor\api\dynamicDecals\sidecarFileMigration.lua
lua\ge\extensions\editor\dynamicDecals\…                # 30+ files: layerStack, brushes, layerTypes/{decal,brushStroke,path,fill,…}
```

The **API** is `extensions.editor_api_dynamicDecals` (registered name). It is genuinely separable from `dynamicDecalsTool` — the tool consumes it, but the tool is not required to load it. Modules whose name starts with `editor_dynamicDecals_*` are tool/UI-only (browser, gizmo, inspector, news, docs, vehicleColorPalette…). We do **not** need any of them.

The textures `gameengine.zip → art/dynamicDecals/textures/*` (brushes, gradients, alphabet, scratch shapes) are loose authored content. We can drop our own brushes into `art/dynamicDecals/textures/` in the mod and they'll be findable the same way.

## 1. Architecture: a thin Lua skin over two C++ singletons

The whole system is C++ underneath. Lua just orchestrates. Two C++ objects do the real work:

- **`DecalShapeRenderApp`** — global, exists when the editor's render pass is active. Method probed: `:getActiveApp()` returns an `appPtr`. May be `nil` outside the editor; this is the "is the editor render path live" check.
- **`DecalProjection`** — constructible directly from Lua: `DecalProjection(name, Point2I(width, height), arg3, materialIdx)`. This is the actual decal compositor that owns the dynamic textures and runs the projection/bake/combine passes.

`api.setup()` (line 1452) takes one of two paths:

1. **Editor-attached path** (line 1456): if `DecalShapeRenderApp:getActiveApp()` is non-nil, the api hooks the editor's existing `DecalProjection` and uses the editor camera.
2. **Free-standing path** (line 1473) — **this is the path we want**: constructs `DecalProjection("", Point2I(4096, 2048), 1, materialIdx)` directly. No editor required. The Lua wrapper computes the camera matrix from the player vehicle's ref-node matrix and `getCameraTransform()`. Texture resolution is **4096×2048 by default**.

The free-standing path is gated only on `getPlayerVehicle(0)` — no career, scenario, or mission requirement. Free-roam is fully supported.

## 2. The C++ surface, by direct method calls

`decalProjection:` methods, all confirmed from source — these are what we'd actually be calling from our GELUA painter:

| Method | What it does |
| --- | --- |
| `getDecalData(cameraM, projM)` | Project a "decal" through the given camera+projection at the current cursor position; returns a layer-shaped table containing `decalPos`, `decalNorm`, `cursorPosScreenUv`, `viewToScreen`, `worldToViewToScreen`, `useSurfaceNormal`, etc. **This is the main constructor for new layer data.** |
| `bakeLayers(layers, jbeamName)` | Incrementally bake the listed layers into the dynamic texture set. Cheap; this is what happens per `addDecal`. **Use this for our event-driven stamps.** |
| `clearBakedTextures()` | Wipe all baked content. Used by `reprojectLayers` (full re-bake from scratch). **Avoid.** |
| `projectDynamicDecals(camM, projM)` | Per-frame live preview projection (what the editor does to show "where will my decal land if I click now"). **Disable for us** via `M.setProjectDynamicDecalsState(false)`. |
| `combineTextures(textureSet)` | Per-frame composite of baked layers into the output set. Runs every frame regardless. Cost is fixed shader work, not stamp-count-dependent. |
| `flushDynamicTextures()` | Flush pending texture writes. Called on enable/disable. |
| `setShape(veh:getDecalProjectionShape())` | Bind a vehicle mesh as the projection target. |
| `setWorldTransform(veh:getRefNodeMatrix())` | Vehicle world transform for projection math. |
| `setRenderTransform(matrix)` | Render-side transform (vehicle origin in render space). |
| `setMirrorOffset(x)` | Offset for left/right mirrored decals. |
| `getTextureSet()`, `setTextureResolution(Point2I)` | Texture set + resize. |
| `getUvLayer()`, `setUvLayer(int)` | **Multi-UV-layer support — confirmed.** Default 0 (UV0), can switch to UV1 (the livery channel). |
| `clearMaterialIdx()`, `setMaterialIdx(int)`, `addMaterialIdx(int)`, `removeMaterialIdx(int)`, `getMaterialIdx()` | **Multi-material per vehicle — confirmed.** A vehicle can have N body materials, each with its own slot in `getShapeMaterialNames()`. The dyn-decals system is bound to a *set* of material indices, all written together. |
| `getMeshObjectCount()`, `getShapeMaterialNames()` | Enumeration. Returns a 1-indexed list; we add the index of materials we care about. |
| `getDecalTexturePath(type)`, `setDecalTexturePath(type, path)` | `type ∈ {"color", "normal", "alpha", "metallic", "roughness"}` — **all five PBR channels per layer.** |
| `setEnableBrushStroke(bool, uid)`, `setEnablePathLayer(bool)` | Tool-mode toggles for stroke/path recording. |
| `getDecalMatrixZBufferValue()`, `getDecalMatrixSurfaceNormalValue()` | Read back the z-buffer depth and surface normal at the current decal projection (these are what `lockDepth` / `lockSurfaceNormal` snapshot). |
| `mirrorLayerData(data, mirrorChildren)` | Produce a left/right mirrored copy of layer data. |
| `setEnabled(bool)`, `getEnabled()` | Master on/off — disables the whole projection/combine pass. |
| `setHighlightedDecal(decal)` | UI/editor only. Ignore for us. |
| `exportTextures(dir, name, ext)`, `exportLayerMask(layer, dir, name, ext)` | Export the baked texture or one layer's mask to disk. Useful for save/load and debug. |
| `drawDynamicTexturesInGui(maxW)`, `drawBakedTexturesInGui(maxW)`, `drawHighlightTexturesInGui(maxW)`, `drawBrushInputTexturesInGui(maxW)`, `drawMaskTexturesInGui(maxW)`, `drawTextureSetInGui(set, name, maxW)` | Imgui debug viewers — invaluable for our investigations. |

`veh:` methods used (BeamNG `BeamNGVehicle` C++ binding):

- `veh:setTextureSet(id, set)` — apply a texture set to the vehicle. `id` is `"@DynamicTexture"`.
- `veh:getDecalProjectionShape()` — vehicle's projection shape (the source mesh, not the deformed flexbody — UV-space stamps survive deformation).
- `veh:getRefNodeMatrix()` — vehicle world transform.
- `veh:getSpawnLocalAABB()` — bounding box for mirror-plane center.
- `veh.jbeam` — the jbeam name (used as the key when baking).

## 3. Coordinate space — the key constraint for our use case

**The API does NOT accept UV coordinates directly.** All decal placement flows through `decalProjection:getDecalData(cameraM, projM)`, which projects from a virtual camera through a screen-space cursor onto the vehicle mesh. The returned `decalData` carries `decalPos` (world), `decalNorm` (world), `cursorPosScreenUv` (screen-space, default 0.5,0.5), and the projection matrices.

For our impact-driven scrapes, this means we cannot simply say "stamp at UV (0.62, 0.31) on this triangle." We have three options:

**(a) Synthetic camera approach.** For each contact event, build a virtual camera at `(impactPos − contactNormal × small_dist)` looking along `contactNormal`, with a tight projection matrix, then call `getDecalData(syntheticCam, projM)` with cursor at (0.5, 0.5). The decal projects from the contact normal direction — exactly what we want for a scrape. Side-effect: per-frame decals require per-frame camera matrices. Workable. Probably what we use.

**(b) Construct decalData directly.** The serialized layer fields show what makes a "decal" structurally (line 232–300 of `dynamicDecals.lua`): `decalPos`, `decalNorm`, `viewToScreen`, `worldToViewToScreen`, `cursorPosScreenUv`, `useSurfaceNormal`, etc. If we can synthesize all of those ourselves, we can call `bakeLayers([decalData])` without going through `getDecalData()`. **Needs probing** — some fields may be C++ side-effects we can't recreate. Worth a 30-min experiment in Phase 2.

**(c) The brush-stroke "cursor position" path.** `setEnableBrushStroke(true)`, then per frame `setCursorPosition(p2f)` (line 2662 in api), then `setEnableBrushStroke(false)` and `addBrushStrokeLayer()`. The cursor positions go through the same camera projection — so we still need to manage the camera. But this is the natural "continuous stroke" primitive the engine already supports, and matches the plan's "SDF-capsule strokes between successive ticks." **Strong candidate for the scrape primitive in Phase 3.**

The plan's "world-to-UV pipeline" via barycentrics is *available to us* but is **not the engine's natural input**. Easiest route: synthetic camera. Hardest but most-direct route: construct decalData in Lua. The decision can wait until Phase 2 has a working static decal — once we know the format of `decalData` from a real call, option (b) becomes much cheaper.

## 4. What runs per frame — performance reality check

The plan stated: *"EVENT-DRIVEN, NOT PER-FRAME: nothing happens on GPU when no scrape is in progress."*

That's not quite right. Per-frame work in `M.onUpdate_()` (line 2927):

1. `app:onUpdate()` — sets the vehicle shape/world-transform/render-transform/mirror-offset on the projection. Light Lua marshalling, no GPU work.
2. `decalProjection:projectDynamicDecals(camM, projM)` — only if `M.projectDynamicDecals == true`. **We disable this** with `setProjectDynamicDecalsState(false)`. This is the live-preview pass; we don't want a live preview.
3. `decalProjection:combineTextures(textureSet)` — **runs every frame regardless.** Composes baked-layer outputs into the final `@DynamicTexture*` channels. Fixed shader cost per channel, independent of stamp count.

Actionable: revise the performance claim to *"GPU work per frame is the fixed `combineTextures` composite — not zero, but flat in stamp count. New stamp work is event-driven via `bakeLayers([newLayer])`."* Combined with `setEnabled(false)` when no scrapes are active recently and no vehicle is close, we can flush and idle the system entirely for distant cars.

`bakeLayers` is the per-event cost. It bakes only the listed layers, not the whole stack — confirmed by `addDecal_Redo` (line 1091): `M.bakeLayers({actionData})`. The plan's "coalesce stamps from one physics tick into one draw" maps directly: queue stamps per VLUA tick, flush as `bakeLayers(arrayOfStamps)` once per GE frame.

`reprojectLayers()` (line 1646) is the *expensive* one — clears textures and re-bakes the entire stack. Called on layer toggle/visibility/move/delete. **Never call this from a scrape event.**

## 5. Vehicle prerequisites — the hard gate

`setVehicleMaterialJob` (line 1381) does material discovery in two ways:

1. **Preferred path:** the vehicle's chosen `paint_design` part declares a `dynDecalMaterials` table in its JBeam. `findPartMaterials()` reads it (line 1367). If present, only those materials are bound.
2. **Fallback heuristic:** find a material whose name matches the jbeam, or ends with `_main`, or ends with `_body`. Used when no `dynDecalMaterials` is declared.

The editor-side tool (`dynamicDecalsTool.lua` line 631–648) sets the vehicle skin to `"dynamicTextures"` via `core_vehicle_partmgmt.setSkin("dynamicTextures")` and explicitly checks for the part `{jbeam}_skin_dynamicTextures` — **if the vehicle doesn't have that skin, the tool warns "not supported" and does nothing.**

This is the same blocker investigation #3 needs to characterize. For Phase 2 we will pick a test vehicle that already ships with `_skin_dynamicTextures` (e.g. probably the Bolide, Pessima, etc. — investigation #3 will enumerate). For Phase 4 (paint/primer/metal stack) we author our own skin part for the test vehicle.

## 6. Layer types we can use

From `M.layerTypes` (line 784):

| id | Name | Fits our use? |
| --- | --- | --- |
| 0 | `decal` | One stamp from one camera projection. **Yes — single-impact splat.** |
| 1 | `fill` | Solid color over the whole texture. Used for the base paint layer. |
| 2 | `textureFill` | Tileable texture over the whole texture. **Yes — base "factory clearcoat" detail map.** |
| 3 | `group` | Folder. |
| 4 | `brushStroke` | Sequence of decals interpolated along recorded cursor positions. **Yes — primary candidate for scrape strokes.** |
| 5 | `path` | Decals interpolated along control points (linear or bezier curve). Mostly for authored decoration. Less natural for impulsive scrapes. |
| 6 | `linkedSet` | Property-link container. Editor convenience. |

For our work, the active vocabulary is **decal** (single stamp on impact) and **brushStroke** (continuous scrape).

Texture channels per decal: `color`, `normal`, `alpha`, `metallic`, `roughness`. Normal/metallic/roughness are commented as "disabled for the time being" in the *property UI* (lines 902–907) but the underlying setter `setDecalTexturePath` accepts them — the engine knows about them, only the editor's inspector hides them. **We can drive all five channels from Lua.** This is exactly the lever for the paint/primer/metal stack.

## 7. Texture resolution and memory

- Default in standalone path: `Point2I(4096, 2048)` — 4096×2048. That's 8.4 MP per channel.
- Configurable post-init via `setTextureResolution(Point2I)` (line 2297). Validated values from `M.textureResolutions`: `512`, `1024`, `2048`, `4096`. Note the option list only shows square — but `setTextureResolution` accepts `Point2I` so non-square may be possible (worth probing).
- Resolution change re-binds the texture set: line 2298–2301 fetch new set, re-apply via `setTextureSet`. So per-LOD downscaling at runtime is allowed.
- The plan's per-channel memory math (depth R8 + direction RG8 = 12–16MB per close vehicle) needs revisiting against actual channel formats — investigation deferred until we can `dump()` the texture set in-game and read back format.

## 8. Other surface that matters for us

- `M.setEnabled(bool)` / `M.toggleEnabled()` — master switch. Use to idle distant vehicles (Phase 5 LOD).
- `M.setProjectDynamicDecalsState(bool)` — disables the per-frame projection of the cursor preview. **Set to false at startup for our use case.**
- `M.exportLayerMask(layer, dir, name, ext)` and `M.exportTextures(dir, name, ext)` — write to disk. Useful for save/load (Phase 5) and for debugging in Phase 2.
- `M.drawBakedTexturesInGui(maxW)` and friends — imgui visualizers. We can wire these to a debug overlay for quick visual verification.
- Hooks fired:
  - `dynamicDecals_onLayerAdded(layerUid)` (line 210)
  - `dynamicDecals_onLayerDeleted(layerUid)` (line 226)
  - `dynamicDecals_onTextureFileAdded(filepath)` (textures.lua line 178)
  - `dynamicDecals_onTextureFileDeleted(filepath)` (textures.lua line 213)
  We can ignore these for our painter; only relevant if we want to react to editor-driven changes.
- `decalProjection:exportLayerMask(layer, dir, name, ext)` writes a single layer's contribution to disk — perfect for Phase 2 verification ("did my stamp actually land where I think").

## 9. Multi-vehicle (AI cars) — significant rework needed for Phase 5

The standalone-path `app` (line 1473–1509) hardcodes `getPlayerVehicle(0)` everywhere: `setShape`, `setWorldTransform`, `setRenderTransform`, `setMirrorOffset`. There's a single module-level `decalProjection` instance.

For AI cars we need either:

- One `DecalProjection` per active vehicle (memory cost: per-car texture set, e.g. 8 cars × 16 MB = 128 MB at full res — matches the plan's 100 MB budget for 8 cars).
- OR a custom `app` table that switches vehicle per call. Not obvious this is supported by the C++ side — `bakeLayers(layers, jbeam)` already takes a jbeam name, so the C++ side may already support multiple per-vehicle texture sets. **Needs probing.**

For Phase 1–4 we work with a single vehicle (the player). Phase 5 redesigns this.

## 10. Plan deltas

Things we now know that the original plan didn't or got slightly wrong:

1. **Source path.** `lua\ge\extensions\editor\…`, not `…\util\…`. Update the "READ" line in the plan.
2. **Userfolder layout.** 0.38 changed from `%LOCALAPPDATA%\BeamNG.drive\<version>\` to `%LOCALAPPDATA%\BeamNG\BeamNG.drive\current\`. Hot-reload junction is now at `…\current\mods\unpacked\scratches_mod` — already created.
3. **Coordinate space.** The system is camera-projection-driven, not UV-direct. Phase 3's "world-to-UV pipeline" is achievable but the natural engine path is "synthesize a virtual camera from the contact point and let `getDecalData()` do the projection." Direct decalData synthesis is a candidate but needs Phase 2 probing first.
4. **Per-frame cost is not zero.** `combineTextures` runs every frame. Keep the event-driven story for *new stamp work* but acknowledge a flat per-frame composite cost. Use `setEnabled(false)` to idle distant cars.
5. **`projectDynamicDecals` should be disabled.** That's the live-preview pass and is wasted work for us. `setProjectDynamicDecalsState(false)` at startup.
6. **Five PBR channels available**, not just color/normal. `metallic` and `roughness` are wired in C++ even though disabled in the editor UI — exactly what we need for the multi-stage material in Phase 4.
7. **Vehicle gate is the same blocker as investigation #3.** Without a `_skin_dynamicTextures` part on the vehicle, the system loads but does nothing visible. Phase 2's first task: pick a test vehicle that ships with this skin (e.g. one of the vanilla cars listed in investigation #3) so we don't fight two unknowns at once.
8. **Phase 1 detection skeleton needs no API change** — it's pure VLUA console logging. The Dynamic Decals binding work begins in Phase 2.
9. **Multi-vehicle rework lands in Phase 5**, not Phase 3 as the plan implied. The C++ may already support per-jbeam texture sets (the `bakeLayers(layers, jbeam)` signature suggests it), but the Lua wrapper assumes one player vehicle. Verify before designing AI sync.
10. **Free-roam / non-career: confirmed compatible.** No gating on game mode in `setup()`.

## 11. Open questions (defer to Phase 2 probes)

- What does a real `decalData` table look like field-by-field? `dump(decalData)` after one `addDecal()` call.
- Does `decalProjection:bakeLayers([decalData])` accept a hand-constructed table without `viewToScreen`/`worldToViewToScreen`? If so, option (b) from §3 is viable.
- What's the texture format and channel layout of `getTextureSet()`? Need this for the Phase 5 memory budget.
- Does the editor path (`DecalShapeRenderApp:getActiveApp()` non-nil) ever activate in non-editor sessions? If yes, we need to handle both setup branches.
- Is there a per-frame ticker event we should hook from a non-editor extension to call `M.onUpdate_()`? In the editor the call comes from `dynamicDecalsEditModeUpdate`. We'll need our own ticker — probably from `extensions.hook("onUpdate", …)` in a GELua extension.
