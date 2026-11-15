# sideslide - 20261114-174044_sideslide_candidate-d3d12-endurance_r34

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.117 s - 161 frames, 42.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.161)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1445 | 278 | 71 | 56 | 138 | 84 | 52 | 0.0% | 0 | 11 |

Rejected contacts: Wheel 819, BelowThresh 347, NormalForce 1

Body materials: METAL 195, PLASTIC 83

Surfaces: ASPHALT 278

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 12.748 | 40.502 | 48.789 |
| whole frame, ms | 12.355 (p50) | 52.418 | 82.14 |
| all GE Lua, ms | | 41.625 | 49.911 |
| physics + vehicle Lua, ms | | 5.376 | 8.463 |
| render, ms | | 2.383 | |

- Painter frames over 4 ms: 68; worst flush (project + bake) 48.729 ms, worst composite 0.138 ms.
- Detector: 1.502 us per contact, 5.317 ms total, worst frame 0.869 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 82.14 | 48.79 | 1.20 | 0.30 | 8.88 |
| 2.84 | 61.93 | 28.90 | 0.92 | 7.76 | 2.56 |
| 0.67 | 55.88 | 39.71 | 40.75 | 0.12 | 1.96 |
| 0.38 | 54.28 | 43.58 | 1.07 | 0.05 | 1.88 |
| 0.70 | 54.20 | 43.11 | 41.07 | 0.08 | 1.70 |
