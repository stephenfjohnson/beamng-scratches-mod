# Sequential release threads

> 2026-11-14: Milestones 1–4 implemented for the narrow ETK 800 adapter.
> Progressive mud/dirt/snow, actual driving captures and measured bounds:
> [milestone 2 evidence](../../investigations/07-progressive-deposits.md).
> Milestone 3 adds selective water washing and drying within the ETK scope.
> [Implementation and live evidence](../../investigations/08-water-washing.md).
> Milestone 4 polish: [scope and evidence](../../investigations/09-scratch-impact-polish.md).
> 2026-11-15: Milestone 5 code (synthetic anchors, soil/terrain work) was merged to
> `master` at `56ba091` as a development preview. Its acceptance gates remain
> **open on D3D12**; open items are tracked in [TODO.md](../../TODO.md). Milestone
> 6/public release was not started. [Resumed implementation and gates](../../investigations/11-quality-throughput.md).
> Synthetic anchors removed native projection: Vulkan now meets the native-call and
> delivery gates in measured cohorts; D3D12 still fails (446/447 ms bakes) because the
> engine bake churns ~112 MiB of transient textures per layer. [Investigation 12](../../investigations/12-synthetic-anchors.md).

Run one feature thread at a time. Each starts from the latest merged baseline,
owns a focused branch, implements and tests, updates documentation/examples,
then merges only when its acceptance criteria pass. A blocked feature stays
explicitly incomplete; a passing mock suite does not establish visual success.

1. **Paint and livery compatibility.** Inspect prior accuracy/realism branches
   for overlapping work before changing the painter. Preserve original paint,
   material properties and liveries; keep the current skip safeguard until a
   verified replacement exists. Validate plain paint and a stock livery,
   reset, switching and unsupported vehicles. Record supported scope precisely.
2. **Mud, dirt and snow deposition: implemented for the scoped ETK adapter.**
   [Acceptance evidence](../../investigations/07-progressive-deposits.md). Improve wheel-to-panel placement and
   accumulation while driving. Replace tinted scratch placeholders with suitable
   soil coverage. Validate each surface, caps, reset and scratch coexistence.
3. **Water, washing and wet appearance: implemented for the scoped ETK adapter.**
   [Acceptance evidence](../../investigations/08-water-washing.md). Separate removable soil from lasting
   scratches. Show wetting/drying and cleaning without wiping damage or producing
   paint seams. Validate deep/shallow water behavior and lifecycle changes.
4. **Scratch and impact visual polish: implemented for the scoped ETK adapter.**
   [Evidence and limitations](../../investigations/09-scratch-impact-polish.md). Incorporate relevant prior realism work
   after review; improve opacity, material response, scale and placement. Capture
   matched before/after examples on light and dark paint and several body types.
5. **Performance and compatibility: blocked.** Mitigations and repeated evidence
   are committed on the scoped branch; native stalls still fail acceptance. Explicit quality, batching and grouping
   improve corrected-fixture throughput; [resumed evidence](../../investigations/11-quality-throughput.md)
   distinguishes those gains from unresolved native hitches. Repeated baseline/stress runs, traffic,
   switching, long sessions, renderers and supported vehicles. Record exact
   versions, settings and frame-time results. Address spikes before release.
   The resumed run completed final D3D12/Vulkan regressions and concrete resource,
   stream, batching and quality work. Final native outliers (444/508 ms) and a
   1012 ms delivery age still fail the original gates; this feature is incomplete.
   Synthetic anchors (investigation 12) remove the projection call: Vulkan passes
   native (35.4 ms) and delivery (318 ms) gates in 57 untraced fixtures, D3D12 still
   fails with 446/447 ms bake batches. Merged 2026-11-15 as a development
   preview; acceptance still incomplete ([TODO](../../TODO.md#release-blockers)).
6. **Public release.** Clean ZIP-only install/uninstall test, final screenshots,
   version/changelog, credits/license decision, supported matrix, public ZIP,
   checksums and anonymous download verification. Publish as preview if known
   limitations remain; never label unverified features stable.

## Completion checklist for every thread

- Focused implementation; no unrelated branch merges.
- Lua syntax/global checks, behavior harness and brush sidecar checks pass.
- Relevant live-game tests recorded, with exact build/renderer/vehicle/map.
- README, examples, compatibility evidence and changelog reflect final behavior.
- Commit reviewed; merge into the integration/default branch without overwriting
  unrelated work. Push updates to GitHub, then start the next thread.
- Record any unfinished work plainly and stop before starting another feature
  if the current milestone needs a design decision.

The earlier contact-accuracy and material-aware realism branches were retired
on 2026-11-15 and preserved as `archive/*` tags. Their unported ideas are listed
in [TODO.md](../../TODO.md#ideas-parked-on-archived-branches); review and
selectively integrate where relevant.
