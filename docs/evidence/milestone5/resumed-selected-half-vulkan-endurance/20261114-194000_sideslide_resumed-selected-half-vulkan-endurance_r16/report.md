# sideslide - 20261114-194000_sideslide_resumed-selected-half-vulkan-endurance_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.218 s - 313 frames, 73.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2353 | 628 | 87 | 131 | 116 | 102 | 151 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1080, BelowThresh 640, NormalForce 5

Body materials: METAL 467, PLASTIC 161

Surfaces: ASPHALT 628

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.559 | 34.275 | 40.794 |
| whole frame, ms | 9.923 (p50) | 42.898 | 53.478 |
| all GE Lua, ms | | 35.473 | 41.914 |
| physics + vehicle Lua, ms | | 0.092 | 0.578 |
| render, ms | | 1.806 | |

- Painter frames over 4 ms: 42; worst flush (project + bake) 40.773 ms, worst composite 0.066 ms.
- Detector: 1.817 us per contact, 8.245 ms total, worst frame 0.326 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.39 | 53.48 | 40.79 | 1.09 | 0.05 | 1.69 |
| 0.34 | 50.66 | 38.80 | 2.20 | 0.06 | 1.50 |
| 0.57 | 49.29 | 37.51 | 1.73 | 0.05 | 1.27 |
| 0.47 | 48.84 | 36.58 | 2.07 | 0.06 | 1.45 |
| 0.80 | 48.76 | 38.81 | 2.97 | 0.05 | 1.29 |
