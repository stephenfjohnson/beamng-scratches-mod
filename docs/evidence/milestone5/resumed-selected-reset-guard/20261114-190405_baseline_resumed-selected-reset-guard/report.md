# baseline - 20261114-190405_baseline_resumed-selected-reset-guard

_upright, coasting at 15 m/s - should leave no marks_

**Run error:** `[string "lua/ge/extensions/scratches/bench.lua"]:143: cosmetic reset during measured run; queues/coverage invalidated`

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 0.0 s - 90 frames, 87.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.016 |
| whole frame, ms | 11.415 (p50) | 12.884 | 16.368 |
| all GE Lua, ms | | 1.054 | 1.695 |
| physics + vehicle Lua, ms | | 0.127 | 0.168 |
| render, ms | | 3.036 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0 us per contact, 0.0 ms total, worst frame 0.0 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.61 | 16.37 | 0.01 | 0.86 | 0.07 | 3.17 |
| 0.90 | 15.05 | 0.01 | 0.90 | 0.07 | 3.40 |
| 0.64 | 13.25 | 0.01 | 0.99 | 0.08 | 3.88 |
| 0.42 | 12.92 | 0.01 | 0.95 | 0.10 | 2.39 |
| 0.57 | 12.88 | 0.01 | 1.05 | 0.10 | 2.88 |
