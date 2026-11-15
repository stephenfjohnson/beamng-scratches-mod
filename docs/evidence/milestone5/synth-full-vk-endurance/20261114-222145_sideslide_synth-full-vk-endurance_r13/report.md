# sideslide - 20261114-222145_sideslide_synth-full-vk-endurance_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.277 s - 334 frames, 77.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.188)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2505 | 626 | 101 | 117 | 127 | 99 | 130 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1247, BelowThresh 628, NormalForce 4

Body materials: METAL 448, PLASTIC 178

Surfaces: ASPHALT 626

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.245 | 3.599 | 6.016 |
| whole frame, ms | 12.196 (p50) | 18.682 | 23.798 |
| all GE Lua, ms | | 4.476 | 7.056 |
| physics + vehicle Lua, ms | | 0.091 | 0.147 |
| render, ms | | 1.672 | |

- Painter frames over 4 ms: 11; worst flush (project + bake) 2.274 ms, worst composite 0.274 ms.
- Detector: 1.63 us per contact, 8.648 ms total, worst frame 0.377 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.33 | 23.80 | 2.90 | 1.60 | 0.05 | 1.27 |
| 1.71 | 22.05 | 2.42 | 6.16 | 0.06 | 1.23 |
| 3.00 | 21.59 | 3.07 | 1.97 | 0.05 | 1.51 |
| 0.63 | 20.98 | 6.02 | 3.57 | 0.08 | 1.47 |
| 1.17 | 20.93 | 1.02 | 6.08 | 0.05 | 1.22 |
