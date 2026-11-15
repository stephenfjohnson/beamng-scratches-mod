# sustained - 20261114-205128_sustained_resumed-control-v2-disabled-vulkan-endurance_r15

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.01 s - 2446 frames, 81.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14711 | 7046 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5827, BelowThresh 1807, NormalForce 31

Body materials: METAL 7040, PLASTIC 6

Surfaces: ASPHALT 6087, COBBLESTONE 959

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.077 |
| whole frame, ms | 12.26 (p50) | 13.475 | 19.371 |
| all GE Lua, ms | | 1.136 | 3.271 |
| physics + vehicle Lua, ms | | 0.082 | 0.226 |
| render, ms | | 1.91 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.506 us per contact, 32.013 ms total, worst frame 0.096 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 25.14 | 19.37 | 0.01 | 1.27 | 0.05 | 3.42 |
| 4.76 | 18.29 | 0.01 | 1.16 | 0.07 | 2.62 |
| 5.18 | 17.82 | 0.01 | 0.97 | 0.05 | 2.52 |
| 2.09 | 16.43 | 0.01 | 0.85 | 0.04 | 2.57 |
| 24.53 | 16.42 | 0.01 | 1.02 | 0.07 | 1.68 |
