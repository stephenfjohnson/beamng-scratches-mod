# Changelog

## Milestone 5: performance investigation — blocked, unmerged

- Reuse private ETK projection resources and exact material indices across attachments;
  drain captured layers before further projection to prevent starvation.
- Add explicit 4096/2048/1024 damage widths and independent native bake batch limits.
  Default resolution is unchanged; separate soil and original material maps are untouched.
- Add opt-in same-panel grouping and representative footprint coalescing with explicit
  completed/merged/pending/lost request and proxy coverage accounting. Retain every
  stream layer when grouping; do not present representative brushes as pixel-equivalent.
- Correct sustained fixture velocity forcing, reject mid-run cosmetic resets, record
  queue ages and native outlier timestamps, and add continuous circular endurance.
- 254 mock checks pass. Historical 148-run cohort remains separately documented;
  new corrected-fixture cohorts, invalid old runs and traced diagnostics are distinguished.
- Capture a 426 ms native call with a correlated 423 ms graphics paging packet.
  WPR CPU profiling remains unavailable; no unsupported shader/driver attribution.
- Half-resolution grouping improves observed throughput but still reproduces native
  stalls (613 ms projection / 402 ms bake in untraced warm runs). Stable release and
  milestone 5 merge remain blocked; no milestone 6/public release.
  [Resumed implementation and evidence](investigations/11-quality-throughput.md).

## Milestone 4: scratch and impact polish — 2026-11-14

- Select depth-colored brush generation from prior realism work, with ten new
  seeded assets, smaller impacts/gouges, narrower slide bands and reduced haze.
- Prevent immediate brush repeats per family; reduce positional jitter to 8 mm.
- Mute only the private ETK damage stage diffuse response; preserve original
  PBR/livery, soil color, selective washing and bounded scheduler.
- Add matched engine captures and reproducible capture/configuration helper.
- 222 mock checks plus Lua syntax/global and brush sidecar preflight.
- [Evidence and tradeoffs](investigations/09-scratch-impact-polish.md). No stable release.

## Milestone 3: selective washing and drying — 2026-11-14

- Split ETK soil into a reusable 1024x512 target above the lasting damage stage.
- Fade soil from real sampled body immersion; clear only fully washed soil,
  reopen deposit allowance, and restore cloned clearcoat values after drying.
- Preserve original maps/Police design, per-vehicle clones and editor isolation.
- Fix native projection initialization order and transient soil preview leaking
  into the damage target, both discovered during live validation.
- Add real mud/dirt/snow wash captures and reproducible engine probes; 212 mock
  checks plus syntax/global/brush preflight. No stable release or milestone 4.
- [Evidence, bounds and limitations](investigations/08-water-washing.md).

## Milestone 2: progressive deposits — 2026-11-14

- Admit rolling tire contacts by vehicle speed, prioritize wheels over body
  contacts, refresh queued node positions, and project onto lower side panels.
- Add distinct deterministic mud, dirt and snow coverage masks, progressive
  overlap, and bounded lifetime/cell limits. Keep the private ETK adapter.
- Validate real mud/dirt/snow driving, stationary behavior, 96-deposit cap,
  scratch/Police coexistence, plain paint, reset and switching.
- Fix adapter cleanup after map teardown deletes cloned scene materials.
- Record D3D12 build/config, real screenshots and measured CPU/resource limits;
  205 mock checks plus syntax/global/brush preflight pass.
- No visual washing, wet gloss, broad performance certification or stable release.
- [Evidence and reproducible examples](investigations/07-progressive-deposits.md).

## Milestone 1: narrow ETK material adapter — 2026-11-14

- Preserve ETK 800 empty Paint Design and stock Police main-body materials under
  scratches, including original normal/detail, palette, metallic, roughness and
  clearcoat channels. Keep Paint Design unchanged; use per-vehicle clones.
- Use a private Dynamic Decals API/projection; clearing does not wipe editor
  layers. Suspend for editor ownership and resume cleanly after closure.
- Validate plain/police scratches, clean/reset, switching two ETKs and unicycle,
  vehicle/extension reload, editor layers and unsupported designs in game.
- Correct plain material selection to current `etk800_main` PBR material.
- Add matched captures and material comparison tools, 20 adapter regressions
  (192 total mock checks), exact configuration and instructional examples.
- Initial activation can reload the car once. Generic liveries, extra-material
  damage and broad renderer/version support remain deferred. Dark-mark opacity
  is color-dependent; disabled clones remain for existing mesh references. No milestone
  2 work, deposit art changes, wet gloss or visual washing.
- [Implementation, real screenshots and limitations](investigations/06-etk-material-adapter.md).

## Earlier milestone 1 investigation checkpoint — 2026-11-14

- Preserve stock liveries on same-id part changes; guard destructive clear.
- Skip unowned Dynamic Textures designs, including after extension reload.
- Add read-only compatibility/material probe and seven regression checks (172 total).
- Record 0.40.5.0 build 302427 Vulkan ETK/plain/police/reset/switch and unicycle evidence.
- Generic compositing and exact paint-material fidelity remain incomplete.
  See [investigation](investigations/05-livery-preservation.md); no milestone 2 work.


## Unreleased

- Experimental bounded mud/dirt/snow contact deposits, using tinted haze brushes.
- Water detection and internal wetness/washing/drying state. Visual washing and
  wet gloss are not implemented.
- 165 mock checks pass; Lua syntax/global and brush sidecar preflight pass.
- Live ETK 800 asphalt sideslide regression captured; environmental rendering
  and broad vehicle compatibility remain unverified.
- Added installation guidance, examples, troubleshooting, compatibility evidence,
  contribution instructions and a sequential release plan.

Existing scratches, impact chips, diagnostic controls and reset behavior remain.
Other liveried vehicles remain intentionally skipped. No stable release is tagged.
