# sideslide - 20261114-224019_sideslide_synth-full-d3d12-endurance_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.331 s - 248 frames, 58.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.173)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2106 | 386 | 104 | 86 | 166 | 82 | 122 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1095, BelowThresh 624, NormalForce 1

Body materials: METAL 281, PLASTIC 105

Surfaces: ASPHALT 386

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.764 | 18.622 | 29.692 |
| whole frame, ms | 12.361 (p50) | 28.093 | 41.452 |
| all GE Lua, ms | | 19.48 | 30.847 |
| physics + vehicle Lua, ms | | 0.235 | 2.107 |
| render, ms | | 1.956 | |

- Painter frames over 4 ms: 122; worst flush (project + bake) 3.643 ms, worst composite 0.099 ms.
- Detector: 1.274 us per contact, 5.456 ms total, worst frame 0.383 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 41.45 | 29.69 | 1.36 | 0.05 | 2.24 |
| 2.08 | 35.79 | 18.02 | 19.08 | 0.05 | 1.61 |
| 2.32 | 31.36 | 16.12 | 17.05 | 0.06 | 1.67 |
| 1.99 | 31.17 | 22.47 | 1.50 | 1.73 | 1.54 |
| 1.53 | 30.52 | 16.68 | 17.38 | 0.05 | 1.68 |
