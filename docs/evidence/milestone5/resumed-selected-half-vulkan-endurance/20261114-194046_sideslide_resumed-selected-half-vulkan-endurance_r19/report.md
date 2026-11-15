# sideslide - 20261114-194046_sideslide_resumed-selected-half-vulkan-endurance_r19

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.258 s - 317 frames, 74.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2645 | 604 | 88 | 126 | 118 | 97 | 154 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1409, BelowThresh 632

Body materials: METAL 436, PLASTIC 168

Surfaces: ASPHALT 604

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.583 | 34.914 | 40.083 |
| whole frame, ms | 9.998 (p50) | 44.867 | 51.769 |
| all GE Lua, ms | | 35.83 | 40.819 |
| physics + vehicle Lua, ms | | 0.09 | 0.417 |
| render, ms | | 1.562 | |

- Painter frames over 4 ms: 42; worst flush (project + bake) 40.061 ms, worst composite 0.047 ms.
- Detector: 1.474 us per contact, 7.736 ms total, worst frame 0.511 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.34 | 51.77 | 40.08 | 1.18 | 0.04 | 1.45 |
| 2.14 | 50.58 | 37.65 | 1.29 | 0.06 | 1.47 |
| 2.62 | 48.98 | 35.94 | 1.33 | 0.06 | 1.40 |
| 0.50 | 48.83 | 36.58 | 1.55 | 0.05 | 1.40 |
| 1.60 | 48.17 | 36.23 | 1.57 | 0.10 | 1.22 |
