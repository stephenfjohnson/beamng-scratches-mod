# sideslide - 20261114-164456_sideslide_original-d3d12-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 5.739 s - 227 frames, 36.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.178)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1650 | 322 | 115 | 55 | 193 | 86 | 60 | 0.0% | 0 | 8 |

Rejected contacts: Wheel 764, BelowThresh 564

Body materials: METAL 225, PLASTIC 97

Surfaces: ASPHALT 322

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 13.742 | 49.121 | 63.819 |
| whole frame, ms | 14.768 (p50) | 61.68 | 81.304 |
| all GE Lua, ms | | 50.679 | 66.307 |
| physics + vehicle Lua, ms | | 7.136 | 15.31 |
| render, ms | | 2.945 | |

- Painter frames over 4 ms: 81; worst flush (project + bake) 63.771 ms, worst composite 0.137 ms.
- Detector: 2.662 us per contact, 9.158 ms total, worst frame 0.764 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.00 | 81.30 | 46.58 | 1.43 | 13.20 | 2.41 |
| 1.22 | 77.27 | 63.82 | 1.50 | 2.39 | 2.51 |
| 2.30 | 71.19 | 53.70 | 1.69 | 3.58 | 2.21 |
| 3.63 | 70.66 | 47.10 | 1.15 | 11.08 | 2.37 |
| 0.19 | 67.22 | 56.31 | 42.43 | 0.10 | 2.60 |
