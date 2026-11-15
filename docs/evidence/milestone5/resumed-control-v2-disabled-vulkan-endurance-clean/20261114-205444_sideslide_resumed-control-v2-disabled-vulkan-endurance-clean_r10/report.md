# sideslide - 20261114-205444_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.494 s - 373 frames, 82.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.188)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2661 | 665 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1274, BelowThresh 722

Body materials: METAL 477, PLASTIC 188

Surfaces: ASPHALT 665

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.032 |
| whole frame, ms | 12.088 (p50) | 13.521 | 15.092 |
| all GE Lua, ms | | 1.185 | 3.13 |
| physics + vehicle Lua, ms | | 0.082 | 0.149 |
| render, ms | | 1.753 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.988 us per contact, 4.09 ms total, worst frame 0.035 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.88 | 15.09 | 0.01 | 0.95 | 0.05 | 1.44 |
| 1.69 | 14.82 | 0.01 | 0.96 | 0.04 | 1.74 |
| 2.42 | 14.60 | 0.01 | 1.19 | 0.05 | 1.34 |
| 1.94 | 14.27 | 0.01 | 0.91 | 0.06 | 1.31 |
| 0.63 | 14.23 | 0.01 | 0.80 | 0.05 | 1.50 |
