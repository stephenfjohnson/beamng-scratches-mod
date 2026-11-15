# sideslide - 20261114-202500_sideslide_resumed-fixed2-full-vulkan-endurance_r28

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.221 s - 249 frames, 58.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.231)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2335 | 493 | 80 | 92 | 119 | 92 | 110 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1292, BelowThresh 545, NormalForce 5

Body materials: METAL 349, PLASTIC 144

Surfaces: ASPHALT 493

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.165 | 18.481 | 35.927 |
| whole frame, ms | 13.859 (p50) | 31.491 | 47.923 |
| all GE Lua, ms | | 19.717 | 36.873 |
| physics + vehicle Lua, ms | | 0.123 | 0.196 |
| render, ms | | 1.847 | |

- Painter frames over 4 ms: 57; worst flush (project + bake) 35.898 ms, worst composite 0.13 ms.
- Detector: 1.755 us per contact, 8.495 ms total, worst frame 1.309 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 47.92 | 35.93 | 0.93 | 0.06 | 1.36 |
| 3.34 | 45.35 | 32.41 | 0.91 | 0.04 | 1.35 |
| 0.23 | 38.74 | 32.62 | 0.85 | 0.07 | 1.29 |
| 0.87 | 37.43 | 19.25 | 3.62 | 0.08 | 1.58 |
| 0.32 | 35.93 | 20.08 | 3.32 | 0.05 | 1.54 |
