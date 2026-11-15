# Milestone 5 continued: projection-free synthetic anchors

Continues [investigation 11](11-quality-throughput.md) from candidate `17d74a3`.
Its acceptance thresholds are reused unchanged: every native projection/bake call
or batch <=100 ms, oldest GE-admitted input to completed layer <=1000 ms, all
accepted layers retained, no queue/capture losses, original material/livery/soil/
editor isolation preserved. No subagents, no milestone 6, no release publishing.

## New diagnosis: the stalling call only supplies an anchor

Every remaining native stall above 100 ms on the final candidate was inside
`DecalProjection:projectDynamicDecals` (508 ms Vulkan endurance, 444 ms D3D12 warm,
613 ms half-detail warm; the D3D12 ETW trace correlated one 426 ms instance with a
423 ms paging packet). Earlier work reduced how often it ran (grouping, budgets,
resolution) but kept it in the path for every job. The question that had not been
answered is *what the pass contributes to a baked layer*.

Reading the installed `editor/api/dynamicDecals.lua` showed that saved skin
projects rebuild and bake decal layers purely from serialized fields
(`decalPos`, `decalNorm`, `camPosition`, `worldToViewToScreen`,
`cursorPosScreenUv`, scale, rotation, textures), with no projection pass.
Investigation 01 had noted "construct decalData directly ... needs probing"; it
was never probed.

In-game probes on a fresh Vulkan process (BeamNG.drive 0.40.5.0, ETK800 Police,
private damage target):

| Observation | Result |
| --- | --- |
| `projectDynamicDecals` on an idle, undamaged car | 29.6-36.3 ms per call |
| `getDecalData` (camera matrices, cursor, style snapshot) | 0.02-0.09 ms |
| Fields that change with the camera passed to `getDecalData` | `camPosition`, `worldToViewToScreen`, cursor; computed on the CPU |
| Fields that only change after a projection | `decalPos`, `decalNorm`, `surfaceNormal` (the readback hit) |
| `setDecalLocalPos(layer, p)` | moves cursor and `zBufferDepth`; never re-reads `decalPos` |
| Layer captured with no projection (stale hit from another camera) | painted at the stale hit, not at its own cursor |
| Same layer with `decalPos`/`decalNorm` set in Lua | painted at its own position, on either side of the car |
| Anchor moved -15, -8, -3, +3, +8, +15 cm along the normal | six identical, correctly placed marks |

The consistent model: the bake places each decal where the camera ray through its
cursor meets the plane (`decalPos`, `decalNorm`), oriented to that normal. The
projection is a GPU render plus readback whose only output the painter uses is that
plane. The painter already shared one centroid hit across every stamp in a cluster,
so per-stamp anchors from the detector are no less exact than the old path. (A
debugging note for future probes: the private material takes damage opacity from
the canvas red channel, so pure green/blue/cyan test decals are invisible.)

## Implementation

`setSyntheticAnchors(true)` (default) skips `projectDynamicDecals` in both cluster
and stream jobs. Each captured layer keeps its CPU camera/cursor data and is
anchored at its own contact point: discrete stamps at the stamp's local position,
stream haze/segments at their segment centres. The normal is the detector's contact
normal with its sign resolved against the owning hull face (collision normals can
point into the car), falling back to the hull axis when it grazes the face by more
than about 70 degrees. The transient soil-preview flush is skipped because no
preview pass runs. `setSyntheticAnchors(false)` restores the legacy projected path
for comparison; `perf_candidate.py`/`perf_endurance.py` accept `--projected-anchors`.

Nothing is dropped, merged or delayed to achieve this: the same jobs, budgets,
grouping and layer accounting run, and `getStats().anchors.synthesized` counts every
anchored layer. Tools now treat capture jobs (`stamp.projectsIssued`) plus baked
layers as evidence of contact work, since `perf.projectCalls` is zero by design.

Tradeoffs: the anchor normal comes from physics contact data, not the rendered
mesh normal, so marks on strongly curved or deformed panels can be oriented a few
degrees differently from the legacy path. Node positions are not exactly on the
visual mesh; the measured +-15 cm anchor tolerance covers that offset in tested
contacts, not every possible part geometry.

Mock preflight: **271 checks** (seven new: default mode, no native projection,
every layer captured and anchored, inward normals flipped, own-contact anchoring,
legacy mode still selectable).

## Measurements (untraced, product preset)

Preset for every cohort: 4096x2048 private damage target, bake3, flush 0.05 s,
panel grouping on, representative coalescing **off** (every accepted layer kept),
synthetic anchors on. Same sideslide / roofdrop / sustained v2 fixtures and gates
as investigation 11. "Native" is the largest timed projection or bake batch; with
synthetic anchors it is always a bake batch. Each value is the worst run in the
cohort, not an average. Raw results, captures and mounted-source hashes are linked.

| Cohort | Fixtures | Native max | Completed-layer age max | Worst frame (phase) | Layers baked / lost |
| --- | ---: | ---: | ---: | --- | --- |
| [Vulkan process-cold x3](../docs/evidence/milestone5/synth-full-vk-cold) | 9 | **16.7 ms** | 316 ms | 417.7 ms (OtherRender 406) | 2,560 / 0 |
| [Vulkan warm](../docs/evidence/milestone5/synth-full-vk-warm2) | 9 | **14.7 ms** | 306 ms | 414.0 ms (RenderShadows 404) | 3,187 / 0 |
| [Vulkan 10-min endurance](../docs/evidence/milestone5/synth-full-vk-endurance) | 39 / 605 s | **35.4 ms** | 318 ms | 248.2 ms (FramePresent 242) | all / 0 |
| [D3D12 process-cold x3](../docs/evidence/milestone5/synth-full-d3d12-cold) | 9 | **31.7 ms** | 525 ms | 53.8 ms | all / 0 |
| [D3D12 warm](../docs/evidence/milestone5/synth-full-d3d12-warm) | 9 | **446.0 ms** (1 of 114 batches) | 600 ms | 455.6 ms (Lua) | all / 0 |
| [D3D12 10-min endurance](../docs/evidence/milestone5/synth-full-d3d12-endurance) | 39 / 604 s | **447.2 ms** (and 200.5) | 551 ms | 456.6 ms | all / 0 |

Matched prior projected-anchor results (same preset, candidate `219f8b0`):
Vulkan cold 60.8 ms, warm 37.8 ms, endurance **508.5 ms** native and **1012 ms**
completed-layer age (fail); D3D12 warm **443.8 ms** native (fail).

Every synthetic fixture had zero native projection calls, conservation
`stampsAttempted == stampsEnqueued == baked - stream` and expected == captured
stream layers, zero aggregate/job drops, capture misses, failed jobs or failed
bakes, and empty final queues. Process-private memory: Vulkan 7.69 -> 9.15 peak ->
7.94 GiB after collection; D3D12 7.67 -> 10.16 -> 7.65 GiB.

Genuine matched captures (`sideslide/`, `roofdrop/`, `sustained/` in each cohort
with damaged / original-stages / reset images) show the same gray chip and scrape
placement as the projected build on the fender, rocker and rear quarter, with the
Police artwork and original material fields unchanged. Roof-drop marks are as
subtle as in the projected captures. Physics contacts vary run to run; these are
matched within each set, not pixel replays across builds.

A first Vulkan warm cohort is retained as **invalid** (operator error: the in-game
bench file was edited and redeployed mid-cohort, and the sixth fixture returned an
empty result). Its five completed fixtures are not counted.

## What remains: per-layer allocation churn inside the native bake

Synthetic anchors eliminated the projection stall class and the 30 ms per-job
projection cost. They did not eliminate an intermittent ~400-450 ms graphics stall:

* On Vulkan it now appears only as a whole-frame pause in an engine render phase
  (OtherRender, RenderShadows or FramePresent), never inside a mod call: two
  ~410 ms frames in 18 cold/warm fixtures, three 186-248 ms frames in the endurance.
* On D3D12 the bake call blocks: one 446 ms batch in nine warm fixtures, 200.5
  and 447.2 ms batches plus four 280-420 ms frame pauses in the endurance.

Scanning all retained Vulkan evidence, every OtherRender pause above 100 ms
(393-924 ms, projected and synthetic builds) occurred within 0.4 s of mod GPU work
and none appeared in painting-disabled controls. VRAM use was 13.2 of 24 GiB, so
this is not ordinary budget eviction.

New evidence: the earlier D3D12 ETW window around the 426 ms projection contained
15 full-target RGBA8 and 10 full-target R8 texture creations in about half a second.
[`tools/perf_alloc_probe.py`](../tools/perf_alloc_probe.py) then isolated each
native call type on a parked car ([counts](../docs/evidence/milestone5/synth-alloc-d3d12)):

| 20 calls of | Direct3D12 resources created by the game |
| --- | --- |
| `combineTextures` | nothing beyond the idle UI baseline |
| `bakeLayers`, 1 layer | 60 x 4096x2048 RGBA8, 40 x 4096x2048 R8, 20 x 256 B, 8 x 32 MiB buffers |
| `bakeLayers`, 3 layers | 180 RGBA8 + 120 R8 full-size: per **layer**, not per call |
| `projectDynamicDecals` (after the 3-layer loop) | none; blocked >30 s behind 300 deferred destroys |

Each baked layer creates and destroys three full-target RGBA8 and two full-target
R8 textures, about 112 MiB at 4096x2048, inside the native call. Sustained scraping
bakes ~15 layers per second, roughly 1.7 GiB/s of transient allocation churn. The
traced 423 ms stall was a kernel paging packet. Together these support (but do not
prove) the mechanism: transient allocation churn in the engine bake occasionally
produces a long paging operation, which blocks whichever call or render phase next
synchronizes with the GPU. D3D12 bakes themselves synchronize (25-35 ms per
3-layer batch versus 5-15 ms on Vulkan), so the stall lands inside them.

Earlier half- and quarter-resolution cohorts (386-613 ms stalls) are consistent
with frequency depending on allocation **count** rather than size. Batch size cannot
help (churn is per layer). Reducing layers reduces work, not the existence of the
event; the Lua API exposes no pooling, allocator or asynchronous bake. The engine-
side remedy is to reuse the bake's transient render targets across layers/calls.

## Acceptance ledger (gates unchanged)

| Requirement | Vulkan (synthetic) | D3D12 (synthetic) |
| --- | --- | --- |
| Every native call/batch <=100 ms | **Pass** in 57 untraced fixtures (max 35.4 ms) | **Fail** (446.0 / 447.2 ms bake batches) |
| Oldest input to completed layer <=1000 ms | **Pass** (max 318 ms) | **Pass** (max 600 ms) |
| Accepted layers retained, no backlog/miss | Pass | Pass |
| Whole-frame tails (recorded, not a gate) | ~410 ms render-phase pauses in 2 of 18 short fixtures; none above 250 ms in 39 endurance fixtures | 280-456 ms pauses |
| Original materials/livery, soil, editor isolation | see functional suite below | see functional suite below |
| Multi-hour resource qualification | see long session below | not run |
