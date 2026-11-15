# sustained - 20261114-202342_sustained_resumed-fixed2-full-vulkan-endurance_r24

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.012 s - 2215 frames, 73.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13870 | 7073 | 77 | 643 | 150 | 252 | 266 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5185, BelowThresh 1583, NormalForce 29

Body materials: METAL 7039, PLASTIC 34

Surfaces: ASPHALT 6147, COBBLESTONE 926

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.053 | 29.102 | 37.147 |
| whole frame, ms | 11.754 (p50) | 36.574 | 49.216 |
| all GE Lua, ms | | 30.128 | 39.356 |
| physics + vehicle Lua, ms | | 0.104 | 1.379 |
| render, ms | | 2.002 | |

- Painter frames over 4 ms: 240; worst flush (project + bake) 37.118 ms, worst composite 0.153 ms.
- Detector: 3.494 us per contact, 71.378 ms total, worst frame 0.416 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 26.36 | 49.22 | 34.05 | 1.02 | 0.05 | 1.62 |
| 24.22 | 48.36 | 35.69 | 0.78 | 0.05 | 1.65 |
| 22.27 | 48.36 | 35.50 | 0.94 | 0.07 | 1.24 |
| 0.28 | 48.34 | 35.32 | 0.94 | 0.06 | 1.21 |
| 22.09 | 47.96 | 34.33 | 0.84 | 0.08 | 1.25 |
