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
