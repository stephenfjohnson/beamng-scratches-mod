# Changelog

## Repository cleanup and feature showcase — 2026-11-15

- Merge the milestone 5 stack (synthetic anchors, directional and terrain-tinted
  soil, cross-panel splashes, soil relief, scratch visibility) into `master` as a
  development preview. Preflight: 358 mock checks, Lua syntax/global and brush
  sidecar checks pass. D3D12 acceptance gates remain open.
- Rewrite the README as a feature showcase built from real captures
  ([`tools/make_showcase.py`](tools/make_showcase.py), `docs/showcase/`); move
  the milestone narrative to [docs/milestones.md](docs/milestones.md).
- Add [TODO.md](TODO.md): release blockers, quality, verification,
  compatibility, tech debt and ideas from archived branches.
- Retire merged branches; preserve the unmerged realism/accuracy branches as
  `archive/*` tags.

## Directional wheel soil

- Replace wheel mud/dirt blobs with two deterministic droplet/tapered-tail
  variants per material. Align the pattern to vehicle-relative travel with an
  upward component; faster travel lengthens/flattens it and reversing flips it.
- Keep one baked layer per deposit and existing caps/washing separation.
- 275 mock checks and preflight pass, including reverse-flow direction.
- Live forward mud driving produced 10 early and 22 late deposits, then stopped
  at 31 after braking. [Close-up](docs/evidence/directional-soil/mud-close.png)
  and [recorded state](docs/evidence/directional-soil/mud.json). Dirt/reverse live
  visuals remain unverified. Tails do not animate after deposition.

## Play-test scratch visibility adjustment

- Increase damage-stage opacity from 1 to 1.6 and remove the 0.75 diffuse
  multiplier on Police/dark plain paint; preserve the light-paint dark response.
- Leave original PBR/livery and washable soil stages unchanged.
- 271 mock checks and packaging preflight pass. Real Police sideslide: visible
  left fender/rear-quarter marks; white-door contrast remains a limitation.
- [Actual run and screenshots](docs/evidence/visibility/report.md). Single-run
  rendering verification only; this does not close performance acceptance gates.

## Milestone 5: performance investigation — merged as preview, gates open

- **Projection-free synthetic anchors (default).** Captured layers are anchored at
  their own detector contact point and hull-resolved normal instead of reading the
  anchor back from a native `projectDynamicDecals` pass (30 ms idle, 444–613 ms
  under load). `setSyntheticAnchors(false)` keeps the legacy path for comparison;
  `perf_candidate`/`perf_endurance` accept `--projected-anchors`. 271 mock checks.
- Full-detail Vulkan with every layer retained: native maximum 16.7 / 14.7 / 35.4 ms
  (process-cold, warm, ten-minute endurance), completed-layer age ≤318 ms. D3D12:
  delivery ≤600 ms, but 446/447 ms bake batches still fail the native gate.
  Intermittent ~410 ms Vulkan render-phase frame pauses remain and are recorded.
- New `perf_alloc_probe.py`: each baked layer makes the engine create and destroy
  ~112 MiB of full-target transient textures (three RGBA8, two R8 at 4096x2048);
  composites and projections allocate nothing. Likely trigger of the remaining
  paging stalls; not poolable from Lua. ETW tool gains a whole-frame trigger;
  `perf_endurance_summary.py` publishes long sessions compactly.
- Full-detail D3D12 functional suite passes with synthetic anchors (stock configs,
  lifecycle, traffic, maps, editor, guarded mud/water/drying with persistent scuffs).
  [Investigation 12](investigations/12-synthetic-anchors.md).
- Reuse private ETK projection resources and exact material indices across attachments;
  drain captured layers before further projection to prevent starvation.
- Add explicit 4096/2048/1024 damage widths and independent native bake batch limits.
  Default resolution is unchanged; separate soil and original material maps are untouched.
- Add opt-in same-panel grouping and representative footprint coalescing with explicit
  completed/merged/pending/lost request and proxy coverage accounting. Retain every
  stream layer when grouping; do not present representative brushes as pixel-equivalent.
- Correct sustained fixture velocity forcing, reject mid-run cosmetic resets, record
  queue ages and native outlier timestamps, and add continuous circular endurance.
- Fix merged stream segment aliasing that duplicated later bands in the first band's
  haze/path; count partial native capture loss and verify full-layer conservation.
- Repair identical ETK spawns whose cached construction bundle contained another
  vehicle's clone. Invalidate that cache before ETK construction, including background
  spawns (the retry-only approach was insufficient); this increases construction work.
  reclaim marked private materials only after their owner and all mesh references are gone.
- 264 mock checks pass. Historical 148-run cohort remains separately documented;
  new corrected-fixture cohorts, invalid old runs and traced diagnostics are distinguished.
- Capture a 426 ms native call with a correlated 423 ms graphics paging packet.
  WPR CPU profiling remains unavailable; no unsupported shader/driver attribution.
- Half-resolution grouping improves observed throughput but still reproduces native
  stalls (613 ms projection / 402 ms bake in untraced warm runs). Stable release and
  milestone 5 merge remain blocked; no milestone 6/public release.
  [Resumed implementation and evidence](investigations/11-quality-throughput.md).
- Final full-resolution Vulkan endurance retains all accepted layers but reproduces
  a 508 ms projection and a separate 965 ms frame pause / 1012 ms layer age. Both
  original performance gates remain failed. Guarded real washing preserves the
  same scratch generation; invalid transfer-reset fixtures remain disclosed.
- Final D3D12 warm regressions retain accepted full-detail layers and tracked
  half-detail representative coverage, but still reproduce 444/184 ms projections.
  Nine fresh Vulkan six-layer ablations improve observed drainage; they are not
  an endurance-qualified cure. A clean ten-minute disabled control peaks at 25.5 ms
  per frame and does not establish the cause of enabled outliers.

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
