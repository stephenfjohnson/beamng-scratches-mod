# sustained - 20261114-224254_sustained_synth-full-d3d12-endurance_r18

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.01 s - 2659 frames, 88.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17603 | 9829 | 47 | 575 | 106 | 199 | 212 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6407, BelowThresh 1347, NormalForce 20

Body materials: METAL 9804, PLASTIC 25

Surfaces: ASPHALT 8935, COBBLESTONE 894

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.994 | 11.122 | 26.326 |
| whole frame, ms | 10.923 (p50) | 21.053 | 37.761 |
| all GE Lua, ms | | 12.011 | 27.323 |
| physics + vehicle Lua, ms | | 0.087 | 1.042 |
| render, ms | | 2.503 | |

- Painter frames over 4 ms: 212; worst flush (project + bake) 1.643 ms, worst composite 0.144 ms.
- Detector: 3.463 us per contact, 83.397 ms total, worst frame 0.324 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.46 | 37.76 | 23.48 | 24.77 | 0.09 | 2.01 |
| 12.34 | 36.53 | 26.33 | 2.46 | 0.11 | 2.47 |
| 0.34 | 35.45 | 25.81 | 2.09 | 0.07 | 1.72 |
| 27.23 | 31.23 | 21.13 | 2.19 | 0.08 | 2.65 |
| 0.45 | 31.01 | 23.84 | 2.06 | 0.04 | 1.91 |
