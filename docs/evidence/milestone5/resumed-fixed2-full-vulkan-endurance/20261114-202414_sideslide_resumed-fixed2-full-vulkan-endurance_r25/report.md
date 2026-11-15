# sideslide - 20261114-202414_sideslide_resumed-fixed2-full-vulkan-endurance_r25

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.467 s - 273 frames, 61.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.174)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2042 | 481 | 95 | 106 | 138 | 98 | 126 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 954, BelowThresh 606, NormalForce 1

Body materials: METAL 341, PLASTIC 140

Surfaces: ASPHALT 481

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.207 | 19.222 | 36.11 |
| whole frame, ms | 13.729 (p50) | 29.914 | 48.362 |
| all GE Lua, ms | | 20.167 | 37.066 |
| physics + vehicle Lua, ms | | 0.111 | 0.969 |
| render, ms | | 1.726 | |

- Painter frames over 4 ms: 61; worst flush (project + bake) 36.084 ms, worst composite 0.131 ms.
- Detector: 1.689 us per contact, 6.882 ms total, worst frame 0.431 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 48.36 | 36.11 | 0.75 | 0.07 | 1.36 |
| 2.55 | 43.97 | 32.37 | 0.96 | 0.74 | 1.37 |
| 2.61 | 38.41 | 31.93 | 0.87 | 0.74 | 1.21 |
| 2.00 | 34.73 | 20.84 | 4.52 | 0.05 | 1.22 |
| 2.23 | 33.46 | 27.25 | 3.10 | 0.06 | 1.26 |
