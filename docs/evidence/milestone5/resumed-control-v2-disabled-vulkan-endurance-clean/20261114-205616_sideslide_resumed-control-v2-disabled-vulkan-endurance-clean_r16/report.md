# sideslide - 20261114-205616_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.093 s - 342 frames, 83.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.145)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3165 | 852 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1629, BelowThresh 680, NormalForce 4

Body materials: METAL 649, PLASTIC 203

Surfaces: ASPHALT 852

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.04 |
| whole frame, ms | 11.994 (p50) | 13.171 | 19.583 |
| all GE Lua, ms | | 1.099 | 1.61 |
| physics + vehicle Lua, ms | | 0.081 | 0.229 |
| render, ms | | 1.802 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.928 us per contact, 4.314 ms total, worst frame 0.033 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.32 | 19.58 | 0.01 | 1.03 | 0.06 | 1.77 |
| 1.22 | 16.18 | 0.01 | 0.93 | 0.04 | 2.88 |
| 1.42 | 15.07 | 0.01 | 1.02 | 0.05 | 2.16 |
| 0.99 | 14.01 | 0.01 | 1.05 | 0.05 | 1.72 |
| 1.97 | 13.90 | 0.01 | 0.99 | 0.06 | 1.51 |
