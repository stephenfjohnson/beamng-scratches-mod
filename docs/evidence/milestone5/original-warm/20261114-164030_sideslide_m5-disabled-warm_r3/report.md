# sideslide - 20261114-164030_sideslide_m5-disabled-warm_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.192 s - 391 frames, 93.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.165)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3066 | 874 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1445, BelowThresh 738, NormalForce 9

Body materials: METAL 657, PLASTIC 217

Surfaces: ASPHALT 874

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.004 | 0.006 | 0.009 |
| whole frame, ms | 10.645 (p50) | 12.843 | 16.048 |
| all GE Lua, ms | | 0.905 | 3.206 |
| physics + vehicle Lua, ms | | 0.089 | 0.129 |
| render, ms | | 2.875 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.086 us per contact, 4.974 ms total, worst frame 0.045 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.94 | 16.05 | 0.00 | 0.88 | 0.06 | 2.79 |
| 1.50 | 15.81 | 0.00 | 0.84 | 0.04 | 2.63 |
| 3.32 | 14.98 | 0.01 | 0.78 | 0.05 | 2.20 |
| 1.05 | 14.52 | 0.01 | 0.62 | 0.06 | 3.25 |
| 3.03 | 14.42 | 0.00 | 0.81 | 0.05 | 2.55 |
