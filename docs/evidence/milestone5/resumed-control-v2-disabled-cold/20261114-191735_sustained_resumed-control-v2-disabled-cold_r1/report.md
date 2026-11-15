# sustained - 20261114-191735_sustained_resumed-control-v2-disabled-cold_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.006 s - 2859 frames, 93.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16096 | 6779 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 7831, BelowThresh 1429, NormalForce 57

Body materials: METAL 6756, PLASTIC 23

Surfaces: ASPHALT 5608, COBBLESTONE 1171

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.005 | 0.006 | 0.06 |
| whole frame, ms | 10.645 (p50) | 11.811 | 17.058 |
| all GE Lua, ms | | 1.064 | 2.699 |
| physics + vehicle Lua, ms | | 0.08 | 0.274 |
| render, ms | | 2.173 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.563 us per contact, 33.858 ms total, worst frame 0.157 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 21.43 | 17.06 | 0.01 | 1.45 | 0.06 | 1.88 |
| 8.00 | 15.64 | 0.00 | 1.18 | 0.10 | 2.69 |
| 15.93 | 15.20 | 0.01 | 0.83 | 0.06 | 2.72 |
| 17.37 | 14.87 | 0.01 | 0.75 | 0.04 | 2.57 |
| 22.65 | 14.85 | 0.00 | 0.91 | 0.05 | 1.77 |
