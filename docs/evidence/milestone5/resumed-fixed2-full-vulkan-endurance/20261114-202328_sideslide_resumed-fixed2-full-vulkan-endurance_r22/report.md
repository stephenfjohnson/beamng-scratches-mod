# sideslide - 20261114-202328_sideslide_resumed-fixed2-full-vulkan-endurance_r22

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.262 s - 251 frames, 58.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.168)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2253 | 462 | 96 | 104 | 137 | 93 | 124 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1251, BelowThresh 540

Body materials: METAL 340, PLASTIC 122

Surfaces: ASPHALT 462

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.029 | 19.358 | 35.087 |
| whole frame, ms | 14.277 (p50) | 34.823 | 45.745 |
| all GE Lua, ms | | 20.335 | 36.245 |
| physics + vehicle Lua, ms | | 0.123 | 1.263 |
| render, ms | | 2.167 | |

- Painter frames over 4 ms: 59; worst flush (project + bake) 35.061 ms, worst composite 0.136 ms.
- Detector: 1.608 us per contact, 7.364 ms total, worst frame 0.43 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 45.74 | 35.09 | 0.89 | 0.08 | 1.40 |
| 1.73 | 40.18 | 24.22 | 2.59 | 0.07 | 2.15 |
| 2.67 | 39.29 | 23.06 | 3.61 | 0.06 | 2.11 |
| 2.31 | 37.37 | 22.52 | 2.16 | 0.11 | 1.36 |
| 0.36 | 37.10 | 19.50 | 2.08 | 0.07 | 2.02 |
