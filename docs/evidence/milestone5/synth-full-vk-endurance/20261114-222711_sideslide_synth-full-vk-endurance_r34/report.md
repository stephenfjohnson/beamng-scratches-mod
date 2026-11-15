# sideslide - 20261114-222711_sideslide_synth-full-vk-endurance_r34

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.361 s - 330 frames, 75.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.178)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2312 | 555 | 105 | 125 | 129 | 110 | 141 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1140, BelowThresh 615, NormalForce 2

Body materials: METAL 400, PLASTIC 155

Surfaces: ASPHALT 555

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.505 | 4.292 | 10.428 |
| whole frame, ms | 12.458 (p50) | 19.461 | 25.208 |
| all GE Lua, ms | | 5.304 | 11.501 |
| physics + vehicle Lua, ms | | 0.088 | 0.276 |
| render, ms | | 2.066 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 2.293 ms, worst composite 0.12 ms.
- Detector: 1.442 us per contact, 7.592 ms total, worst frame 0.452 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.78 | 25.21 | 5.11 | 6.08 | 0.05 | 1.61 |
| 2.07 | 24.29 | 5.83 | 5.82 | 0.07 | 1.48 |
| 2.50 | 22.30 | 3.34 | 5.78 | 0.06 | 1.35 |
| 0.30 | 22.09 | 6.13 | 3.50 | 0.05 | 1.49 |
| 2.56 | 21.78 | 5.04 | 3.99 | 0.12 | 1.55 |
