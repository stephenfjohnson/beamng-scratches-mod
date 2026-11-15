# sideslide - 20261114-222014_sideslide_synth-full-vk-endurance_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.23 s - 331 frames, 78.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2748 | 684 | 84 | 136 | 113 | 110 | 140 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1391, BelowThresh 669, NormalForce 4

Body materials: METAL 504, PLASTIC 180

Surfaces: ASPHALT 684

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.42 | 4.025 | 9.491 |
| whole frame, ms | 12.082 (p50) | 18.583 | 23.134 |
| all GE Lua, ms | | 5.038 | 10.774 |
| physics + vehicle Lua, ms | | 0.089 | 0.159 |
| render, ms | | 1.84 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 2.716 ms, worst composite 0.1 ms.
- Detector: 1.513 us per contact, 8.216 ms total, worst frame 0.372 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.27 | 23.13 | 2.94 | 5.41 | 0.05 | 1.52 |
| 2.22 | 20.53 | 3.10 | 4.19 | 0.07 | 1.43 |
| 0.25 | 20.26 | 8.74 | 3.10 | 0.07 | 1.38 |
| 1.29 | 20.15 | 2.91 | 4.54 | 0.06 | 1.85 |
| 1.28 | 19.97 | 3.58 | 3.41 | 0.08 | 1.61 |
