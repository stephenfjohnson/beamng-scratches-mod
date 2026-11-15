# sideslide - 20261114-194349_sideslide_resumed-selected-half-vulkan-endurance_r31

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.583 s - 345 frames, 74.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.166)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2723 | 605 | 92 | 133 | 105 | 102 | 157 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1306, BelowThresh 810, NormalForce 2

Body materials: METAL 450, PLASTIC 155

Surfaces: ASPHALT 605

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.403 | 35.186 | 41.316 |
| whole frame, ms | 10.823 (p50) | 45.182 | 52.009 |
| all GE Lua, ms | | 36.055 | 42.042 |
| physics + vehicle Lua, ms | | 0.081 | 0.181 |
| render, ms | | 1.544 | |

- Painter frames over 4 ms: 43; worst flush (project + bake) 41.286 ms, worst composite 0.056 ms.
- Detector: 1.425 us per contact, 7.707 ms total, worst frame 0.436 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.46 | 52.01 | 40.15 | 1.48 | 0.04 | 1.33 |
| 0.33 | 51.66 | 41.32 | 1.61 | 0.04 | 1.40 |
| 2.74 | 51.46 | 39.41 | 1.14 | 0.05 | 1.30 |
| 2.60 | 51.07 | 39.97 | 1.38 | 0.06 | 1.28 |
| 0.48 | 49.68 | 34.46 | 1.56 | 0.04 | 1.32 |
