# sideslide - 20261114-211702_sideslide_resumed-half-d3d-func-traffic

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.546 s - 346 frames, 73.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2837 | 598 | 84 | 123 | 120 | 109 | 130 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1397, BelowThresh 838, NormalForce 4

Body materials: METAL 440, PLASTIC 158

Surfaces: ASPHALT 598

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.616 | 23.808 | 34.701 |
| whole frame, ms | 10.76 (p50) | 31.068 | 44.812 |
| all GE Lua, ms | | 25.156 | 35.666 |
| physics + vehicle Lua, ms | | 0.165 | 0.406 |
| render, ms | | 2.024 | |

- Painter frames over 4 ms: 104; worst flush (project + bake) 34.664 ms, worst composite 0.109 ms.
- Detector: 1.533 us per contact, 8.484 ms total, worst frame 0.344 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 44.81 | 32.76 | 1.31 | 0.12 | 1.92 |
| 2.25 | 41.08 | 34.70 | 0.90 | 0.08 | 1.36 |
| 1.68 | 41.00 | 32.19 | 1.00 | 0.07 | 1.72 |
| 1.95 | 40.65 | 33.78 | 0.97 | 0.08 | 1.43 |
| 0.33 | 40.63 | 32.32 | 10.11 | 0.12 | 1.65 |
