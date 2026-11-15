# sideslide - 20261114-221841_sideslide_synth-full-vk-endurance_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.077 s - 307 frames, 75.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.142)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3017 | 730 | 75 | 130 | 104 | 102 | 129 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1635, BelowThresh 649, NormalForce 3

Body materials: METAL 549, PLASTIC 181

Surfaces: ASPHALT 730

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.588 | 4.385 | 14.157 |
| whole frame, ms | 12.814 (p50) | 19.308 | 25.957 |
| all GE Lua, ms | | 5.473 | 15.132 |
| physics + vehicle Lua, ms | | 0.092 | 0.129 |
| render, ms | | 1.848 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 2.301 ms, worst composite 0.104 ms.
- Detector: 1.591 us per contact, 8.832 ms total, worst frame 0.415 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.33 | 25.96 | 14.08 | 3.39 | 0.06 | 1.53 |
| 1.94 | 25.57 | 3.77 | 5.55 | 0.05 | 2.08 |
| 0.20 | 25.50 | 14.16 | 1.90 | 0.06 | 1.50 |
| 1.38 | 23.68 | 3.31 | 5.58 | 0.05 | 1.92 |
| 2.64 | 22.17 | 3.86 | 6.33 | 0.07 | 1.81 |
