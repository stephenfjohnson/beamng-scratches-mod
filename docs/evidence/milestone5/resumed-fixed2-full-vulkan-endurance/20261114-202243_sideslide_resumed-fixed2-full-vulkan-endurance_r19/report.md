# sideslide - 20261114-202243_sideslide_resumed-fixed2-full-vulkan-endurance_r19

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.151 s - 233 frames, 57.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.14)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2232 | 501 | 82 | 104 | 137 | 72 | 116 | 0.0% | 0 | 6 |

Rejected contacts: Wheel 1172, BelowThresh 555, NormalForce 4

Body materials: METAL 381, PLASTIC 120

Surfaces: ASPHALT 501

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.754 | 19.181 | 29.827 |
| whole frame, ms | 16.814 (p50) | 34.38 | 43.311 |
| all GE Lua, ms | | 20.443 | 30.774 |
| physics + vehicle Lua, ms | | 0.129 | 1.986 |
| render, ms | | 2.047 | |

- Painter frames over 4 ms: 56; worst flush (project + bake) 29.792 ms, worst composite 0.098 ms.
- Detector: 1.967 us per contact, 8.033 ms total, worst frame 0.499 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 43.31 | 29.83 | 1.23 | 0.10 | 1.98 |
| 0.97 | 39.96 | 21.75 | 3.53 | 0.08 | 2.69 |
| 1.39 | 39.71 | 19.18 | 4.24 | 0.10 | 1.42 |
| 0.64 | 39.17 | 19.81 | 5.23 | 0.13 | 2.43 |
| 1.77 | 38.39 | 21.95 | 3.95 | 0.10 | 1.38 |
