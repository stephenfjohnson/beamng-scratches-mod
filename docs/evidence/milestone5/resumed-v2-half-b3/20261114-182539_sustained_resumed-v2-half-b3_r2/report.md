# sustained - 20261114-182539_sustained_resumed-v2-half-b3_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true)`

Settled: False after 30.012 s - 2606 frames, 86.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16375 | 9057 | 35 | 540 | 96 | 173 | 179 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5824, BelowThresh 1466, NormalForce 28

Body materials: METAL 9024, PLASTIC 33

Surfaces: ASPHALT 8473, COBBLESTONE 584

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.846 | 23.632 | 221.784 |
| whole frame, ms | 10.681 (p50) | 30.048 | 231.818 |
| all GE Lua, ms | | 24.569 | 222.665 |
| physics + vehicle Lua, ms | | 0.078 | 0.3 |
| render, ms | | 2.099 | |

- Painter frames over 4 ms: 192; worst flush (project + bake) 221.761 ms, worst composite 0.225 ms.
- Detector: 3.375 us per contact, 73.332 ms total, worst frame 0.428 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 9.38 | 231.82 | 221.78 | 0.83 | 0.06 | 1.80 |
| 25.64 | 48.13 | 42.01 | 0.74 | 0.05 | 1.38 |
| 29.53 | 43.76 | 32.17 | 1.00 | 0.06 | 1.91 |
| 5.43 | 43.37 | 34.19 | 0.89 | 0.07 | 1.81 |
| 11.71 | 42.45 | 31.09 | 0.72 | 0.07 | 1.87 |
