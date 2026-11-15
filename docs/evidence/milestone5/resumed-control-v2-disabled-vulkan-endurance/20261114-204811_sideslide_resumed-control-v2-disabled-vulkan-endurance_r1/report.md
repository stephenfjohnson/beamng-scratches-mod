# sideslide - 20261114-204811_sideslide_resumed-control-v2-disabled-vulkan-endurance_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.093 s - 340 frames, 82.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.161)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3126 | 740 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1739, BelowThresh 645, NormalForce 2

Body materials: METAL 555, PLASTIC 185

Surfaces: ASPHALT 740

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.032 |
| whole frame, ms | 12.083 (p50) | 13.538 | 16.316 |
| all GE Lua, ms | | 1.143 | 1.85 |
| physics + vehicle Lua, ms | | 0.085 | 0.143 |
| render, ms | | 1.886 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.879 us per contact, 3.935 ms total, worst frame 0.045 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.95 | 16.32 | 0.01 | 0.87 | 0.06 | 1.57 |
| 0.84 | 16.08 | 0.01 | 0.88 | 0.09 | 1.57 |
| 3.49 | 15.94 | 0.01 | 0.77 | 0.03 | 2.54 |
| 0.45 | 15.76 | 0.01 | 0.93 | 0.04 | 1.72 |
| 1.99 | 15.58 | 0.01 | 0.99 | 0.06 | 2.46 |
