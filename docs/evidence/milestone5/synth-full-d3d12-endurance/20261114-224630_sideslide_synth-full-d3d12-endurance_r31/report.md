# sideslide - 20261114-224630_sideslide_synth-full-d3d12-endurance_r31

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.25 s - 209 frames, 51.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.171)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1833 | 389 | 103 | 85 | 164 | 70 | 118 | 0.0% | 0 | 4 |

Rejected contacts: Wheel 1021, BelowThresh 422, NormalForce 1

Body materials: METAL 287, PLASTIC 102

Surfaces: ASPHALT 389

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 9.548 | 20.221 | 23.559 |
| whole frame, ms | 22.73 (p50) | 30.337 | 36.85 |
| all GE Lua, ms | | 21.393 | 24.607 |
| physics + vehicle Lua, ms | | 0.485 | 2.492 |
| render, ms | | 2.828 | |

- Painter frames over 4 ms: 118; worst flush (project + bake) 3.625 ms, worst composite 0.109 ms.
- Detector: 1.482 us per contact, 5.852 ms total, worst frame 0.571 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.16 | 36.85 | 23.33 | 18.82 | 0.07 | 2.03 |
| 1.12 | 34.26 | 18.27 | 17.92 | 0.10 | 2.15 |
| 1.80 | 33.44 | 17.64 | 20.55 | 0.05 | 2.58 |
| 2.12 | 32.91 | 21.93 | 3.22 | 2.49 | 1.67 |
| 2.36 | 32.90 | 17.54 | 21.06 | 0.06 | 2.26 |
