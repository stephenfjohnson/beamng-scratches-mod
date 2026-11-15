# sideslide - 20261114-205704_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r19

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.1 s - 340 frames, 82.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.141)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3019 | 815 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1542, BelowThresh 660, NormalForce 2

Body materials: METAL 618, PLASTIC 197

Surfaces: ASPHALT 815

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.05 |
| whole frame, ms | 12.075 (p50) | 13.465 | 16.175 |
| all GE Lua, ms | | 1.172 | 2.124 |
| physics + vehicle Lua, ms | | 0.088 | 0.142 |
| render, ms | | 2.105 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.032 us per contact, 4.74 ms total, worst frame 0.206 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.58 | 16.17 | 0.01 | 0.91 | 0.05 | 3.12 |
| 3.95 | 15.63 | 0.01 | 0.98 | 0.05 | 3.15 |
| 3.18 | 15.09 | 0.01 | 1.01 | 0.05 | 2.68 |
| 0.12 | 14.75 | 0.01 | 0.95 | 0.07 | 2.20 |
| 2.55 | 14.75 | 0.01 | 0.92 | 0.05 | 1.65 |
