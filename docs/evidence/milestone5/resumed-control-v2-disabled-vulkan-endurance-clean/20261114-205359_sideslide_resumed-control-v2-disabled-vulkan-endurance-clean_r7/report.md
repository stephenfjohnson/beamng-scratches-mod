# sideslide - 20261114-205359_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.259 s - 353 frames, 82.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.192)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2824 | 695 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1483, BelowThresh 644, NormalForce 2

Body materials: METAL 501, PLASTIC 194

Surfaces: ASPHALT 695

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.036 |
| whole frame, ms | 12.066 (p50) | 13.869 | 19.05 |
| all GE Lua, ms | | 1.222 | 1.712 |
| physics + vehicle Lua, ms | | 0.088 | 0.348 |
| render, ms | | 2.09 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.984 us per contact, 4.303 ms total, worst frame 0.047 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.59 | 19.05 | 0.01 | 1.67 | 0.11 | 4.31 |
| 1.64 | 15.62 | 0.01 | 1.07 | 0.08 | 2.35 |
| 0.86 | 15.53 | 0.01 | 1.04 | 0.10 | 2.70 |
| 3.97 | 15.17 | 0.01 | 0.91 | 0.06 | 2.17 |
| 2.37 | 14.98 | 0.01 | 0.96 | 0.07 | 1.69 |
