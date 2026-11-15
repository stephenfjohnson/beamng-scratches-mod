# sideslide - 20261114-222100_sideslide_synth-full-vk-endurance_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.207 s - 317 frames, 75.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.152)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2903 | 670 | 93 | 129 | 129 | 115 | 142 | 0.0% | 0 | 0 |

Rejected contacts: Wheel 1561, BelowThresh 668, NormalForce 4

Body materials: METAL 501, PLASTIC 169

Surfaces: ASPHALT 670

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.509 | 4.251 | 7.79 |
| whole frame, ms | 12.392 (p50) | 19.903 | 28.384 |
| all GE Lua, ms | | 5.308 | 9.108 |
| physics + vehicle Lua, ms | | 0.098 | 0.418 |
| render, ms | | 2.08 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 3.105 ms, worst composite 0.091 ms.
- Detector: 1.61 us per contact, 9.176 ms total, worst frame 0.467 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.94 | 28.38 | 4.44 | 7.56 | 0.08 | 2.30 |
| 0.89 | 24.71 | 2.73 | 5.49 | 0.10 | 2.16 |
| 0.96 | 24.22 | 4.15 | 5.79 | 0.07 | 2.30 |
| 1.29 | 22.34 | 3.51 | 3.76 | 0.07 | 2.07 |
| 3.17 | 22.09 | 3.45 | 4.79 | 0.07 | 1.46 |
