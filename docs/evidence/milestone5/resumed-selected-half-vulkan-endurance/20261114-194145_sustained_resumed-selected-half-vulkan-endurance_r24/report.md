# sustained - 20261114-194145_sustained_resumed-selected-half-vulkan-endurance_r24

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.004 s - 2328 frames, 77.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14964 | 7438 | 76 | 602 | 134 | 207 | 228 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5846, BelowThresh 1662, NormalForce 18

Body materials: METAL 7423, PLASTIC 15

Surfaces: ASPHALT 6497, COBBLESTONE 941

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.648 | 33.306 | 41.889 |
| whole frame, ms | 11.773 (p50) | 41.306 | 50.055 |
| all GE Lua, ms | | 34.235 | 43.095 |
| physics + vehicle Lua, ms | | 0.082 | 0.543 |
| render, ms | | 1.696 | |

- Painter frames over 4 ms: 192; worst flush (project + bake) 41.861 ms, worst composite 0.894 ms.
- Detector: 3.194 us per contact, 68.477 ms total, worst frame 0.539 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 21.11 | 50.06 | 37.11 | 0.89 | 0.06 | 1.36 |
| 20.55 | 48.79 | 36.34 | 0.87 | 0.05 | 1.14 |
| 28.10 | 48.78 | 35.95 | 0.89 | 0.05 | 1.19 |
| 19.46 | 48.59 | 36.51 | 0.87 | 0.05 | 1.29 |
| 25.96 | 48.49 | 36.04 | 0.96 | 0.06 | 1.26 |
