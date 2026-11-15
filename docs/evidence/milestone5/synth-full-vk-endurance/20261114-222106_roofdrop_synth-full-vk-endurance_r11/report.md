# roofdrop - 20261114-222106_roofdrop_synth-full-vk-endurance_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.002 s - 393 frames, 78.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1028 | 50 | 50 | 0 | 55 | 17 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 597, BelowThresh 381

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.191 | 1.255 | 5.211 |
| whole frame, ms | 12.712 (p50) | 15.482 | 21.543 |
| all GE Lua, ms | | 2.228 | 6.06 |
| physics + vehicle Lua, ms | | 0.072 | 0.198 |
| render, ms | | 1.713 | |

- Painter frames over 4 ms: 2; worst flush (project + bake) 1.216 ms, worst composite 0.055 ms.
- Detector: 1.301 us per contact, 3.862 ms total, worst frame 0.621 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.89 | 21.54 | 5.21 | 4.29 | 0.07 | 1.66 |
| 1.27 | 19.05 | 0.01 | 1.03 | 0.05 | 1.44 |
| 0.66 | 18.80 | 0.01 | 0.88 | 0.05 | 1.52 |
| 2.28 | 18.09 | 0.01 | 2.23 | 0.07 | 1.43 |
| 0.60 | 17.57 | 3.45 | 4.36 | 0.07 | 1.93 |
