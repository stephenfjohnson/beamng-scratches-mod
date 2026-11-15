# sideslide - 20261114-180930_sideslide_resumed-half-b6

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(6)`

Settled: True after 4.203 s - 300 frames, 71.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2508 | 633 | 83 | 112 | 122 | 84 | 72 | 0.0% | 0 | 16 |

Rejected contacts: Wheel 1308, BelowThresh 565, NormalForce 2

Body materials: METAL 467, PLASTIC 166

Surfaces: ASPHALT 633

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.934 | 31.461 | 57.512 |
| whole frame, ms | 10.412 (p50) | 41.246 | 66.574 |
| all GE Lua, ms | | 32.362 | 58.494 |
| physics + vehicle Lua, ms | | 0.156 | 2.146 |
| render, ms | | 2.866 | |

- Painter frames over 4 ms: 81; worst flush (project + bake) 57.48 ms, worst composite 0.135 ms.
- Detector: 1.674 us per contact, 7.972 ms total, worst frame 0.351 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.30 | 66.57 | 57.51 | 1.23 | 0.05 | 1.96 |
| 1.35 | 62.23 | 49.91 | 0.90 | 0.07 | 1.83 |
| 0.93 | 55.96 | 47.07 | 1.33 | 0.07 | 2.11 |
| 1.96 | 53.21 | 43.32 | 0.88 | 0.05 | 2.04 |
| 1.14 | 52.72 | 44.75 | 0.95 | 0.06 | 2.05 |
