# sustained - 20261114-205412_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r9

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.004 s - 2451 frames, 81.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15648 | 8410 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5857, BelowThresh 1354, NormalForce 27

Body materials: METAL 8389, PLASTIC 21

Surfaces: ASPHALT 7590, COBBLESTONE 820

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.042 |
| whole frame, ms | 12.23 (p50) | 13.619 | 19.576 |
| all GE Lua, ms | | 1.181 | 4.104 |
| physics + vehicle Lua, ms | | 0.086 | 0.34 |
| render, ms | | 1.811 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.535 us per contact, 34.125 ms total, worst frame 0.086 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 17.97 | 19.58 | 0.01 | 0.73 | 0.05 | 2.31 |
| 18.31 | 18.32 | 0.01 | 1.08 | 0.09 | 1.81 |
| 17.13 | 17.85 | 0.01 | 1.05 | 0.07 | 1.36 |
| 12.42 | 17.63 | 0.01 | 4.10 | 0.08 | 2.02 |
| 18.59 | 17.20 | 0.01 | 1.17 | 0.07 | 2.94 |
