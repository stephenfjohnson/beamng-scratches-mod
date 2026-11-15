# sustained - 20261114-202602_sustained_resumed-fixed2-full-vulkan-endurance_r33

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.006 s - 2299 frames, 76.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14015 | 6777 | 42 | 538 | 118 | 178 | 191 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5466, BelowThresh 1722, NormalForce 50

Body materials: METAL 6700, PLASTIC 77

Surfaces: ASPHALT 5948, COBBLESTONE 829

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.425 | 31.328 | 37.783 |
| whole frame, ms | 11.798 (p50) | 38.654 | 49.718 |
| all GE Lua, ms | | 32.225 | 38.781 |
| physics + vehicle Lua, ms | | 0.091 | 0.762 |
| render, ms | | 1.825 | |

- Painter frames over 4 ms: 177; worst flush (project + bake) 37.76 ms, worst composite 0.109 ms.
- Detector: 3.332 us per contact, 66.747 ms total, worst frame 0.521 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.43 | 49.72 | 36.50 | 0.93 | 0.08 | 1.36 |
| 29.62 | 49.68 | 37.78 | 0.88 | 0.06 | 1.53 |
| 12.17 | 48.40 | 34.75 | 0.67 | 0.04 | 1.57 |
| 0.27 | 48.22 | 35.88 | 0.75 | 0.05 | 1.65 |
| 22.77 | 48.19 | 35.43 | 1.08 | 0.05 | 1.46 |
