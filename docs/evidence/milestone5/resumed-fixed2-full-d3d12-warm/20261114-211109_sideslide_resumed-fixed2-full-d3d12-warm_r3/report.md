# sideslide - 20261114-211109_sideslide_resumed-fixed2-full-d3d12-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.107 s - 191 frames, 48.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.159)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1812 | 376 | 78 | 77 | 151 | 59 | 105 | 0.0% | 0 | 4 |

Rejected contacts: Wheel 1008, BelowThresh 425, NormalForce 3

Body materials: METAL 278, PLASTIC 98

Surfaces: ASPHALT 376

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 11.545 | 29.199 | 35.753 |
| whole frame, ms | 23.707 (p50) | 37.138 | 45.684 |
| all GE Lua, ms | | 30.626 | 37.071 |
| physics + vehicle Lua, ms | | 0.11 | 4.114 |
| render, ms | | 2.178 | |

- Painter frames over 4 ms: 122; worst flush (project + bake) 35.728 ms, worst composite 0.112 ms.
- Detector: 1.592 us per contact, 5.955 ms total, worst frame 0.42 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.12 | 45.68 | 35.75 | 14.46 | 0.07 | 1.82 |
| 3.16 | 43.33 | 33.26 | 16.79 | 0.08 | 1.69 |
| 2.59 | 42.25 | 33.16 | 18.60 | 0.09 | 1.68 |
| 1.86 | 40.67 | 30.83 | 18.82 | 0.10 | 1.56 |
| 0.88 | 39.58 | 32.71 | 17.84 | 0.10 | 1.40 |
