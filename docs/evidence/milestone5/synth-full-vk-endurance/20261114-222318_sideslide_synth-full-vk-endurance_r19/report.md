# sideslide - 20261114-222318_sideslide_synth-full-vk-endurance_r19

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.077 s - 296 frames, 72.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.146)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2906 | 739 | 73 | 130 | 97 | 105 | 127 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1557, BelowThresh 609, NormalForce 1

Body materials: METAL 561, PLASTIC 178

Surfaces: ASPHALT 739

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.543 | 4.337 | 12.78 |
| whole frame, ms | 13.238 (p50) | 20.801 | 25.071 |
| all GE Lua, ms | | 5.758 | 14.023 |
| physics + vehicle Lua, ms | | 0.096 | 0.323 |
| render, ms | | 2.27 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 2.222 ms, worst composite 0.215 ms.
- Detector: 1.813 us per contact, 9.504 ms total, worst frame 0.351 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.77 | 25.07 | 4.75 | 5.01 | 0.10 | 2.65 |
| 2.66 | 25.04 | 1.90 | 5.24 | 0.06 | 2.16 |
| 1.24 | 23.08 | 3.12 | 6.75 | 0.06 | 1.36 |
| 2.30 | 22.42 | 4.51 | 3.75 | 0.06 | 1.34 |
| 2.40 | 21.92 | 3.18 | 4.80 | 0.08 | 1.99 |
