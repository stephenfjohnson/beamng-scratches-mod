# sustained - 20261114-211344_sustained_resumed-fixed2-half-d3d12-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.002 s - 2568 frames, 85.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15241 | 7217 | 71 | 542 | 110 | 189 | 195 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6615, BelowThresh 1388, NormalForce 21

Body materials: METAL 7215, PLASTIC 2

Surfaces: ASPHALT 6312, COBBLESTONE 905

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.101 | 25.377 | 184.06 |
| whole frame, ms | 10.7 (p50) | 32.047 | 195.123 |
| all GE Lua, ms | | 26.367 | 185.317 |
| physics + vehicle Lua, ms | | 0.082 | 0.207 |
| render, ms | | 2.139 | |

- Painter frames over 4 ms: 219; worst flush (project + bake) 184.029 ms, worst composite 0.174 ms.
- Detector: 3.157 us per contact, 67.783 ms total, worst frame 0.492 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.09 | 195.12 | 184.06 | 0.87 | 0.05 | 2.02 |
| 15.20 | 45.79 | 34.46 | 0.91 | 0.04 | 1.76 |
| 2.41 | 44.35 | 32.71 | 0.80 | 0.04 | 1.83 |
| 0.28 | 44.24 | 33.12 | 0.84 | 0.06 | 2.19 |
| 17.22 | 43.66 | 30.93 | 0.87 | 0.05 | 1.98 |
