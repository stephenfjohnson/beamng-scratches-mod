# sustained - 20261114-223947_sustained_synth-full-d3d12-endurance_r6

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.006 s - 2594 frames, 86.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18253 | 9462 | 63 | 583 | 114 | 180 | 205 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 7584, BelowThresh 1174, NormalForce 33

Body materials: METAL 9457, PLASTIC 5

Surfaces: ASPHALT 8843, COBBLESTONE 619

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.079 | 11.477 | 29.853 |
| whole frame, ms | 10.934 (p50) | 21.904 | 40.052 |
| all GE Lua, ms | | 12.438 | 31.005 |
| physics + vehicle Lua, ms | | 0.089 | 2.796 |
| render, ms | | 2.564 | |

- Painter frames over 4 ms: 205; worst flush (project + bake) 2.219 ms, worst composite 0.117 ms.
- Detector: 3.302 us per contact, 84.793 ms total, worst frame 1.731 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.96 | 40.05 | 18.98 | 3.08 | 0.11 | 1.89 |
| 0.76 | 38.81 | 29.85 | 21.53 | 0.07 | 1.61 |
| 14.04 | 37.07 | 23.75 | 21.18 | 0.13 | 2.01 |
| 4.28 | 36.31 | 19.84 | 4.15 | 0.08 | 2.67 |
| 3.23 | 35.76 | 21.17 | 20.78 | 0.08 | 2.09 |
