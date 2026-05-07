# Refined Plan — post-investigation

This document supersedes the original plan in the prompt where they conflict. Everything in the original plan that isn't called out below stands as written.

**Bottom line:** the architecture survives intact. UV-space damage masks via `@DynamicTexture*` channels remain the right approach. The big surprises were *positive* — node-contact data is pushed to us by the engine (no raycasts needed), and the Dynamic Decals API is fully reachable from non-editor Lua (free-roam compatible). The constraints we now know about are real but workable.

---

## What didn't change

- Two-extension architecture: VLUA `detect.lua` + GELUA `paint.lua`, async-only bridge via `obj:queueGameEngineLua` / `vehicle:queueLuaCommand`.
- UV-space masks survive flexbody deformation (vehicle's `getDecalProjectionShape()` is the source mesh, baked masks are UV-space).
- Layered PBR via `materials.json` v1.5 with `@DynamicTexture*` channels — confirmed working in 40 vanilla vehicles.
- Phase ordering: detection → static decal → continuous strokes → multi-stage materials → polish/perf/persist.

## What changed (numbered for easy reference back)

### Path & environment

1. **Userfolder is `%LOCALAPPDATA%\BeamNG\BeamNG.drive\current\`** (not `%LOCALAPPDATA%\BeamNG.drive\<version>\`). The legacy path is dead since 0.38. Junction already created at `…\current\mods\unpacked\scratches_mod`.
2. **Steam install is on E:** (`E:\SteamLibrary\steamapps\common\BeamNG.drive`). Update any docs that hardcode `C:\Program Files (x86)\…`.
3. **Dynamic Decals source is under `editor/`, not `util/`.** Read locations:
   - `lua/ge/extensions/editor/api/dynamicDecals.lua` (the public API, ~200KB)
   - `lua/ge/extensions/editor/dynamicDecals/*.lua` (UI/tool layer, not needed by us)
   - `lua/ge/extensions/editor/api/dynamicDecals/textures.lua` (sidecar metadata)
   - `gameengine.zip → art/dynamicDecals/textures/*` (vanilla brush library)

### Detection — Phase 1 simpler than planned

4. **Engine pushes node collisions to us.** The global `onNodeCollision(id1, pos, normal, nodeVel, perpendicularVel, slipVec, slipVel, slipForce, normalForce, depth, materialId1, materialId2)` in `lua/vehicle/main.lua` is called per contact per physics tick. We wrap it in our extension at init. **No GE raycasts. No manual `getNodeContact` derivation. No per-tick `getNodePosition`/`getNodeVelocity` polling.**
5. **Wheel/body discriminator is `v.data.nodes[id].wheelID`** (non-nil = tire, nil = body). Filter early.
6. **Material enum is in `lua/common/particles.json`,** loaded via `particles.getMaterialsParticlesTable()`. **Look up IDs by name** (`particles.getMaterialIDByName(materials, "METAL")`) rather than hardcoding indices — the JSON's first row is a schema row that affects offset interpretation.
7. **Engine's own scrape thresholds (`particles.json`) are our calibration baseline:** `slipVel > 2.5 m/s` for sliding scrapes, `perpendicularVel > 2.5 m/s` for impact-style contacts. Body materials worth marking: METAL, PLASTIC, GLASS. Surface materials worth marking against: ASPHALT, ASPHALT_WET, SLIPPERY, ROCK, METAL, COBBLESTONE, RUMBLE_STRIP, GRAVEL.
8. **`beamBroken(id, energy)` and `onBeamDeformed(id, ratio)`** are still useful — but as a **secondary signal** for "panel torn / heavily bent → spawn extra-deep gouge layer," not as the primary detection path. They are not extension hooks; same wrap-the-global pattern as `onNodeCollision`.

### Painter API — Phase 2 needs synthetic-camera trick

9. **The Dynamic Decals API works without the editor.** `M.setup()` has a free-standing path that constructs `DecalProjection("", Point2I(4096, 2048), 1, materialIdx)` directly when `DecalShapeRenderApp:getActiveApp()` is nil. Free-roam compatible. No career mode required. `getPlayerVehicle(0)` is the only gate.
10. **Decals are placed via virtual camera projection, NOT UV coordinates.** `decalProjection:getDecalData(cameraM, projM)` projects from a camera through a screen-space cursor at (0.5, 0.5). For our impact events, **synthesize a virtual camera at `pos − normal × small_dist` looking along `normal`** and call `getDecalData()` on it. The engine handles world-to-mesh-to-UV. **The plan's "world-to-UV pipeline with barycentric math + Jacobian inversion" is replaced by this much simpler synthetic-camera approach.**
11. **Per-event work uses `decalProjection:bakeLayers([newLayer], jbeamName)`** — incremental, not full re-bake. Never call `reprojectLayers()` from a scrape event (it clears the entire texture and re-bakes the whole stack).
12. **Per-frame work is NOT zero.** `decalProjection:combineTextures(textureSet)` runs every frame regardless of activity (composes baked layers into the output set). Cost is fixed (independent of stamp count). Disable the live-preview projection with `setProjectDynamicDecalsState(false)` at startup. Use `setEnabled(false)` on the projection to fully idle distant vehicles in Phase 5.

### Material stack — Phase 4 needs reworking

13. **5 source channels, 4 output channels.** API can drive `color/normal/alpha/metallic/roughness` *as decal source textures*, but the vehicle materials only sample 4 dynamic outputs: `@DynamicTextureBaseColor`, `@DynamicTextureColorPalette`, `@DynamicTextureMetallic`, `@DynamicTextureRoughness`. **There is no `@DynamicTextureNormal`.** Per-scratch normal masks are not possible.
14. **Use a tileable detail normal map for scratch micro-relief.** Authored once, applied via static `normalMap` + `detailNormalMapStrength`. Intensity modulated by the depth mask.
15. **Materials format is declarative — no shader-side smoothstep.** The plan's "smoothstep thresholds with per-texel noise jitter" cannot live in `materials.json`. Two workarounds:
    - **(A) Encode thresholds in brush textures.** Author each brush as a radial depth gradient. The PBR stage opacities sample the dynamic texture directly. Soft transitions come from the brush gradient. Simpler. **Default choice for v1.**
    - **(B) Pre-compose per-stage masks in Lua.** Maintain `paintMask`, `primerMask`, `metalMask` and update them per scrape with depth-aware brightness. More memory, more compute, cleaner output. **Promote to B if A's transitions look bad.**
16. **Materials format v1.5 supports up to 4 PBR stages with per-stage `opacityMap`.** Confirmed in the file. Default skins use 2 stages (factory paint + dynamic decal layer); we'll add a third (and possibly fourth) for primer/bare-metal in Phase 4.

### Memory budget

17. **~57 MB per vehicle at 4096×2048 (default resolution),** not 12–16 MB. Math: BaseColor RGBA8 33MB + ColorPalette R8 8MB + Metallic R8 8MB + Roughness R8 8MB. Verify formats with `dump(textureSet)` in Phase 2.
18. **Updated LOD budget for 8 visible cars:** Player @ 4096² (~57 MB), nearest 2 AI @ 2048² (~28 MB), rest 5 @ 512² (~9 MB) ⇒ **~94 MB total**. Still under the plan's 100 MB ceiling, but only with aggressive LOD. Per-vehicle resolution is changeable at runtime via `setTextureResolution(Point2I)`.

### Vehicle compatibility

19. **40 of ~70 vanilla vehicles support dynamic decals.** Each ships with `vehicles/{name}/dynamicDecals/main.jbeam` + `…/main.materials.json`. The `md_series` part is explicitly disabled (`_TEMPORARILYDISABLED_skin_dynamicTextures`) and unsupported.
20. **Phase 2 test target = Pigeon.** Single body material, smallest dynamicDecals materials.json (~1.5 KB), simplest to iterate on.
21. **Auto-set the skin on vehicle spawn.** `core_vehicle_partmgmt.setSkin("dynamicTextures")`, gated by `hasAvailablePart(jbeam .. "_skin_dynamicTextures")`. Without this call, our painter has nowhere to render.
22. **Multi-material vehicles use the JBeam `dynDecalMaterials` array** to bind the decal projection to multiple body materials. All bound materials share one mask set per vehicle. Acceptable.
23. **UV1 is the dynamic-decal channel.** Stage 0 paint uses UV0 (mirrored). Stage 1 dynamic-decal uses UV1 (non-mirrored, full body). Mirror-UV worry from the plan: confirmed handled by upstream.

### Multi-vehicle / AI cars (Phase 5 implication)

24. **The Lua wrapper assumes one player vehicle** (`getPlayerVehicle(0)` hardcoded throughout `M.setup()`). For AI car support we either run one `DecalProjection` per vehicle (memory cost: see §17) or hot-swap the projection's bound vehicle per call. **C++ side may already support per-vehicle texture sets** (the `bakeLayers(layers, jbeam)` signature suggests it) — verify in Phase 5 with `dump()` probing.

---

## Refined Phase plan

### Phase 1 — Detection skeleton (3–5 days, was 1–2 weeks)

Smaller than planned because the engine hands us the contact data.

- VLUA extension at `lua/vehicle/extensions/scrapes/detect.lua`.
- `onInit` wraps `_G.onNodeCollision`, calling original then ours.
- Filter: `node.wheelID == nil` AND body material ∈ {METAL, PLASTIC, GLASS} AND surface material ∈ {ASPHALT, ASPHALT_WET, SLIPPERY, ROCK, METAL, COBBLESTONE, RUMBLE_STRIP, GRAVEL} AND `slipVel > 2.5 OR perpendicularVel > 2.5`.
- Print filtered events to console: `node id, partPath, pos, normal, slipVel, normalForce, materialID2 name`.
- Manual test: drag the Pigeon along a curb → verify event stream.
- Probe `dump(obj)` and `dump(v.data.nodes[someBodyNodeId])` for completeness.
- **Exit criterion:** clean console stream of plausible scrape events while dragging the test car.

### Phase 2 — One static decal at the right place (3–5 days, was 1 week)

- GELUA extension at `lua/ge/extensions/scrapes/paint.lua`.
- Init: `extensions.editor_api_dynamicDecals.setup()`, `setProjectDynamicDecalsState(false)`, auto-set skin, register an `onUpdate` to call `M.onUpdate_()` per frame.
- Manual test trigger via in-game `~` console: `scrapes_paint.testStamp(worldPos, normal)` synthesizes a virtual camera and calls `addDecal()`.
- Verify with `M.drawBakedTexturesInGui` debug overlay.
- **Exit criterion:** a single hardcoded scratch decal lands at a chosen world position on the player Pigeon, in the correct UV-space spot, surviving body deformation.

### Phase 3 — Continuous scrapes (1.5–2 weeks, was 2–3 weeks)

- VLUA → GELUA event flow: per VLUA tick, accumulate filtered scrape events into a small Lua array; flush via `obj:queueGameEngineLua("scrapes_paint.applyBatch(...)")` once per render frame (not per event).
- GELUA receives, for each event: synthesize virtual camera, call `decalProjection:getDecalData(cam, projM)`, add to a `bakeLayers` batch.
- Continuous scrapes via `setEnableBrushStroke(true)` + per-frame `setCursorPosition(...)` + `setEnableBrushStroke(false)` + `addBrushStrokeLayer()`. Cursor position is the screen-space UV from the synthetic camera.
- Author 4–6 initial scratch brushes (greyscale gradients) in `art/dynamicDecals/textures/`.
- Test on Pigeon (single-material, no UV mirror complexity), then on Pessima (multi-material, real-world test).
- **Exit criterion:** dragging the test car along a curb leaves a continuous, directional scratch trail at the correct location.

### Phase 4 — Multi-stage paint/primer/metal (2 weeks, was 2–3 weeks)

- Author `vehicles/pigeon/scratches/main.jbeam` (override `paint_design` slot with our 3-stage variant).
- Author `vehicles/pigeon/scratches/main.materials.json` overriding `pigeon.skin.dynamicTextures` with 3 active stages: bare metal (stage 0) → primer (stage 1) → paint (stage 2). Each stage's `opacityMap` references `@DynamicTextureMetallic` (Workaround A).
- Brush textures encode the depth gradient (radial: bright = deep gouge, dim = surface scratch).
- Verify: a deep brush stroke shows paint→primer→metal radially.
- Add the static detail-normal-map for scratch micro-relief.
- **Exit criterion:** a deep scrape on the test vehicle visually shows the layered material breach, not a flat color shift.

### Phase 5 — Polish, performance, persistence (2 weeks, unchanged)

- Transient impact-flash particle/decal at moment of contact (100–300ms lifetime) — these *can* be world-projected since their lifetime is short and the deformation between spawn and despawn is negligible.
- LOD masks per camera distance (per §17–§18).
- Per-vehicle `DecalProjection` instances if the C++ supports it; else multi-vehicle deferred to v2.
- Save/load via `M.exportLayerMask` / `M.loadLayerStackFromFile`. Format is JSON layer stack; texture data lives in the persisted layer params, not the baked texture.
- Stress test with 8 AI cars in derby map (only vehicles known to support the skin, per §19).
- **Exit criterion:** runs at 60 fps with 8 visible cars all scratched up; masks persist across save/load.

---

## Open probes (deferred to Phase 1/2)

A handful of things we couldn't determine from source alone. To resolve in early Phase 1 with in-game `~` console probes:

1. `dump(obj)` — full enumeration of `obj:*` bindings on this build.
2. `dump(v.data.nodes[someBodyNodeId])` — confirm `partPath`, `nodeMaterial`, `wheelID` populated as expected.
3. `dump(decalProjection)` and `dump(app.textureSet)` after a successful `setup()` — confirm texture formats and channel layouts.
4. `dump(decalData)` after one `addDecal()` — confirm field shape so we can decide if Phase 3 can construct decalData directly (option (b) in inv #1 §3) instead of going through synthetic camera.
5. Round-trip latency of `obj:queueGameEngineLua` (timestamp send + receive print).
6. Verify mods can override an existing material by re-defining its `mapTo` in the mod's materials.json (relevant for Phase 4 authoring).

## What stays out of scope for v1 (unchanged)

- Procedural rust accumulation in deep scratches over time.
- Wash/repair gameplay.
- Parallax occlusion on gouges (would need shader access we don't have).
- Multiplayer sync via BeamMP.

## What I'd flag as risky / wants your eye

- **Workaround A vs B (§15)** — A is simpler but the layered look quality depends entirely on brush authoring. If A turns out flat or muddy in Phase 4, B is a 3–5 day pivot.
- **Per-vehicle `DecalProjection` instances** — if the C++ doesn't support multiple instances, Phase 5's "AI car damage" becomes "player car damage only" and AI scrapes are deferred. Verify early if AI damage matters to you.
- **No `@DynamicTextureNormal`** — confirms the architecture, but the visual fidelity of scratches will be lower than what e.g. an AAA shader-driven system can produce. Detail-normal-map is a workable substitute but the depth-cued normal variation will be uniform per scratch (not per pixel of the gouge).
- **Materials.json mod override** — needs Phase 4 verification. If we can't override, we'd ship a forked Pigeon variant or wrap the override differently. Workable but adds friction.
