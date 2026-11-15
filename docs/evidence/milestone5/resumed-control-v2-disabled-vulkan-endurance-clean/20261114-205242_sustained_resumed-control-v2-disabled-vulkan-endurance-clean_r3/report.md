# sustained - 20261114-205242_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.0 s - 2451 frames, 81.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14670 | 7111 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5754, BelowThresh 1779, NormalForce 26

Body materials: METAL 7070, PLASTIC 41

Surfaces: ASPHALT 6778, COBBLESTONE 333

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.038 |
| whole frame, ms | 12.271 (p50) | 13.473 | 19.512 |
| all GE Lua, ms | | 1.111 | 3.439 |
| physics + vehicle Lua, ms | | 0.08 | 0.247 |
| render, ms | | 1.784 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.498 us per contact, 31.427 ms total, worst frame 0.146 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 22.50 | 19.51 | 0.02 | 1.32 | 0.06 | 4.11 |
| 13.58 | 17.15 | 0.01 | 1.09 | 0.08 | 1.35 |
| 12.34 | 16.40 | 0.01 | 0.88 | 0.05 | 2.40 |
| 13.26 | 15.97 | 0.01 | 1.08 | 0.06 | 1.39 |
| 9.77 | 15.93 | 0.01 | 1.02 | 0.07 | 2.48 |
