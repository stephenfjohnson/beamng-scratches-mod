# sideslide - 20261114-173054_sideslide_candidate-d3d12-endurance_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.271 s - 144 frames, 35.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1019 | 275 | 89 | 59 | 168 | 85 | 57 | 0.0% | 0 | 8 |

Rejected contacts: Wheel 519, BelowThresh 224, NormalForce 1

Body materials: METAL 199, PLASTIC 76

Surfaces: ASPHALT 275

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.489 | 47.73 | 58.652 |
| whole frame, ms | 21.073 (p50) | 56.712 | 79.693 |
| all GE Lua, ms | | 48.784 | 59.534 |
| physics + vehicle Lua, ms | | 5.583 | 8.746 |
| render, ms | | 2.354 | |

- Painter frames over 4 ms: 74; worst flush (project + bake) 58.611 ms, worst composite 0.102 ms.
- Detector: 2.056 us per contact, 5.651 ms total, worst frame 0.883 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 79.69 | 49.61 | 1.09 | 2.05 | 7.24 |
| 2.11 | 66.75 | 58.65 | 0.96 | 2.24 | 1.37 |
| 2.95 | 61.19 | 48.99 | 34.04 | 0.07 | 1.61 |
| 0.38 | 60.69 | 47.89 | 0.80 | 0.07 | 1.85 |
| 2.53 | 60.17 | 33.71 | 0.96 | 8.75 | 1.80 |
