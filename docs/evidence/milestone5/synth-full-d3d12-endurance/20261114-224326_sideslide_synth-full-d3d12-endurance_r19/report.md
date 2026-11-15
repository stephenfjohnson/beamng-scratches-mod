# sideslide - 20261114-224326_sideslide_synth-full-d3d12-endurance_r19

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.591 s - 366 frames, 65.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.173)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2874 | 382 | 136 | 79 | 182 | 80 | 123 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1335, BelowThresh 1156, NormalForce 1

Body materials: METAL 279, PLASTIC 103

Surfaces: ASPHALT 382

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.312 | 18.112 | 21.847 |
| whole frame, ms | 11.16 (p50) | 28.529 | 35.4 |
| all GE Lua, ms | | 19.119 | 22.67 |
| physics + vehicle Lua, ms | | 0.097 | 1.839 |
| render, ms | | 2.376 | |

- Painter frames over 4 ms: 123; worst flush (project + bake) 2.467 ms, worst composite 0.154 ms.
- Detector: 1.3 us per contact, 7.168 ms total, worst frame 0.38 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.39 | 35.40 | 15.85 | 16.73 | 0.10 | 2.04 |
| 0.41 | 32.56 | 19.77 | 19.08 | 0.08 | 2.40 |
| 1.73 | 31.89 | 16.70 | 17.28 | 0.06 | 1.72 |
| 0.52 | 31.84 | 15.67 | 18.82 | 0.09 | 3.26 |
| 2.06 | 31.76 | 16.29 | 19.65 | 0.06 | 1.85 |
