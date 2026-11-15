# sideslide - 20261114-163938_sideslide_m5-original-warm_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Settled: True after 4.381 s - 144 frames, 31.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.153)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 998 | 304 | 107 | 62 | 175 | 84 | 58 | 0.0% | 0 | 15 |

Rejected contacts: Wheel 525, BelowThresh 166, NormalForce 3

Body materials: METAL 219, PLASTIC 85

Surfaces: ASPHALT 304

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 19.366 | 46.51 | 57.871 |
| whole frame, ms | 31.701 (p50) | 61.186 | 75.798 |
| all GE Lua, ms | | 47.423 | 58.653 |
| physics + vehicle Lua, ms | | 7.211 | 11.971 |
| render, ms | | 3.776 | |

- Painter frames over 4 ms: 75; worst flush (project + bake) 57.822 ms, worst composite 0.146 ms.
- Detector: 2.081 us per contact, 5.231 ms total, worst frame 0.633 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.80 | 75.80 | 48.56 | 1.37 | 1.28 | 4.92 |
| 2.31 | 73.05 | 56.11 | 36.35 | 0.13 | 1.82 |
| 2.56 | 72.49 | 57.87 | 1.65 | 3.35 | 2.88 |
| 2.08 | 67.35 | 47.20 | 42.44 | 0.10 | 3.29 |
| 1.86 | 64.49 | 47.65 | 19.42 | 0.09 | 2.09 |
