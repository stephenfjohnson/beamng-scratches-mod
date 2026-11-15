# sideslide - 20261114-202023_sideslide_resumed-fixed2-full-vulkan-endurance_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.267 s - 265 frames, 61.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2355 | 465 | 95 | 103 | 141 | 101 | 122 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1314, BelowThresh 574, NormalForce 2

Body materials: METAL 345, PLASTIC 120

Surfaces: ASPHALT 465

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.133 | 20.535 | 36.205 |
| whole frame, ms | 13.54 (p50) | 31.561 | 48.648 |
| all GE Lua, ms | | 21.84 | 37.172 |
| physics + vehicle Lua, ms | | 0.094 | 0.319 |
| render, ms | | 1.614 | |

- Painter frames over 4 ms: 52; worst flush (project + bake) 36.182 ms, worst composite 0.143 ms.
- Detector: 1.42 us per contact, 6.537 ms total, worst frame 0.307 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 48.65 | 36.21 | 0.72 | 0.06 | 1.19 |
| 0.23 | 36.74 | 31.02 | 0.80 | 0.06 | 1.24 |
| 2.82 | 36.40 | 20.95 | 2.44 | 0.06 | 1.27 |
| 3.15 | 35.70 | 29.23 | 1.03 | 0.04 | 1.20 |
| 1.98 | 35.62 | 25.07 | 1.90 | 0.05 | 1.20 |
