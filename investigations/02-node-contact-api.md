# Investigation #2 — Node-contact API

**Build investigated:** 0.38.5.0 build 19602
**Source root:** `E:\SteamLibrary\steamapps\common\BeamNG.drive\lua\vehicle\` and `…\lua\common\`
**Status:** Much better than the plan assumed. The engine **already pushes a per-contact callback** into VLUA carrying everything we need — slip velocity, normal force, surface material, contact normal. We do **not** need to derive contact from `getNodePosition` + GE-side raycasts. This is the largest plan delta of any of the three investigations.

---

## 0. The smoking gun: `onNodeCollision`

`lua/vehicle/main.lua:485`:

```lua
function onNodeCollision(id1, pos, normal, nodeVel, perpendicularVel, slipVec, slipVel,
                         slipForce, normalForce, depth, materialId1, materialId2)
  local p = particlefilter.particleData
  p.id1, p.pos, p.normal, p.nodeVel, p.perpendicularVel = id1, pos, normal, nodeVel, perpendicularVel
  p.slipVec, p.slipVel, p.slipForce = slipVec, slipVel, slipForce
  p.normalForce, p.depth, p.materialID1, p.materialID2 = normalForce, depth, materialId1, materialId2

  wheels.nodeCollision(p)
  fire.nodeCollision(p)
  controller.nodeCollision(p)
  particlefilter.nodeCollision(p)
  bdebug.nodeCollision(p)
end
```

This is a **global function** in VLUA, called by the C++ physics engine on every node-vs-world contact event. The named arguments tell the whole story:

| Field | Meaning |
| --- | --- |
| `id1` | Node CID (the colliding body node) |
| `pos` | Contact point in world space |
| `normal` | Surface normal at contact |
| `nodeVel` | Node's velocity (3D vec) |
| `perpendicularVel` | Velocity component perpendicular to `normal` — i.e., **slide speed across the surface**. **This is the scrape-detection signal.** |
| `slipVec`, `slipVel` | Friction-cone slip vector and its magnitude |
| `slipForce` | Sliding friction force |
| `normalForce` | Normal contact force — the impact-detection signal |
| `depth` | Penetration depth |
| `materialID1` | Material of the colliding node (METAL/PLASTIC/GLASS/RUBBER/…) |
| `materialID2` | Material of the surface it hit (ASPHALT/CONCRETE/DIRT/…) |

**Frequency:** called every physics tick where a contact exists. With BeamNG at 2 kHz physics, this is high volume — must be filtered aggressively before any GE round-trip.

The plan's worry — *"the official docs do NOT expose obj:getNodeContact(cid) or similar"* — was right at the API-pull level (no `getNodeContact()` exists), but pulling is unnecessary because the engine **pushes** to us.

## 1. How to subscribe in our extension

Two clean options:

### Option A: Wrap the global at extension load (recommended for v1)

```lua
-- lua/vehicle/extensions/scrapes/detect.lua
local M = {}
local origOnNodeCollision

local function onScrapeContact(id1, pos, normal, nodeVel, perpVel, slipVec, slipVel,
                                slipForce, normalForce, depth, mat1, mat2)
  -- our filtering + queueing logic
end

local function init()
  if not origOnNodeCollision then
    origOnNodeCollision = _G.onNodeCollision
    _G.onNodeCollision = function(...)
      origOnNodeCollision(...)
      onScrapeContact(...)
    end
  end
end

local function onExtensionUnloaded()
  if origOnNodeCollision then
    _G.onNodeCollision = origOnNodeCollision
    origOnNodeCollision = nil
  end
end

M.onInit = init
M.onExtensionUnloaded = onExtensionUnloaded
return M
```

Pros: tiny, surgical, works without modifying core. Cons: every reload (Ctrl+R) re-wraps; we must guard against double-wrapping (the `if not origOnNodeCollision` does that).

### Option B: Patch a sibling module

Don't. The engine modules (`wheels`, `fire`, `controller`, `particlefilter`, `bdebug`) are core and should not be touched by a mod.

### Option C: Find a real extension hook

There isn't one. `extensions.hook(...)` is only fired in places like `beamstate.beamBroken`, `onTireDeflated`, etc. **Not** for `onNodeCollision`. If we want a hook fired, we'd need to PR upstream — out of scope for this mod.

**Decision: Option A.**

## 2. Body-vs-wheel discrimination — also free

The dispatched `wheels.nodeCollision(p)` (`lua/vehicle/wheels.lua:100`) shows the standard:

```lua
local node = v.data.nodes[p.id1]
if node then
  local wheelID = node.wheelID
  if wheelID then
    -- wheel contact
  elseif p.slipForce > 0 then
    -- non-wheel body contact
  end
end
```

`v.data.nodes[id].wheelID` is **non-nil for tire/hub nodes, nil for body nodes** — exactly the discriminator we want. We add: `if node.wheelID then return end` to ignore tire contacts, since the existing tire-skid system already handles those.

## 3. `nodeMaterial` — the body material enum (full list)

Source of truth: `lua/common/particles.json` (loaded by `lua/common/particles.lua` and exposed as `particles.getMaterialsParticlesTable()`).

The first array entry is a schema row; real materials start at index **1**:

| ID | Name | RGB hint |
| --- | --- | --- |
| 1 | METAL | 192,192,192 |
| 2 | PLASTIC | 0,0,255 |
| 3 | RUBBER | 0,0,0 |
| 4 | GLASS | 0,255,255 |
| 5 | WOOD | 128,96,64 |
| 6 | FOLIAGE | 64,255,64 |
| 7 | CLOTH | 192,192,128 |
| 8 | WATER | 0,0,255 |
| 9 | ASPHALT | 128,128,0 |
| 10 | ASPHALT_WET | 128,128,255 |
| 11 | SLIPPERY | 255,255,225 |
| 12 | ROCK | 64,64,128 |
| 13 | DIRT_DUSTY | 118,130,96 |
| 14 | DIRT | 120,100,80 |
| 15 | SAND | 200,195,140 |
| 16 | SANDY_ROAD | 150,145,100 |
| 17 | MUD | 100,80,0 |
| 18 | GRAVEL | 96,80,0 |
| 19 | GRASS | 96,80,0 |
| 20 | ICE | 196,255,237 |
| 21 | SNOW | 255,255,255 |
| 22–24 | FIRESMALL/FIREMEDIUM/FIRELARGE | (smoke/fire) |
| 25–27 | SMOKE/STEAM | |
| 28 | RUMBLE_STRIP | |
| 29 | COBBLESTONE | 64,64,128 |
| 30 | FOLIAGE_THIN | |
| 31 | SPIKE_STRIP | |

The header in `particles.json` warns: *"the order here defines the groundmodel ids that are hardcoded in vlua, do NOT change this order without speaking to @estama or @fenkler"* — i.e., these IDs are stable across patches by contract. Comments in the file refer to METAL=2, GLASS=5, etc., implying a 1-offset (probably treating the schema row as index 1). **For safety, look up by name at runtime** rather than hardcoding ID numbers:

```lua
local materials = particles.getMaterialsParticlesTable()
local NM_METAL    = particles.getMaterialIDByName(materials, "METAL")
local NM_ASPHALT  = particles.getMaterialIDByName(materials, "ASPHALT")
local NM_DIRT     = particles.getMaterialIDByName(materials, "DIRT")
-- … etc
```

`particles.getMaterialIDByName` is exported (line 30 of `particles.lua`).

## 4. The engine's own scrape-spark thresholds — our reference

`particles.json` defines exactly which combinations spawn sparks/dust/etc. Selected rows for our use case:

```
METAL  + ASPHALT  , slipVel > 2.5  → spark (particleType 1)
METAL  + METAL    , slipVel > 2.5  → spark (particleType 1)
METAL  + GRAVEL   , slipVel > 2.5  → dust + spark
METAL  + WOOD     , slipVel > 2.5  → wood chips
METAL  + DIRT     , slipVel > 2.5  → dust spray
PLASTIC + (same)  , similar thresholds
```

Plus the impact (perpendicular-velocity) rows:

```
METAL  + DIRT       , perpendicularVel > 2.5 → impact dust
PLASTIC + DIRT_DUSTY, perpendicularVel > 2.5 → impact dust
```

These are the engine's calibrated thresholds for "yes, this is a real scrape/impact, not noise." We should mirror them as defaults:

- **Scrape:** body node has `nodeMaterial ∈ {METAL, PLASTIC, GLASS}` AND `materialID2 ∈ {ASPHALT, ASPHALT_WET, SLIPPERY, ROCK, METAL, COBBLESTONE, RUMBLE_STRIP, GRAVEL}` AND `slipVel > 2.5` AND `slipForce > 0`.
- **Impact:** body node material as above AND `perpendicularVel > 2.5` AND `normalForce > some-threshold`.

Plus the particlefilter heuristic from `particlefilter.lua:29`:
```lua
if p.perpendicularVel > p.depth * depthCoef then
```
where `depthCoef = 0.5 / physicsDt` (line 6) — penetration-velocity vs penetration-depth, used as a "real contact" filter (rejects grazing contacts).

## 5. Beam-break / beam-deform events (the secondary signal)

Independent of `onNodeCollision`, two beam-event hooks fire from `beamstate.lua`:

- `beamstate.beamBroken(id, energy)` (`beamstate.lua:800`) — beam fully broke. Receives `id` (beam CID) and `energy` (joules dissipated). Used by the engine to break collision tris, deflate tires, hide props, spawn break particles. **Our hook target for "deep gouge / metal exposed / panel rip" events.** Beam-id → part-path lookup is via `beamBodyPartLookup[id]` and `v.data.beams[id].partPath`.
- `beamstate.onBeamDeformed(id, ratio)` (`beamstate.lua:1270`) — *"only being called if the beam has deform triggers"* (per the source comment). `ratio` is the deformation amount. **Less universal** — only beams with `deformGroup` or `deformSwitches` set fire this. So it's not a substitute for `onNodeCollision`, but it's useful for "body panel was visibly bent" → trigger a bigger paint-flake patch.

Both are member functions of the `beamstate` module and called by the C++ side via `beamstate.beamBroken(id, energy)` and `beamstate.onBeamDeformed(id, ratio)`. They are NOT extensions hooks. Same wrapping technique applies if we want to listen.

## 6. obj:* bindings worth probing in-game

Not needed for v1 (since `onNodeCollision` covers it), but good to have for Phase 2/3 verification. Confirmed used in source:

| Binding | Returns / does |
| --- | --- |
| `obj:getId()` | numeric vehicle id |
| `obj:getNodePosition(cid)` | vec3 world pos |
| `obj:getNodeVelocity(cid)` | vec3 velocity (existence implied — should verify with `dump(obj)` since not directly seen but standard) |
| `obj:getNodeMass(cid)` | mass |
| `obj:getOriginalNodeMass(cid)` | spawn mass |
| `obj:getDissipatedEnergy()` | scalar — total dissipated energy |
| `obj:getBeamRestLength(cid)`, `obj:beamIsBroken(cid)`, `obj:getBeamDeformation(cid)` | per-beam state |
| `obj:addParticleByNodesRelative(n1, n2, t, type, …)` | spawn engine particle (e.g. spark on contact) |
| `obj:addParticleVelWidthTypeCount(id, normal, vel, mult, w, type, count)` | richer particle spawn with vel/normal |
| `obj:queueGameEngineLua("string")` | **VLUA → GELUA bridge.** This is how our detect.lua sends scrape events to our paint.lua. |
| `obj:queueObjectLuaCommand(otherObjId, "string")` | VLUA → other-vehicle VLUA |
| `obj:setPersistentData(s)` / `obj:getPersistentData()` | round-trip save/load. **Useful for masks save/load in Phase 5.** |
| `obj:breakCollisionTriangle(ctid)`, `obj:breakBeam(id)`, `obj:breakMeshes(id)` | break-state mutators |
| `obj:setNodeFrictionSlidingCoefs`, `obj:setBeamSpringDamp`, `obj:setBeamPressureRel` | physical mutators |
| `obj.debugDrawProxy:drawNodeSphere`, `obj.debugDrawProxy:drawText2D` | debug viz from VLUA |
| `obj:inSameNodeCluster(a, b)` | same-cluster check |
| `obj:setPlanets(p)` | gravity field setter |

For the in-game `~` console, `dump(obj)` will list everything. We should run that as the very first probe in Phase 1.

## 7. From contact event to "which panel got scraped"

The plan's biggest open question. Two routes available:

**Route 1: node → part-path** (cheap, JBeam-level)

`v.data.nodes[id].partPath` (sometimes `partOrigin`) — the JBeam path that contributed this node. E.g. `"/vehicles/pessima/pessima_body.jbeam"` or just a part name. This tells us *which JBeam part* the colliding node belongs to (front bumper, hood, left fender, etc.). For Phase 1's logging, `partPath` is enough: "scrape at node 142 on `pessima_hood.jbeam`."

**Route 2: world → mesh triangle → UV** (expensive, mesh-level)

For the actual paint stamping in Phase 3, we need to translate world position to UV on the body mesh. From investigation #1 we know the engine's natural API does this *via* a virtual camera projection (`decalProjection:getDecalData(cam, projM)`) rather than barycentric lookup. So Route 2 collapses to *"send pos+normal to GE, synthesize a virtual camera, call addDecal."* No barycentric math required for the engine path.

The **velocity → UV-tangent direction** part of the plan (Phase 3 step 2: "transform by inverse of UV-to-world Jacobian") is therefore *not* the engine's natural path either. The engine's `decalRotation` plus `slipVec` projected onto the contact tangent plane is sufficient — the brush-stroke layer type (or a stretched single decal) handles the directional smear.

This means **Phase 3's "world-to-UV pipeline and brush stamping" is mostly about choosing scrape brushes and generating brushStroke layers, NOT about per-triangle barycentric math.** Significant simplification.

## 8. Performance / cost notes

- `onNodeCollision` fires per contact per physics tick. With ~20 body nodes scraping a curb at 2 kHz, that's 40 000 calls/s. **Filter aggressively before doing anything.** Material check (cheap, table lookup) → wheelID check (cheap, field access) → magnitude check (cheap, scalar compare). Only after passing all three, accumulate to a per-tick batch.
- Batch and flush per VLUA tick: collect contacts in a Lua table during `onNodeCollision`, then in a per-tick `onPhysicsStep` send the whole batch as one `obj:queueGameEngineLua("scrapes_paint.applyBatch(<serialized>)")`. **One VLUA→GELUA round-trip per tick maximum**, not per contact.
- The plan's "2 kHz detection rate" is optimistic — in practice, we accumulate across multiple physics steps and flush once per render frame is fine. The damage mask doesn't need 2 kHz fidelity; the human eye won't see a difference between 60 Hz and 2 kHz of paint update.

## 9. Open probes for Phase 1

- `dump(obj)` from the in-game console to enumerate all `obj:*` bindings on the current build.
- `dump(v.data.nodes[some_body_node_id])` to confirm which fields are populated (`partPath`, `partOrigin`, `nodeMaterial`, `wheelID`, …) on a vanilla vehicle.
- Drag the test car along a curb and `print(...)` from `onNodeCollision` to confirm the call rate, the plausibility of `slipVel`/`slipForce` thresholds, and whether `materialID2` correctly identifies "ASPHALT" on a road and "ROCK" on a wall.
- Verify `obj:queueGameEngineLua` round-trip latency by sending a timestamp and printing it on receipt.

## 10. Plan deltas

1. **Detection is push-based, not pull-based.** Plan said "derive contact from `getNodePosition` + `getNodeVelocity` + GE-side raycasts." In reality, `onNodeCollision(id1, pos, normal, nodeVel, perpendicularVel, slipVec, slipVel, slipForce, normalForce, depth, materialId1, materialId2)` is called on us. **No raycasts needed.**
2. **Phase 3 simplifies.** The plan's "world-to-UV pipeline and brush stamping" with barycentric math and Jacobian inversion is replaced by "synthesize a virtual camera at the contact point pointing along the contact normal, then call `decalProjection:getDecalData(cam, projM)`." The engine does the projection-onto-mesh math for us. Plan's Phase 3 can shed ~half its scope.
3. **Use `particles.json` as the canonical threshold reference.** The engine's own spark/dust thresholds are right there, version-stable by contract. Mirror them as defaults.
4. **`nodeMaterial` enum is dynamic — look up by name.** `particles.getMaterialIDByName(materials, "METAL")` at init. The order is "stable by contract" but the indices interact with a schema row in a way that's fragile to hardcode.
5. **Beam-break events stay in the plan,** but now as a *secondary* signal for "this was a panel-tearing event" specifically. `beamBroken(id, energy)` and `onBeamDeformed(id, ratio)` are not substitutes for `onNodeCollision` — they're complementary, fired only for break/deform-triggered beams.
6. **`v.data.nodes[id].wheelID` is the wheel/body discriminator.** Already used by every core module — copy the pattern.
7. **`partPath` on the node is the JBeam-part identifier.** Sufficient for Phase 1 logging. Adds free per-panel attribution.
