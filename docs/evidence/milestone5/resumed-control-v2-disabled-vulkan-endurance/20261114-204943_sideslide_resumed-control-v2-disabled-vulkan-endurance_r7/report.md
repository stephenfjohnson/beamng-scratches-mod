# sideslide - 20261114-204943_sideslide_resumed-control-v2-disabled-vulkan-endurance_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.095 s - 341 frames, 83.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.139)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3104 | 822 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1602, BelowThresh 676, NormalForce 4

Body materials: METAL 616, PLASTIC 206

Surfaces: ASPHALT 822

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.009 | 0.031 |
| whole frame, ms | 12.005 (p50) | 13.211 | 15.596 |
| all GE Lua, ms | | 1.059 | 1.707 |
| physics + vehicle Lua, ms | | 0.079 | 0.226 |
| render, ms | | 1.783 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.91 us per contact, 4.069 ms total, worst frame 0.036 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.08 | 15.60 | 0.01 | 1.08 | 0.05 | 2.51 |
| 1.23 | 15.42 | 0.01 | 1.03 | 0.05 | 1.66 |
| 3.39 | 14.26 | 0.01 | 0.96 | 0.05 | 1.48 |
| 3.11 | 13.85 | 0.01 | 1.71 | 0.12 | 2.21 |
| 0.04 | 13.78 | 0.01 | 0.82 | 0.04 | 1.38 |
