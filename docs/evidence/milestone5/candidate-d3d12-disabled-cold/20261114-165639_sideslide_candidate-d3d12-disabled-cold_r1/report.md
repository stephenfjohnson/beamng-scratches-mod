# sideslide - 20261114-165639_sideslide_candidate-d3d12-disabled-cold_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.076 s - 418 frames, 102.3 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.142)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3860 | 1052 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1992, BelowThresh 809, NormalForce 7

Body materials: METAL 792, PLASTIC 260

Surfaces: ASPHALT 1052

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.009 | 0.011 | 0.397 |
| whole frame, ms | 10.32 (p50) | 12.153 | 15.155 |
| all GE Lua, ms | | 1.241 | 2.329 |
| physics + vehicle Lua, ms | | 0.097 | 0.256 |
| render, ms | | 2.825 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.287 us per contact, 6.577 ms total, worst frame 0.169 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.85 | 15.15 | 0.01 | 1.14 | 0.06 | 2.61 |
| 0.61 | 14.96 | 0.01 | 0.76 | 0.05 | 1.85 |
| 1.45 | 14.48 | 0.01 | 1.07 | 0.06 | 3.49 |
| 1.53 | 13.87 | 0.01 | 2.33 | 0.07 | 2.06 |
| 2.88 | 13.85 | 0.01 | 0.78 | 0.05 | 2.19 |
