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
system performance." WPR reports no recording. No ETL was produced. Installed
Optick attempts in investigation 10 also produced no usable file. Native GPU wait,
shader and allocation attribution remains unavailable, not inferred as fact.


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
