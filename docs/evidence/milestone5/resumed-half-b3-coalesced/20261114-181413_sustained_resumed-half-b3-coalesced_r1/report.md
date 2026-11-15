# sustained - 20261114-181413_sustained_resumed-half-b3-coalesced_r1

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

**Run error:** `[string "lua/ge/extensions/scratches/bench.lua"]:217: no player vehicle`

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setCoverageCoalescing(true)`

Settled: False after 0.0 s - 1818 frames, 83.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1270 | 269 | 443 | 0.0% | 0 | 46 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.855 | 10.753 | 53.552 |
| whole frame, ms | 10.447 (p50) | 19.313 | 65.476 |
| all GE Lua, ms | | 12.401 | 54.38 |
| physics + vehicle Lua, ms | | 0.088 | 9.915 |
| render, ms | | 2.2 | |

- Painter frames over 4 ms: 312; worst flush (project + bake) 53.52 ms, worst composite 0.9 ms.
- Detector: 0 us per contact, 0.0 ms total, worst frame 0.0 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 65.48 | 53.55 | 0.79 | 0.06 | 1.83 |
| 19.33 | 58.19 | 47.47 | 0.90 | 0.06 | 1.82 |
| 17.46 | 57.71 | 46.14 | 0.85 | 0.04 | 2.29 |
| 0.81 | 55.03 | 43.07 | 0.80 | 0.05 | 1.90 |
| 18.71 | 55.00 | 44.16 | 0.85 | 0.07 | 1.81 |
