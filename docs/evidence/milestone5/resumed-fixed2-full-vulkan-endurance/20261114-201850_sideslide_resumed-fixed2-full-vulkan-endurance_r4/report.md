# sideslide - 20261114-201850_sideslide_resumed-fixed2-full-vulkan-endurance_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.272 s - 263 frames, 61.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2252 | 479 | 93 | 96 | 149 | 92 | 122 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1209, BelowThresh 563, NormalForce 1

Body materials: METAL 347, PLASTIC 132

Surfaces: ASPHALT 479

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.314 | 18.512 | 37.687 |
| whole frame, ms | 13.108 (p50) | 30.511 | 50.229 |
| all GE Lua, ms | | 19.37 | 38.68 |
| physics + vehicle Lua, ms | | 0.102 | 0.18 |
| render, ms | | 1.637 | |

- Painter frames over 4 ms: 63; worst flush (project + bake) 37.666 ms, worst composite 0.25 ms.
- Detector: 1.622 us per contact, 7.729 ms total, worst frame 0.45 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 50.23 | 37.69 | 0.71 | 0.05 | 1.26 |
| 3.18 | 35.06 | 16.43 | 5.12 | 0.13 | 1.20 |
| 2.80 | 33.15 | 21.46 | 1.10 | 0.09 | 1.28 |
| 2.94 | 32.30 | 16.81 | 3.39 | 0.07 | 1.35 |
| 0.33 | 32.29 | 18.51 | 3.63 | 0.08 | 1.58 |
