# sideslide - 20261114-222231_sideslide_synth-full-vk-endurance_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.288 s - 332 frames, 77.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2668 | 588 | 96 | 122 | 123 | 108 | 133 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1421, BelowThresh 656, NormalForce 3

Body materials: METAL 445, PLASTIC 143

Surfaces: ASPHALT 588

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.332 | 3.775 | 7.266 |
| whole frame, ms | 12.335 (p50) | 18.997 | 22.662 |
| all GE Lua, ms | | 4.798 | 8.642 |
| physics + vehicle Lua, ms | | 0.086 | 0.263 |
| render, ms | | 2.03 | |

- Painter frames over 4 ms: 14; worst flush (project + bake) 2.877 ms, worst composite 0.082 ms.
- Detector: 1.477 us per contact, 8.206 ms total, worst frame 0.378 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.79 | 22.66 | 3.24 | 1.39 | 0.04 | 1.45 |
| 0.63 | 20.45 | 5.65 | 4.01 | 0.11 | 1.43 |
| 2.06 | 20.28 | 3.88 | 5.35 | 0.07 | 1.66 |
| 2.00 | 20.27 | 4.66 | 5.80 | 0.08 | 2.20 |
| 2.50 | 20.26 | 3.62 | 3.95 | 0.13 | 1.81 |
