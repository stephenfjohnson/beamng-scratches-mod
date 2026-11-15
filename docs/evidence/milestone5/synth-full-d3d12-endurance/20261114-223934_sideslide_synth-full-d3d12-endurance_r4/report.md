# sideslide - 20261114-223934_sideslide_synth-full-d3d12-endurance_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.245 s - 214 frames, 52.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1927 | 388 | 95 | 85 | 158 | 76 | 113 | 0.0% | 0 | 3 |

Rejected contacts: Wheel 1059, BelowThresh 479, NormalForce 1

Body materials: METAL 288, PLASTIC 100

Surfaces: ASPHALT 388

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 9.146 | 20.296 | 25.943 |
| whole frame, ms | 20.071 (p50) | 31.526 | 51.546 |
| all GE Lua, ms | | 21.301 | 27.037 |
| physics + vehicle Lua, ms | | 0.201 | 2.435 |
| render, ms | | 2.499 | |

- Painter frames over 4 ms: 113; worst flush (project + bake) 2.579 ms, worst composite 0.107 ms.
- Detector: 1.533 us per contact, 6.024 ms total, worst frame 0.493 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.90 | 51.55 | 17.69 | 18.55 | 0.10 | 1.77 |
| 0.19 | 36.31 | 25.94 | 1.91 | 0.10 | 1.76 |
| 0.30 | 34.58 | 24.47 | 25.78 | 0.06 | 2.20 |
| 2.83 | 34.47 | 18.59 | 19.68 | 0.10 | 2.58 |
| 0.28 | 33.61 | 24.61 | 23.84 | 0.07 | 2.04 |
