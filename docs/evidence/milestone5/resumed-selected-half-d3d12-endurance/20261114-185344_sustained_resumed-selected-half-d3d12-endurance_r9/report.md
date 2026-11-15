# sustained - 20261114-185344_sustained_resumed-selected-half-d3d12-endurance_r9

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.009 s - 2588 frames, 86.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16204 | 8074 | 50 | 555 | 97 | 182 | 221 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6747, BelowThresh 1347, NormalForce 36

Body materials: METAL 8065, PLASTIC 9

Surfaces: ASPHALT 7411, COBBLESTONE 663

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.964 | 24.467 | 34.293 |
| whole frame, ms | 10.626 (p50) | 31.712 | 43.489 |
| all GE Lua, ms | | 25.451 | 35.201 |
| physics + vehicle Lua, ms | | 0.082 | 0.36 |
| render, ms | | 2.333 | |

- Painter frames over 4 ms: 225; worst flush (project + bake) 34.271 ms, worst composite 0.173 ms.
- Detector: 3.1 us per contact, 69.702 ms total, worst frame 0.345 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 10.60 | 43.49 | 31.97 | 0.86 | 0.06 | 1.82 |
| 11.84 | 43.18 | 34.29 | 0.77 | 0.04 | 1.47 |
| 10.88 | 42.78 | 31.95 | 0.76 | 0.05 | 1.81 |
| 1.85 | 42.12 | 32.05 | 0.90 | 0.06 | 2.24 |
| 4.09 | 42.02 | 30.49 | 0.86 | 0.04 | 1.92 |
