# sideslide - 20261114-205531_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.127 s - 345 frames, 83.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.149)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3150 | 781 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1664, BelowThresh 702, NormalForce 3

Body materials: METAL 592, PLASTIC 189

Surfaces: ASPHALT 781

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.087 |
| whole frame, ms | 11.942 (p50) | 14.87 | 16.325 |
| all GE Lua, ms | | 1.603 | 3.164 |
| physics + vehicle Lua, ms | | 0.088 | 0.303 |
| render, ms | | 1.851 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.922 us per contact, 4.339 ms total, worst frame 0.039 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.71 | 16.32 | 0.02 | 1.03 | 0.06 | 1.68 |
| 4.09 | 16.32 | 0.01 | 1.01 | 0.05 | 1.91 |
| 2.05 | 15.57 | 0.01 | 1.20 | 0.05 | 1.36 |
| 2.88 | 15.54 | 0.01 | 1.08 | 0.05 | 1.36 |
| 2.26 | 15.36 | 0.01 | 0.86 | 0.05 | 1.42 |
