# roofdrop - 20261114-205451_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 6.325 s - 499 frames, 78.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1418 | 55 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 825, BelowThresh 538

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.034 |
| whole frame, ms | 12.715 (p50) | 13.851 | 16.486 |
| all GE Lua, ms | | 1.113 | 1.914 |
| physics + vehicle Lua, ms | | 0.071 | 0.191 |
| render, ms | | 1.674 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.125 us per contact, 3.695 ms total, worst frame 0.119 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.55 | 16.49 | 0.01 | 0.87 | 0.04 | 3.01 |
| 0.45 | 15.91 | 0.01 | 0.84 | 0.05 | 2.48 |
| 5.52 | 15.77 | 0.01 | 0.86 | 0.04 | 2.16 |
| 1.03 | 15.05 | 0.01 | 1.71 | 0.08 | 1.93 |
| 1.56 | 15.03 | 0.01 | 0.92 | 0.06 | 1.33 |
