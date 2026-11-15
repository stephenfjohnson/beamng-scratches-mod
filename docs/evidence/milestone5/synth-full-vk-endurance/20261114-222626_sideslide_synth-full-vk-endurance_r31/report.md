# sideslide - 20261114-222626_sideslide_synth-full-vk-endurance_r31

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.244 s - 332 frames, 78.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.168)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2724 | 636 | 85 | 129 | 103 | 108 | 132 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1461, BelowThresh 625, NormalForce 2

Body materials: METAL 466, PLASTIC 170

Surfaces: ASPHALT 636

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.298 | 3.949 | 5.696 |
| whole frame, ms | 12.207 (p50) | 18.528 | 23.642 |
| all GE Lua, ms | | 4.835 | 6.606 |
| physics + vehicle Lua, ms | | 0.086 | 0.163 |
| render, ms | | 1.841 | |

- Painter frames over 4 ms: 15; worst flush (project + bake) 2.556 ms, worst composite 0.097 ms.
- Detector: 1.511 us per contact, 9.322 ms total, worst frame 0.376 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.54 | 23.64 | 3.67 | 5.58 | 0.08 | 1.46 |
| 2.53 | 23.58 | 4.82 | 3.52 | 0.05 | 1.70 |
| 2.23 | 23.11 | 3.55 | 3.96 | 0.05 | 1.40 |
| 0.33 | 22.64 | 4.73 | 4.33 | 0.05 | 1.50 |
| 2.85 | 22.14 | 3.18 | 5.98 | 0.06 | 1.65 |
