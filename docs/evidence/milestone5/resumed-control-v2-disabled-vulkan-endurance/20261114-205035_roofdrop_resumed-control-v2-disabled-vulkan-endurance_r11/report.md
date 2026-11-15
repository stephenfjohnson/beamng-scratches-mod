# roofdrop - 20261114-205035_roofdrop_resumed-control-v2-disabled-vulkan-endurance_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.315 s - 418 frames, 78.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1091 | 54 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 610, BelowThresh 427

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.03 |
| whole frame, ms | 12.787 (p50) | 13.941 | 16.302 |
| all GE Lua, ms | | 1.079 | 2.645 |
| physics + vehicle Lua, ms | | 0.072 | 0.202 |
| render, ms | | 1.715 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.192 us per contact, 2.903 ms total, worst frame 0.018 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.22 | 16.30 | 0.01 | 1.10 | 0.06 | 1.58 |
| 4.13 | 16.05 | 0.01 | 0.98 | 0.04 | 1.52 |
| 2.49 | 15.74 | 0.01 | 0.80 | 0.05 | 1.44 |
| 1.88 | 15.10 | 0.01 | 0.98 | 0.05 | 3.42 |
| 3.12 | 14.86 | 0.01 | 0.79 | 0.04 | 1.49 |
