# roofdrop - 20261114-204904_roofdrop_resumed-control-v2-disabled-vulkan-endurance_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.06 s - 396 frames, 78.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1004 | 48 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 571, BelowThresh 385

Body materials: METAL 47, PLASTIC 1

Surfaces: ASPHALT 48

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.06 |
| whole frame, ms | 12.844 (p50) | 14.009 | 18.542 |
| all GE Lua, ms | | 1.18 | 1.814 |
| physics + vehicle Lua, ms | | 0.082 | 0.162 |
| render, ms | | 1.883 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.182 us per contact, 2.676 ms total, worst frame 0.056 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.23 | 18.54 | 0.01 | 0.94 | 0.05 | 3.25 |
| 1.31 | 16.08 | 0.01 | 1.21 | 0.09 | 2.94 |
| 0.95 | 15.90 | 0.01 | 0.90 | 0.05 | 1.46 |
| 3.64 | 15.89 | 0.01 | 0.85 | 0.06 | 1.42 |
| 1.28 | 15.56 | 0.01 | 0.77 | 0.04 | 3.50 |
