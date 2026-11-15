# Soft terrain and cross-panel soil

BeamNG 0.40.5.0 / Vulkan, ETK800 sedan, plain paint and stock Police skin.

## Changes

- MUD, SNOW and GRASS no longer emit scratch impacts or scrape streams, even
  under large body-contact loads. Mud/snow still feed the independent deposit
  path. Dirt, sand, gravel and hard surfaces remain abrasive.
- A wheel spray is one 1.8–2.8 m long projection, 0.48 m wide, shifted downstream
  from its wheel contact. Its rotation follows the engine's surface-normal
  basis directly; it is not restarted per body panel. Reverse travel flips
  the flow. Projection depth is bounded below the body's total width so the
  slab remains short of the opposite side. Deposit and scheduler caps remain.
- The ETK sedan's rear quarters and some body sections use `etk800_extra`, not
  the main material. The adapter now constructs separate private main/extra
  clones and binds both exact indices to the existing damage and soil targets.
  Plain and Police each use the correct stock source for both materials.
  Original two stages remain untouched; appended stages receive damage, soil,
  detail normals and washing. Unload/cleanup handles both clones, and custom
  overrides of either source are rejected.

## Visual evidence

The controlled fixture places the actual mud brush across three seam regions,
four overlapping passes each, on both sides. It is a projection check, not
evidence that a stationary vehicle naturally produces this pattern.

- Plain: [before material fix](plain/before-material-fix.png),
  [after, left](plain/seams-left.png), [after, right](plain/seams-right.png).
- Police: [before material fix](police/before-material-fix.png),
  [after, left](police/seams-left.png), [after, right](police/seams-right.png).
- [Diagnostic broad stamp](diagnostic-wide.png) isolated the missing quarter
  material before the fix. This deliberately oversized stamp is not gameplay.
- [Final real Police mud pass](police/close.png), [contact/state evidence](police/mud.json):
  22 deposits after six seconds, 31 after braking; unchanged while stationary.
  Filtered scratch contacts, impacts and streams remained zero.
- [Plain real mud pass](plain/close.png), [state](plain/mud.json): 31 deposits,
  no scratch events. This pass tested the longer trails before the extra-material
  correction; the final plain material coverage is verified by the seam fixture.

The same spray pattern now continues across the fender/front-door, front/rear
door and rear-door/quarter boundaries. Physical panel gaps remain. Contrast
changes across the Police livery and lighting; white paint still shows lighter
soil than black paint. A live field comparison of the final Police extra clone
against its source found no differences in the original two stages (excluding
identity and global layer-count fields).

## Reproduce

1. `python tools/package.py` — build and preflight.
2. `python tools/dev.py deploy --reload` — install both construction-time
   overrides. This reloads/repairs the player's vehicle and clears old marks.
3. On each supported paint, `python tools/soil_seam_probe.py --output <folder>`
   clears marks and captures both sides, restoring camera/pause/background settings.
4. For real contacts on Gridmap v2:
   `python tools/soil_probe.py mud --x -313 --seconds 6 --output <folder>`.
   This moves/resets the current car, drives briefly, brakes and records frames.

334 mock checks pass, including high-force soft-ground rejection, retained
soil, forward/reverse projection direction on both sides, both stock-material
stage copies, extra-material conflict rejection and lifecycle/quality reuse.
Lua syntax/global checks, sidecars and ZIP packaging pass.

## Remaining limitations

Mud color is still the fixed `(0.62, 0.36, 0.16)` palette; it is not sampled from
the visible ground. This looks too orange on this map. Contact callbacks carry
surface IDs, not surface RGB; the `particles.json` material colors also include
categorical/debug colors and should not be mistaken for terrain albedo.
Terrain-aware color matching is unfinished.

Reverse flow and dirt artwork have mock coverage but no new real-drive visual
capture here. Snow/body-contact deposition remains the shorter coverage brush.
No D3D12, water-drive, widebody, wagon or long-session performance requalification
was run. One extra private material is retained per supported vehicle/config;
there are still two reusable projection targets, not one per body panel.
