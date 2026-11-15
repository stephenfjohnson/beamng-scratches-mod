# sideslide - 20261114-205922_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r28

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.132 s - 346 frames, 83.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.15)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3157 | 756 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1663, BelowThresh 736, NormalForce 2

Body materials: METAL 559, PLASTIC 197

Surfaces: ASPHALT 756

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.037 |
| whole frame, ms | 11.958 (p50) | 13.295 | 16.972 |
| all GE Lua, ms | | 1.09 | 1.332 |
| physics + vehicle Lua, ms | | 0.075 | 0.112 |
| render, ms | | 1.694 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.884 us per contact, 4.06 ms total, worst frame 0.048 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.47 | 16.97 | 0.01 | 0.80 | 0.04 | 1.83 |
| 0.12 | 15.78 | 0.01 | 0.90 | 0.06 | 1.37 |
| 3.78 | 15.40 | 0.01 | 0.78 | 0.03 | 1.57 |
| 2.60 | 14.85 | 0.01 | 0.85 | 0.05 | 3.09 |
| 0.04 | 14.63 | 0.01 | 0.80 | 0.04 | 1.56 |
