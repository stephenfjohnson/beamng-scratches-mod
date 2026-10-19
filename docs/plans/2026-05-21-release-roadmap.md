# Release roadmap

Date: 2026-05-21

Trackable backlog toward packaging `scratches_mod` for release. Work the phases
in order, one chunk at a time. Check off `[x]` as chunks land. Bugs before
polish; debug tooling first so every later bug costs one click instead of a
console session.

## Phase 1 — Debug tooling & UI

Goal: make feeding debug info back effortless — reproduce, click "Copy debug
report", paste. Or just screenshot the panel.

Design notes:

- Both `paint.lua` and `scratches_detect.lua` call the global `log()` directly
  with no local alias, so a local `log` shadow at the top of each file can
  capture every existing call site into a ring buffer for free.
- Round K already pushes a VLUA->GE stats snapshot every 0.25s via
  `recordDetectStats`; the vehicle-side log lines piggyback on that channel.

- [x] **1.1** Log ring buffer + `log` capture wrapper (GE / `paint.lua`).
  Fixed-size ring of `{seq, t, lvl, src='GE', msg}`; local `log` shadow
  appends then calls the real `log()`.
- [x] **1.2** Vehicle-side capture + labeled piping to GE. Same `log` shadow
  in `scratches_detect.lua` (`src='VEH'`); `pushLogsToGE` ships new lines
  (`%q`-escaped, capped 30/push) on the 0.25s channel; `recordDetectLog`
  merges them into the GE ring.
- [x] **1.3** Panel restructure: left log pane (scrolling, auto-scroll,
  color-coded — red errors / amber warnings, lines tagged `[GE]`/`[VEH]`,
  `W/E only` filter) and right controls (existing stats, sliders, presets).
- [x] **1.4** "Copy debug report" button. Curated markdown block: env header
  (vehicle jbeam, painter-ready, skin state, layer count) + one-line stats &
  tunables summary + log lines filtered to warnings/errors plus recent
  context, each labeled. Not an `I`-spam dump.
- [x] **1.5** UI hardening: status header (painter READY/NOT READY +
  vehicle); paint-canvas controls and Clear stamps grey out via
  `BeginDisabled` when not ready; other controls self-guard.

## Phase 2 — Livery-wipe bug

Bug (confirmed): a livery is a part in BeamNG's single `paint_design` slot.
`core_vehicle_partmgmt.setSkin("dynamicTextures")` overwrites that slot's
`chosenPartName`, evicting the livery. BeamNG's own dynamic-decals editor
does the same — coexistence isn't a supported mode.

- [x] **2.1** Diagnostics: `currentPaintDesignPart()` logs the slot's chosen
  part before the swap; `clearStamps` logs layer count before the wipe.
- [x] **2.2** Diagnosed: `paint_design` held `sunburst2_skin_itasha` — a
  factory/mod livery skin part, evicted by the swap (Case A).
- [x] **2.3** Preservation by skip: `ensureSkin` inspects the slot first; if
  a real livery is present it skips the vehicle entirely (no swap, no
  scratches) instead of evicting. Empty slot / our own skin -> proceed.
- [x] **2.4** Verified: liveried car (itasha) keeps its livery and is
  skipped; plain car still gets scratches.

### Dedicated session — livery + paint-canvas rework

Originally two bundled items in a deferred dedicated session. The paint-canvas
half is done; the livery half is still pending.

1. **Livery + scratches compositing.** *(still pending)* Liveried cars
   currently get no scratches (skipped by `ensureSkin`). To support both:
   before the skin swap, capture the livery's body textures and re-stamp them
   as a base layer in the dynamic canvas so scratches composite on top.
2. **Paint-canvas seed rework.** *(done 2026-05-23)* Root cause: the body's
   metallic and roughness lived on the dynamic-decals canvas, and any
   `clearBakedTextures` wipe forced a re-seed via projected decals — which
   each deposit only on the hemisphere facing their camera, so silhouette
   seams are unavoidable. **Fix:** take M/R *off* the dynamic canvas entirely.
   `restoreFactoryMR` re-points each body material's `metallicMap` /
   `roughnessMap` (on the `.skin.dynamicTextures` variant) at static PNGs
   shipped with the mod — `_zero.png` for metallic, a tiny 0.2-grey
   `_paint_roughness.png` for roughness — then `flush()` + `reload()` the
   material. Base gloss is uniform across the whole body, factory-perfect,
   and never needs seeding. `addPaintFill` collapsed to one `fill` layer for
   baseColor only. Trade-off: scratches lose metal-glint (their
   `setMetallicIntensity` / `setRoughnessIntensity` writes go to an unused
   canvas — harmless no-ops). Scratches still read as color marks.

See memory `livery-paintseed-dedicated-session`.

## Phase 3 — Reset Car (R) clears all scratches & slides

Bug (confirmed): `onReset` queues `clearStamps`, and `clearStamps` *runs* fine
on Ctrl+R (not a timing/ready issue). It used the wrong wipe primitive —
`flushDynamicTextures` resets only the working/dynamic texture stage, while
the mod bakes stamps additively into the *baked* textures.

- [x] **3.1** Diagnosed via a Ctrl+R repro report: `clearStamps` runs, but
  `flushDynamicTextures` doesn't touch the baked textures. BeamNG's own
  wipes (`reprojectLayers`, `clearLayerStack_Redo`) use `clearBakedTextures`.
- [x] **3.2** `clearStamps` now calls `decalProjection:clearBakedTextures()`
  — the same primitive BeamNG uses — before the flush/combine. Fixes both
  the Ctrl+R path and the panel's "Clear stamps" button.
- [x] **3.3** Verified: Ctrl+R removes baked impact stamps and slide
  streaks. Side effect — `clearBakedTextures` also wipes baseColor/M-R, so
  the re-seed shows uneven paint (two-tone body, matte roof). Deferred to
  the dedicated livery + paint-canvas session above.

## Phase 4 — Auto-load both sides + bindable hotkey

- [x] **4.1** Already satisfied by design: the vehicle side auto-loads from
  `extensions/auto/`, and it bootstraps the GE painter via
  `extensions.load('scratches_paint')` on its lifecycle hooks. No manual
  command, no code change needed.
- [x] **4.2** Verified — both sides come up with zero console commands;
  combined with the 4.3 hotkey, the mod needs no console interaction.
- [x] **4.3** Add a mod input-action file (`lua/ge/extensions/core/input/
  actions/scratches.json`) registering `scratches_toggle_ui`, bindable in
  Options > Controls > Debug. (Done early, out of phase order.)
- [x] **4.4** Wire the action to `toggleUI()` (lazy-loads the extension
  first); appears in Controls > Debug. User binds their own key — BeamNG
  has no clean way for a mod to ship a pre-bound default without
  overwriting the game's keyboard map.

## Phase 5 — In-depth README + packaging

Done — `README.md` rewritten as a full install + tech guide.

- [x] **5.1** Installation section (player packaged install + developer
  unpacked junction).
- [x] **5.2** "How it works" — detection -> event batching -> decal painting,
  across both Lua VMs, plus the auto-load path.
- [x] **5.3** Supported vehicles, requirements, limitations.
- [x] **5.4** Controls + debug-panel guide.
- [x] **5.5** Packaging: `tools/package.py` builds `dist/scratches_mod.zip`
  with `lua/` + `art/` at the zip root, preflighting `luac -p` and the
  brush `.dynDecalTexture.json` sidecars. README updated to match.

## Phase 6 — More variation + performance

- [ ] **6.1** Scratch-decal variation (brushes, color/rotation/scale jitter).
- [ ] **6.2** Impact-decal variation.
- [x] **6.3** Performance pass (2026-10-18 audit against game 0.39.4).
  Earlier (2026-09-08): spawn-AABB cached per vehicle id; log rings trim in
  blocks. The 2026-10-18 pass:
  - **Player-only detection.** The detector auto-loads into every vehicle;
    traffic cars now return on the first line of `onNodeCollision` instead of
    running the filter and shipping their hits to GE (where they were stamped
    onto the *player's* car with the player's matrix). A traffic car's reset no
    longer wipes the player's scratches.
  - **Per-node verdict cache** on the physics hot path (was a lowercase + 18
    substring scans per contact per tick).
  - **Candidate logging off by default** (was ~40 log lines/s per sliding node).
  - **Stream thinning** — samples closer than 1.5 cm to the last are dropped.
  - **One GE call per frame** — streams ride with impacts in
    `scratches_paint.ingest(vid, events, streams)`; was one compiled
    `queueGameEngineLua` per stream.
  - **Unified job queue** — every impact cluster / stream is a projection job;
    at most N per frame (default 6), one `bakeLayers` per frame; backlog capped.
  - **Composite gating** — `api.onUpdate_` (texture re-bind + full-canvas
    `combineTextures`) runs only on frames that baked/cleared, during setup, and
    on a 0.5 s heartbeat. `setFullRateCombine(true)` restores the old behaviour.
  - **Idempotent `restoreFactoryMR`** — only `@DynamicTexture` stages are
    repointed (factory stage-0 maps are kept), so repeat calls skip the reload.
  - Still open: in-game profiling numbers (BeamNG profiler, `dynamicDecals/*`
    events) to tune the projection budget and heartbeat.

## Audit fixes (2026-10-18)

- [x] Crash: `spawnAabbCache` (2026-09-08 WIP) was declared after the
  functions that reset it, so `onVehicleSwitched` indexed a nil global on
  every vehicle switch. `tools/package.py` now rejects unexpected globals.
- [x] Surface materials `ASPHALT_PREPPED`, `CONCRETE`, `SAND_DENSE` don't exist
  in `particles.json` and silently aliased PLASTIC; names now resolve exactly
  and `SANDY_ROAD` was added.
- [x] Batches from a vehicle that isn't the current player car are dropped
  (stale batch after a switch landed on the new car).
- [x] Setup no longer re-runs (and re-warns) for a skipped/liveried car on
  every traffic spawn.
- [x] Decal rotation passed in radians (`setDecalRotation` takes radians).
- [x] `tools/sim/harness.lua`: mocked-engine checks for both VMs, run by
  `tools/package.py`.

## Robustness fixes (2026-09-08)

- [x] `decalProjection` (plucked from an `api.bakeLayers` upvalue) is now
  cleared on `onVehicleSwitched` and `onExtensionUnloaded`. `trySetup` calls
  `api.setup()` again for the new vehicle; if that rebuilds the API's
  projection, the cached handle was dead and every bake went nowhere.
- [x] `clearStamps` now re-runs `restoreFactoryMR()` before re-seeding.
  It previously ran only once, from the binding stabilizer at setup — but a
  respawn (the Ctrl+R path into `clearStamps`) can rebuild the
  `.skin.dynamicTextures` materials and put M/R back on the canvas that was
  just wiped, which is the Phase 3.3 matte-body symptom returning.
- [x] Stale UI/doc strings: 'Clear stamps' tooltip said Ctrl+L (it's Ctrl+R),
  aggregate-cap tooltip said default 32 (it's 96), README still listed the
  paint-canvas re-seed as an open bug (fixed 2026-05-23).
