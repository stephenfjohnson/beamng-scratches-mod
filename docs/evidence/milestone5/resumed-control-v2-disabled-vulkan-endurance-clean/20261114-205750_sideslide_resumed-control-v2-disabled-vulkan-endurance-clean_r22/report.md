# sideslide - 20261114-205750_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r22

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.119 s - 343 frames, 82.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.141)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3144 | 742 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1659, BelowThresh 741, NormalForce 2

Body materials: METAL 567, PLASTIC 175

Surfaces: ASPHALT 742

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.054 |
| whole frame, ms | 11.997 (p50) | 14.582 | 17.254 |
| all GE Lua, ms | | 1.227 | 3.241 |
| physics + vehicle Lua, ms | | 0.086 | 0.115 |
| render, ms | | 2.013 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.93 us per contact, 4.31 ms total, worst frame 0.04 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.95 | 17.25 | 0.01 | 0.94 | 0.05 | 1.53 |
| 0.83 | 16.76 | 0.01 | 1.09 | 0.07 | 1.76 |
| 0.79 | 16.72 | 0.01 | 1.10 | 0.10 | 1.73 |
| 1.60 | 16.10 | 0.01 | 1.28 | 0.07 | 1.69 |
| 1.92 | 16.08 | 0.01 | 0.94 | 0.06 | 3.99 |
