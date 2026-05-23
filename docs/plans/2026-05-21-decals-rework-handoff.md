# Handoff — dynamic-decals canvas rework (livery + paint seed)

Date: 2026-05-21
Purpose: self-contained brief for a fresh session tackling the deferred
"decals issue". Read this top to bottom before touching code.

## Status (updated 2026-05-23)

- **Problem 1 (paint-canvas re-seed)**: ✅ resolved. Solution: take metallic
  and roughness off the dynamic-decals canvas entirely. `restoreFactoryMR`
  in `paint.lua` re-points each body material's `metallicMap` /
  `roughnessMap` (on the `.skin.dynamicTextures` variant) at static PNGs
  shipped with the mod (`_zero.png` for metallic, `_paint_roughness.png`
  for roughness), then `flush()` + `reload()` so the renderer picks them up.
  Base gloss is now uniform across the whole body and never needs seeding;
  `addPaintFill` collapsed to a single `fill` layer for baseColor. Trade-off:
  scratches lose metal-glint (their M/R intensity writes go to an unused
  dynamic canvas; the scratches still read as color marks). The body of
  this brief describes the *original* attempt (six axis-projected decals)
  for context — that approach was abandoned because projected decals
  deposit only on the hemisphere facing their camera, so silhouette seams
  are unavoidable. See `2026-05-21-release-roadmap.md` for details.
- **Problem 2 (livery + scratches compositing)**: ⏳ still pending. The
  goal and constraints below remain valid. A natural starting point is to
  capture the livery's per-material baseColor textures and bake them into
  the dynamic `@DynamicTextureBaseColor` canvas as a base layer; with M/R
  no longer on the canvas, only one channel needs to be handled.

## Mission

Fix two related problems with how `scratches_mod` manages BeamNG's
dynamic-decal canvas. They share the same mechanics, so do them together.

1. **Paint-canvas re-seed is uneven** — after a clear/reset the body
   repaints with a visible two-tone seam and a matte (non-glossy) roof.
2. **Liveried cars get no scratches** — the mod skips them entirely to
   avoid destroying the livery. Goal: livery *and* scratches together.

## Background — the mod

`scratches_mod` paints procedural scratch/scrape/impact decals onto BeamNG
vehicle panels from physics contact events. It spans two Lua VMs:

- `lua/vehicle/extensions/auto/scratches_detect.lua` (VLUA) — detects and
  batches contact events.
- `lua/ge/extensions/scratches/paint.lua` (GELUA) — owns a Dynamic Decals
  projection and bakes the decals.

The painter uses BeamNG's `editor_api_dynamicDecals` extension (held as
`api`) and a resolved `decalProjection` object.

## Problem 1 — paint-canvas re-seed

### What happens

`clearStamps` (paint.lua) wipes the canvas with
`decalProjection:clearBakedTextures()` — this clears **every** baked channel
(baseColor, metallic, roughness, normal). Then `addPaintFill` re-seeds:

- 6 axis-aligned projected decals (`buildAxisCameraLocal` for ±X/±Y/±Z),
  each a full-canvas `_one.png` carrying metallic/roughness (and colour),
  baked via `decalProjection:bakeLayers`.
- A separate projection-free `fill` layer for uniform baseColor.

### The defect

Coverage is uneven. The fill layer makes the *colour* uniform, but a fill
layer writes baseColor **only** — it cannot write metallic/roughness. The
6-axis projected seed is what carries M/R, and it has gaps (notably the
roof) and overlaps (a two-tone seam down the body).

Result: roof is the right colour but matte; body shows a tonal seam.

### Goal

A re-seed that paints the whole body **evenly** — uniform colour *and*
uniform glossy metallic/roughness — with no seams or matte patches.

### Leads to explore

- Why does the 6-axis projected seed overlap/gap? `buildAxisCameraLocal`
  builds a camera at `axis * SEED_DIST` looking at the origin; check the
  frustum/scale (`SEED_DIST=4.0`, `SEED_SCALE=6.0`) against real vehicle
  bounds, and whether `setUseSurfaceNormal(true)` is dropping grazing-angle
  panels.
- Is there a uniform way to write the metallic/roughness channels (the way
  a `fill` layer writes baseColor uniformly)? Investigate `textureFill`
  layers and whether the projection exposes a direct channel write.
- Consider whether the seed should use more/better-placed cameras, or a
  different primitive entirely.

## Problem 2 — livery + scratches compositing

### Current behaviour

`ensureSkin` (paint.lua) inspects the `paint_design` slot via
`currentPaintDesignPart()`. If a real livery is present it **skips** the
vehicle (no skin swap, no scratches) so the livery is never destroyed.

### Why it's hard

BeamNG gives a vehicle one skin slot (`paint_design`). The mod needs the
`dynamicTextures` skin there for the decal canvas; a livery is also a
`paint_design` part. `core_vehicle_partmgmt.setSkin` overwrites the slot
outright. BeamNG's own dynamic-decals editor (`dynamicDecalsTool.lua`)
does the same swap — coexistence is not an engine-supported mode.

### Goal

Before the skin swap, capture the livery's body textures; after swapping
to `dynamicTextures`, re-stamp the livery into the dynamic canvas as a
base layer so scratches composite on top.

### Leads to explore

- How to read a livery skin part's per-material textures.
- Whether a `textureFill` layer (layer type 2) can carry the livery
  texture into the canvas per material, and how UVs map.
- The dynamic canvas is per body material — handle each.

## Key BeamNG API facts (already verified — don't re-investigate)

Reference source (read-only): the BeamNG install at
`<SteamLibrary>\steamapps\common\BeamNG.drive\lua\ge\extensions\editor\` —
`api/dynamicDecals.lua`, `dynamicDecalsTool.lua`.

- `decalProjection:bakeLayers(layers, jbeam)` bakes a list and dispatches
  on each `layer.type`. The Lua `M.bakeLayers` just forwards to it.
- `decalProjection:clearBakedTextures()` wipes the baked textures (all
  channels). Used by `reprojectLayers` and `clearLayerStack_Redo`.
- `decalProjection:flushDynamicTextures()` + `combineTextures(ts)` clears
  the working/dynamic stage and pushes it to the texture set.
- `reprojectLayers()` = `clearBakedTextures()` + `bakeLayers(layerStack)`.
- Layer types: `api.layerTypes.fill = 1`, `textureFill = 2`. A `fill`
  layer serializes `name/blendMode/color/colorPaletteMapId/type` — colour
  only, no M/R. `textureFill` adds `scale/offset/fillTexturePath`.
- `M.addFillLayer` / `M.addTextureFillLayer` exist (history-based);
  `M.setFillLayerColor` sets the colour.
- `core_vehicle_partmgmt.setSkin(name)` rewrites the `paint_design` slot's
  `chosenPartName` and respawns the vehicle.

## Current code map (paint.lua)

- `ensureSkin(jbeam)` — skin swap + the livery skip-guard.
- `currentPaintDesignPart()` — reads the `paint_design` slot's chosen part.
- `addPaintFill()` — the canvas seed (6 axis decals + fill layer).
- `clearStamps()` — clearLayerStack + clearBakedTextures + flush/combine +
  re-seed.
- `buildAxisCameraLocal(axis, dist)` — synthetic seed cameras.
- `PAINT_SEED_COLOR` / `PAINT_METALLIC` / `PAINT_ROUGHNESS` — seed tunables.

## Tools available

- **Debug panel** — bind "Toggle Scratches Debug Panel" (Options > Controls
  > Debug) or call `scratches_paint.toggleUI()`. Left pane shows merged
  GE+VEH logs; "Copy debug report" puts a paste-ready report on the
  clipboard.
- **Syntax check** — `luac -p <file>` (both Lua files are plain Lua 5.1).
- **Reload** — `Ctrl+L` reloads GELUA, `Ctrl+R` respawns + reloads VLUA.

## Suggested order

Start with Problem 1 (paint seed) — it is self-contained, currently
visibly broken, and builds the canvas understanding Problem 2 needs.
Diagnose with the debug panel before changing code.
