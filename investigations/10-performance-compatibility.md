# Milestone 5: performance and compatibility investigation

Started from c8bcae6. Milestone 6/public release is excluded.

## Acceptance criteria (set before tuning)

- Repeat enabled and painting-disabled identical physics scenarios at least three
  times warm and across fresh processes. Preserve raw frame samples, p95/p99/max,
  native projection/bake maxima, failures, drops and remaining queues. Process-cold
  is not shader-cache-cold; do not delete user caches to manufacture cold results.
- Native calls above 100 ms remain a stable-release blocker. A scheduler cannot
  preempt one native call. No favorable average or mock count waives this gate.
- Preserve full-resolution damage, private ETK source channels, Police lettering,
  separate removable soil, lasting scratches and editor isolation; review captures.
- Repeated reset/switch/reload/map tests must stay ready without stale references;
  inactive vehicles must not acquire marks. Record resource samples over sustained
  work; bounded Lua queues alone do not prove bounded native/GPU resources.
- Record exact installed build, renderer, config and settings. D3D12 and Vulkan
  require separate evidence. Unsupported vehicles remain unverified or skipped,
  not implicitly supported. No claim about all hardware FPS.

Results and remaining gates will be appended after experiments. Milestone 5 and
stable-release readiness are not yet accepted.


## Reproduced native stall and diagnostic boundary

Original-code fresh-process D3D12 repeat 2, roofdrop:
`original-d3d12-cold/20261114-164346_roofdrop_original-d3d12-cold_r2`.
One `projectDynamicDecals` call took **652.4749 ms**, with a **663.8656 ms**
whole frame. Before that sample, aggregate projection time was already 159.7567 ms:
this was not simply the first projection after launch. Queued captured layers
went 0, 1, 0 around the stall; queued jobs were zero in all three samples.
The following engine metrics row reports Lua 654.5434 ms, consistent with the
metrics API's one-frame delay. LuaGC was approximately 0.06-0.08 ms; sampled
physics and renderer CPU sections were small. No growing Lua backlog explains
this event. This localizes the wait inside native projection, **not** its C++
root cause: these main-thread elapsed timers cannot distinguish GPU synchronization, driver
allocation, shader work or native resource contention. No GPU trace attribution
is claimed, and no shader cache was purged.

## Candidate changes

- Reuse the private installed Dynamic Decals API/projection across ETK
  attachments within one painter instance, retaining 4096x2048 damage resolution.
  Rebind the new shape before clearing/selecting its exact material indices.
  The independent 1024x512 soil target remains reusable. Extension reload still
  constructs a new instance; no unsafe native destructor or shared editor cache
  is introduced.
- Drain captured layers before issuing another projection batch. Previously a
  frame longer than the flush interval could repeatedly prioritize projection
  over baking. The new slow-frame mock fails on c8bcae6 and passes on the
  candidate. Count budgets, brush quality and source material fields are retained.
- Add frame-by-frame cumulative projection/bake timings and queue depths to the
  developer bench, plus repeatable process-cold and lifecycle probes.

The first candidate matched Police capture preserves lettering, visible side
scuffs and original-stage fields. This is visual verification, not proof that
native stalls are fixed. Original lifecycle: 20 player switches and 10 vehicle
reloads retained ready status; memory fluctuated and returned after collection.
Whole-process memory alone does not establish a leak or its absence.


## Candidate failure retained (not waived by favorable cold repeats)

All three candidate D3D12 process-cold repeats drained their queues, without
reproducing the long native stall. The subsequent sustained roof-scrape series
**did reproduce it**: repeat 3 had projection 738.0238 ms, painter 739.6770 ms,
and worst whole frame 757.8555 ms. All three 30-second sustained repeats exceeded
throughput: 38/26/47 jobs and 215/110/17 aggregate inputs dropped respectively;
32/39/26 jobs remained at the three-second drain cutoff (repeat 1 also had 28
captured layers pending). Zero thrown jobs is not a throughput pass.

The one-projection alternative also fails latency: 34/35/38 jobs remained after
its sideslide drain cutoff. Reduced peaks cannot be interpreted as equivalent
rendering when so much work is delayed. Default resolution and brush quality
remain unchanged. A shorter flush interval is being tested separately; it cannot
preempt a single native call. Stable release remains blocked.

## Functional and resource regression observations

- Original vs candidate lifecycle: 20 switches and 10 vehicle reloads each;
  all 32 snapshots ready with unchanged original fields. Original process-private
  memory 7.56-10.25 GiB, ending 7.79 GiB after collection; candidate 7.53-7.79 GiB,
  ending 7.67 GiB. Automation elapsed 371.4 vs 80.8 seconds includes MCP and host
  sampling waits, so it is not a frame-time benchmark. This supports reduced
  allocation churn, not proof of multi-hour native/GPU memory safety.
- Five candidate extension reloads passed; stock Heritage and unicycle skipped;
  return to Police ready. Nonempty editor test layer UID A3A8-EABF was unchanged
  through mod clear/reload, then the fixture was removed.
- Three moving stock `simple_traffic` vehicles had zero detector impacts/streams;
  the player ETK produced 83 projections. This is a three-car functional test,
  not heavy-traffic performance certification.
- Matched plain/Police D3D12 captures retain visible scratches and original fields.
  Real mud/water regression starts with 26 deposits, shallow unchanged, removes
  soil while photographed gray scratches remain, dries to original fields,
  freezes while paused and re-dirties to 27 deposits. No fake contacts or water
  sensor values are injected; Gridmap's real WaterBlock is temporarily repositioned and restored.
