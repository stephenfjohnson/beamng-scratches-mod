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

### Dedicated session — livery + paint-canvas rework (deferred)

The user wants this in its own session/context. Two bundled items:

1. **Livery + scratches compositing.** Liveried cars currently get no
   scratches (skipped by `ensureSkin`). To support both: before the skin
   swap, capture the livery's body textures and re-stamp them as a base
   layer in the dynamic canvas so scratches composite on top.
2. **Paint-canvas seed rework.** `clearBakedTextures` (Phase 3.2) wipes the
   whole canvas, so `addPaintFill` must repaint baseColor + metallic/
   roughness. The current 6-axis decal + separate fill-layer seed has uneven
   coverage — a two-tone seam on the body and a matte roof. The seed needs
   rethinking for clean, even, glossy re-paint.

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

- [ ] **4.1** Auto-load GELUA `scratches_paint` on game start — no manual
  `extensions.load`, no two-command bootstrap.
- [ ] **4.2** Verify clean load on fresh game start and on mod enable/disable.
- [x] **4.3** Add a mod input-action file (`lua/ge/extensions/core/input/
  actions/scratches.json`) registering `scratches_toggle_ui`, bindable in
  Options > Controls > Debug. (Done early, out of phase order.)
- [x] **4.4** Wire the action to `toggleUI()` (lazy-loads the extension
  first); appears in Controls > Debug. User binds their own key — BeamNG
  has no clean way for a mod to ship a pre-bound default without
  overwriting the game's keyboard map.

## Phase 5 — In-depth README + packaging

- [ ] **5.1** Installation section (end-user mod install, not the dev junction).
- [ ] **5.2** "How it works" — detection -> event batching -> decal painting.
- [ ] **5.3** Supported vehicles, requirements, limitations.
- [ ] **5.4** Controls + debug-panel guide.
- [ ] **5.5** Packaging checklist (zip layout, mod metadata).

## Phase 6 — More variation + performance

- [ ] **6.1** Scratch-decal variation (brushes, color/rotation/scale jitter).
- [ ] **6.2** Impact-decal variation.
- [ ] **6.3** Performance pass (profiling, bake-batching review).
