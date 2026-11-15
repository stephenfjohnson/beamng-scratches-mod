# sustained - 20261114-170859_sustained_m5-sustained_r3

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 26, "stamps": 0}`

**Incomplete drain: rendering backlog remains. This run is not a latency acceptance pass.**

Settled: False after 30.005 s - 1172 frames, 34.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18942 | 1863 | 1407 | 50 | 2592 | 466 | 466 | 0.0% | 47 | 123 |

Rejected contacts: BelowThresh 13487, PartExcluded 2252, Wheel 1303, NormalForce 19, BodyMat 18

Body materials: METAL 1617, PLASTIC 246

Surfaces: ASPHALT 1402, COBBLESTONE 441, RUMBLE_STRIP 20

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.673 | 43.8 | 739.677 |
| whole frame, ms | 23.241 (p50) | 55.836 | 757.856 |
| all GE Lua, ms | | 44.926 | 740.868 |
| physics + vehicle Lua, ms | | 5.351 | 12.689 |
| render, ms | | 3.075 | |

- Painter frames over 4 ms: 605; worst flush (project + bake) 739.635 ms, worst composite 0.165 ms.
- Detector: 0.975 us per contact, 31.545 ms total, worst frame 0.632 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 19.45 | 757.86 | 739.68 | 46.65 | 0.07 | 2.81 |
| 11.58 | 81.05 | 49.87 | 1.35 | 12.25 | 2.40 |
| 24.55 | 78.45 | 51.21 | 0.98 | 1.55 | 1.89 |
| 18.95 | 76.17 | 58.23 | 36.37 | 0.15 | 2.49 |
| 13.13 | 74.51 | 52.64 | 37.94 | 0.12 | 2.91 |
