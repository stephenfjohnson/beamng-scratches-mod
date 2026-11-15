# sideslide - 20261114-223212_sideslide_synth-full-d3d12-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.102 s - 320 frames, 65.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.138)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3210 | 720 | 79 | 123 | 112 | 106 | 128 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1749, BelowThresh 738, NormalForce 3

Body materials: METAL 541, PLASTIC 179

Surfaces: ASPHALT 720

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 6.496 | 20.253 | 30.101 |
| whole frame, ms | 10.905 (p50) | 29.6 | 40.003 |
| all GE Lua, ms | | 21.631 | 31.074 |
| physics + vehicle Lua, ms | | 0.093 | 0.56 |
| render, ms | | 2.137 | |

- Painter frames over 4 ms: 128; worst flush (project + bake) 2.671 ms, worst composite 0.182 ms.
- Detector: 1.58 us per contact, 9.842 ms total, worst frame 0.535 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.35 | 40.00 | 24.16 | 31.07 | 0.07 | 1.84 |
| 0.25 | 37.06 | 29.32 | 2.96 | 0.05 | 1.82 |
| 0.34 | 36.95 | 30.10 | 2.83 | 0.05 | 1.52 |
| 1.95 | 34.43 | 26.02 | 20.17 | 0.06 | 2.11 |
| 2.75 | 33.34 | 15.91 | 18.95 | 0.05 | 1.93 |
