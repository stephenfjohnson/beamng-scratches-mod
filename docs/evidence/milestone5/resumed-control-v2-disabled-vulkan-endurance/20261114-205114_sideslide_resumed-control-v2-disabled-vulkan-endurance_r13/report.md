# sideslide - 20261114-205114_sideslide_resumed-control-v2-disabled-vulkan-endurance_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.116 s - 343 frames, 83.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.141)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3068 | 808 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1579, BelowThresh 675, NormalForce 6

Body materials: METAL 609, PLASTIC 199

Surfaces: ASPHALT 808

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.014 |
| whole frame, ms | 11.997 (p50) | 14.689 | 20.132 |
| all GE Lua, ms | | 1.356 | 4.088 |
| physics + vehicle Lua, ms | | 0.085 | 0.173 |
| render, ms | | 2.048 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.998 us per contact, 4.502 ms total, worst frame 0.035 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.19 | 20.13 | 0.01 | 3.74 | 0.08 | 2.35 |
| 2.72 | 19.92 | 0.01 | 0.99 | 0.06 | 1.57 |
| 3.18 | 17.01 | 0.01 | 0.75 | 0.03 | 2.69 |
| 0.79 | 16.30 | 0.01 | 0.81 | 0.07 | 1.40 |
| 1.71 | 16.14 | 0.01 | 0.94 | 0.04 | 1.57 |
