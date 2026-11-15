# sideslide - 20261114-180829_sideslide_resumed-full-b6

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6)`

Settled: True after 4.27 s - 136 frames, 33.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1040 | 273 | 99 | 54 | 182 | 89 | 60 | 0.0% | 0 | 15 |

Rejected contacts: Wheel 543, BelowThresh 222, NormalForce 2

Body materials: METAL 200, PLASTIC 73

Surfaces: ASPHALT 273

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 19.023 | 43.016 | 59.188 |
| whole frame, ms | 32.101 (p50) | 55.254 | 69.647 |
| all GE Lua, ms | | 44.3 | 60.018 |
| physics + vehicle Lua, ms | | 5.703 | 7.909 |
| render, ms | | 2.399 | |

- Painter frames over 4 ms: 78; worst flush (project + bake) 59.151 ms, worst composite 0.117 ms.
- Detector: 2.222 us per contact, 6.774 ms total, worst frame 1.357 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.27 | 69.65 | 47.18 | 1.51 | 6.80 | 1.62 |
| 0.38 | 66.29 | 59.19 | 0.80 | 0.04 | 1.79 |
| 1.90 | 58.45 | 43.95 | 33.88 | 0.06 | 1.53 |
| 0.59 | 58.25 | 47.25 | 0.84 | 4.76 | 1.39 |
| 0.89 | 57.95 | 41.54 | 39.33 | 0.09 | 1.56 |
