# sideslide - 20261114-185549_sideslide_resumed-selected-half-d3d12-endurance_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.192 s - 323 frames, 77.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.152)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3164 | 688 | 88 | 127 | 106 | 102 | 147 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1773, BelowThresh 697, NormalForce 6

Body materials: METAL 513, PLASTIC 175

Surfaces: ASPHALT 688

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.889 | 25.317 | 34.791 |
| whole frame, ms | 10.525 (p50) | 31.618 | 45.546 |
| all GE Lua, ms | | 26.214 | 35.919 |
| physics + vehicle Lua, ms | | 0.082 | 0.106 |
| render, ms | | 2.194 | |

- Painter frames over 4 ms: 100; worst flush (project + bake) 34.769 ms, worst composite 0.263 ms.
- Detector: 1.416 us per contact, 8.042 ms total, worst frame 0.327 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 45.55 | 34.79 | 0.86 | 0.05 | 1.79 |
| 1.84 | 41.76 | 34.76 | 0.92 | 0.05 | 1.88 |
| 1.18 | 40.66 | 33.37 | 1.09 | 0.04 | 2.36 |
| 2.01 | 39.72 | 32.71 | 1.31 | 0.05 | 1.52 |
| 2.64 | 38.80 | 32.25 | 0.75 | 0.04 | 1.45 |
