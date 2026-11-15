# sideslide - 20261114-202547_sideslide_resumed-fixed2-full-vulkan-endurance_r31

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.849 s - 387 frames, 62.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.187)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3102 | 433 | 105 | 96 | 142 | 92 | 123 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1393, BelowThresh 1274, NormalForce 2

Body materials: METAL 314, PLASTIC 119

Surfaces: ASPHALT 433

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.135 | 18.38 | 36.441 |
| whole frame, ms | 12.731 (p50) | 30.13 | 403.171 |
| all GE Lua, ms | | 19.322 | 37.481 |
| physics + vehicle Lua, ms | | 0.094 | 0.935 |
| render, ms | | 1.637 | |

- Painter frames over 4 ms: 55; worst flush (project + bake) 36.41 ms, worst composite 0.076 ms.
- Detector: 1.315 us per contact, 7.778 ms total, worst frame 0.428 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.43 | 403.17 | 2.74 | 16.76 | 0.08 | 1.28 |
| 0.18 | 48.41 | 36.44 | 0.78 | 0.06 | 1.39 |
| 5.07 | 48.34 | 35.62 | 0.70 | 0.03 | 1.22 |
| 4.01 | 46.74 | 34.41 | 0.92 | 0.06 | 1.23 |
| 3.30 | 40.10 | 34.26 | 0.79 | 0.03 | 1.36 |
