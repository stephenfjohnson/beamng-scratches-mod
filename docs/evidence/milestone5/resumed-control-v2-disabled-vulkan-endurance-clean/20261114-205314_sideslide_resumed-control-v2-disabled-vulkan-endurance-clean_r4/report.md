# sideslide - 20261114-205314_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.068 s - 338 frames, 82.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.16)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3154 | 744 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1749, BelowThresh 658, NormalForce 3

Body materials: METAL 555, PLASTIC 189

Surfaces: ASPHALT 744

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.035 |
| whole frame, ms | 12.055 (p50) | 13.425 | 17.533 |
| all GE Lua, ms | | 1.208 | 1.474 |
| physics + vehicle Lua, ms | | 0.084 | 0.155 |
| render, ms | | 1.929 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.891 us per contact, 4.273 ms total, worst frame 0.045 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.55 | 17.53 | 0.01 | 0.84 | 0.03 | 1.64 |
| 0.76 | 15.66 | 0.01 | 0.80 | 0.04 | 1.75 |
| 1.39 | 15.07 | 0.01 | 1.04 | 0.07 | 2.64 |
| 2.24 | 15.05 | 0.01 | 0.84 | 0.05 | 2.27 |
| 2.19 | 14.80 | 0.01 | 0.88 | 0.05 | 1.76 |
