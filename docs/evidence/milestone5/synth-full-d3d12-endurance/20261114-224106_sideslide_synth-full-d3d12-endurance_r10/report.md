# sideslide - 20261114-224106_sideslide_synth-full-d3d12-endurance_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.65 s - 339 frames, 61.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.173)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2636 | 344 | 142 | 71 | 199 | 73 | 120 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1243, BelowThresh 1048, NormalForce 1

Body materials: METAL 253, PLASTIC 91

Surfaces: ASPHALT 344

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 6.006 | 19.045 | 26.246 |
| whole frame, ms | 11.115 (p50) | 30.631 | 35.694 |
| all GE Lua, ms | | 20.344 | 27.982 |
| physics + vehicle Lua, ms | | 0.115 | 1.682 |
| render, ms | | 2.245 | |

- Painter frames over 4 ms: 120; worst flush (project + bake) 3.663 ms, worst composite 0.097 ms.
- Detector: 1.27 us per contact, 7.519 ms total, worst frame 1.033 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.21 | 35.69 | 18.91 | 20.77 | 0.06 | 1.58 |
| 2.71 | 34.92 | 21.07 | 7.61 | 0.09 | 2.77 |
| 2.60 | 34.85 | 19.58 | 18.74 | 0.07 | 2.00 |
| 0.20 | 34.52 | 26.25 | 23.20 | 0.11 | 2.34 |
| 3.14 | 33.78 | 17.80 | 18.70 | 0.07 | 1.83 |
