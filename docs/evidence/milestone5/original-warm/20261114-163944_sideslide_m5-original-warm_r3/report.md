# sideslide - 20261114-163944_sideslide_m5-original-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Settled: True after 4.134 s - 147 frames, 35.3 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.159)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1113 | 317 | 87 | 68 | 165 | 84 | 60 | 0.0% | 0 | 14 |

Rejected contacts: Wheel 598, BelowThresh 197, NormalForce 1

Body materials: METAL 231, PLASTIC 86

Surfaces: ASPHALT 317

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.792 | 45.914 | 63.938 |
| whole frame, ms | 25.836 (p50) | 55.713 | 83.593 |
| all GE Lua, ms | | 46.889 | 64.613 |
| physics + vehicle Lua, ms | | 5.449 | 9.767 |
| render, ms | | 3.197 | |

- Painter frames over 4 ms: 76; worst flush (project + bake) 63.891 ms, worst composite 0.107 ms.
- Detector: 1.848 us per contact, 5.069 ms total, worst frame 0.591 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.82 | 83.59 | 47.38 | 0.66 | 2.95 | 2.35 |
| 3.04 | 71.70 | 63.94 | 0.89 | 1.76 | 1.49 |
| 2.58 | 68.25 | 57.93 | 0.79 | 2.99 | 1.71 |
| 2.13 | 62.93 | 46.24 | 16.32 | 0.06 | 2.49 |
| 2.35 | 58.33 | 43.59 | 17.83 | 0.06 | 2.07 |
