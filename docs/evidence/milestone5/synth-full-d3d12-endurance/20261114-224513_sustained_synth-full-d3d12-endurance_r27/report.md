# sustained - 20261114-224513_sustained_synth-full-d3d12-endurance_r27

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.004 s - 2663 frames, 88.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14741 | 7027 | 65 | 602 | 120 | 210 | 220 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6489, BelowThresh 1173, NormalForce 52

Body materials: METAL 7025, PLASTIC 2

Surfaces: ASPHALT 5789, COBBLESTONE 1238

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.025 | 11.129 | 27.778 |
| whole frame, ms | 10.86 (p50) | 21.108 | 38.196 |
| all GE Lua, ms | | 12.034 | 28.902 |
| physics + vehicle Lua, ms | | 0.084 | 1.033 |
| render, ms | | 2.346 | |

- Painter frames over 4 ms: 220; worst flush (project + bake) 3.825 ms, worst composite 0.126 ms.
- Detector: 3.137 us per contact, 69.636 ms total, worst frame 0.506 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.48 | 38.20 | 21.33 | 28.90 | 0.06 | 2.02 |
| 0.46 | 35.95 | 27.78 | 2.18 | 0.05 | 1.97 |
| 0.34 | 34.47 | 24.60 | 1.81 | 0.06 | 3.09 |
| 13.62 | 33.31 | 20.84 | 2.67 | 0.06 | 2.10 |
| 14.33 | 32.64 | 18.19 | 1.46 | 0.05 | 1.93 |
