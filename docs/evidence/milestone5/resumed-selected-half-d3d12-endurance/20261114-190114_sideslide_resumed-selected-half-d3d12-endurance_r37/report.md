# sideslide - 20261114-190114_sideslide_resumed-selected-half-d3d12-endurance_r37

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.2 s - 329 frames, 77.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.154)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3234 | 669 | 73 | 130 | 109 | 109 | 151 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1838, BelowThresh 725, NormalForce 2

Body materials: METAL 479, PLASTIC 190

Surfaces: ASPHALT 669

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.995 | 27.044 | 38.326 |
| whole frame, ms | 10.316 (p50) | 33.356 | 44.245 |
| all GE Lua, ms | | 27.89 | 39.164 |
| physics + vehicle Lua, ms | | 0.09 | 0.133 |
| render, ms | | 2.118 | |

- Painter frames over 4 ms: 99; worst flush (project + bake) 38.304 ms, worst composite 0.098 ms.
- Detector: 1.424 us per contact, 8.165 ms total, worst frame 0.383 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.76 | 44.24 | 38.33 | 1.00 | 0.05 | 1.52 |
| 1.64 | 43.23 | 35.09 | 0.77 | 0.05 | 1.78 |
| 2.90 | 42.86 | 36.32 | 0.81 | 0.04 | 1.55 |
| 0.18 | 42.15 | 31.74 | 0.85 | 0.09 | 2.00 |
| 3.33 | 40.80 | 31.71 | 0.80 | 0.04 | 1.69 |
