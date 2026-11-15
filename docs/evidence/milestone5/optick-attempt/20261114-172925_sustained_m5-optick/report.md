# sustained - 20261114-172925_sustained_m5-optick

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.002 s - 1359 frames, 43.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17916 | 1669 | 1408 | 19 | 2504 | 424 | 421 | 0.0% | 33 | 111 |

Rejected contacts: BelowThresh 13734, PartExcluded 2131, Wheel 281, BodyMat 92, NormalForce 9

Body materials: METAL 1504, PLASTIC 165

Surfaces: ASPHALT 1347, COBBLESTONE 319, RUMBLE_STRIP 3

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 12.906 | 40.171 | 56.925 |
| whole frame, ms | 12.406 (p50) | 50.796 | 65.402 |
| all GE Lua, ms | | 41.329 | 57.776 |
| physics + vehicle Lua, ms | | 5.526 | 11.998 |
| render, ms | | 2.473 | |

- Painter frames over 4 ms: 553; worst flush (project + bake) 56.869 ms, worst composite 0.182 ms.
- Detector: 0.951 us per contact, 27.863 ms total, worst frame 0.664 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 10.49 | 65.40 | 56.93 | 0.81 | 1.66 | 1.55 |
| 28.59 | 65.02 | 54.48 | 0.83 | 3.90 | 1.80 |
| 22.52 | 64.68 | 36.46 | 2.96 | 8.34 | 8.00 |
| 30.70 | 61.53 | 46.63 | 2.82 | 2.66 | 2.19 |
| 29.01 | 61.41 | 54.17 | 0.94 | 1.03 | 1.41 |

**Optick was requested but no capture file was found. No native/GPU trace attribution is available from this run.**
