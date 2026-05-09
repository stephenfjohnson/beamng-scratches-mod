# Scratches: perf + variation pass

Date: 2026-05-08

## Why

Rolling a car down a hill produced visible problems:

- A wall of `stampAtLocal` log lines, many with `result decalPos=(-0.00,-0.00,-0.00)
  cursor=(0.500,0.500)` — wasted bakes (projection missed, but we still ran a full
  texture recomposite).
- Side panel reads as a dense field of near-identical white starbursts. Each stamp
  uses `(0.7, 0.7, 0.7)` grey, scale wobble is only ±30%, brushes are uniform-random
  with no recency avoidance.
- Discrete impact stamps each call `bakeLayers({oneLayer})` independently. N stamps
  in one tick = N full texture recomposites. The `stampStream` path already
  batches sub-strokes; the discrete path does not.

## Plan

Five steps, in order. A and B unlock the headroom that E spends.

### A. Skip failed projections (paint.lua)

After `getDecalData` in `stampAtLocal`, before `bakeLayers`, detect the
"projection missed" case and return without baking:

```
missed = (|decalPos.x|+|decalPos.y|+|decalPos.z|) < 1e-3
       AND |cursorPosScreenUv.x - 0.5| < 1e-4
       AND |cursorPosScreenUv.y - 0.5| < 1e-4
```

Project still runs (we need its output to know the projection missed). The bake —
the expensive recomposite — is skipped. Add a `stats.skippedMissed` counter so we
can confirm the rate.

### B. Per-frame bake batching (paint.lua)

Split `stampAtLocal` into build + flush:

- **Build**: project + getDecalData + missed-filter + uid mint. Append surviving
  `decalData` to module-local `pendingStamps`. Return.
- **Flush**: in existing `onUpdate` after `api.onUpdate_()`, if `#pendingStamps > 0`
  call `bakeLayers(pendingStamps, jbeam)` once and clear.

Texture is identical (bakes are additive). N bakes per frame → 1 bake per frame.

Stream path is unchanged. Streams already batch their sub-strokes into one bake;
folding them into the discrete queue would conflict on cameras and gain nothing.

Hard cap on the discrete queue at 64 entries per frame; further enqueues drop and
bump `stats.aggregateDropped`. Worst-case rolls don't melt.

### C. Variation (paint.lua)

- **Color jitter**: per-stamp brightness in [0.45, 0.85], with a 35% chance of a
  faint warm push (+0.04 R, -0.02 B). Replace the `(0.7, 0.7, 0.7)` constant in
  both `stampAtLocal` and `stampStream`.
- **Wider scale wobble**: `0.7 + rand*0.6` → `0.5 + rand*1.2` (range 0.5×–1.7×).
- **Brush recency avoidance**: ring buffer of last 3 brushes; on collision,
  re-roll once. New helper `pickBrush()`.
- **Per-brush scale bias**: `chip_cluster` × 0.75 (it's busy at default scale);
  `streak_*` × 1.1.
- **Roughness jitter**: `setRoughnessIntensity(0.10 + rand*0.25)` per stamp.
  Keeps metallic=1 but mixes shinier and duller scratches.

### D. Quiet per-stamp logs (paint.lua)

- Module-local `stampVerbose = false` flag.
- Gate the `log('I', logTag, "stampAtLocal: ...")` and equivalent stream-end log
  behind it. Probe: `M.setStampVerbose(b)`.
- Add `M.dumpPaintStats` exposing `stampsAttempted`, `stampsBaked`,
  `stampsSkippedMissed`, `streamsBaked`, `streamSubstrokesTotal`,
  `aggregateDropped`. Replaces visibility lost from silencing per-stamp logs.

### E. Density tuning (detect.lua + paint.lua)

Only safe after A+B land.

- `paintCooldown`: 0.05 → **0.025**.
- `IMPACT_COOLDOWN`: 1.0 → **0.4**.
- `STREAM_MAX_POINTS`: 20 → **30**.
- `STREAM_MAX_DURATION`: 0.50 → **0.45**.
- `CHUNK_TARGET` (paint.lua): 4 → **3**.
- `interpolationSteps`: 8 → **10**.
- New aggregate cap from B: `AGGREGATE_PER_FRAME_CAP = 24`, exposed as
  `M.setAggregateCap(n)`.

Not touched: `IMPACT_FORCE_THRESHOLD`, `SLIP_THRESHOLD`, `PERP_THRESHOLD`,
`EXCLUDE_PART_PATTERNS`. None of those caused the perf or variation issues, and
the part-exclude list prevents real bugs (windshield spider-web).

## Verification

- `scratches_paint.dumpPaintStats` after a roll should show
  `stampsSkippedMissed / stampsAttempted` ≈ the missed fraction in the original
  log wall (eyeball: 30-50%).
- `bakes per frame` (a new stat) should be ≤ 1 on the discrete path during a roll.
- Visual: side panel after a roll should show varied tones (some darker, some
  warmer), varied sizes, no obvious "two of the same brush adjacent" runs.

## Round 2: F + G (still hitching during heavy rolls)

After A-E shipped, rolling cars still produced visible hitches. Two more fixes
landed in the same design pass:

### F. Single-camera batching for discrete stamps (paint.lua)

The previous discrete path still ran `projectDynamicDecals` *per stamp* — a
full depth-pass render. With 24 queued stamps that's 24 render passes per
frame, the dominant cost.

`stampAtLocal` now records a raw input descriptor (`{localPos, localNormal,
brush, color, scale, rot, roughness, ...}`) and returns. No api calls, no
project, no `getDecalData`.

`flushPendingStamps` clusters the inputs greedily by spatial proximity
(`CLUSTER_RADIUS = 1.5m`, vehicle-local). For each cluster:

1. Build a synthetic camera at the cluster centroid (radial outward).
2. `projectDynamicDecals` ONCE.
3. For each stamp in the cluster: set per-stamp api state, `getDecalData`,
   `setDecalLocalPos` to override cursor to the stamp's actual position.
4. Frustum check on the resulting cursor; out-of-frustum stamps drop.
5. Push surviving layers to the bake list.

Single `bakeLayers` call after all clusters. Stats: `projectsIssued` and
`clustersTotal` exposed via `dumpPaintStats`. Tunable via `setClusterRadius(m)`.

The missed-projection check changed from `decalPos≈0 ∧ cursor≈(0.5,0.5)` to
`cursor outside [0,1]` because `setDecalLocalPos` overrides the cursor —
the old sentinel is no longer reliable.

Effect: project count goes from N to K (K = cluster count). Typical slide
produces K=1 (all stamps cluster on the contacting panel), so 24× speedup
on the project step.

### G. VLUA→GE event batching (detect.lua + paint.lua)

`detect.lua` previously called `obj:queueGameEngineLua("...stampAt(...)...")`
once per impact. During a roll that's a Lua source-string compile + eval per
event on the GE side, ~30+ per frame.

Detect side now accumulates `{x,y,z,nx,ny,nz,kind}` records into
`pendingDetectEvents`. `updateGFX` (per render frame) serializes the whole
buffer as a Lua table-literal payload and queues *one* GE call to a new
`scratches_paint.stampBatch(events)`.

Stream flushes (`flushStream` for ≥2 points) still use direct
`queueGameEngineLua` because each stream is already a single batched call.
Only the per-event impacts and 1-point fallbacks pipe through the batch.

Effect: one Lua compile+eval per frame instead of N. Cuts both VLUA payload-
construction overhead and GE-side compile cost.

## Round 3: H + sensitivity bump

Visual issue noticed after F+G: brushStroke streams with `interpolationSteps`
read as a row of repeated stamps rather than a continuous mark. The bake also
composites every interpolated decal — paying for visual cadence we don't want.

### H. Stretched-decal stream (1-3 segments by curvature)

`stampStream` no longer emits `brushStroke` layers. The points list is
analyzed for curvature (cumulative turning angle at interior points) and
split into 1-3 segments:

- `<25°` total turn → 1 segment
- `25-55°` → 2 segments at the highest-turn interior point
- `>55°` → 3 segments at the top two turn points

Each segment emits ONE elongated `decal` layer:

- `length` = distance(firstPt, lastPt)
- `width` = jittered 0.06m–0.18m
- `decalScale = vec3(length/2, 1, width/2)` (asymmetric)
- `rotation` = `atan2` of the segment's screen-UV delta, computed via a
  reusable probe layer (`getDecalData` once per stream, then `setDecalLocalPos`
  to start/end to read back UV).
- `brush` from `STRETCH_BRUSHES` (streak_01/02/03/05) — the only ones that
  tile cleanly when stretched at high aspect ratios.

Brushes split into two purpose-specific sets:

- `IMPACT_BRUSHES` — chip_cluster, tbone, raptor_claw_01/02. Used by
  `pickBrush()` for discrete impacts and 1-point fallbacks. "Something hit
  and bit the panel."
- `STRETCH_BRUSHES` — streak_01/02/03/05. Used by `pickStretchBrush()` for
  the slide segments only.

The `recentBrushes` ring is shared across both sets so back-to-back layers
don't share textures even when crossing slide↔impact boundaries.

Cost: a 30-point straight slide goes from ~28 baked decals (10-step
brushStroke chunks) to 1 elongated decal. Curving slides: 2-3 decals.

### Sensitivity bumps (detect.lua)

H made the stream path so cheap that we have headroom to register lighter
events without budget pressure:

- `SLIP_THRESHOLD`: 2.5 → **1.5** m/s (catches slow drags)
- `PERP_THRESHOLD`: 2.5 → **2.0** m/s
- `MIN_NORMAL_FORCE`: 50 → **30** N
- `IMPACT_FORCE_THRESHOLD`: 5000 → **3000** N (lighter impacts register)
- `IMPACT_COOLDOWN`: 0.4 → **0.25** s
- `paintCooldown`: 0.025 → **0.015** s (~66 samples/sec/node)
- `AGGREGATE_PER_FRAME_CAP` (paint.lua): 24 → **32**

The previous run had `aggregateDropped=0` with the cap at 24, so 32 is just
giving the rare heavy frame more room. If frames hitch under the new
sensitivity, lower the cap with `setAggregateCap(20)` or push thresholds back
up via `setThresholds` / `setImpactParams`.

## Round 4: I (force-scaled synth camera)

Symptom: rear corner crushed in by a hard hit; rear-bumper nodes fired 12-18
events each (verified via `dumpStats` top-nodes), but the visible damage on
the deformed corner was sparse. Hypothesis: when a node fires after its
panel has already deformed inward, the radial-outward synth camera at
`localPos + outward*0.5m` shoots its ray INTO the dent's cavity instead of
grazing the outer skin from the side. Decals land on inner geometry or
outside the visible mesh.

### I. Force-scaled synth camera distance + size

Detect side now records `normalForce` per impact event and per stream sample,
serializing it as the 8th field in the `pendingDetectEvents` payload.

GE side `stampBatch` plumbs `force` through `stampAt`. The "impact" branch
computes:

```
heavy = clamp((force - 3000) / 30000, 0, 1)   -- 0..1 over 3-33 kN
opts.scale = 0.18 + heavy * 0.15              -- 0.18m .. 0.33m
opts.dist  = 0.5  + heavy * 1.5               -- 0.5m  .. 2.0m
```

So a 3 kN graze gets the original 0.5m camera; a 33+ kN crunch gets a 2.0m
camera with a flatter incidence angle plus a 1.8x larger decal so the visible
mark covers the deformed area instead of vanishing inside it.

Per-cluster: `flushPendingStamps` finds `max(member.dist)` and uses that for
the cluster's shared camera. Lighter stamps in a heavy-stamp cluster get
slightly lower projection resolution (acceptable) in exchange for the heavy
stamp landing reliably on the outer skin.

1-point slide fallbacks also pick up the `dist` scaling when their force
exceeds the impact threshold.

Streams (≥2-point) keep the default 0.5m camera — slides happen on
not-yet-deformed panels typically, and the centroid camera already covers
them well.

## Round 5: J (deformation-driven stamps)

I helped, but the user wants belt-and-suspenders coverage: every realistic
spot should have damage. I+collision still misses the case where a panel
deforms purely from internal force transfer (e.g. denied chassis node hits
ground; force propagates into an outer skin node that itself never touched
anything).

### J. Deformation-tier supplementary stamp source

A second event source running in parallel with `onNodeCollision`:

**Detect side (VLUA)** — `scratches_detect.lua`:
- `buildBodySkinNodes` enumerates `v.data.nodes` once, keeping nodes that
  pass the same body-material + part-deny filters the impact branch uses.
  Cached for the life of the vehicle (Ctrl+R doesn't change node IDs / rest).
- `scanDeformations` runs from `updateGFX`. Round-robin slice of
  `DEFORM_SCAN_PER_FRAME = 12` nodes per frame; for each, compute
  `magnitude = |obj:getNodePosition(nid) - node.pos|` (both vehicle-local,
  so the diff is pure deformation, no rigid-body motion).
- Tier gate: when `magnitude` crosses one of `DEFORM_TIERS = {0.04, 0.10, 0.20}`
  meters that the node hasn't fired before, emit one stamp. So a single node
  can fire up to 3 times across a session, scaling with damage severity.
- Pushed to `pendingDetectEvents` with `kind="d"` and the magnitude as the
  severity field. Coords are vehicle-local (deformation direction goes in
  the unused-by-camera normal slot for traceability).

**Paint side (GE)** — `paint.lua`:
- `stampBatch` dispatches `kind="d"` directly to `stampAtLocal` (skipping
  the world→local conversion `stampAt` does for collision-sourced events).
- Severity-scaled opts: `scale = 0.20 + heavy*0.20` (0.20m → 0.40m, slightly
  larger than collision impacts), `dist = 0.5 + heavy*1.5` (same scaling
  as I). Brush from `IMPACT_BRUSHES`.

### Tunables

- `scratches_detect.setDeformTiers(t1, t2, t3)` — adjust the magnitude tiers.
  Lower = more sensitive = more stamps. Resets per-node tier history.
- Stat: `dumpStats` now shows `deformEvents = N (tiers …, M skin nodes)`.

### What this catches that I+collision didn't

- Outer skin pushed by an internal frame node where the frame node is on
  the deny list (skidplate, exhaust, suspension): the visible damage is on
  the skin, but the contact event was on the denied node. Now the skin
  fires its own deformation event.
- Sustained pressure crumple: slow press without a single hard impact —
  no collision events at all, but the panel still deforms. J fires on
  the deformation directly.
- Internal panel-on-panel: panels that bend toward each other from a
  remote impact propagate force inward. Both panels' skin nodes register
  movement and emit stamps.

## Round 6: K (live IMGUI debug + tuning panel)

A debug overlay so the user can see counts in real time and dial tunables
without console gymnastics.

### Architecture

VLUA→GE one-way snapshot push (no bidirectional state machine):

- `scratches_detect.lua` — `pushStatsToGE` runs from `updateGFX` at
  `STATS_PUSH_PERIOD = 0.25s`. Serializes counts (totalCalls, filteredCalls,
  impactEvents, deformEvents, streamsFlushed, maxNormalForce) AND current
  tunable values (slip/perp/minForce/impForce/impCool/paintCool/defT1-3) into
  one `recordDetectStats({...})` call via `queueGameEngineLua`.

- `scratches_paint.lua` — `M.recordDetectStats(s)` stores the snapshot in
  `lastDetectStats`. The IMGUI panel reads from it.

GE→VLUA tuning callback when sliders change:

- The window uses the player vehicle's `queueLuaCommand` to send
  `scratches_detect.setThresholds(...)` / `setImpactParams(...)` /
  `setDeformTiers(...)` / `setPaintCooldown(...)` strings. One command per
  slider drag (BeamNG ImGui returns true only on change).

GE-only tunables (`AGGREGATE_PER_FRAME_CAP`, `CLUSTER_RADIUS`) bind directly
to the slider's `IntPtr/FloatPtr` value.

### UI layout

- Live counters: collision impacts, deformation events, streams baked,
  discrete stamps queued/skipped, filtered/total, projects/clusters per
  frame, max normalForce.
- "Scratches (slides)" — slip threshold, sample period.
- "Impact marks" — force threshold, cooldown.
- "Deformation tiers" — three magnitude sliders.
- "Bake limits (GE)" — aggregate cap, cluster radius.
- Buttons: Reset stats (GE + VLUA), Clear stamps, Hide.

`syncUIPointersFromSnapshot` updates slider ptrs from VLUA snapshot when the
user isn't actively dragging (`im.IsAnyItemActive`) — keeps display in sync
with console-side `setThresholds` calls without fighting the user's drag.

### Toggle

Invoked via `scratches_paint.toggleUI()` from GE Lua console. Idempotent.
`extensions.load("ui_imgui")` runs lazily in `trySetup` so the imgui
bindings are available the first time the user opens the panel.
