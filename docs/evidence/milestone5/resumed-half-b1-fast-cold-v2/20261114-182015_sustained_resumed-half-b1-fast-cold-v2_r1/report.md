# sustained - 20261114-182015_sustained_resumed-half-b1-fast-cold-v2_r1

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(2); scratches_paint.setLayerBudget(12); scratches_paint.setCoverageCoalescing(true)`

Settled: False after 30.007 s - 2420 frames, 80.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14 | 0 | 0 | 0 | 2167 | 380 | 1726 | 0.0% | 13 | 211 |

Rejected contacts: Wheel 14

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.995 | 31.981 | 43.398 |
| whole frame, ms | 9.819 (p50) | 40.958 | 55.636 |
| all GE Lua, ms | | 32.857 | 44.305 |
| physics + vehicle Lua, ms | | 0.092 | 4.273 |
| render, ms | | 2.175 | |

- Painter frames over 4 ms: 255; worst flush (project + bake) 43.363 ms, worst composite 0.595 ms.
- Detector: 1.034 us per contact, 34.08 ms total, worst frame 0.524 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 24.86 | 55.64 | 43.40 | 2.12 | 0.06 | 1.62 |
| 26.05 | 52.27 | 37.50 | 1.84 | 0.05 | 2.23 |
| 23.34 | 51.61 | 39.79 | 1.77 | 0.04 | 1.74 |
| 26.14 | 51.53 | 40.26 | 1.80 | 0.07 | 1.34 |
| 21.76 | 51.34 | 39.18 | 1.92 | 0.08 | 1.98 |
