# baseline - 20261114-164512_baseline_original-d3d12-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: False after 4.004 s - 363 frames, 90.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4851 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4851

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.091 |
| whole frame, ms | 11.013 (p50) | 13.805 | 16.929 |
| all GE Lua, ms | | 1.188 | 3.076 |
| physics + vehicle Lua, ms | | 0.123 | 0.222 |
| render, ms | | 3.013 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.623 us per contact, 5.111 ms total, worst frame 0.633 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.02 | 16.93 | 0.01 | 1.17 | 0.18 | 5.84 |
| 1.39 | 16.70 | 0.01 | 0.76 | 0.05 | 2.02 |
| 0.26 | 16.66 | 0.01 | 0.78 | 0.09 | 2.51 |
| 1.22 | 16.43 | 0.01 | 0.91 | 0.05 | 1.90 |
| 1.45 | 15.51 | 0.01 | 0.76 | 0.04 | 2.39 |
