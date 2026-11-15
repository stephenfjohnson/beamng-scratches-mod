# sideslide - 20261114-173239_sideslide_candidate-d3d12-endurance_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.15 s - 135 frames, 34.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.161)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1097 | 284 | 101 | 54 | 166 | 84 | 53 | 0.0% | 0 | 14 |

Rejected contacts: Wheel 589, BelowThresh 223, NormalForce 1

Body materials: METAL 212, PLASTIC 72

Surfaces: ASPHALT 284

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 18.045 | 45.315 | 52.175 |
| whole frame, ms | 26.123 (p50) | 56.981 | 70.457 |
| all GE Lua, ms | | 46.384 | 53.456 |
| physics + vehicle Lua, ms | | 7.26 | 9.33 |
| render, ms | | 2.403 | |

- Painter frames over 4 ms: 69; worst flush (project + bake) 52.129 ms, worst composite 0.163 ms.
- Detector: 1.685 us per contact, 4.161 ms total, worst frame 0.405 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 70.46 | 45.31 | 0.94 | 2.80 | 1.69 |
| 2.14 | 68.14 | 52.17 | 1.08 | 6.09 | 2.66 |
| 1.46 | 67.35 | 33.74 | 0.91 | 6.78 | 2.49 |
| 2.80 | 64.48 | 50.07 | 34.51 | 0.07 | 1.71 |
| 3.27 | 60.22 | 50.85 | 0.88 | 3.04 | 1.51 |
