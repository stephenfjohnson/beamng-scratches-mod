# sideslide - 20261114-224500_sideslide_synth-full-d3d12-endurance_r25

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.102 s - 239 frames, 59.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.158)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2543 | 480 | 75 | 88 | 131 | 80 | 105 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1448, BelowThresh 614, NormalForce 1

Body materials: METAL 360, PLASTIC 120

Surfaces: ASPHALT 480

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.227 | 18.754 | 22.978 |
| whole frame, ms | 11.378 (p50) | 28.218 | 33.021 |
| all GE Lua, ms | | 19.82 | 24.102 |
| physics + vehicle Lua, ms | | 0.095 | 1.523 |
| render, ms | | 2.161 | |

- Painter frames over 4 ms: 105; worst flush (project + bake) 2.678 ms, worst composite 0.097 ms.
- Detector: 1.327 us per contact, 6.2 ms total, worst frame 0.422 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 33.02 | 21.42 | 1.33 | 0.05 | 2.05 |
| 0.87 | 32.49 | 16.03 | 17.22 | 0.10 | 2.00 |
| 2.75 | 31.94 | 16.68 | 17.85 | 0.06 | 1.64 |
| 2.19 | 31.67 | 17.12 | 22.99 | 0.06 | 1.74 |
| 1.24 | 30.72 | 15.82 | 18.27 | 0.05 | 1.90 |
