# sideslide - 20261114-205029_sideslide_resumed-control-v2-disabled-vulkan-endurance_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.195 s - 350 frames, 83.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.166)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2660 | 740 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1253, BelowThresh 665, NormalForce 2

Body materials: METAL 551, PLASTIC 189

Surfaces: ASPHALT 740

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.029 |
| whole frame, ms | 11.978 (p50) | 13.258 | 16.353 |
| all GE Lua, ms | | 1.113 | 1.853 |
| physics + vehicle Lua, ms | | 0.08 | 0.142 |
| render, ms | | 1.986 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.017 us per contact, 4.063 ms total, worst frame 0.031 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.10 | 16.35 | 0.01 | 0.91 | 0.04 | 3.27 |
| 1.08 | 15.45 | 0.01 | 1.10 | 0.06 | 1.36 |
| 1.45 | 15.20 | 0.01 | 1.14 | 0.08 | 3.62 |
| 3.68 | 14.74 | 0.01 | 0.85 | 0.04 | 1.75 |
| 3.06 | 14.67 | 0.01 | 1.22 | 0.07 | 2.72 |
