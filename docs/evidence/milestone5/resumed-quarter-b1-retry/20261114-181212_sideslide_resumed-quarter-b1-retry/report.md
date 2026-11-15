# sideslide - 20261114-181212_sideslide_resumed-quarter-b1-retry

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(1)`

Settled: False after 10.006 s - 1000 frames, 99.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 0.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.062 |
| whole frame, ms | 9.996 (p50) | 10.888 | 17.435 |
| all GE Lua, ms | | 0.862 | 2.803 |
| physics + vehicle Lua, ms | | 0.04 | 0.148 |
| render, ms | | 2.091 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0 us per contact, 0.0 ms total, worst frame 0.0 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.82 | 17.44 | 0.01 | 1.42 | 0.05 | 2.41 |
| 7.76 | 13.94 | 0.00 | 0.76 | 0.04 | 1.79 |
| 2.10 | 13.22 | 0.01 | 0.60 | 0.03 | 2.04 |
| 4.93 | 13.16 | 0.00 | 0.55 | 0.03 | 1.78 |
| 2.76 | 13.04 | 0.01 | 0.60 | 0.03 | 1.74 |
