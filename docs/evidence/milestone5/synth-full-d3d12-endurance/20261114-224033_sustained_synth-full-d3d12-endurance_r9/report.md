# sustained - 20261114-224033_sustained_synth-full-d3d12-endurance_r9

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.003 s - 2660 frames, 87.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15482 | 7211 | 97 | 597 | 172 | 259 | 276 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6269, BelowThresh 1954, NormalForce 48

Body materials: METAL 7189, PLASTIC 22

Surfaces: ASPHALT 6800, COBBLESTONE 411

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.237 | 11.394 | 30.351 |
| whole frame, ms | 10.829 (p50) | 21.879 | 419.321 |
| all GE Lua, ms | | 12.283 | 31.35 |
| physics + vehicle Lua, ms | | 0.082 | 1.26 |
| render, ms | | 2.223 | |

- Painter frames over 4 ms: 276; worst flush (project + bake) 1.537 ms, worst composite 0.202 ms.
- Detector: 3.028 us per contact, 69.403 ms total, worst frame 0.575 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 15.47 | 419.32 | 0.43 | 0.76 | 0.04 | 1.72 |
| 0.34 | 38.74 | 27.87 | 1.68 | 0.04 | 1.64 |
| 0.43 | 36.70 | 30.35 | 2.25 | 0.07 | 1.43 |
| 12.38 | 33.62 | 23.79 | 1.35 | 0.06 | 1.86 |
| 16.96 | 33.28 | 20.57 | 1.23 | 0.06 | 2.46 |
