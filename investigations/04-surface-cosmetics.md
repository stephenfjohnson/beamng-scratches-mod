# Surface cosmetics implementation and engine validation handoff

## Implemented scope

Mud, dirt and snow contacts add translucent color deposits through the existing
scratch projection/bake scheduler. The existing haze brush is reused and tinted
brown, tan or off-white; this is an initial cosmetic approximation, not new mud
or snow artwork. Body contacts use the existing paintable-node filter. Tire
contacts may add soil but remain excluded from scratch generation. Contact
slip must be at least 0.5 m/s and normal force at least 10 N; ordinary rolling
without sufficient contact slip does not accumulate soil. No airborne dust,
weather, tire spray trajectory, snow depth or physical grip changes are modeled.

Material names are resolved from the engine particle table, not numeric IDs:
MUD; DIRT/DIRT_DUSTY/SAND/SANDY_ROAD/GRAVEL; SNOW. GRASS, ICE, unknown
materials and generic wet asphalt do not imply soil or liquid water. Maps whose
visual mud/snow uses a different collision material cannot be recognized reliably.

`obj:inWater(cid)` is sampled on up to eight evenly selected eligible body nodes.
Submersion suppresses new soil samples and increases a normalized wetness value;
water reduces the three normalized exposure values, and wetness dries over about
20 seconds. These values are observable through `scratches_paint.getSurfaceState()`.
Wetness increases at 0.8/sec, washing reduces each exposure at 0.15/sec. A water
sample expires after 0.5 simulated seconds; loss of messages cannot keep washing
forever. Simulated time drives these rates and pause stops them. Frame deltas are
capped at 0.25 s, so long stalls intentionally undercount elapsed exposure time.

**Visual water wetness and visual cleaning are not implemented.** The state probe
explicitly reports `visualWetnessSupported=false` and
`visualCleaningSupported=false`. Washed exposure values are not a measurement
of visible baked dirt. Existing soil remains until the normal full reset/clear.
No gloss/material changes are made. This leaves the parent's paint/skin work
untouched. The verified baked-canvas clear destroys scratches as well as soil;
there is no verified selective erase operation in the Lua API inspected here.
A future removable overlay needs a separately composited texture or a retained
layer/reprojection design with measured memory and frame costs. Do not describe
this implementation to players as a working visual car wash.

## API evidence (read-only investigation, no game execution)

Installed source inspected at
`E:/SteamLibrary/steamapps/common/BeamNG.drive/` on 2026-11-14:

- `lua/vehicle/main.lua:491`: `onNodeCollision` receives node ID, world contact
  position/normal, slip velocity, normal force and both material IDs; dispatch
  populates `materialID1` and `materialID2`. The existing repository's contact
  investigation identifies material 1 as the contacted surface, material 2 as
  the body; the harness exercises this order.
- `lua/common/particles.lua` / `particles.json`: material-name table used by the
  existing detector. No invented `getNodeContact` or ground raycast is used.
- `lua/vehicle/wheels.lua:99`: node wheel classification via `node.wheelID`.
- `lua/vehicle/wheels.lua:247`, `fire.lua:87`, `bdebugImpl.lua:1140`: stock code
  uses `obj:inWater(nodeId)`. Absence/errors are tolerated and reported through
  `waterSupported`; water is not inferred from a guessed height API.
- `lua/ge/extensions/editor/api/dynamicDecals.lua:1584,1647,2245,3039`:
  `bakeLayers`, whole baked-texture rebuild, dynamic preview flush and texture
  combine. Flushing preview textures does not selectively erase baked soil.
- Official [ground model documentation](https://documentation.beamng.com/modding/levels/level_formats/groundmodels/)
  confirms `collisiontype` resolves through the particle materials table and
  maps may override ground models. Visual terrain names are not dependable IDs.

## Bounds and lifecycle

- Three coalesced samples maximum per 0.25 simulated seconds (one per kind).
  First contact of each kind wins; contact multiplicity does not raise the rate.
- At most eight water queries per tick, one cached node scan per lifecycle.
- One small surface packet per tick, including dry heartbeats. No traffic work.
- 96 lifetime deposit **attempts**, three per kind per approximately 33 cm
  vehicle-local cell. Rejected/dropped projections still consume this allowance;
  washing does not restore it. State accumulation can continue at the cap.
- Same bounded stamp/job/bake queues and projection budget as scratches. Surface
  jobs can contend with scratches under overload; no separate unbounded queue.
- Reset clears pending exposure samples and water-node selection; clear, switch,
  player spawn and painter unload reset GE surface state. Leaving the vehicle
  drops unsent samples. Foreign-vehicle packets are ignored. Disabling detection
  or painting drops unsent surface samples. Existing baked marks persist until
  the established clear/reset path removes them.
- No persistent per-vehicle save. Same-ID delayed packets across reset have the
  existing scratch pipeline's FIFO/lifecycle assumptions (no generation token).

## Verification and integration

Run from the repository root, without deploying:

```text
lua tools/sim/harness.lua
python -c "import tools.package as p; f=p.collect_files(); p.check_lua_syntax(f); p.check_brush_sidecars(f)"
git diff --check
```

Result: 165 mock checks pass; Lua 5.1 syntax, global allow-list and brush sidecars
pass. Tests cover the existing scratch pipeline plus tire soil classification,
1000-contact coalescing, all three surface kinds, internal-node rejection,
water wetting/washing/drying, missing API fallback, foreign/invalid packets,
deposit cap, shared projection budget, disable, exit, reset and switch.
Mocks do not validate rendering, engine performance, water coverage or ABI.

Parent integration: cherry-pick the implementation commit, resolve any overlapping
paint lifecycle edits while retaining `resetSurfaceState` calls, and run the above
checks. No new module, asset or packaging entry is needed. No README/release
changes were made. Nothing was deployed, published or sent to a running game.

Engine-only checks for the parent:

1. On a supported non-liveried vehicle/working renderer, slide tires and body
   over actual MUD, DIRT and SNOW collision materials; compare the state probe
   and visible deposits. Verify the contact-point projection/hull approximation
   lands on body panels: wheel-ground positions can miss, hit inappropriate
   panels, or be occluded. There is no simulated wheel-to-panel splash path.
2. Enter water far enough to submerge sampled body nodes. Confirm wetness rises,
   exposure falls and new deposits stop. Shallow wheel-only puddles or water
   between sampled nodes may be missed. Confirm dry decay and pause behavior.
3. Verify scratches still appear on hard contacts and survive water entry.
   Expect visible baked soil to survive too; reset should remove both.
4. Exercise reset, same-ID respawn, player switch, vehicle removal and hot reload
   with queued work. Confirm no old surface marks reach the next car.
5. Profile sustained mixed contacts and the capped state on the target engine.
   Count bounds are mock-tested, but no FPS or latency guarantee is established.

No visual verification or live-game performance measurement was performed.
