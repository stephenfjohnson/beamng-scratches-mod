# sustained - 20261114-223901_sustained_synth-full-d3d12-endurance_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.009 s - 2589 frames, 85.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16112 | 7402 | 72 | 580 | 147 | 257 | 290 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6781, BelowThresh 1867, NormalForce 62

Body materials: METAL 7389, PLASTIC 13

Surfaces: ASPHALT 6904, COBBLESTONE 498

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.486 | 12.285 | 28.995 |
| whole frame, ms | 10.901 (p50) | 23.031 | 416.757 |
| all GE Lua, ms | | 13.301 | 30.005 |
| physics + vehicle Lua, ms | | 0.092 | 1.517 |
| render, ms | | 2.529 | |

- Painter frames over 4 ms: 291; worst flush (project + bake) 4.042 ms, worst composite 0.215 ms.
- Detector: 3.164 us per contact, 72.855 ms total, worst frame 0.414 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 17.91 | 416.76 | 0.38 | 1.04 | 0.08 | 1.91 |
| 12.40 | 37.59 | 28.99 | 2.32 | 0.11 | 2.15 |
| 23.97 | 37.21 | 17.60 | 2.37 | 0.10 | 1.78 |
| 0.64 | 36.41 | 19.51 | 21.12 | 0.15 | 1.70 |
| 0.49 | 36.17 | 20.40 | 27.89 | 0.07 | 2.07 |
