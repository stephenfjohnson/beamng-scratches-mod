# sustained - 20261114-172518_sustained_m5-vulkan-sustained_r1

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.001 s - 2321 frames, 67.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18144 | 1682 | 1420 | 33 | 2196 | 483 | 434 | 0.0% | 0 | 95 |

Rejected contacts: BelowThresh 14481, PartExcluded 1932, Wheel 37, NormalForce 7, BodyMat 5

Body materials: METAL 1499, PLASTIC 183

Surfaces: ASPHALT 1351, COBBLESTONE 321, RUMBLE_STRIP 10

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.409 | 31.72 | 56.262 |
| whole frame, ms | 12.29 (p50) | 42.249 | 760.245 |
| all GE Lua, ms | | 32.75 | 57.245 |
| physics + vehicle Lua, ms | | 0.269 | 5.985 |
| render, ms | | 2.101 | |

- Painter frames over 4 ms: 518; worst flush (project + bake) 56.163 ms, worst composite 0.212 ms.
- Detector: 1.302 us per contact, 40.941 ms total, worst frame 0.767 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 30.24 | 760.25 | 0.01 | 3.88 | 0.05 | 1.49 |
| 0.60 | 68.62 | 56.26 | 1.13 | 0.07 | 1.80 |
| 0.80 | 66.05 | 52.95 | 0.93 | 0.05 | 2.05 |
| 4.23 | 64.65 | 48.13 | 0.96 | 0.06 | 1.46 |
| 3.96 | 60.97 | 46.42 | 1.22 | 0.07 | 1.70 |
