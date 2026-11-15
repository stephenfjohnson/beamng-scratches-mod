# roofdrop - 20261114-171955_roofdrop_candidate-vulkan-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 7.677 s - 593 frames, 77.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1754 | 65 | 65 | 0 | 58 | 18 | 17 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 984, BelowThresh 705

Body materials: METAL 63, PLASTIC 2

Surfaces: ASPHALT 65

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.915 | 0.011 | 49.2 |
| whole frame, ms | 12.466 (p50) | 15.264 | 63.752 |
| all GE Lua, ms | | 1.654 | 50.32 |
| physics + vehicle Lua, ms | | 0.08 | 0.16 |
| render, ms | | 2.076 | |

- Painter frames over 4 ms: 20; worst flush (project + bake) 49.179 ms, worst composite 0.119 ms.
- Detector: 1.563 us per contact, 6.613 ms total, worst frame 0.565 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.48 | 63.75 | 49.20 | 0.91 | 0.07 | 1.42 |
| 0.53 | 52.95 | 40.34 | 1.22 | 0.16 | 1.67 |
| 2.68 | 52.93 | 38.09 | 1.08 | 0.05 | 1.46 |
| 0.74 | 51.55 | 38.49 | 0.69 | 0.05 | 1.71 |
| 6.38 | 48.89 | 33.34 | 0.98 | 0.04 | 1.46 |
