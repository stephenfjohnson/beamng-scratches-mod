# Milestone 1: preservation investigation (2026-11-14)

**Historical investigation checkpoint (a3a8f03).** Its incomplete status below
was superseded by the [implemented ETK adapter and validation](06-etk-material-adapter.md).
Generic compositing remains deferred; unsupported designs still use the safeguard.
This document records what was known before the adapter experiments.

## Source and overlap review

Baseline: `8695b7a`. Reviewed painter/livery handling in local branches:

- `t3/mod-review-improvements` (`e93737c`): contact accuracy changes; same
  `ensureSkin` livery skip and same-model shortcut.
- `t3/improve-wreck-scratches-dings` (`b4e4036`): material-aware brushes and
  shading; same skip safeguard, no stock-livery composition.
- `t3/council-crash-realism-loop` (`37ddfeb`): damage-stage split and restoration
  bookkeeping, but targets `.skin.dynamicTextures`; same livery skip.

No branch was merged or cherry-picked. Contact, brush and realism work remains
outside this milestone. Existing scratches and experimental deposits remain;
water wash/gloss is still deferred.

Inspected installed source at `E:/SteamLibrary/steamapps/common/BeamNG.drive`:

- `lua/ge/extensions/core/vehicle/partmgmt.lua:859`: `setSkin` rewrites the
  `paint_design` node and calls `core_vehicles.replaceVehicle`. It does not stack
  two skins or preserve the old material underneath.
- `lua/ge/extensions/editor/api/dynamicDecals.lua:1230`: `addTextureFillLayer`
  builds a texture-fill layer with a color texture, scalar palette id, scale and
  offset; `bakeLayers` performs the bake. It does not capture a whole PBR material.
- Same file, `setup` at 1450 and update at 2402: one projection texture set is
  bound through `veh:setTextureSet("@DynamicTexture", set)`. Setup also creates
  a fill when the editor layer stack is empty. This API is shared with the editor.
- Same file, 1635/1650: reprojection/clearing clears baked textures. Reset cannot
  selectively erase our marks from a flattened texture containing user artwork.
- `content/vehicles/etk800.zip`, `skin.materials.json` and
  `dynamicDecals/main.materials.json`: police skin and dynamic skin differ in
  material response, not just their base-color images.

## Concrete preservation/compositing approach and rejection boundary

For an explicitly authored single-skin adapter, a color-only experiment could
seed the existing plain-paint fill, then use `setFillTexturePath`,
`setFillLayerColor`, `setFillLayerColorPaletteMapId`,
`setTextureFillLayerScale`, `setTextureFillOffset`, and `addTextureFillLayer`
with `vehicles/etk800/etk800_skin_police_b.color.png`, unit scale/zero offset,
white color and palette id zero. Scratch bakes could follow this immutable base;
reset would need to rebuild that base before accepting new scratch jobs.
These setters and layer types exist in this installed Lua API. This recipe is
**not a verified renderer prototype**, and is intentionally not auto-applied.

Why it is not a preservation solution: ETK police stage 1 uses metallic 0.5,
roughness 0.5, clearcoat roughness about 0.03 and orange-peel detail normals.
The dynamic variant instead reads dynamic M/R textures, uses clearcoat roughness
0.06 and lacks that detail-normal setup. The current painter further substitutes
its own M/R maps. Copying RGB would keep the police lettering but alter its
appearance. Other skins use palette maps, other UVs, multiple materials and
additional layers. A single scalar palette id cannot copy a palette texture.

A more promising **unverified** per-vehicle adapter would retain every original
stage and add a scratch stage using the dynamic canvas as color/alpha, with
explicit material indices and correct UV1/body masks. It needs spare stages,
verified alpha semantics, per-instance material isolation, and full restoration
on unload, reset and switch. Shared material mutation could affect other cars.
The council branch's restoration bookkeeping is relevant to a future adapter,
but its dynamic-skin split is not that adapter. No engine shader or material
files were patched in this investigation.

Before enabling any adapter: demonstrate identical untouched paint, palette,
normal/detail, metallic/roughness and clearcoat; preserve editor source layers;
separate base reconstruction from scratch clearing; validate multiple cars
sharing materials. Generic feasibility is unresolved, not proven impossible.

## Safeguard changes

Same-id part respawns now invalidate readiness and queued work and re-run the
slot check. `clearStamps` checks the current design before clearing a canvas.
The same-model shortcut no longer bypasses that check. Existing Dynamic
Textures selections are treated as potentially user-authored liveries, unless
this extension instance selected that skin from an empty slot. Ownership ends
on vehicle destruction or detection of another livery. A reload deliberately
forgets ownership; it cannot distinguish saved mod paint from editor artwork.

`getCompatibility()` and `tools/livery_probe.py` expose read-only status and
material fields without initializing the canvas. The probe samples the main
material and police/dynamic variants; it is not a complete arbitrary-vehicle
material discovery tool.

Concurrent Dynamic Decals editor use on an already-owned car is **unsupported**:
the shared editor API has no ownership isolation in this implementation. Its own
vehicle-switch hook can bind textures independently of this mod; this patch
defers only the mod's explicit forwarding until after its safeguard. Save
editor work and unload the scratches extension before editing. Do not interpret
this change as a guarantee for every editor interaction. Full plain-paint PBR
fidelity also remains unresolved; configured paint values are retained but the
rendered material can differ.

## Live evidence

BeamNG **0.40.5.0 x64 build 302427**, Vulkan on NVIDIA RTX 3090, Windows 11;
Gridmap v2 (`gridmap_v2`). Build and renderer came from the running `beamng.log`.
3840x2160, Custom preset, Ultra lighting, High shaders, Normal textures, SMAA,
dynamic reflections enabled. Captures are genuine engine screenshots at 0.5
scale (1920x1080), not generated imagery.

ETK 800 config: `vehicles/etk800/rennspecht_8r_A.pc`, with paint design changed
explicitly for each case. Three paint values and material fields are retained in
[probe JSON](../docs/evidence/milestone1/plain.json). First paint RGB is
0.08/0.18/0.105, metallic 0.8, roughness 0.65, clearcoat 1, coat roughness 0.05.
The stock police skin test uses that same vehicle/config with `etk800_skin_police`;
it is not a claim to have tested every police configuration.

| Case | Observation | Evidence |
| --- | --- | --- |
| Stock police skin | Skipped; lettering retained | [before](../docs/evidence/milestone1/police-before.png), [status](../docs/evidence/milestone1/police.json) |
| Police reset + clear attempt | Still skipped; skin/material fields retained | [after](../docs/evidence/milestone1/police-reset.png), [status](../docs/evidence/milestone1/police-reset.json) |
| Plain sideslide | Visible scratches on contacted left side | [capture](../docs/evidence/milestone1/plain-sideslide.jpg), [raw bench result](../docs/evidence/milestone1/sideslide-result.json) |
| Reset / clean baseline | Clean left side, zero impact/stream/projection counters | [capture](../docs/evidence/milestone1/plain-clean.jpg), [raw result](../docs/evidence/milestone1/baseline-result.json) |
| Switch to unicycle | Unsupported, not ready | [status](../docs/evidence/milestone1/unsupported.json) |
| Switch back to ETK | Owned skin, ready | [status](../docs/evidence/milestone1/switched-back.json) |
| Change active plain ETK to police | Readiness revoked, police retained | [status](../docs/evidence/milestone1/plain-to-police.json) |
| Reload on Dynamic Textures | Unowned design skipped | [status](../docs/evidence/milestone1/reload-unowned.json) |
| Final code plain/reset smoke | Ready before and after reset | [plain](../docs/evidence/milestone1/final-plain.json), [reset](../docs/evidence/milestone1/final-reset.json) |

The baseline scenario ends at its configured four-second duration (the tool
labels this “timed out”); it is not a crash or a settling test. Bench JSON keeps
raw counters and timings; these single runs are not a performance certification.
Screenshots were visually inspected. The first direct reset screenshot had an
obstructed view after the side pose reset; the subsequent upright baseline
capture above is the useful clean-surface evidence. The final ownership-destruction
hook was added after bench captures and then checked by preflight and live
plain/reset smoke. Deposits retain their mock coverage, not new live soil evidence.

## Validation and disposition

`python tools/package.py`: 172 mock checks, Lua syntax/global checks and brush
sidecars pass; ZIP contains only `lua/` and `art/`. Added seven checks cover
same-id stock livery, no clear/seed on skipped cars, unowned dynamic design,
re-enable from empty paint, owned respawn and destroyed-id reuse.

This is a focused investigation/safeguard branch. **Milestone 1 acceptance fails**
for generic compositing and exact original paint/material preservation. Keep it
unmerged; no subsequent milestone started. A narrow authored adapter or a
plain-paint-only release scope remains a future design decision.
