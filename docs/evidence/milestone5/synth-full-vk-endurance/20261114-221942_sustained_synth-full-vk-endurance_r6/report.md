# sustained - 20261114-221942_sustained_synth-full-vk-endurance_r6

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.01 s - 2488 frames, 82.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16898 | 9267 | 49 | 580 | 125 | 186 | 189 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5519, BelowThresh 2099, NormalForce 13

Body materials: METAL 9205, PLASTIC 62

Surfaces: ASPHALT 8630, COBBLESTONE 637

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.234 | 1.646 | 15.727 |
| whole frame, ms | 11.98 (p50) | 15.241 | 60.268 |
| all GE Lua, ms | | 2.775 | 16.804 |
| physics + vehicle Lua, ms | | 0.082 | 0.312 |
| render, ms | | 1.918 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 1.182 ms, worst composite 0.105 ms.
- Detector: 3.227 us per contact, 76.192 ms total, worst frame 0.404 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 7.58 | 60.27 | 0.01 | 0.75 | 0.04 | 1.52 |
| 0.41 | 33.79 | 15.73 | 1.41 | 0.05 | 1.42 |
| 12.43 | 28.07 | 13.53 | 1.46 | 0.05 | 1.41 |
| 11.73 | 27.45 | 15.18 | 1.20 | 0.07 | 1.56 |
| 29.65 | 24.91 | 8.49 | 10.41 | 0.07 | 1.51 |
