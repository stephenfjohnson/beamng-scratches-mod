# Changelog

## Unreleased — underside, wheels, snow fling, ground transfer; README and docs split

Driven live on Vulkan, BeamNG 0.40.6.0: Gridmap mud strip, a simulated snow
drive (Gridmap has no snow), the bench sideslide and a new `bellyflop` scenario,
mostly on the Sunburst rally car, with wheel binding checked on eleven other
vehicles. Painter worst frame with all of it on: 5.4 ms (sideslide) and 5.8 ms
(bellyflop). On D3D12 the sideslide and the mud drive were run once each and
render the same; worst bake there 19.6 ms.

<!-- NEW-FEATURES-START -->
- **Snow fling.** Snow wheel deposits take the fling path with their own powder
  brushes (`soil_snow_fling_1..3`), with a packed patch at the arch every third
  deposit. `scratches_paint.setSoilExtras(underside, sills, snowFling)`.
- **Wheels and undercarriage.** New `wheelAdapter.lua`: per-vehicle clones of the
  tyre, rim and undercarriage materials (skid plates, suspension, exhaust, mud
  flaps, running boards) get a tiling soil stage whose strength follows what the
  wheels rolled through, tinted like the body soil; it washes off with the body.
  Rims and undercarriage also get an abrasion stage, driven by wheel-side scrapes
  and by belly contacts. `scratches_paint.setWheelDirt(false)` turns it off.
- **Underside.** Belly contacts form bottom-face patches with a shallow box, and
  low mechanical parts are accepted for underside contacts only
  (`setUndersideScrapes`). Soil is also projected up from below and, in deep mud
  or snow, laid in bands along the sills (`soil_*_band_*`). On the Sunburst the
  painted floor pan does not take canvas marks, so what shows underneath is the
  undercarriage overlay; belly scrapes have not been driven in game yet.
- **Ground transfer.** New `groundPaint.lua`: slide streams and ground impacts
  leave streaks on the road in the car's paint, then primer and metal as the
  scrape wears through; wheel-side scrapes leave dark marks. Up to 400 marks,
  fading after a few minutes. `scratches_paint.setGroundPaint(false)`.
- **Wet mud tone.** Terrain-sampled mud is darkened and browned (`soilColor.wetTone`);
  dry-ground colour was hard to see on bright paint.
- Underside soil is projected under the sills, not at the floor pan: a car's
  skin UV layout has no floor in it, so nothing showed there.
- Fixed after a six-way code review of the above: wheel clones were all
  reloaded on any change (13 to 16 ms frames; now one clone at a time, only the
  ones that changed); a car replaced in place kept the previous car's wheel
  materials; switching into a car rebuilt and repaired it; ground marks spent
  the whole ring on the end of a slide (now one streak per 0.2 m cell, 1200
  marks); wear ran to bare metal within a few frames; deep-soil sill bands
  landed on the wrong side; sill height was fixed at a saloon's.
<!-- NEW-FEATURES-END -->
- README rewritten as a short, image-led front page for players (hero, tour,
  three-step install, plain-language caveats). The technical content moved,
  unchanged apart from links, into [`docs/`](docs/README.md):
  [features](docs/features.md), [install](docs/install.md),
  [how it works](docs/how-it-works.md), [performance](docs/performance.md),
  [development](docs/development.md), [debug panel](docs/debug-panel.md) and
  [known issues](docs/known-issues.md).

## Unreleased — contact patches: realistic scrapes, no crash hitching (Vulkan)

Measured on BeamNG 0.40.6.0, Vulkan and D3D12
([numbers](docs/evidence/contact-patches/summary.json),
[investigation 13](investigations/13-contact-patches.md)). The wash cycle was
re-run on D3D12; snow and dirt have not been driven since these changes.

- New `patches.lua`: contacts fold into slide and impact patches, and each patch
  is baked as one decal sized to its extent. One sideslide bakes 47 layers
  instead of 301; the worst painter frame drops from 81.7 ms to 16.0 ms and the
  631 ms stall did not recur in eight runs.
- Brush textures: the engine keeps about two loaded and a reload costs time in
  proportion to pixel count. Brushes are now 512×256 (chips 256×256), the
  painter reuses the loaded brush for the next patch of the same kind, and a
  patch needing that brush may jump the queue by up to 0.35 s. Worst painter
  frame in a sideslide: 5–8 ms on Vulkan (six fresh-process runs), 10–15 ms on
  D3D12. The spawn-time warm-up stays for the one-time ~8 ms first load per file.
- **Mud and dirt fling.** Wheel deposits are fans thrown up and back from the
  rear of the tyre (`tools/generate_fling.py`), stepping through throw angles so
  a wheel builds a rooster tail; flatter and longer when faster. Replaces the
  horizontal splashes. Soil target raised to 2048×1024.
- Plain light paint shows exposed material at 0.46 grey (0.30 read as black);
  six scored-chip brushes instead of two.
- Checked on ten vehicles on Vulkan and six on D3D12: every clone preserves its
  original stages. `showcase_fleet.py --out` and timing columns.
- README showcase re-shot with the new look (hero, scrapes, impacts, livery,
  fleet grids, mud over scrapes, wash cycle); `tools/make_showcase.py` builds it
  from `docs/evidence/contact-patches/`.
- Not fixed: about one painted crash in ten has a single 0.3–0.6 s frame with no
  painter time in it (both renderers); D3D12 still has its occasional ~310 ms bake.
- New `w2_*` brushes from `tools/generate_wear.py`: three slide tiers and three
  chip tiers plus scored chips, with metallic and roughness maps from tier 2.
- Damage stage reads per-pixel metallic and roughness from the decals, uses
  opacity factor 1 (1.6 overshot the layer blend), and adds static abrasion
  relief and paint-speck break-up detail maps. Soil stage is unchanged.
- Detector sends the slip velocity with each impact so glancing hits are scored
  along it.
- `setContactPatches(false)` keeps the previous pipeline; 394 mock checks.

## v0.2.0-preview — 2026-11-15: material-preserving adapter for every vehicle

ZIP-only install, crash, mud and uninstall tested in game
([record](docs/evidence/release-v0.2.0/README.md)).

- Replace the ETK-only adapter with `bodyAdapter.lua`. Body materials are found
  the way the game does (mesh keys with a Dynamic Textures variant in the
  vehicle's own folder), and sources resolve through `mapTo` and the chosen
  skin, like the renderer. Clones get damage and soil stages after 1–2 original
  stages. Non-PBR or full materials, foreign overrides and editor designs are skipped.
- 38/38 stock Dynamic Textures vehicles attach, including every factory livery
  and the default ETK Rennspecht livery (previously skipped).
- Ten-vehicle crash validation across six paint colours and four liveries:
  original stages identical on every clone. New `tools/adapter_survey.py`,
  `tools/showcase_fleet.py` and fleet gallery images.
- 375 mock checks (generic discovery, name/mapTo trap, skin fallback, one-stage
  materials, rejection paths, cleanup of old ETK clones).
- Known cost: ~+180 ms per supported vehicle spawn from JBeam cache invalidation.

## v0.1.0-preview — 2026-11-15

First public download, a development preview for the ETK 800 (plain paint or
stock Police livery) on BeamNG.drive 0.40.5.0.

- MIT license, shipped in the ZIP. The packager now writes a `.sha256` next to it.
- ZIP-only install and uninstall tested in game
  ([record](docs/evidence/release-v0.1.0/README.md)).
- New HUD-free impact close-up and debug-panel screenshots
  (`tools/showcase_capture.py`).
- Repository history slimmed from 1.27 GB to 435 MB; raw milestone 5 runs now
  live in the `evidence-milestone5` release.
- Known limits: D3D12 bake stalls, ETK-only livery preservation. See [TODO.md](TODO.md).

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
