# sustained - 20261114-172628_sustained_m5-vulkan-sustained_r3

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.014 s - 2259 frames, 68.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 21180 | 1864 | 1446 | 53 | 2320 | 427 | 449 | 0.0% | 0 | 109 |

Rejected contacts: BelowThresh 16999, PartExcluded 2156, Wheel 131, BodyMat 20, NormalForce 10

Body materials: METAL 1657, PLASTIC 207

Surfaces: ASPHALT 1479, COBBLESTONE 384, RUMBLE_STRIP 1

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.512 | 31.862 | 54.56 |
| whole frame, ms | 12.648 (p50) | 40.773 | 65.827 |
| all GE Lua, ms | | 32.735 | 55.589 |
| physics + vehicle Lua, ms | | 0.433 | 3.909 |
| render, ms | | 2.154 | |

- Painter frames over 4 ms: 528; worst flush (project + bake) 54.529 ms, worst composite 0.545 ms.
- Detector: 1.122 us per contact, 39.743 ms total, worst frame 0.784 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.81 | 65.83 | 54.56 | 1.11 | 0.06 | 1.51 |
| 0.60 | 63.23 | 50.88 | 1.32 | 0.09 | 2.18 |
| 27.26 | 59.03 | 46.33 | 0.78 | 0.05 | 1.28 |
| 21.92 | 57.96 | 44.93 | 0.84 | 0.05 | 1.24 |
| 22.77 | 57.78 | 43.01 | 1.23 | 0.07 | 1.65 |
