# sideslide - 20261114-222539_sideslide_synth-full-vk-endurance_r28

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.247 s - 327 frames, 76.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.168)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2750 | 642 | 81 | 132 | 105 | 107 | 138 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1460, BelowThresh 644, NormalForce 4

Body materials: METAL 483, PLASTIC 159

Surfaces: ASPHALT 642

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.355 | 3.945 | 7.734 |
| whole frame, ms | 12.312 (p50) | 19.52 | 25.345 |
| all GE Lua, ms | | 5.058 | 8.933 |
| physics + vehicle Lua, ms | | 0.087 | 0.191 |
| render, ms | | 1.805 | |

- Painter frames over 4 ms: 15; worst flush (project + bake) 2.27 ms, worst composite 0.109 ms.
- Detector: 1.486 us per contact, 8.15 ms total, worst frame 0.458 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.26 | 25.35 | 2.74 | 4.71 | 0.09 | 1.64 |
| 0.40 | 24.78 | 5.81 | 4.25 | 0.06 | 2.04 |
| 0.37 | 22.71 | 3.29 | 3.92 | 0.06 | 1.63 |
| 2.24 | 22.65 | 2.84 | 5.34 | 0.06 | 1.34 |
| 2.34 | 22.60 | 3.16 | 5.05 | 0.10 | 1.43 |
