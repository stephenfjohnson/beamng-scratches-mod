# sideslide - 20261114-185939_sideslide_resumed-selected-half-d3d12-endurance_r31

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.159 s - 320 frames, 76.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2945 | 648 | 81 | 123 | 114 | 99 | 145 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1600, BelowThresh 694, NormalForce 3

Body materials: METAL 483, PLASTIC 165

Surfaces: ASPHALT 648

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.816 | 25.81 | 40.148 |
| whole frame, ms | 10.464 (p50) | 33.533 | 46.704 |
| all GE Lua, ms | | 26.892 | 41.591 |
| physics + vehicle Lua, ms | | 0.092 | 0.169 |
| render, ms | | 2.166 | |

- Painter frames over 4 ms: 97; worst flush (project + bake) 40.081 ms, worst composite 0.158 ms.
- Detector: 1.409 us per contact, 7.94 ms total, worst frame 0.537 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.00 | 46.70 | 40.15 | 2.56 | 0.07 | 1.68 |
| 0.90 | 41.37 | 33.63 | 2.59 | 0.06 | 2.00 |
| 2.68 | 40.75 | 33.67 | 0.85 | 0.05 | 1.72 |
| 0.18 | 39.15 | 28.81 | 0.98 | 0.06 | 1.89 |
| 0.99 | 38.43 | 30.92 | 1.62 | 0.04 | 2.24 |
