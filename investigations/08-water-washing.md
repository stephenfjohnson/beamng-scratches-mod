# Milestone 3: water compositor and live validation

Development work from `20ff2ea`; no milestone 4 or stable release.

## Bounded layer design

The ETK clone has four stages: the two original stock stages, lasting damage,
and removable soil. A live solid-color experiment established that
`vehicle:setTextureSet("@ScratchesSoil", textureSet)` supports a separate named
set before implementation. The original private damage target stays intact.
A second `DecalProjection` uses 1024x512 texels (524,288), one sixteenth of the
existing 4096x2048 projection area. One soil target is reused across vehicle
switches within the painter instance. No layer history or replay is retained.
Original paint maps, normals, metallic, palette and livery are never replaced.

The existing six-layer/frame bake allowance is partitioned between damage and
soil; it is not doubled. Soil retains the 96-attempt, 12-per-cell bounds. Washing
changes the soil stage opacity in 20 steps and clears **only the soil target**
once fully removed, reopening the deposition allowance. It never clears or
replays the damage target. Partial washing retains its attenuation when fresh
soil arrives; a completed wash starts a new full-strength deposit cycle.
This is a whole-body cosmetic approximation, not a spatial waterline mask.

At most eight representative body nodes call the real vehicle `obj:inWater(cid)`
every 0.25 simulated seconds. Their submerged fraction scales wetting and washing:
full immersion takes about eight simulated seconds to remove a full soil cycle;
shallow water touching no sampled body node does nothing. Stationary immersion
works. A 0.5-second sample timeout stops washing after exit. Wetness dries over
20 simulated seconds. Pausing freezes both processes.

Wetness interpolates the private clone's original clearcoat factors toward a
smooth coat in ten steps, and lowers soil roughness. Drying and detach restore
exact original clearcoat strings. No source/shared material is written. Other
Paint Designs remain rejected; legacy vehicles do not gain this compositor.
Editor activation detaches the clone and discards cosmetic state before resuming.

## Installed engine APIs and rejected experiment

Inspected BeamNG's installed `lua/ge/extensions/editor/api/dynamicDecals.lua`:
`setup` constructs `DecalProjection`, obtains its texture set, binds a named set,
and supplies shape/world/local transforms. `setMaterialIdx` and `clearMaterialIdx`
select exact mesh material indices. `bakeLayers`, `clearBakedTextures`,
`flushDynamicTextures`, and `combineTextures` drive the two separate targets.
Stock wheels/fire/thermals use `obj:inWater(cid)`.

The initial test used `setPosRot` to move the dirty car into the pool. Installed
`lua/ge/spawn.lua` and live state showed this repairs/resets the vehicle. That
clean result was rejected as washing evidence. The accepted controlled test
moves Gridmap's real `WaterBlock_1` around the same parked dirty car and restores
its original position in `finally`. It injects no collision or water events.
This tests actual engine immersion, not an unassisted drive through the pool.
Deep water can flood the engine; that stock damage is not repaired by the probe.

## Reproduce

```powershell
python tools/dev.py deploy
python tools/soil_probe.py mud --x -313 --seconds 8 --output docs/evidence/milestone3/mud-final
python tools/water_probe.py --output docs/evidence/milestone3/mud-final --redirty-x -313
# Dirt strip, same water experiment:
python tools/soil_probe.py dirt --x -350 --seconds 7 --output docs/evidence/milestone3/dirt-final
python tools/water_probe.py --output docs/evidence/milestone3/dirt-final --redirty-x -350
# Load Automation Test Track and select empty Paint Design first:
python tools/soil_probe.py snow --x -500 --y 900 --z 270 --seconds 5 --output docs/evidence/milestone3/snow-final
python tools/water_probe.py --output docs/evidence/milestone3/snow-final
```

The probes pause for unretouched engine screenshots; final re-dirtying uses the
stock cluster velocity API for assisted rolling, not injected soil events.
The JSON records material comparisons, config, paints, positions and CPU timers.

## Evidence and acceptance status

BeamNG **0.40.5.0 x64 build 302427, D3D12, NVIDIA RTX 3090, Windows 11**.
[Engine startup record](../docs/evidence/milestone3/build-renderer.txt).
ETK 800 `vehicles/etk800/rennspecht_8r_A.pc`, Police on Gridmap v2 for mud/dirt,
empty Paint Design on Automation Test Track for snow. 3840x2160 Custom, Ultra
lighting, High shaders, Normal textures, SMAA, dynamic reflections on. Captures
are unretouched 1920x1080 engine output. Each raw JSON records all three paints,
config, map and graphics settings. These are cosmetic water tests, not fluid simulation.

| Final run | Before | Dirty | Wet/partial | Washed/wet | Dry | New soil | Raw |
| --- | --- | --- | --- | --- | --- | --- | --- |
| mud | [before](../docs/evidence/milestone3/mud-final/mud-clean.png) | [dirty](../docs/evidence/milestone3/mud-final/dirty.png) | [partial](../docs/evidence/milestone3/mud-final/wet-partial.png) | [washed](../docs/evidence/milestone3/mud-final/washed-wet.png) | [dry](../docs/evidence/milestone3/mud-final/dry.png) | [re-dirty](../docs/evidence/milestone3/mud-final/redirty.png) | [JSON](../docs/evidence/milestone3/mud-final/water.json) |
| dirt | [before](../docs/evidence/milestone3/dirt-final/dirt-clean.png) | [dirty](../docs/evidence/milestone3/dirt-final/dirty.png) | [partial](../docs/evidence/milestone3/dirt-final/wet-partial.png) | [washed](../docs/evidence/milestone3/dirt-final/washed-wet.png) | [dry](../docs/evidence/milestone3/dirt-final/dry.png) | [re-dirty](../docs/evidence/milestone3/dirt-final/redirty.png) | [JSON](../docs/evidence/milestone3/dirt-final/water.json) |
| snow | [before](../docs/evidence/milestone3/snow-final/snow-clean.png) | [dirty](../docs/evidence/milestone3/snow-final/dirty.png) | [partial](../docs/evidence/milestone3/snow-final/wet-partial.png) | [washed](../docs/evidence/milestone3/snow-final/washed-wet.png) | [dry](../docs/evidence/milestone3/snow-final/dry.png) | [re-dirty](../docs/evidence/milestone3/snow-final/redirty.png) | [JSON](../docs/evidence/milestone3/snow-final/water.json) |

Each run includes shallow and deep-progress captures in its evidence directory.
The final mud pair shows the same scratches remaining over Police after cleaning;
the final snow pair shows its coating removed and the lower-panel scrape retained.
Wet body reflections become sharper, then return on drying. No pixel-identity
claim is made: the engine's lighting and vehicle settling continue between captures.
Dry material comparisons have zero original-stage field differences.

Final mud starts with 36 deposits and re-dirties to 26; final snow starts with 33
and re-dirties to 25. Final dirt starts with 34 and re-dirties to 26. Wheel-height water leaves soil unchanged. Partial immersion
samples 0.75 and fades more slowly than deep immersion at 1. All three material
kinds share the removable target, never the baked damage target. Pause snapshots
retain identical exposure/soil state. Stationary dry deposit counts stay fixed.

The snow test uses an explicitly temporary, nonsaved engine WaterBlock at the
hill because that map has no WaterBlock_1. The fixture is removed afterward.
Mud/dirt move and restore Gridmap's existing volume. The helper never fabricates
`inWater` or collision responses. Re-dirtying is assisted rolling; the mud/dirt
return to their strips uses `setClusterPosRelRot`, which preserves cosmetic and
physical damage, unlike the rejected `setPosRot` test.

## Regressions found and corrected

- The first custom-target solid-color [probe](../docs/evidence/milestone3/alias-probe.png)
  proved named texture bindings before implementing the compositor.
- Calling native `setMaterialIdx` before `setShape` crashed the engine. The
  [trace](../docs/evidence/milestone3/rejected-index-order-crash.txt) records that
  rejected ordering. Setup now binds the shape first; the harness asserts this
  ordering. Fresh launch, reloads and switches pass after correction.
- A [rejected snow wash](../docs/evidence/milestone3/snow/washed-wet.png) left the
  last brush preview visible despite zero soil counters. Capturing soil through
  the main camera had left transient working pixels in the damage projection.
  Flushing **working** dynamic textures after capture removes that preview without
  touching baked damage. All three `*-final` runs use this correction.
- Earlier wall-clock drying snapshots could precede completion when simulation
  ran slowly. The helper now waits for simulated wetness to reach zero. The
  earlier dirt re-dirty route missed the strip; the corrected nonreset test
  [recorded 27 deposits](../docs/evidence/milestone3/dirt/redirty-confirmed.json).

## Lifecycle and resource bounds

[Live lifecycle record](../docs/evidence/milestone3/lifecycle.json): five extension
reloads ready; vehicle reload/reset ready; real editor activation skipped and
closure resumed; two same-model ETKs use distinct material names, with the inactive
clone limited to its original two stages. Three return switches passed. A separate
[nonempty editor layer test](../docs/evidence/milestone3/editor-artwork.json)
retains identical artwork through mod clear and reload. The test-created editor
layer is removed afterward. [Map return](../docs/evidence/milestone3/map-return.json)
restores the Police adapter with unchanged source fields. Lifecycle tests precede
only the final transient-preview cleanup; final driving runs use the final code.
Unsupported designs still take the original guard (the restart's Rennspecht design
was skipped before explicitly choosing empty paint); no generic livery support.

One additional 1024x512 projection/texture set is reused across vehicle switches
within an adapter instance. No per-wash allocation, retained decal history or
scratch replay. At most six queued layers total bake per frame, split across the
two targets. Four material stages total; twenty soil-opacity steps and ten wetness
steps bound one monotonic wash/dry cycle. The 96-deposit allowance resets only on
full cleaning or lifecycle reset. Partial washing retains attenuation; it does not
resurrect old deposits when fresh soil arrives.

Final mud wash/dry: 3,722 painter frames, 202.86 ms aggregate CPU, 7.68 ms peak;
final snow: 3,925 frames, 232.45 ms aggregate, 7.03 ms peak. Both issue zero
projections and bakes during the stationary wash/dry segment; material updates
are included in painter timings. Final dirt: 4,620 frames, 208.36 ms aggregate, 5.61 ms peak, also zero projections/bakes. Deposition still inherits projection/bake spikes.

Whole-process private memory across five hot reloads was 12.40, 13.20, 14.01,
13.54, 13.71 GB. After explicit Lua collection and subsequent lifecycle tests it
was 11.27 GB. These are noisy whole-game allocations, **not soil-target GPU
memory or proof of a memory leak**. Native resources and the original large
damage projection can wait for collection; rapid developer reloads are costly.
Target dimensions/reuse bound this feature's live allocation count, but long-session
GPU/memory certification remains milestone 5. No zero-cost or stable-release claim.

Preflight: **212 mocked-engine checks**, Lua syntax/global allow-list and brush
sidecars. `python tools/check_water_evidence.py` checks recorded progression,
pause, drying, original channels and re-dirtying; images were inspected separately.
The [source hashes](../docs/evidence/milestone3/source-sha256.json) identify the
shipped Lua used by final captures. No engine source or test fixtures enter the ZIP.

Within the ETK/build/renderer scope and documented whole-body approximation,
milestone 3 feature acceptance passes. This does not complete the release roadmap.
No milestone 4, stable release, generic livery support or broad performance
certification is included.
