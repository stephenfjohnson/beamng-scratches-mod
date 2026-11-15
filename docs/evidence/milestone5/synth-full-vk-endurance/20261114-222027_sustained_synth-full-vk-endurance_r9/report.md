# sustained - 20261114-222027_sustained_synth-full-vk-endurance_r9

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.007 s - 2473 frames, 82.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15089 | 8017 | 60 | 574 | 130 | 199 | 221 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5660, BelowThresh 1389, NormalForce 23

Body materials: METAL 7969, PLASTIC 48

Surfaces: ASPHALT 7524, COBBLESTONE 493

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.264 | 1.93 | 17.112 |
| whole frame, ms | 12.047 (p50) | 15.184 | 26.399 |
| all GE Lua, ms | | 2.89 | 18.502 |
| physics + vehicle Lua, ms | | 0.079 | 0.179 |
| render, ms | | 1.774 | |

- Painter frames over 4 ms: 29; worst flush (project + bake) 1.835 ms, worst composite 0.106 ms.
- Detector: 3.15 us per contact, 70.505 ms total, worst frame 0.423 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.47 | 26.40 | 13.65 | 18.50 | 0.17 | 1.70 |
| 0.46 | 24.24 | 17.11 | 2.01 | 0.05 | 1.53 |
| 12.42 | 22.12 | 9.86 | 1.41 | 0.05 | 1.48 |
| 21.15 | 21.30 | 6.43 | 1.45 | 0.05 | 1.47 |
| 12.78 | 21.07 | 5.54 | 1.13 | 0.05 | 1.37 |
