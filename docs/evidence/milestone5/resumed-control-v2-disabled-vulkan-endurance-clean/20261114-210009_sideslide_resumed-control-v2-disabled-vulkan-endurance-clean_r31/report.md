# sideslide - 20261114-210009_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r31

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.104 s - 345 frames, 83.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.158)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3269 | 863 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1771, BelowThresh 632, NormalForce 3

Body materials: METAL 656, PLASTIC 207

Surfaces: ASPHALT 863

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.03 |
| whole frame, ms | 11.955 (p50) | 13.308 | 17.246 |
| all GE Lua, ms | | 1.131 | 1.552 |
| physics + vehicle Lua, ms | | 0.085 | 0.191 |
| render, ms | | 1.828 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.934 us per contact, 4.488 ms total, worst frame 0.042 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.08 | 17.25 | 0.01 | 0.85 | 0.05 | 1.29 |
| 2.49 | 15.13 | 0.01 | 1.21 | 0.08 | 2.37 |
| 2.93 | 14.71 | 0.01 | 0.94 | 0.06 | 1.45 |
| 1.35 | 14.71 | 0.01 | 0.94 | 0.06 | 1.39 |
| 3.64 | 14.05 | 0.01 | 0.85 | 0.05 | 1.52 |
