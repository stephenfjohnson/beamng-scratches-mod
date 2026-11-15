# sustained - 20261114-224428_sustained_synth-full-d3d12-endurance_r24

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.01 s - 2666 frames, 88.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18598 | 9034 | 53 | 637 | 86 | 180 | 201 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 7503, BelowThresh 2021, NormalForce 40

Body materials: METAL 9009, PLASTIC 25

Surfaces: ASPHALT 7413, COBBLESTONE 1621

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.967 | 11.05 | 29.222 |
| whole frame, ms | 10.896 (p50) | 21.253 | 37.516 |
| all GE Lua, ms | | 11.936 | 30.137 |
| physics + vehicle Lua, ms | | 0.081 | 1.599 |
| render, ms | | 2.307 | |

- Painter frames over 4 ms: 201; worst flush (project + bake) 3.27 ms, worst composite 0.159 ms.
- Detector: 2.964 us per contact, 77.064 ms total, worst frame 0.421 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.44 | 37.52 | 25.61 | 30.14 | 0.06 | 1.87 |
| 12.51 | 36.93 | 28.29 | 1.68 | 0.06 | 1.92 |
| 0.42 | 36.47 | 29.22 | 2.00 | 0.04 | 1.47 |
| 2.11 | 34.79 | 16.61 | 17.56 | 0.06 | 2.18 |
| 12.00 | 33.15 | 22.58 | 1.38 | 0.06 | 1.80 |
