# sideslide - 20261114-170951_sideslide_candidate-traffic

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.227 s - 150 frames, 36.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.171)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1243 | 255 | 96 | 47 | 176 | 83 | 57 | 0.0% | 0 | 8 |

Rejected contacts: Wheel 698, BelowThresh 290

Body materials: METAL 179, PLASTIC 76

Surfaces: ASPHALT 255

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.973 | 43.52 | 52.377 |
| whole frame, ms | 15.237 (p50) | 55.694 | 62.623 |
| all GE Lua, ms | | 45.142 | 53.925 |
| physics + vehicle Lua, ms | | 4.969 | 7.936 |
| render, ms | | 3.036 | |

- Painter frames over 4 ms: 74; worst flush (project + bake) 52.34 ms, worst composite 0.162 ms.
- Detector: 1.524 us per contact, 4.41 ms total, worst frame 0.354 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.67 | 62.62 | 52.38 | 0.98 | 2.26 | 1.90 |
| 0.19 | 60.65 | 48.53 | 41.60 | 0.14 | 2.26 |
| 1.17 | 60.55 | 42.05 | 42.73 | 0.25 | 3.46 |
| 3.22 | 59.77 | 30.65 | 1.30 | 7.94 | 6.54 |
| 1.13 | 59.48 | 41.05 | 42.63 | 0.28 | 3.02 |
