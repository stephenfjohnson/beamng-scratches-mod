# sideslide - 20261114-193653_sideslide_resumed-selected-half-vulkan-endurance_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.358 s - 321 frames, 73.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2716 | 599 | 93 | 123 | 121 | 104 | 151 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1398, BelowThresh 717, NormalForce 2

Body materials: METAL 450, PLASTIC 149

Surfaces: ASPHALT 599

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.726 | 34.045 | 41.347 |
| whole frame, ms | 9.691 (p50) | 44.396 | 51.116 |
| all GE Lua, ms | | 35.039 | 42.337 |
| physics + vehicle Lua, ms | | 0.087 | 0.137 |
| render, ms | | 1.887 | |

- Painter frames over 4 ms: 46; worst flush (project + bake) 41.32 ms, worst composite 0.082 ms.
- Detector: 1.6 us per contact, 9.987 ms total, worst frame 0.462 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.48 | 51.12 | 38.78 | 1.51 | 0.07 | 1.49 |
| 0.59 | 50.85 | 41.35 | 1.48 | 0.05 | 1.68 |
| 1.31 | 50.58 | 38.67 | 1.61 | 0.08 | 1.27 |
| 2.37 | 49.84 | 37.38 | 1.79 | 0.05 | 1.33 |
| 1.86 | 48.01 | 35.91 | 1.85 | 0.06 | 1.29 |
