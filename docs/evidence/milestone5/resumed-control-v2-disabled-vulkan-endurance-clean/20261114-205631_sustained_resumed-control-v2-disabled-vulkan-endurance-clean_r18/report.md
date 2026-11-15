# sustained - 20261114-205631_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r18

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.005 s - 2448 frames, 81.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15161 | 7352 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6222, BelowThresh 1566, NormalForce 21

Body materials: METAL 7327, PLASTIC 25

Surfaces: ASPHALT 5966, COBBLESTONE 1386

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.171 |
| whole frame, ms | 12.236 (p50) | 14.144 | 25.53 |
| all GE Lua, ms | | 1.229 | 3.643 |
| physics + vehicle Lua, ms | | 0.084 | 0.232 |
| render, ms | | 2.052 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.56 us per contact, 34.075 ms total, worst frame 0.069 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 25.11 | 25.53 | 0.01 | 3.34 | 0.09 | 2.35 |
| 29.07 | 19.30 | 0.01 | 1.22 | 0.07 | 1.99 |
| 28.84 | 19.16 | 0.01 | 0.93 | 0.06 | 2.73 |
| 17.50 | 17.79 | 0.01 | 1.11 | 0.09 | 2.20 |
| 16.58 | 17.59 | 0.01 | 0.97 | 0.06 | 1.79 |
