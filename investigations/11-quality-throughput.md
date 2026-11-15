# Milestone 5 resumed: quality, native batching and coverage throughput

Resumed in the same thread from f414136, under explicit user authorization.
No milestone 6, public release or subagents. Investigation 10 is the prior run's
blocked verdict, not a reason to stop this implementation.

## Candidate acceptance, before final selection

The existing 100 ms native-call blocker remains. Reduced damage resolution may
be an explicit, documented quality preset; original PBR/livery and separate soil
must remain unchanged. Matched genuine collision captures must show representative
scrape/chip coverage, not simply fewer marks. Whole-frame p95/p99/worst and native
stages are recorded separately, without GPU/shader attribution from wall timers.

For a selected throughput candidate: no queue-cap losses or failed representatives,
no unrepresented footprint-proxy cells at completion, no tracking overflow, and
oldest completed-layer input age at most 1 second in repeated sustained tests.
This is an explicit visual-latency ceiling, not a claim that every mark is immediate.
Queue ages and completed-layer age maxima accompany drain time. Coverage proxies
are necessary diagnostics, not proof of pixel equivalence or visual quality.
Existing detector limits/spot saturation and stream shaping remain disclosed.

Repeat warm and fresh-process trials, then same-process endurance without painter
reload. Preserve failures and source/settings records. A physically unstable
fixture is an invalid throughput acceptance run and must not be counted as a pass.

## Implementation under evaluation

- Explicit 4096x2048, 2048x1024 and 1024x512 private damage resolution settings.
  Changing resolution clears cosmetics; it never changes original material maps
  or the independent 1024x512 soil target. Defaults remain 4096 until selection.
- Independently adjustable native bake layer count (1 through 24), distinct from
  the projection layer cap. Input-to-project, input-to-bake and oldest queued wall
  ages are retained. No native call can be interrupted by a Lua budget.
- Optional discrete damage coalescing before the aggregate cap. A new mark is
  represented by an existing queued/baked mark only when its circular footprint
  fits inside that mark, normals agree and brush family/severity tier match.
  This is a representative-quality policy, not identical random brush compositing.
  New area, stronger severity and opposing panels retain separate work. Soil
  bypasses the policy. Streams retain their existing path/spot rules.
- Explicit request ledger: new representatives, queued/baked merges, stale queued
  merges, completed/pending/lost requests, failed representatives, required and
  delivered 8 cm dominant-plane footprint proxy cells. Failed work cannot suppress
  retries. History is bounded to 8192 representatives; cell accounting has an
  explicit overflow counter at 65536. Reset/switch clears this cosmetic history.

## Early observations (not final acceptance)

At the same 4K D3D12 settings, first full-resolution sustained repeat reproduced a
447 ms bake batch and over 5.5 seconds completed-layer age. Half resolution with
six layers reduced observed bake peaks to about 24 ms, but still lost aggregate
inputs; one-layer batches reduced typical peaks further but could delay output by
multiple seconds. Quarter resolution did not alone remove queue loss/latency.

Two coalesced sustained trials hit BeamNG's vehicle-physics instability and lost
the player car. Their errors are retained. One also measured a 668 ms bake batch
at half resolution / three layers. The ground-height ray check along the fixture
path was flat at z=100; no cause of the physics instability is established.
Fresh-process repetitions are in progress.

The initial quality-sweep matched captures left the car rolled over and do not
adequately establish scraped-panel fidelity. The corrected candidate capture
sequence uses the bench's existing upright-without-repair step. The half-resolution
Police damaged/original pair shows visible scuffs and unchanged Police artwork;
additional plain/roof and selected-candidate captures remain required.

Windows Performance Recorder 10.0.26100 is installed. Both GPU+GeneralProfile and
GPU-only attempts failed with **0xc5585011**, "Failed to enable the policy to profile
system performance." WPR reports no recording. That WPR attempt produced no ETL. A later user-provider ETW capture succeeded (below). Installed
Optick attempts in investigation 10 also produced no usable file. CPU stacks and native GPU-command attribution remain unavailable; the later trace provides narrower paging evidence.


## Stress-fixture correction

Inspection found that the old sustained fixture used
`applyClusterVelocityScaleAdd(ref, 0, vx, vy, currentVz)` every render frame.
The zero scale discards internal node velocities. Two fresh-process repeats also
failed/reset under this fixture, so it cannot serve as reliable long-duration
acceptance evidence. Historical native-call stalls remain real measurements;
its throughput/contact rates are an artificial, potentially unstable stress load.

Fixture v2 instead uses scale 1 with only the horizontal velocity delta, preserving
internal deformation and vertical motion. Both full-resolution control and quality
candidate are rerun with v2. This is a fixture correction, not a relaxation of the
native-call/coverage gates. The bench now records cosmetic generations, preserves
the last valid painter snapshot and rejects a reset during the measured window.
Per-frame coverage counters expose progress before a failed/reset run; a cleared
queue is no longer mistaken for successful delivery. Old resumed cold run 1 had
zero final coverage/detector counters after work, so it is invalid despite lacking
an old bench error flag. Its raw data remains unchanged.


## Native resource trace obtained during resumed implementation

`tools/perf_trace.py` uses a 128 MiB circular user-provider ETW session without
requesting elevation. D3D12 mask 0x484, DXGI 0x2, Direct3DShaderCache 0xf and
DxgKrnl 0x80c1 are recorded. WPR system CPU profiling still lacks permission.
Trace runs are explicitly diagnostic and excluded from untraced acceptance.

Third diagnostic sustained run captured **425.9219 ms** inside native projection.
The engine clock was aligned to host UTC with approximately +/-2.47 ms initial
round-trip uncertainty. Game-owned D3D12 event streams pause for about 423 ms.
DxgKrnl PagingQueuePacket sequence 29480 is submitted 2.30 ms after call start
and completes 424.94 ms after call start, about 1 ms before projection returns.
Its queue-to-complete interval is **422.64 ms**. A 256-byte default-heap buffer
creation is also recorded near the pause start; it is not the damage texture.
This supports a graphics-resource/paging delay correlated with this stall,
not a proven driver/engine root cause or evidence of a 423 ms GPU draw.
The native API remains synchronous and exposes no asynchronous completion handle
or cancellation mechanism to this scheduler.

No selected shader-cache or pipeline-state-create events occur in this window;
that absence does not exclude shader work. The recorded packet's numeric
VidMmOpType 113 is not assigned an undocumented interpretation. No CPU wait stacks
were collected. The system-wide ETL stays local (128 MiB; SHA256 in trace.json).
[Sanitized owned-process events](../docs/evidence/milestone5/resumed-native-ring/stall-owned-events.json)
and [analysis/limits](../docs/evidence/milestone5/resumed-native-ring/stall-analysis.json)
are retained with the raw mod timings. Graphics addresses and unrelated processes
are omitted from the public export. Half resolution did not prevent this stall.

## Grouping and continuous-session fixture

Optional panel grouping retains every accepted layer while combining nearby
same-facing discrete jobs (maximum 24 layers) and up to six stream bands per
shared projection camera. Camera distance expands with the group. It reduces
projection passes without describing discarded inputs as equivalent coverage.
Discrete representative coalescing remains separately counted and optional.

The endurance tool now supports one continuous 25 m radius assisted roof scrape,
with additive horizontal velocity correction, preserving internal/vertical node
motion. It does not reset the car or painter during the measured interval.
Repeated-fixture endurance remains available and is labeled separately. Native
process-memory sampling replaces spawning PowerShell inside measured windows.
Any automatic reset, missing car, residual work or lost coverage fails acceptance.


## Evidence cohort boundaries

The `resumed-full-b6`, `resumed-half-b6`, `resumed-half-b1`, quarter-b1 and early
coalesced cohorts use the old v1 sustained forcing. Their side/drop fixtures are
unchanged, but their sustained throughput is **not acceptance evidence**. The
misleadingly named `resumed-half-b1-fast-cold-v2` also predates the actual fixture
correction: repeat 1 reset its counters and repeat 2 lost the car. Both are invalid.
No raw results were rewritten to hide that mistake.

`resumed-v2-full-control` and `resumed-v2-half-b3` are the first corrected sustained
comparisons. `resumed-grouped-half-warm` ran during an ETW diagnostic and is excluded
from untraced acceptance, as is `resumed-native-ring`. The separate
`resumed-grouped-half-untraced` cohort uses the grouped candidate with no ETW session.
It reproduced 613 ms projection and 402 ms bake stalls while completing all tracked
requests, with no queue-cap drops or uncovered footprint-proxy cells.

The 25 m circular attempt was stopped at 235.5 seconds after the car rolled upright.
It is retained as `resumed-half-circle-d3d12`, with an error and full up-vector/activity
samples. It is **not** ten-minute continuous-scrape acceptance. Later tooling rejects
more than five seconds upright automatically. Repeated fresh-contact endurance
resets the vehicle between fixtures but keeps the same game process and painter.
This distinction is explicit; no idle tail is sold as sustained projection load.

The resumed report separates per-frame accumulated projection/bake distributions
(all frames and active frames) from exact individual-call maxima. Completed-layer
age is conservative and cannot certify individual pixel appearance time. Coverage
coalescing applies to discrete inputs; existing stream path shaping, detector caps
and spot saturation remain outside that proxy and are reported separately.

Static review also found that a thrown native bake had already removed its layers
from the queue without resolving their coverage ledger. The new failure path logs
and counts the failed batch/layers, marks requests lost and permits later work.
It does not retry a potentially partially composited batch. A mock native exception
verifies failure accounting and subsequent recovery. Explicit custom color/alpha/
rotation/material overrides no longer share a procedural representative. Bounded
history/coverage overflow tests exercise 8200 representatives. **256 mock checks**
pass; these checks do not waive native/visual acceptance.

Native-call histograms added for the subsequent selected/control cohorts report
p95/p99 upper bin bounds (0.1 ms through 100 ms, 1 ms through 1000 ms, explicit
overflow above 1000 ms) plus exact worst and call counts. Bake timing is the entire
batch, including both native calls when damage and soil share a chunk. The histogram
is bounded and read at run completion, not copied/scanned every render frame.
Earlier cohorts retain per-frame stage distributions and exact native maxima only.

First corrected D3D12 repeated-fixture endurance: 39 fixtures over 606 seconds,
no tracked lost requests, maximum completed-layer input age 656.5 ms. Native
projection/bake peak **411.3 ms**, so the unchanged 100 ms gate fails. Process-private
memory sampled 7.33–8.18 GiB and returned to 7.37 GiB after collection. These are
whole-process samples, not a proof of native/GPU allocation bounds. This cohort
predates the later custom-style/native-failure accounting hardening and call
histograms; its mounted runtime hashes are retained. Subsequent cold/renderer
cohorts exercise the hardened implementation.

The old quarter-b1 sideslide had zero detector contacts and zero projections. It
is not a performance/quality pass; the resumed runner now rejects an enabled
damage fixture that produces no contact/projection work. New quarter-resolution
repeats explicitly re-enable paint submission and retain genuine captures.

The first one-variable side-slide ablations (unchanged side-slide fixture) measured:
full4096/bake6 mean batch 31.93 ms, peak47.34 ms, age826 ms; half2048/bake6 mean10.73 ms,
peak23.83 ms, age872 ms; half2048/bake1 mean1.00 ms, peak5.34 ms, age3123 ms.
These are single early exploratory runs with different actual contact counts
(309/385/467 layers), not repeat-confirmed equal-load comparisons. They explain
why a one-layer budget was rejected despite lower call cost. The selected bundle
combines half resolution, three layers, faster flushing and grouping; its gains
cannot all be attributed to resolution alone. Full-resolution controls in the
resumed cohort use the M5 resource/scheduler fixes, not the untouched M4 binary.

The D3D12 half-resolution candidate completed three fresh-process sets (nine
fixtures) without queue loss; their observed native maximum was 37.3 ms and
completed-layer age maximum 271 ms. This favorable cold cohort does not supersede
613 ms warm / 411 ms endurance stalls. Quarter-resolution grouped repeats still
reproduced a **386 ms** native stall, with visibly softer small scuffs. The matched
original-stage/reset pair retains the source body and Police artwork. Across runs,
physics contacts, brush variants and cloud reflections vary; images are matched
within each damaged/original/reset set, not pixel-identical across resolutions.

D3D12 painting-disabled controls: three warm sets and three fresh-process sets,
sustained plus coasting baseline, six fixtures each. Observed worst frames were
21.1 ms warm and 20.0 ms cold. They keep the detector/adapter loaded and the full
resolution target, disabling paint submission; this is not a clean-uninstall
comparison or proof that the whole engine never stalls.

All stage timings are main-thread elapsed intervals. In particular, short Vulkan
bake calls can defer work to later synchronization and do not establish lower
GPU execution cost. Whole-frame tails accompany the call histograms. The retained
ETW evidence is a D3D12 paging correlation, not Vulkan or shader root-cause proof.

## Full-resolution candidate criteria before its new trials

The corrected Vulkan full-resolution control still reached 1106 ms completed-layer
age in one side slide. A new full-resolution candidate therefore uses bake3,
flush0.05 and panel grouping, **without representative coalescing**. The test asks
whether scheduling/grouping can preserve every accepted brush layer and full detail
while meeting the same 100 ms native / 1000 ms completed-layer age gates.

For this no-coalescing candidate, request conservation replaces the representative
proxy ledger: in dry collision fixtures, require `stampsAttempted == stampsEnqueued
== bakeLayersTotal - streamSubstrokesTotal`, empty queues, and zero aggregate/job
drops, job/bake failures, lost layers or missed stamps. All accepted discrete and
stream layers must reach successful native batches. No represented requests are
substituted or silently counted as retained. Existing detector and spot saturation
still apply upstream and remain disclosed. Genuine captures are required because
layer submission alone does not prove visible geometry/pixel coverage. This is a
stricter retention alternative, not a relaxed native/latency gate.

Before the full-resolution/no-coalescing trials, stream capture accounting was
strengthened: expected layers (one underlay per accepted band plus each shaped
segment) and missed layers are now counted even if only part of a stream fails.
A simulated nil native layer verifies that partial loss is reported while the
valid remainder bakes. Full retention additionally requires expected stream layers
to equal captured stream layers. Earlier half-resolution runs lack this new
partial-stream diagnostic; their zero discrete proxy loss must not be presented
as proof of every stream layer. This revision adds counters, not a rendering or
scheduler behavior change. Current preflight: **256 mock checks**.

## Further retention and lifecycle findings

The first full4096/bake3/grouped/no-coalescing warm cohort exposed an existing
stream table alias: the first band and the aggregate budget list shared the same
segments array. Merging another band appended its segments to both, duplicating
those layers and stretching the first haze. Expected-versus-captured counters
exposed this (222 expected versus 237 captured in one sustained run). This is
extra, incorrectly styled coverage, not missing work. Separate segment arrays
now preserve each band exactly; a two-band regression requires exactly four
layers (two hazes and two segments). That first cohort is diagnostic for retention;
new fixed cohorts are required. The code preflight now passes 258 mock checks.

A three-cycle material spawn/delete probe stayed at two live private materials,
but later new vehicle IDs referenced the earlier fixture's clone. Installed
loader.lua caches the Phase2-mutated bundle by configuration and skips Phase2 on
a cache hit. A readiness/isolation probe follows; bounded material counts alone
do not establish correct lifecycle behavior. No speculative deletion of a
material still referenced by a cached/live mesh is appropriate.

The readiness probe confirmed two of three subsequent identical ETK spawns were
skipped. The narrow existing one-shot construction retry now invokes the installed
loader public cache-invalidation entry point before reload. This invalidates the
whole JBeam construction cache on that exceptional retry (not per frame or every
spawn); it does not edit a config or share another vehicle's material. Editor
ownership blocks the operation. Five replacements then all became ready with
distinct clones. That exposed genuine material accumulation (3 to 8 after five
spawn/deletes). Deferred cleanup now deletes only explicitly marked mod-owned
materials whose owner and all mesh references are gone. It runs after destruction
or extension startup, pauses for editor ownership and prunes stale Lua records.
Five further replacements returned to the same count after every deletion. The
eight older unmarked materials in that process were deliberately not deleted;
a fresh process verifies clean lifetime bounds. Current preflight: 263 checks.

The subsequent warm readiness guard correctly stopped before measurement: an
original vehicle reload fetched a cached clone belonging to the last deleted
fixture. A dedicated background-spawn probe also showed two ETKs referencing
the same four-stage active clone after selecting one. Thus retry-only invalidation
was insufficient. The final fix uses the installed onSpawnCCallback, before loader
cache lookup, to invalidate construction data for ETK spawns/reloads, including
background vehicles. create also verifies actual mesh ownership even when Lua
prepared state exists. The repeated three-vehicle probe now has distinct clones
and only the selected player at four stages; both inactive vehicles stay at two.

Tradeoff: the installed public invalidation API clears the whole JBeam construction
cache. ETK construction therefore gives up cached bundle reuse and can make later
vehicle spawning/reloading more expensive. No engine functions are monkey-patched,
no config fields are added, and no cache operation runs during steady scraping.
Editor ownership blocks invalidation and cleanup. Multi-vehicle correctness takes
priority over a cached spawn optimization in this narrow development adapter.
The earlier nine fixed cold fixtures use identical stream/scheduler code but the
retry-only lifecycle revision; mounted hashes distinguish them. Final warm/cold/
endurance and functional cohorts below use the construction-hook revision.
Current preflight: 264 mock checks.

## Final-build native stall reproduced

The construction-hook build's three fresh Vulkan processes (nine fixtures) peaked
at 60.8 ms per native call; nine warm fixtures peaked at 37.8 ms. Endurance then
reproduced a **508.453 ms projection** in fixture 20, a roof impact, with a
**517.856 ms frame interval** and 600.775 ms maximum GE-input-to-completed-layer age.
[Exact run, call histogram summary and frame/phase samples](../docs/evidence/milestone5/resumed-fixed2-full-vulkan-endurance/20261114-202248_roofdrop_resumed-fixed2-full-vulkan-endurance_r20/result.json).
This is an untraced run on the final rendering/scheduler/lifecycle code, not a
historical version or a profiler-induced stall. The 100 ms native gate still fails.

That fixture's engine-reported Lua phase peaked at 510.8 ms, physics/VLua at
0.73 ms, Render at 2.86 ms, Present at 7.75 ms and WaitNextFrame below 0.004 ms.
The independently timed synchronous projection accounts for nearly all the long
Lua-phase interval; the largest bake batch was 5.96 ms. These elapsed phase
maxima may overlap or be offset by a frame, and do not identify CPU execution,
GPU execution or a wait stack. The D3D12 ETW paging correlation is separate
evidence and cannot be assigned as this untraced Vulkan stall's cause.

The available Lua interface offers synchronous projection and baking, with no
asynchronous submission/cancellation or allocator-control hook found. Scheduling
can limit calls and keep accepted work from becoming stale; it cannot interrupt
this native call. Smaller targets and layer batches reduce typical bake costs,
but none of the tested quality changes establishes a stall-free engine path.
Stable readiness and milestone 5 merge remain blocked, irrespective of check counts.

The completed 39-fixture session also failed the one-second delivery gate:
fixture 38 reached **1012.267 ms**, not rounded down to a pass. Its largest native
projection was only 36.66 ms and its largest bake batch 4.30 ms. A **965.070 ms
frame gap** coincided with an engine-reported **OtherRender peak of 923.715 ms**;
Lua peaked at 38.08 ms, LuaGC at 0.95 ms and physics at 0.20 ms. Immediately before
the gap, there were no queued projection jobs or captured bake layers, and pending
input age was only 14.65 ms. After the gap, six captured layers drained over two
three-layer batches, taking the oldest completed layer just past one second.
[Raw phase and queue history](../docs/evidence/milestone5/resumed-fixed2-full-vulkan-endurance/20261114-202728_roofdrop_resumed-fixed2-full-vulkan-endurance_r38/result.json).
This distinguishes the remaining engine-frame pause from a growing mod backlog;
it does not excuse the failed wall-latency gate or identify the render wait's cause.
A six-layer ablation follows to measure drain cost, not to claim a cure from a
run that simply does not reproduce this intermittent engine pause.

## Guarded functional and visual regression

The resumed full-detail Vulkan matrix completed exact stock 844 plain/Police
slides and captures, unsupported 854 Polizei/Heritage/unicycle and installed GT3
safe skips, 20 switches/10 vehicle reloads, five extension reloads, four real map
changes, editor sentinel preservation and three moving NPCs with zero detector
calls. Two identical background ETKs retain distinct clones with only the player
at four active stages. Ten additional spawn/delete cycles return to one private
material each time. [Current matrix](../docs/compatibility.md).

The first mud-transfer persistence fixture was invalid: raw placement at z=100.3
triggered an engine instability reset (generation 10 to 11), wiping the preceding
asphalt damage. A guarded all-cluster-placement retry also changed generation and
was rejected. Both failed attempts remain in evidence. The final helper uses
the installed `spawn.safeTeleport` with `resetVehicle=false`, and asserts unchanged
generation from the measured scrape through every water/drying/redirty snapshot.
Its horizontal assistance preserves internal and vertical velocity.

The Vulkan safe-placement retry retained generation 16 throughout, washed 27 mud
deposits to zero, returned wetness to zero with original material fields identical,
and admitted 27 fresh mud deposits. Dirty/dry/redirty captures show the original
gray side scuffs persisting while orange soil disappears and returns. No damage
layers were rebaked during the wash. The earlier state-only wash checks are not
presented as proof of original asphalt-scratch persistence.
[Guarded result and genuine captures](../docs/evidence/milestone5/resumed-full-vk-wash-safe).
