# TODO

Open work for scratches_mod, swept on 2026-11-15. Everything that shipped is on
`master` and shown in the [README](README.md). This list holds what remains:
release blockers first, then quality, verification, compatibility, tech debt,
and the ideas still parked on archived branches.

Each item links the evidence or investigation it comes from, so nothing here
is a guess about current behavior.

## Release blockers

Milestone 5 (performance and compatibility) is merged as a development preview,
but its acceptance gates still fail on D3D12. Milestone 6 (public release) has
not started. See [the release plan](docs/plans/release-sequence.md).

- [ ] **D3D12 native bake stalls (446 / 447 ms).** Every baked layer makes the
  engine create and destroy ~112 MiB of full-resolution transient textures
  (three RGBA8 + two R8 at 4096×2048). On D3D12 the bake synchronizes, so an
  occasional paging stall lands inside it. Lua can't pool or defer it. Options:
  ask BeamNG to reuse bake render targets across layers; bake fewer layers per
  contact (the grouping/coalescing tradeoffs are measured in
  [investigation 11](investigations/11-quality-throughput.md)); or find another
  bake path. Evidence: [investigation 12](investigations/12-synthetic-anchors.md#what-remains-per-layer-allocation-churn-inside-the-native-bake).
- [ ] **Rare 0.3–0.6 s pauses with painting on.** Contact patches (2026-11-20)
  cut layers per crash about sixfold, but the pause still happens: on Vulkan
  562 ms (OtherRender) and 638 ms (UIpixelsToGPU) in 22 painted runs, plus one
  91 ms; none in six painting-off runs. On D3D12 one 319 ms frame in game Lua
  (the mod's ingest measures at most 0.3 ms). Not attributed. Next: a long
  alternating on/off session, and the same at 2048×1024 damage resolution
  ([investigation 13](investigations/13-contact-patches.md#rare-long-frames)).
- [ ] **Wash and snow after the stage change.** Mud fling was driven on both
  renderers; washing, snow and dirt were not, and soil is now 2048×1024.
- [ ] **One 31 ms bake** in the Vulkan Scintilla run (others peak at 5–9 ms). Not
  reproduced or explained.
- [ ] **Long-session qualification.** No multi-hour D3D12 run yet. The Vulkan
  functional suite (lifecycle, traffic, maps, editor, washing) hasn't been
  rerun on the synthetic-anchor build; only D3D12 was
  ([compatibility](docs/compatibility.md#synthetic-anchor-build-current)).
- [ ] **First mud contact hitch.** The first terrain-texture read for soil tint
  takes ~99 ms; cached lookups take ~0.03 ms. Pre-warm the cache on map load
  or move the first sample off the contact frame
  ([terrain color report](docs/evidence/terrain-color/report.md)).

## Showcase and release materials

- [x] ZIP-only install and uninstall in game, 2026-11-15
  ([test record](docs/evidence/release-v0.1.0/README.md)). Not yet repeated on a
  brand-new user folder or another machine.
- [x] MIT license (`LICENSE`, also shipped inside the ZIP).
- [x] v0.1.0-preview GitHub pre-release with `scratches_mod.zip` and its SHA-256.
- [x] Signed-out download of the release asset matches its SHA-256 (2026-11-15).
- [x] Impact close-up and debug-panel screenshot, captured HUD-free with
  [`tools/showcase_capture.py`](tools/showcase_capture.py).
- [ ] Re-shoot the older showcase images HUD-free with `showcase_capture.py`
  (they are still crops that work around the game HUD).
- [ ] Listing text and screenshots for the BeamNG mod repository.
- [x] The default ETK Rennspecht livery (and every other factory livery) is now
  supported, so a fresh install shows scratches immediately.
- [x] [v0.2.0-preview](https://github.com/stephenfjohnson/beamng-scratches-mod/releases/tag/v0.2.0-preview) with the generic adapter; ZIP-only install,
  crash and uninstall tested ([record](docs/evidence/release-v0.2.0/README.md)).

## Visual quality

- [ ] **Contrast on mixed liveries.** Scuffs across the white Police doors are
  still subtle ([visibility report](docs/evidence/visibility/report.md)).
- [x] **Metal glint.** The damage stage now takes metallic and roughness from
  the decals' own maps (the canvases as material properties, not as opacity
  masks, which is what milestone 4 rejected). Soft brush edges get a faint
  metallic fringe because the metallic canvas clears to 1.
- [ ] **Weak dark marks.** Damage opacity follows the canvas red channel, so
  near-black marks can't be drawn; contact-patch brushes are full red and vary
  only in tint, metal and roughness.
- [ ] **Slide patches fill between contact nodes.** A patch box covers recessed
  areas between the nodes that touched, and its decal is a straight band on a
  curved panel.
- [ ] **Crushed panels stay too clean.** Anchors use physics nodes, not the
  deformed visual mesh. On strongly curved or deformed panels, synthetic-anchor
  normals can be off by a few degrees.
- [ ] **Repeated silhouettes.** Brush repeats are reduced, not eliminated:
  eight slide and eight chip brushes, each mirrored at random.
- [ ] **No waterline.** Washing is a uniform fade, and a partial wash weakens new
  deposits until that soil cycle is fully removed
  ([investigation 8](investigations/08-water-washing.md)).
- [ ] **Fling is a placement rule.** Throw angle and length follow speed, but
  the wheel-arch lip, the mud flaps and wheelspin are ignored, and nothing lands
  on the car behind.
- [ ] **Static splashes.** Fling drops are baked art; they don't run or drip
  after landing.

## Needs live verification

- [ ] Terrain tint for **dirt and snow**, and on maps other than Gridmap v2.
  Only Gridmap mud has been checked.
- [ ] Dirt fling artwork and **reverse-direction** flings in game (mock-checked only).
- [ ] The legacy non-ETK Dynamic Textures path on 0.40.5.0.

## Compatibility

- [x] Livery support beyond the ETK 800 and Police, and every stock vehicle on
  the material-preserving adapter: generic `bodyAdapter.lua`, 38/38 stock
  Dynamic Textures vehicles attach ([survey](docs/evidence/adapter-survey/survey.json)),
  ten crash-tested with exact original-stage preservation
  ([fleet](docs/evidence/showcase/fleet/README.md)).
- [x] Mud driven live on a non-ETK vehicle (Covet, 26 deposits, terrain tint;
  [evidence](docs/evidence/release-v0.2.0/mud-covet/)).
- [ ] Drive snow and water washing live on non-ETK vehicles.
- [ ] Spawn cost: clearing the JBeam cache before every supported spawn adds
  ~180 ms (covet: ~850 vs ~710 ms), traffic included. Invalidate only when the
  same config is already cached with another vehicle's clones.
- [ ] Clones are made for every supported vehicle, including AI traffic that
  never gets painted. Measure material memory with heavy traffic.
- [ ] Mod vehicles: anything shipping `dynamicDecals/` materials should work,
  but none has been tested.
- [ ] Concurrent editor use on the legacy non-ETK path is unsupported.
- [ ] To keep private clones per vehicle, ETK construction invalidates the
  engine's JBeam bundle cache, which can slow spawns and reloads.
- [ ] Other BeamNG builds, GPUs and drivers are untested (tested: 0.40.5.0
  build 302427, RTX 3090).
- [ ] Decide whether marks should survive a vehicle switch. Today reset,
  switch, reload and editor use all clear cosmetic state.

## Tech debt

- [ ] **No CI.** The 358-check harness and preflight only run locally
  (`python tools/package.py`). A GitHub Action with Lua 5.1 would guard `master`.
- [ ] **`paint.lua` is near Lua's local limit.** About 3,500 lines and 163
  top-level locals; Lua 5.1 caps a function at 200. Split the scheduler, soil
  and debug panel into modules before it hits the cap.
- [x] **Repository weight.** History rewritten on 2026-11-15: raw milestone 5
  runs moved to the [evidence-milestone5 release](https://github.com/stephenfjohnson/beamng-scratches-mod/releases/tag/evidence-milestone5);
  the pack went from 1.27 GB to 435 MB.
- [ ] **Remaining weight** is ~300 MB of lossless 1080p PNG captures in
  milestones 2–4. Converting them to JPEG would cut most of it, at the cost of
  lossless evidence.
- [ ] **Long paths on Windows.** Some milestone 5 run folders exceed 260
  characters when cloned into a deep directory; enable `core.longpaths` or
  shorten run names.

## Ideas parked on archived branches

On 2026-11-15, four unmerged branches were retired and preserved as tags on
GitHub. Milestones 1 and 4 reviewed each of them and absorbed parts
selectively. Porting anything else means reworking it against the current
soil/water protocol and the material-preservation contract.

### [`archive/improve-wreck-scratches-dings`](https://github.com/stephenfjohnson/beamng-scratches-mod/tree/archive/improve-wreck-scratches-dings): material-aware damage (Oct 18)

Already absorbed: the nested-depth brush algorithm, now `tools/generate_damage.py`.

- [ ] **Surface-routed marks.** Guardrails, poles and other cars leave a zinc
  smear; gravel peppers chips; wood transfers bark; cones and tyres leave rubber.
- [ ] **METAL / PLASTIC panel routing.** Bumper covers stress-whiten down to
  black plastic and never show bare metal.
- [ ] **Force-tiered depth.** A light tap only scuffs, slides scale with peak
  force, and repeat passes dig deeper.
- Background: `investigations/04-crash-damage-realism.md`,
  `docs/plans/2026-10-18-material-aware-damage.md` and `tools/preview_brushes.py`
  on that tag.

### [`archive/mod-review-improvements`](https://github.com/stephenfjohnson/beamng-scratches-mod/tree/archive/mod-review-improvements): contact accuracy (Oct 28)

- [ ] **Node-anchored contacts.** Send the node id plus a local offset, then
  re-resolve the node just before baking so marks follow deformation.
  Synthetic anchors already place marks from detector contacts; this would
  add deformation tracking on top.
- [ ] **In-game accuracy suite** (`tools/test_accuracy.py`): fixed-config PNG
  fixtures and a nonzero exit code on failure.
- [ ] Re-arm impacts only after the contact separates.

### [`archive/council-crash-realism-loop`](https://github.com/stephenfjohnson/beamng-scratches-mod/tree/archive/council-crash-realism-loop): realism rework (Nov 5)

A two-model review loop scored this rework 5.5–6 / 10. Its handoff is at
`docs/plans/2026-11-05-realism-council-handoff.md` on the tag.

- [ ] **Impact composition by contact angle.** Glancing hits give abrasion,
  streaks and torn gouges; square-on hits give crush scuffs.
- [ ] **Car-on-car contact with paint transfer.**
- [ ] **Micro-scratch detail and metal glint** through a damage-layer
  roughness/metallic split. As written, it rewrites factory materials, so it
  needs a preserving variant.
- [ ] **The council's open gaps.** A bollard clip yields only 1–4 contacts, so
  corner scuffs are thin; crease scuffing is missing; bands still look stamped.

### `archive/master-wip-2026-10-18`

A September WIP snapshot, superseded by the merged performance rework. Nothing
to port.

## Decided against (don't redo)

- **Deformation-tier skin-node scanner.** It was built and removed in May 2026
  because it stamped panels that never took a collision. The pipeline is
  intentionally collision-driven: impacts, slide streams and wheel soil.
- **Roughness-mask and metallic-mask damage stages.** Rejected in milestone 4
  ([evidence](docs/evidence/milestone4/rejected-roughness-mask/)).
- **Rewriting factory materials or flattening liveries into the canvas.** This
  breaks the paint and livery preservation contract.
- **Native projection for anchors.** Replaced by synthetic anchors. The legacy
  path stays behind `setSyntheticAnchors(false)` only for comparison.
