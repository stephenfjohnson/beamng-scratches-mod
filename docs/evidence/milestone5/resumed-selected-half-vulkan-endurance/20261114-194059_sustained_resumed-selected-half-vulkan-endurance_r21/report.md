# sustained - 20261114-194059_sustained_resumed-selected-half-vulkan-endurance_r21

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.002 s - 2345 frames, 78.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14644 | 7972 | 58 | 568 | 119 | 177 | 204 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5388, BelowThresh 1238, NormalForce 46

Body materials: METAL 7938, PLASTIC 34

Surfaces: ASPHALT 7582, COBBLESTONE 390

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.347 | 32.093 | 37.02 |
| whole frame, ms | 11.82 (p50) | 38.722 | 49.158 |
| all GE Lua, ms | | 33.22 | 38.09 |
| physics + vehicle Lua, ms | | 0.08 | 0.482 |
| render, ms | | 1.616 | |

- Painter frames over 4 ms: 174; worst flush (project + bake) 37.001 ms, worst composite 0.161 ms.
- Detector: 3.32 us per contact, 69.255 ms total, worst frame 0.506 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.86 | 49.16 | 34.91 | 0.83 | 0.06 | 1.40 |
| 1.73 | 48.73 | 37.02 | 2.71 | 0.05 | 1.29 |
| 14.04 | 48.59 | 35.98 | 1.18 | 0.08 | 1.94 |
| 17.82 | 48.29 | 36.71 | 0.68 | 0.05 | 1.21 |
| 0.28 | 48.27 | 36.16 | 0.71 | 0.06 | 1.33 |
