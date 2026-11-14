# sideslide - 20261114-163931_sideslide_m5-original-warm_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Settled: True after 4.452 s - 122 frames, 27.2 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.153)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 957 | 267 | 109 | 47 | 217 | 78 | 57 | 0.0% | 0 | 10 |

Rejected contacts: Wheel 518, BelowThresh 170, NormalForce 2

Body materials: METAL 195, PLASTIC 72

Surfaces: ASPHALT 267

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 24.299 | 54.893 | 62.758 |
| whole frame, ms | 42.581 (p50) | 66.106 | 84.2 |
| all GE Lua, ms | | 55.806 | 63.751 |
| physics + vehicle Lua, ms | | 7.766 | 10.97 |
| render, ms | | 2.898 | |

- Painter frames over 4 ms: 74; worst flush (project + bake) 58.271 ms, worst composite 0.107 ms.
- Detector: 1.83 us per contact, 4.468 ms total, worst frame 0.489 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.52 | 84.20 | 56.53 | 33.83 | 0.09 | 2.48 |
| 1.77 | 77.76 | 58.32 | 35.36 | 0.11 | 2.63 |
| 0.67 | 73.39 | 62.76 | 37.60 | 0.13 | 2.90 |
| 3.42 | 71.95 | 55.53 | 36.03 | 0.10 | 2.03 |
| 0.40 | 69.66 | 62.15 | 56.54 | 0.06 | 2.00 |
