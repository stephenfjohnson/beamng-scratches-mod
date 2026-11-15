# sideslide - 20261114-205200_sideslide_resumed-control-v2-disabled-vulkan-endurance_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.223 s - 350 frames, 82.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.166)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2826 | 721 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1430, BelowThresh 670, NormalForce 5

Body materials: METAL 527, PLASTIC 194

Surfaces: ASPHALT 721

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.031 |
| whole frame, ms | 12.088 (p50) | 13.546 | 19.649 |
| all GE Lua, ms | | 1.275 | 2.782 |
| physics + vehicle Lua, ms | | 0.089 | 0.132 |
| render, ms | | 2.445 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.068 us per contact, 4.631 ms total, worst frame 0.045 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.14 | 19.65 | 0.01 | 0.87 | 0.07 | 4.42 |
| 2.05 | 15.55 | 0.01 | 1.01 | 0.08 | 2.52 |
| 3.08 | 15.28 | 0.01 | 0.94 | 0.07 | 3.10 |
| 3.62 | 15.16 | 0.02 | 0.99 | 0.05 | 2.42 |
| 0.63 | 15.08 | 0.01 | 1.32 | 0.10 | 2.36 |
