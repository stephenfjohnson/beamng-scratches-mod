# roofdrop - 20261114-204949_roofdrop_resumed-control-v2-disabled-vulkan-endurance_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.121 s - 402 frames, 78.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1046 | 54 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 588, BelowThresh 404

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.032 |
| whole frame, ms | 12.819 (p50) | 13.937 | 15.59 |
| all GE Lua, ms | | 1.161 | 3.288 |
| physics + vehicle Lua, ms | | 0.075 | 0.203 |
| render, ms | | 1.745 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.212 us per contact, 2.888 ms total, worst frame 0.053 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.32 | 15.59 | 0.01 | 1.18 | 0.06 | 2.41 |
| 1.87 | 15.26 | 0.01 | 0.80 | 0.04 | 2.75 |
| 2.70 | 15.06 | 0.01 | 1.02 | 0.09 | 1.53 |
| 1.84 | 14.96 | 0.01 | 1.04 | 0.08 | 2.11 |
| 4.72 | 14.88 | 0.01 | 1.07 | 0.04 | 1.38 |
