# sideslide - 20261114-194218_sideslide_resumed-selected-half-vulkan-endurance_r25

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.081 s - 297 frames, 68.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.145)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2949 | 703 | 70 | 123 | 103 | 98 | 138 | 0.0% | 0 | 0 |

Rejected contacts: Wheel 1594, BelowThresh 650, NormalForce 2

Body materials: METAL 528, PLASTIC 175

Surfaces: ASPHALT 703

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.685 | 35.293 | 323.625 |
| whole frame, ms | 10.423 (p50) | 44.31 | 334.914 |
| all GE Lua, ms | | 36.272 | 324.622 |
| physics + vehicle Lua, ms | | 0.095 | 0.88 |
| render, ms | | 1.564 | |

- Painter frames over 4 ms: 41; worst flush (project + bake) 323.603 ms, worst composite 0.057 ms.
- Detector: 1.55 us per contact, 8.926 ms total, worst frame 1.219 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.32 | 334.91 | 323.62 | 1.61 | 0.08 | 1.27 |
| 2.11 | 51.61 | 39.79 | 2.98 | 0.05 | 1.26 |
| 1.10 | 48.97 | 37.43 | 1.25 | 0.04 | 1.27 |
| 2.36 | 48.66 | 37.22 | 1.48 | 0.09 | 1.27 |
| 1.87 | 48.05 | 37.35 | 1.39 | 0.06 | 1.22 |
