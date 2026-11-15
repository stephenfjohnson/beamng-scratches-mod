# sustained - 20261114-181641_sustained_resumed-half-b3-fast-coalesced_r1

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

**Run error:** `[string "lua/ge/extensions/scratches/bench.lua"]:217: no player vehicle`

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(2); scratches_paint.setLayerBudget(12); scratches_paint.setCoverageCoalescing(true)`

Settled: False after 0.0 s - 1485 frames, 76.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 963 | 250 | 371 | 0.0% | 0 | 109 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.671 | 22.068 | 668.124 |
| whole frame, ms | 10.832 (p50) | 30.123 | 678.234 |
| all GE Lua, ms | | 23.243 | 669.474 |
| physics + vehicle Lua, ms | | 0.103 | 13.314 |
| render, ms | | 2.463 | |

- Painter frames over 4 ms: 281; worst flush (project + bake) 32.824 ms, worst composite 0.662 ms.
- Detector: 0 us per contact, 0.0 ms total, worst frame 0.0 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 7.88 | 678.23 | 668.12 | 22.88 | 0.13 | 2.20 |
| 14.04 | 44.55 | 32.86 | 1.05 | 0.07 | 1.78 |
| 15.38 | 44.28 | 32.67 | 0.95 | 0.09 | 1.77 |
| 17.77 | 43.14 | 29.88 | 0.99 | 0.05 | 1.84 |
| 10.71 | 42.71 | 30.26 | 0.81 | 0.05 | 1.91 |
