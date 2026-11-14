# Milestone 2: progressive mud, dirt and snow

Implemented on the milestone 1 baseline b08721f. No water visual effects or
public release are included. This supersedes the soil portion of investigation 04.

## Behavior and engine basis

Real `onNodeCollision` surface material IDs resolve through the engine particle
table: MUD; DIRT/DIRT_DUSTY/SAND/SANDY_ROAD/GRAVEL; SNOW. Wheels need vehicle
translation of at least 0.75 m/s and contact force of at least 10 N, not tire
slip. Stationary wheelspin does not add deposits. Body contacts retain the
0.5 m/s slip gate and existing paintable-node filter.

Installed 0.40.5 source consulted: `lua/vehicle/main.lua:491` collision signature,
`wheels.lua:99` node.wheelID, `controller/dragTimer.lua:60` getVelocity, and
`extensions/advancedwheeldebug.lua:43` world node position from getNodePosition
plus getPosition. Wheel samples refresh at send time, avoiding stale world
positions trailing the moving car. Tires take priority over body samples;
preference rotates over four wheel IDs, with the first available as fallback.

GE projects from the exterior side, aiming at lower flank panels near the
emitting wheel with bounded spread toward the body center. This is an AABB
placement approximation, not simulated spray trajectories. Dedicated seeded
512x512 alpha masks provide irregular mud clumps, finer dense dirt coverage,
and larger soft-edged snow patches. Repeated overlap increases coverage.
The ETK private material adapter and original stages remain in use.

## Reproduce the real runs

BeamNG **0.40.5.0 x64 build 302427**, **D3D12**, NVIDIA RTX 3090, Windows 11.
3840x2160; Custom, Ultra lighting, High shaders, Normal textures, SMAA,
dynamic reflections on. Engine screenshots are 1920x1080 at 0.5 scale,
unretouched. The restart used by this milestone selected D3D12: these captures
must not be described as Vulkan results from milestone 1.

ETK 800 `vehicles/etk800/rennspecht_8r_A.pc`, Police or empty Paint Design.
All paints, original material comparisons, positions, counters and graphics
settings are preserved in the JSON alongside the captures.

With the game/MCP running and the supported ETK selected:

```powershell
python tools/dev.py deploy
# Gridmap v2 ground model strips, actual throttle-driven physics
python tools/soil_probe.py mud --x -313
python tools/soil_probe.py dirt --x -350 --seconds 5
# Automation Test Track snowy hillside (load the map first)
python tools/soil_probe.py snow --x -500 --y 900 --z 270 --seconds 5
```

These tools move the current vehicle, clear cosmetics, apply throttle, pause for
captures and park afterward. They do not inject contact events. The snow route
also crosses a few dirt contacts; visual snow or road names alone do not prove
SNOW collision material. Initial attempts at the roadside wall were rejected;
only the hillside run is retained as snow evidence.

| Case | Evidence |
| --- | --- |
| Mud progression and scratches over Police | [early](../docs/evidence/milestone2/mud-early.png), [late](../docs/evidence/milestone2/mud-late.png), [parked](../docs/evidence/milestone2/mud-stationary.png), [raw](../docs/evidence/milestone2/mud.json) |
| Dirt progression over Police | [early](../docs/evidence/milestone2/dirt-early.png), [late](../docs/evidence/milestone2/dirt-late.png), [parked](../docs/evidence/milestone2/dirt-stationary.png), [raw](../docs/evidence/milestone2/dirt.json) |
| Snow over Police | [early](../docs/evidence/milestone2/snow-early.png), [late](../docs/evidence/milestone2/snow-late.png), [parked](../docs/evidence/milestone2/snow-stationary.png), [raw](../docs/evidence/milestone2/snow.json) |
| Snow over plain paint | [parked](../docs/evidence/milestone2/snow-plain-stationary.png), [raw](../docs/evidence/milestone2/snow-plain.json) |
| Sustained rolling to cap | [capture](../docs/evidence/milestone2/dirt-capped.png), [raw samples](../docs/evidence/milestone2/cap.json) |
| Map teardown and editor activation/return | [raw](../docs/evidence/milestone2/editor-map-return.json) |
| Reset, unsupported vehicle switch and return | [reset capture](../docs/evidence/milestone2/reset.png), [raw](../docs/evidence/milestone2/lifecycle.json) |

Stationary start/end samples record velocity as well as deposit counts. Mud
stays at 37, dirt at 29, Police snow at 32 during the three-second parked
observation. Mud driving also generates actual body scratches as the low car
sinks into the strip; these coexist with soil and the stock lettering. In the
separate rolling stress, scratch events remain zero.

## Bounds and measured costs

At most three coalesced samples per 0.25 simulated seconds, one per kind;
96 lifetime deposit attempts total, 12 per kind per approximately 33 cm cell.
The spot table therefore has at most 96 entries. No new per-frame scan, texture
canvas, material stage or unbounded history was added. Shared scheduler limits
remain 160 aggregate inputs/frame, 64 jobs, 6 projections/flush and 6 baked
layers/frame. Failed/dropped attempts consume the allowance too.

`python tools/soil_cap_probe.py` maintains 2 m/s using the stock cluster velocity
API on real DIRT collision terrain. This is assisted rolling, distinct from the
throttle-driven examples. Counts progress **20, 40, 61, 81, 96, 96, 96**.
Exactly 96 projections, 96 baked layers, zero dropped/missed jobs, no scratch
events, and empty queues at the end. Across 3563 sampled painter frames, total
painter CPU time is 2955.2 ms, peak 27.31 ms; peak projection 27.01 ms and bake
10.49 ms. Mixed mud/body-scrape work peaked at 77.04 ms. These are measured CPU
costs, not GPU time, total-frame FPS, a memory certification, or a guarantee.
Projection/bake spikes remain a milestone 5 limitation.

## Lifecycle, isolation and limitations

Full reset, switching and reload discard soil with scratches. Original material
field comparisons remain empty. Map switching exposed stale cloned-material
userdata during unload; cleanup now re-resolves by name and skips scene objects
already deleted by level teardown. Regression tests exercise that ordering.
Editor ownership guards and the isolated projection remain unchanged.

Soil detection, packet type, brush assets and exposure state remain distinct from
scratch generation, but their final canvas is still shared. Milestone 3 must
provide separate composition or a bounded replay design before selective visual
washing; current exposure decay is not visual cleaning. No wetness/gloss or
washing rendering was added. Dark soil opacity remains color-dependent in the
existing adapter, and the snow is a cosmetic patch coating, not volumetric snow.

Support is demonstrated for this ETK main body/config, these maps and this
renderer/build. Four-wheel preference and AABB placement are not certification
for every vehicle or deformed body. Other designs stay skipped; legacy plain
vehicles are not newly certified. No stable public release is made.

Preflight: Lua 5.1 syntax/global allow-list, brush sidecars and **205 mock checks**.
Mocks validate gates/bounds/lifecycle; the actual images and physics runs above
supply the rendering evidence.

Within the stated ETK/build/renderer scope, milestone 2 feature acceptance passes.
Milestone 3 is not started. Broad performance work remains milestone 5.
