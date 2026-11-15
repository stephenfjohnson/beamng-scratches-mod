# sustained - 20261114-170748_sustained_m5-sustained_r1

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 28, "jobs": 32, "stamps": 0}`

**Incomplete drain: rendering backlog remains. This run is not a latency acceptance pass.**

Settled: False after 30.016 s - 1228 frames, 36.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 20944 | 2108 | 1650 | 37 | 2945 | 424 | 455 | 0.0% | 38 | 123 |

Rejected contacts: BelowThresh 14783, PartExcluded 3391, Wheel 614, BodyMat 37, NormalForce 11

Body materials: METAL 1893, PLASTIC 215

Surfaces: ASPHALT 1667, COBBLESTONE 438, RUMBLE_STRIP 3

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.944 | 42.037 | 54.553 |
| whole frame, ms | 18.284 (p50) | 53.984 | 458.068 |
| all GE Lua, ms | | 43.417 | 55.651 |
| physics + vehicle Lua, ms | | 5.577 | 13.334 |
| render, ms | | 2.645 | |

- Painter frames over 4 ms: 596; worst flush (project + bake) 54.494 ms, worst composite 0.174 ms.
- Detector: 0.963 us per contact, 33.573 ms total, worst frame 0.722 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.26 | 458.07 | 0.01 | 1.17 | 0.07 | 1.88 |
| 10.73 | 71.64 | 54.55 | 33.92 | 0.11 | 2.87 |
| 24.08 | 69.88 | 50.94 | 40.00 | 0.15 | 3.36 |
| 9.57 | 69.35 | 51.33 | 13.28 | 0.10 | 2.60 |
| 16.17 | 68.99 | 53.20 | 13.74 | 0.11 | 2.49 |
