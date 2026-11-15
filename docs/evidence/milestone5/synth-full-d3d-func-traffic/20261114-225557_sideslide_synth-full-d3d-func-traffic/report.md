# sideslide - 20261114-225557_sideslide_synth-full-d3d-func-traffic

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.21 s - 228 frames, 54.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.171)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2104 | 417 | 93 | 81 | 156 | 75 | 111 | 0.0% | 0 | 3 |

Rejected contacts: Wheel 1114, BelowThresh 571, NormalForce 2

Body materials: METAL 302, PLASTIC 115

Surfaces: ASPHALT 417

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 8.244 | 21.846 | 29.636 |
| whole frame, ms | 13.53 (p50) | 32.321 | 38.792 |
| all GE Lua, ms | | 23.414 | 31.052 |
| physics + vehicle Lua, ms | | 0.229 | 2.409 |
| render, ms | | 2.301 | |

- Painter frames over 4 ms: 111; worst flush (project + bake) 3.056 ms, worst composite 0.105 ms.
- Detector: 1.597 us per contact, 6.979 ms total, worst frame 0.485 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.20 | 38.79 | 29.64 | 26.56 | 0.14 | 2.00 |
| 0.33 | 37.95 | 26.74 | 4.30 | 0.15 | 2.58 |
| 0.21 | 36.19 | 25.93 | 31.05 | 0.14 | 1.58 |
| 1.34 | 35.53 | 22.76 | 26.19 | 0.21 | 2.78 |
| 1.32 | 35.26 | 24.21 | 3.49 | 1.07 | 2.98 |
