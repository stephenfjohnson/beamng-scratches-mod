# sustained - 20261114-222639_sustained_synth-full-vk-endurance_r33

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.006 s - 2467 frames, 82.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17097 | 10089 | 38 | 584 | 102 | 165 | 172 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5551, BelowThresh 1442, NormalForce 15

Body materials: METAL 10037, PLASTIC 52

Surfaces: ASPHALT 9310, COBBLESTONE 779

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.231 | 1.648 | 13.473 |
| whole frame, ms | 12.103 (p50) | 15.07 | 25.182 |
| all GE Lua, ms | | 2.655 | 14.336 |
| physics + vehicle Lua, ms | | 0.081 | 0.34 |
| render, ms | | 1.964 | |

- Painter frames over 4 ms: 26; worst flush (project + bake) 1.664 ms, worst composite 0.133 ms.
- Detector: 3.469 us per contact, 81.566 ms total, worst frame 0.543 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.41 | 25.18 | 12.94 | 1.32 | 0.05 | 1.50 |
| 25.41 | 24.34 | 9.59 | 1.65 | 0.07 | 1.97 |
| 17.01 | 23.59 | 5.96 | 1.12 | 0.04 | 1.41 |
| 0.36 | 23.45 | 9.56 | 1.78 | 0.05 | 1.57 |
| 0.41 | 22.03 | 13.47 | 1.45 | 0.06 | 1.48 |
