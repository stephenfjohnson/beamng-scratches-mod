# sideslide - 20261114-181031_sideslide_resumed-half-b1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1)`

Settled: True after 4.229 s - 512 frames, 87.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 5376 | 816 | 86 | 147 | 90 | 63 | 467 | 0.0% | 0 | 16 |

Rejected contacts: Wheel 3046, BelowThresh 1511, NormalForce 3

Body materials: METAL 602, PLASTIC 214

Surfaces: ASPHALT 816

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.294 | 3.369 | 51.908 |
| whole frame, ms | 10.6 (p50) | 13.274 | 62.199 |
| all GE Lua, ms | | 4.456 | 52.997 |
| physics + vehicle Lua, ms | | 0.08 | 0.138 |
| render, ms | | 2.179 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 51.879 ms, worst composite 0.125 ms.
- Detector: 1.17 us per contact, 11.756 ms total, worst frame 0.369 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.38 | 62.20 | 51.91 | 0.72 | 0.04 | 1.97 |
| 5.68 | 54.20 | 43.98 | 1.92 | 0.04 | 1.79 |
| 1.04 | 53.12 | 42.05 | 2.01 | 0.07 | 1.92 |
| 0.74 | 50.03 | 39.45 | 1.74 | 0.05 | 1.96 |
| 3.65 | 49.61 | 40.39 | 1.55 | 0.04 | 1.70 |
