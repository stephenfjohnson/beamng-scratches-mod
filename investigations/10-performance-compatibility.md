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
root cause: these CPU timers cannot distinguish GPU synchronization, driver
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
