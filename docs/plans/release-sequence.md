# Sequential release threads

> 2026-11-14: Milestone 1 investigation delivered on its feature branch;
> **incomplete, not ready to merge**. Safeguards hardened; generic composition
> and exact paint-material preservation remain unresolved.
> [Evidence and supported scope](../../investigations/05-livery-preservation.md).
> Do not start milestone 2.

Run one feature thread at a time. Each starts from the latest merged baseline,
owns a focused branch, implements and tests, updates documentation/examples,
then merges only when its acceptance criteria pass. A blocked feature stays
explicitly incomplete; a passing mock suite does not establish visual success.

1. **Paint and livery compatibility.** Inspect prior accuracy/realism branches
   for overlapping work before changing the painter. Preserve original paint,
   material properties and liveries; keep the current skip safeguard until a
   verified replacement exists. Validate plain paint and a stock livery,
   reset, switching and unsupported vehicles. Record supported scope precisely.
2. **Mud, dirt and snow deposition.** Improve wheel-to-panel placement and
   accumulation while driving. Replace tinted scratch placeholders with suitable
   soil coverage. Validate each surface, caps, reset and scratch coexistence.
3. **Water, washing and wet appearance.** Separate removable soil from lasting
   scratches. Show wetting/drying and cleaning without wiping damage or producing
   paint seams. Validate deep/shallow water behavior and lifecycle changes.
4. **Scratch and impact visual polish.** Incorporate relevant prior realism work
   after review; improve opacity, material response, scale and placement. Capture
   matched before/after examples on light and dark paint and several body types.
5. **Performance and compatibility.** Repeated baseline/stress runs, traffic,
   switching, long sessions, renderers and supported vehicles. Record exact
   versions, settings and frame-time results. Address spikes before release.
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

Existing local branches include contact-accuracy and material-aware realism
changes not yet merged here. Their existence is not evidence they are ready;
review and selectively integrate where relevant.
