# sideslide - 20261114-222452_sideslide_synth-full-vk-endurance_r25

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.185 s - 326 frames, 77.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2305 | 647 | 90 | 130 | 111 | 111 | 132 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 981, BelowThresh 673, NormalForce 4

Body materials: METAL 475, PLASTIC 172

Surfaces: ASPHALT 647

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.318 | 3.885 | 6.98 |
| whole frame, ms | 12.242 (p50) | 18.835 | 23.443 |
| all GE Lua, ms | | 4.861 | 7.998 |
| physics + vehicle Lua, ms | | 0.082 | 0.172 |
| render, ms | | 1.761 | |

- Painter frames over 4 ms: 15; worst flush (project + bake) 2.654 ms, worst composite 0.073 ms.
- Detector: 1.739 us per contact, 7.969 ms total, worst frame 0.383 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.34 | 23.44 | 4.55 | 4.04 | 0.05 | 2.74 |
| 2.65 | 21.69 | 2.80 | 1.42 | 0.03 | 1.32 |
| 2.27 | 21.47 | 2.97 | 5.33 | 0.06 | 1.58 |
| 0.36 | 21.26 | 3.92 | 5.91 | 0.08 | 2.59 |
| 2.71 | 21.14 | 2.89 | 5.75 | 0.05 | 1.67 |
