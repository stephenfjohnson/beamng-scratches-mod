# sideslide - 20261114-202110_sideslide_resumed-fixed2-full-vulkan-endurance_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.108 s - 249 frames, 61.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.139)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2488 | 530 | 79 | 109 | 134 | 93 | 122 | 0.0% | 0 | 0 |

Rejected contacts: Wheel 1376, BelowThresh 582

Body materials: METAL 394, PLASTIC 136

Surfaces: ASPHALT 530

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.003 | 19.423 | 37.378 |
| whole frame, ms | 14.359 (p50) | 31.69 | 49.889 |
| all GE Lua, ms | | 20.446 | 38.458 |
| physics + vehicle Lua, ms | | 0.101 | 0.199 |
| render, ms | | 1.753 | |

- Painter frames over 4 ms: 45; worst flush (project + bake) 37.353 ms, worst composite 0.111 ms.
- Detector: 1.558 us per contact, 7.324 ms total, worst frame 0.374 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 49.89 | 37.38 | 0.93 | 0.08 | 1.39 |
| 0.74 | 36.69 | 21.74 | 3.31 | 0.05 | 1.28 |
| 2.07 | 35.07 | 20.08 | 3.60 | 0.08 | 1.44 |
| 0.28 | 34.56 | 22.05 | 2.06 | 0.06 | 1.72 |
| 0.86 | 34.49 | 20.38 | 4.46 | 0.08 | 1.30 |
