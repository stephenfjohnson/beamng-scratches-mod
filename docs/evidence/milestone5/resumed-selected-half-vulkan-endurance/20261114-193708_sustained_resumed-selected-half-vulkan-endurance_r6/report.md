# sustained - 20261114-193708_sustained_resumed-selected-half-vulkan-endurance_r6

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.007 s - 2328 frames, 77.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14387 | 7368 | 68 | 589 | 128 | 201 | 227 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5548, BelowThresh 1448, NormalForce 23

Body materials: METAL 7352, PLASTIC 16

Surfaces: ASPHALT 6440, COBBLESTONE 928

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.575 | 32.883 | 37.534 |
| whole frame, ms | 11.748 (p50) | 40.993 | 49.796 |
| all GE Lua, ms | | 34.213 | 38.559 |
| physics + vehicle Lua, ms | | 0.084 | 0.818 |
| render, ms | | 1.752 | |

- Painter frames over 4 ms: 189; worst flush (project + bake) 37.517 ms, worst composite 0.077 ms.
- Detector: 3.135 us per contact, 66.433 ms total, worst frame 0.53 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 21.77 | 49.80 | 37.53 | 0.72 | 0.04 | 1.19 |
| 16.67 | 49.40 | 36.57 | 0.78 | 0.05 | 1.32 |
| 1.29 | 49.35 | 37.32 | 1.28 | 0.05 | 1.39 |
| 1.84 | 49.06 | 36.59 | 0.90 | 0.04 | 1.33 |
| 24.24 | 48.85 | 35.10 | 0.77 | 0.04 | 1.31 |
