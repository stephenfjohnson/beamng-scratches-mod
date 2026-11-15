# sideslide - 20261114-205836_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r25

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.246 s - 352 frames, 82.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.174)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2621 | 695 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1270, BelowThresh 653, NormalForce 3

Body materials: METAL 514, PLASTIC 181

Surfaces: ASPHALT 695

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.033 |
| whole frame, ms | 12.063 (p50) | 13.77 | 19.056 |
| all GE Lua, ms | | 1.199 | 1.711 |
| physics + vehicle Lua, ms | | 0.088 | 0.274 |
| render, ms | | 1.999 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.047 us per contact, 4.301 ms total, worst frame 0.148 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.29 | 19.06 | 0.01 | 1.02 | 0.07 | 1.58 |
| 3.44 | 16.45 | 0.01 | 0.93 | 0.07 | 2.68 |
| 1.65 | 15.89 | 0.01 | 1.10 | 0.05 | 3.04 |
| 3.39 | 15.81 | 0.01 | 1.15 | 0.06 | 3.23 |
| 3.85 | 15.70 | 0.01 | 1.27 | 0.07 | 1.95 |
