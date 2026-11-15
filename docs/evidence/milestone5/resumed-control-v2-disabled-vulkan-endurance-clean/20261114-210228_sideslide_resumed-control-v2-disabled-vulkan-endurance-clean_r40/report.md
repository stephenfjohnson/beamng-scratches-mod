# sideslide - 20261114-210228_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r40

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.282 s - 358 frames, 83.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.191)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2530 | 707 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1195, BelowThresh 624, NormalForce 4

Body materials: METAL 498, PLASTIC 209

Surfaces: ASPHALT 707

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.042 |
| whole frame, ms | 11.969 (p50) | 13.341 | 16.33 |
| all GE Lua, ms | | 1.291 | 2.431 |
| physics + vehicle Lua, ms | | 0.087 | 0.287 |
| render, ms | | 2.155 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.071 us per contact, 4.197 ms total, worst frame 0.043 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.71 | 16.33 | 0.01 | 0.98 | 0.05 | 2.69 |
| 2.11 | 16.09 | 0.01 | 1.40 | 0.08 | 2.72 |
| 2.87 | 15.44 | 0.01 | 0.85 | 0.05 | 2.01 |
| 2.93 | 14.60 | 0.00 | 0.87 | 0.06 | 1.50 |
| 4.16 | 14.16 | 0.01 | 0.85 | 0.03 | 2.13 |
