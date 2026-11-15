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
