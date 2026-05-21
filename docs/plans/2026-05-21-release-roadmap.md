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

Bug: cars with an existing livery / paint preset / custom livery lose those
decals when the mod activates. Suspect either the `_skin_dynamicTextures`
skin-part swap (a vehicle has one skin slot) or `addPaintFill` seeding
baseColor over the whole body.

- [ ] **2.1** Add targeted diagnostics on the skin-swap and `addPaintFill`
  code paths so the log pane shows the smoking gun.
- [ ] **2.2** Diagnose: reproduce on a liveried car, copy debug report.
- [ ] **2.3** Decide strategy (composite over the livery vs. capture-and-
  restore into the dynamic canvas) and implement livery preservation.
- [ ] **2.4** Verify on a liveried vehicle and a plain vehicle.

## Phase 3 — Reset Car (R) clears all scratches & slides

Bug: `onReset` queues `clearStamps` but baked marks still survive a Ctrl+R.

- [ ] **3.1** Diagnose: timing (painter not `ready` on reset), new vehicle id
  after respawn, `clearStamps`'s `ready` guard short-circuiting.
- [ ] **3.2** Make the post-reset wipe reliable — defer until ready,
  re-resolve projection, target the respawned vehicle.
- [ ] **3.3** Verify R removes both baked impact stamps and slide streaks.

## Phase 4 — Auto-load both sides + bindable hotkey

- [ ] **4.1** Auto-load GELUA `scratches_paint` on game start — no manual
  `extensions.load`, no two-command bootstrap.
- [ ] **4.2** Verify clean load on fresh game start and on mod enable/disable.
- [ ] **4.3** Add a mod input-action map registering "Toggle Scratches Panel"
  with a sensible default key, bindable in Options > Controls.
- [ ] **4.4** Wire the action to `toggleUI()`; verify it appears in controls.

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
