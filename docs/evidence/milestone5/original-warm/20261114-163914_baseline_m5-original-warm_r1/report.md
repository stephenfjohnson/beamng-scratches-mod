# baseline - 20261114-163914_baseline_m5-original-warm_r1

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Settled: False after 4.002 s - 357 frames, 88.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4754 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4754

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.004 | 0.006 | 0.008 |
| whole frame, ms | 11.161 (p50) | 13.143 | 15.5 |
| all GE Lua, ms | | 0.961 | 5.568 |
| physics + vehicle Lua, ms | | 0.115 | 0.186 |
| render, ms | | 3.04 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.399 us per contact, 3.896 ms total, worst frame 0.621 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.04 | 15.50 | 0.00 | 5.57 | 0.07 | 2.38 |
| 2.74 | 15.42 | 0.01 | 0.76 | 0.04 | 3.75 |
| 2.93 | 14.85 | 0.00 | 1.06 | 0.04 | 2.75 |
| 0.49 | 14.72 | 0.00 | 0.64 | 0.09 | 2.62 |
| 3.24 | 14.61 | 0.00 | 0.61 | 0.04 | 2.44 |
