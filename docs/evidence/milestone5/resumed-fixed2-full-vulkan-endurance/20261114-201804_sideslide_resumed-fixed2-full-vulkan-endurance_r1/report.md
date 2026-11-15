# sideslide - 20261114-201804_sideslide_resumed-fixed2-full-vulkan-endurance_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.222 s - 262 frames, 62.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.166)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2197 | 475 | 95 | 96 | 166 | 100 | 124 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1100, BelowThresh 620, NormalForce 2

Body materials: METAL 352, PLASTIC 123

Surfaces: ASPHALT 475

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.253 | 20.93 | 36.799 |
| whole frame, ms | 13.722 (p50) | 30.991 | 49.725 |
| all GE Lua, ms | | 21.903 | 38.23 |
| physics + vehicle Lua, ms | | 0.099 | 1.444 |
| render, ms | | 1.668 | |

- Painter frames over 4 ms: 48; worst flush (project + bake) 36.775 ms, worst composite 0.104 ms.
- Detector: 1.644 us per contact, 7.578 ms total, worst frame 0.733 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 49.72 | 36.80 | 0.85 | 0.05 | 1.43 |
| 3.66 | 44.96 | 32.55 | 0.66 | 0.03 | 1.39 |
| 1.97 | 37.24 | 21.59 | 6.28 | 0.05 | 1.19 |
| 2.91 | 35.44 | 20.23 | 4.95 | 0.08 | 1.29 |
| 1.21 | 35.37 | 20.04 | 3.75 | 0.06 | 1.21 |
