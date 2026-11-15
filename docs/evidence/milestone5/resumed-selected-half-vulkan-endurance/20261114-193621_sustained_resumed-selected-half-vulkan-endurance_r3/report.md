# sustained - 20261114-193621_sustained_resumed-selected-half-vulkan-endurance_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.004 s - 2335 frames, 77.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15360 | 8009 | 55 | 634 | 113 | 191 | 207 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5978, BelowThresh 1348, NormalForce 25

Body materials: METAL 7986, PLASTIC 23

Surfaces: ASPHALT 6986, COBBLESTONE 1023

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.436 | 31.825 | 36.681 |
| whole frame, ms | 11.699 (p50) | 38.128 | 49.077 |
| all GE Lua, ms | | 32.87 | 38.198 |
| physics + vehicle Lua, ms | | 0.088 | 0.768 |
| render, ms | | 1.962 | |

- Painter frames over 4 ms: 183; worst flush (project + bake) 36.657 ms, worst composite 0.163 ms.
- Detector: 3.41 us per contact, 76.481 ms total, worst frame 0.554 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 17.82 | 49.08 | 36.57 | 1.22 | 0.06 | 1.46 |
| 15.25 | 48.48 | 36.27 | 0.86 | 0.05 | 1.30 |
| 6.67 | 48.27 | 32.88 | 1.25 | 0.07 | 2.04 |
| 24.06 | 48.18 | 34.39 | 1.05 | 0.08 | 1.40 |
| 0.28 | 48.17 | 35.82 | 0.87 | 0.06 | 1.40 |
