# sideslide - 20261114-210141_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r37

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.113 s - 345 frames, 83.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.139)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3171 | 758 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1677, BelowThresh 730, NormalForce 6

Body materials: METAL 580, PLASTIC 178

Surfaces: ASPHALT 758

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.009 | 0.038 |
| whole frame, ms | 11.931 (p50) | 13.261 | 15.596 |
| all GE Lua, ms | | 1.236 | 2.963 |
| physics + vehicle Lua, ms | | 0.079 | 0.125 |
| render, ms | | 1.859 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.88 us per contact, 4.137 ms total, worst frame 0.031 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.12 | 15.60 | 0.01 | 1.09 | 0.05 | 2.85 |
| 0.82 | 14.78 | 0.01 | 0.92 | 0.07 | 1.50 |
| 2.08 | 14.65 | 0.01 | 1.39 | 0.09 | 1.74 |
| 0.13 | 14.26 | 0.01 | 0.79 | 0.05 | 1.42 |
| 0.88 | 14.20 | 0.01 | 0.99 | 0.06 | 1.82 |
