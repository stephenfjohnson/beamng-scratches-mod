# sideslide - 20261114-194435_sideslide_resumed-selected-half-vulkan-endurance_r34

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.375 s - 324 frames, 73.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.181)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2203 | 581 | 114 | 128 | 127 | 97 | 162 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1028, BelowThresh 592, NormalForce 2

Body materials: METAL 418, PLASTIC 163

Surfaces: ASPHALT 581

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.638 | 34.786 | 39.442 |
| whole frame, ms | 10.245 (p50) | 42.828 | 50.913 |
| all GE Lua, ms | | 35.662 | 40.283 |
| physics + vehicle Lua, ms | | 0.083 | 0.147 |
| render, ms | | 1.768 | |

- Painter frames over 4 ms: 43; worst flush (project + bake) 39.416 ms, worst composite 0.087 ms.
- Detector: 1.699 us per contact, 7.794 ms total, worst frame 0.468 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 50.91 | 39.21 | 1.25 | 0.04 | 1.31 |
| 0.34 | 50.88 | 39.24 | 1.99 | 0.04 | 1.48 |
| 0.48 | 50.86 | 39.44 | 1.23 | 0.06 | 1.48 |
| 2.66 | 49.28 | 36.56 | 1.42 | 0.09 | 1.23 |
| 2.08 | 48.47 | 36.23 | 1.57 | 0.05 | 1.20 |
