# sustained - 20261114-222420_sustained_synth-full-vk-endurance_r24

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.012 s - 2410 frames, 80.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13998 | 6483 | 41 | 495 | 94 | 168 | 178 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5546, BelowThresh 1937, NormalForce 32

Body materials: METAL 6449, PLASTIC 34

Surfaces: ASPHALT 5937, COBBLESTONE 546

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.255 | 1.945 | 35.504 |
| whole frame, ms | 12.348 (p50) | 15.628 | 46.06 |
| all GE Lua, ms | | 3.036 | 36.54 |
| physics + vehicle Lua, ms | | 0.087 | 0.372 |
| render, ms | | 2.101 | |

- Painter frames over 4 ms: 26; worst flush (project + bake) 1.903 ms, worst composite 0.112 ms.
- Detector: 3.255 us per contact, 66.975 ms total, worst frame 0.345 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.30 | 46.06 | 35.50 | 2.80 | 0.07 | 1.17 |
| 0.42 | 24.54 | 10.89 | 1.23 | 0.05 | 1.23 |
| 1.51 | 24.09 | 2.80 | 2.54 | 0.06 | 1.43 |
| 0.67 | 23.00 | 3.03 | 5.85 | 0.07 | 1.38 |
| 14.46 | 22.09 | 0.01 | 1.24 | 0.08 | 2.40 |
