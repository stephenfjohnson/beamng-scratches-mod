# sideslide - 20261114-170305_sideslide_candidate-d3d12-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.339 s - 148 frames, 33.8 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.153)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1058 | 317 | 94 | 64 | 156 | 87 | 57 | 0.0% | 0 | 10 |

Rejected contacts: Wheel 549, BelowThresh 190, NormalForce 2

Body materials: METAL 230, PLASTIC 87

Surfaces: ASPHALT 317

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 20.761 | 52.767 | 71.739 |
| whole frame, ms | 25.668 (p50) | 72.041 | 87.849 |
| all GE Lua, ms | | 54.448 | 73.661 |
| physics + vehicle Lua, ms | | 11.879 | 17.155 |
| render, ms | | 2.82 | |

- Painter frames over 4 ms: 73; worst flush (project + bake) 59.058 ms, worst composite 0.203 ms.
- Detector: 3.299 us per contact, 8.386 ms total, worst frame 0.872 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.22 | 87.85 | 51.23 | 1.13 | 15.22 | 2.63 |
| 0.19 | 87.46 | 71.74 | 27.70 | 0.15 | 2.53 |
| 2.74 | 87.27 | 53.03 | 1.32 | 17.15 | 2.29 |
| 0.80 | 81.28 | 52.75 | 1.65 | 3.21 | 2.60 |
| 1.02 | 78.22 | 52.12 | 1.44 | 0.07 | 2.43 |
