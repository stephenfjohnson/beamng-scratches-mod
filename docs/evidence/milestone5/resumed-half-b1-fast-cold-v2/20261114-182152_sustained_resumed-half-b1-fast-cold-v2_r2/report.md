# sustained - 20261114-182152_sustained_resumed-half-b1-fast-cold-v2_r2

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

**Run error:** `[string "lua/ge/extensions/scratches/bench.lua"]:217: no player vehicle`

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(2); scratches_paint.setLayerBudget(12); scratches_paint.setCoverageCoalescing(true)`

Settled: False after 0.0 s - 2025 frames, 82.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1472 | 311 | 1308 | 0.0% | 0 | 154 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.632 | 28.829 | 46.326 |
| whole frame, ms | 9.788 (p50) | 37.431 | 56.284 |
| all GE Lua, ms | | 29.824 | 47.53 |
| physics + vehicle Lua, ms | | 0.097 | 5.947 |
| render, ms | | 2.307 | |

- Painter frames over 4 ms: 212; worst flush (project + bake) 46.265 ms, worst composite 0.654 ms.
- Detector: 0 us per contact, 0.0 ms total, worst frame 0.0 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 20.54 | 56.28 | 46.33 | 1.77 | 0.05 | 1.50 |
| 24.26 | 54.30 | 41.42 | 2.12 | 0.06 | 1.93 |
| 24.11 | 53.58 | 40.93 | 1.85 | 0.06 | 1.75 |
| 21.01 | 52.37 | 38.79 | 2.53 | 0.05 | 2.41 |
| 23.76 | 52.31 | 40.26 | 1.92 | 0.06 | 1.91 |
