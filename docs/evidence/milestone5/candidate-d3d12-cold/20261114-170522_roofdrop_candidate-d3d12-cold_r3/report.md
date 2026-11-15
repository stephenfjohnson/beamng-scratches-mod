# roofdrop - 20261114-170522_roofdrop_candidate-d3d12-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 6.172 s - 499 frames, 77.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1397 | 56 | 56 | 0 | 58 | 19 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 844, BelowThresh 497

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.414 | 13.653 | 51.533 |
| whole frame, ms | 11.029 (p50) | 26.463 | 64.631 |
| all GE Lua, ms | | 14.947 | 52.844 |
| physics + vehicle Lua, ms | | 0.126 | 1.182 |
| render, ms | | 3.256 | |

- Painter frames over 4 ms: 32; worst flush (project + bake) 28.766 ms, worst composite 0.229 ms.
- Detector: 2.974 us per contact, 8.538 ms total, worst frame 0.624 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.97 | 64.63 | 51.53 | 49.76 | 0.10 | 2.62 |
| 0.95 | 60.25 | 47.61 | 19.35 | 0.09 | 2.57 |
| 1.58 | 59.78 | 46.49 | 30.17 | 0.07 | 4.27 |
| 0.54 | 58.14 | 46.37 | 20.02 | 0.17 | 2.29 |
| 1.16 | 47.61 | 36.36 | 17.22 | 0.09 | 3.20 |
