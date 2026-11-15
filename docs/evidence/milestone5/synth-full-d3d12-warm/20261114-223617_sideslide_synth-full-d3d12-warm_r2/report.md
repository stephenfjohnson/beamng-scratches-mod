# sideslide - 20261114-223617_sideslide_synth-full-d3d12-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.033 s - 313 frames, 59.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2613 | 351 | 94 | 84 | 150 | 81 | 114 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1230, BelowThresh 1031, NormalForce 1

Body materials: METAL 258, PLASTIC 93

Surfaces: ASPHALT 351

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.145 | 18.134 | 446.118 |
| whole frame, ms | 11.298 (p50) | 27.962 | 455.633 |
| all GE Lua, ms | | 19.178 | 447.144 |
| physics + vehicle Lua, ms | | 0.1 | 1.673 |
| render, ms | | 2.07 | |

- Painter frames over 4 ms: 114; worst flush (project + bake) 2.52 ms, worst composite 0.095 ms.
- Detector: 1.22 us per contact, 6.491 ms total, worst frame 0.328 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.36 | 455.63 | 446.12 | 18.65 | 0.09 | 1.54 |
| 0.19 | 34.05 | 23.74 | 1.93 | 0.09 | 2.01 |
| 0.22 | 33.71 | 27.53 | 20.85 | 0.07 | 1.34 |
| 0.34 | 32.81 | 26.93 | 3.52 | 0.05 | 1.33 |
| 0.28 | 32.64 | 20.40 | 27.28 | 0.06 | 1.43 |
