# circle - 20261114-184725_circle_resumed-half-circle-d3d12_r1

_continuous additive roof scrape in a 25 m radius circle; no mid-run reset_

**Run error:** `aborted`

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 0.0 s - 21106 frames, 89.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 909 | 1146 | 1283 | 0.0% | 0 | 2 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.229 | 5.958 | 130.781 |
| whole frame, ms | 10.51 (p50) | 14.182 | 145.205 |
| all GE Lua, ms | | 6.963 | 133.054 |
| physics + vehicle Lua, ms | | 0.098 | 1.198 |
| render, ms | | 2.288 | |

- Painter frames over 4 ms: 1223; worst flush (project + bake) 44.028 ms, worst composite 0.145 ms.
- Detector: 0 us per contact, 0.0 ms total, worst frame 0.0 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 69.91 | 145.21 | 130.78 | 25.80 | 0.16 | 2.13 |
| 183.78 | 53.70 | 0.00 | 6.62 | 0.08 | 1.79 |
| 106.17 | 50.80 | 44.06 | 6.57 | 0.07 | 1.74 |
| 108.75 | 50.32 | 38.80 | 0.81 | 0.06 | 1.87 |
| 76.77 | 47.74 | 36.46 | 0.76 | 0.06 | 1.77 |
