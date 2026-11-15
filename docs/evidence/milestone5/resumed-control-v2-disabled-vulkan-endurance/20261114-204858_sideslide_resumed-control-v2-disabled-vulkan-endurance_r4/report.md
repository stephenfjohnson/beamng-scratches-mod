# sideslide - 20261114-204858_sideslide_resumed-control-v2-disabled-vulkan-endurance_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.264 s - 354 frames, 82.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.189)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2864 | 665 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1560, BelowThresh 637, NormalForce 2

Body materials: METAL 487, PLASTIC 178

Surfaces: ASPHALT 665

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.018 |
| whole frame, ms | 12.077 (p50) | 14.465 | 16.637 |
| all GE Lua, ms | | 1.41 | 4.627 |
| physics + vehicle Lua, ms | | 0.09 | 0.325 |
| render, ms | | 2.278 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.247 us per contact, 4.924 ms total, worst frame 0.321 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.68 | 16.64 | 0.01 | 1.24 | 0.05 | 2.07 |
| 2.53 | 16.39 | 0.01 | 0.92 | 0.05 | 2.62 |
| 3.30 | 16.28 | 0.01 | 1.08 | 0.06 | 2.18 |
| 3.45 | 15.82 | 0.01 | 0.97 | 0.04 | 1.70 |
| 2.96 | 15.79 | 0.01 | 1.06 | 0.06 | 2.00 |
