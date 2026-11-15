# sustained - 20261114-170824_sustained_m5-sustained_r2

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 39, "stamps": 0}`

**Incomplete drain: rendering backlog remains. This run is not a latency acceptance pass.**

Settled: False after 30.018 s - 1191 frames, 35.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 20100 | 1945 | 1621 | 22 | 2890 | 439 | 483 | 0.0% | 26 | 125 |

Rejected contacts: BelowThresh 14479, PartExcluded 3042, Wheel 383, NormalForce 194, BodyMat 57

Body materials: METAL 1759, PLASTIC 186

Surfaces: ASPHALT 1483, COBBLESTONE 461, RUMBLE_STRIP 1

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 16.836 | 41.243 | 61.497 |
| whole frame, ms | 25.057 (p50) | 52.844 | 102.299 |
| all GE Lua, ms | | 42.412 | 63.005 |
| physics + vehicle Lua, ms | | 5.874 | 12.845 |
| render, ms | | 2.866 | |

- Painter frames over 4 ms: 623; worst flush (project + bake) 61.463 ms, worst composite 0.23 ms.
- Detector: 0.796 us per contact, 29.08 ms total, worst frame 0.509 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 21.63 | 102.30 | 36.80 | 27.67 | 0.06 | 1.44 |
| 8.54 | 81.97 | 61.50 | 15.55 | 0.16 | 2.44 |
| 8.80 | 77.56 | 58.47 | 37.24 | 0.16 | 3.11 |
| 13.29 | 76.08 | 48.53 | 1.21 | 9.94 | 2.39 |
| 8.30 | 71.36 | 54.48 | 32.95 | 0.11 | 2.52 |
