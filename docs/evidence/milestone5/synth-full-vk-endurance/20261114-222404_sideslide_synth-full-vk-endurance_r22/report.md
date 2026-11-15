# sideslide - 20261114-222404_sideslide_synth-full-vk-endurance_r22

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.687 s - 518 frames, 77.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.18)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4159 | 548 | 107 | 121 | 124 | 106 | 137 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1833, BelowThresh 1776, NormalForce 2

Body materials: METAL 383, PLASTIC 165

Surfaces: ASPHALT 548

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.904 | 3.637 | 10.019 |
| whole frame, ms | 12.264 (p50) | 18.753 | 27.47 |
| all GE Lua, ms | | 4.828 | 11.088 |
| physics + vehicle Lua, ms | | 0.092 | 0.152 |
| render, ms | | 1.963 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 3.336 ms, worst composite 0.226 ms.
- Detector: 1.229 us per contact, 10.452 ms total, worst frame 0.584 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.25 | 27.47 | 10.02 | 2.76 | 0.06 | 1.91 |
| 1.43 | 23.24 | 3.15 | 5.08 | 0.04 | 1.22 |
| 0.68 | 22.85 | 6.05 | 3.62 | 0.10 | 1.96 |
| 2.85 | 22.29 | 2.88 | 5.93 | 0.05 | 1.44 |
| 0.44 | 21.92 | 3.83 | 5.59 | 0.08 | 2.18 |
