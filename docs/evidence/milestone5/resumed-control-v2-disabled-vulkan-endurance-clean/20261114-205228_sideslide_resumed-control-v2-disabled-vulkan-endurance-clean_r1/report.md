# sideslide - 20261114-205228_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.156 s - 348 frames, 83.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.151)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3097 | 742 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1614, BelowThresh 739, NormalForce 2

Body materials: METAL 553, PLASTIC 189

Surfaces: ASPHALT 742

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.016 |
| whole frame, ms | 11.944 (p50) | 13.372 | 16.595 |
| all GE Lua, ms | | 1.12 | 2.165 |
| physics + vehicle Lua, ms | | 0.093 | 0.337 |
| render, ms | | 1.784 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.89 us per contact, 4.14 ms total, worst frame 0.04 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.81 | 16.59 | 0.01 | 0.83 | 0.03 | 2.85 |
| 0.46 | 16.40 | 0.01 | 0.90 | 0.04 | 2.54 |
| 2.83 | 16.25 | 0.01 | 1.16 | 0.04 | 1.36 |
| 0.17 | 14.98 | 0.01 | 0.86 | 0.06 | 1.67 |
| 0.39 | 14.62 | 0.01 | 0.86 | 0.04 | 1.36 |
