# scratches_mod

Procedural scratches, scrape streaks, and impact chips for BeamNG.drive vehicle
panels. Vehicle-side Lua listens to real node contact events, filters them down
to paintable body contact, and game-engine Lua bakes scratch decals into
BeamNG's Dynamic Decals texture set.

The goal is visual damage that follows actual contact. If a car slides on its
roof, roof panels get the long scrape marks; side and rear panels should only
get marked when they actually touch something.

## Current Behavior

- Sliding contacts create short stretched scrape decals along the contact path.
- Impacts create larger chip/claw/splatter decals scaled by normal force.
- Long straight slide streams are chunked into many local segments so a roof
  slide builds dense damage without one giant projection bleeding over panel
  edges.
- Synthetic decal cameras are aimed from the owning vehicle hull face using the
  contact normal and spawn AABB. This keeps roof, side, front, rear, and floor
  projections localized to the panel face that is actually contacting.
- Dynamic-texture material bindings are stabilized after vehicle setup so
  multi-material vehicles keep all supported paint materials writable.
- The paint canvas is seeded for metallic/roughness so the dynamic-textures skin
  keeps glossy paint behavior.

## Aggressive Damage Defaults

The current default profile is intentionally heavy for visible crash testing:

| Setting | Default |
| --- | ---: |
| Slide threshold | `0.6 m/s` |
| Impact/perpendicular threshold | `0.8 m/s` |
| Minimum normal force | `10 N` |
| Impact force threshold | `800 N` |
| Impact cooldown per node | `0.025 s` |
| Slide sample period per node | `0.003 s` |
| Stream max duration | `0.25 s` |
| Stream max points | `80` |
| Stretched scrape chunk length | `0.22 m` |
| Stretched scrape segment cap | `40` per stream |
| GE aggregate cap | `96` discrete stamps per frame |
| GE cluster radius | `0.65 m` |

Impact decals scale from about `0.28 m` to `0.63 m` based on normal force. This
is a high-density profile; use the in-game debug UI's lighter presets if frame
hitches become a problem.

## Repo Layout

```text
lua/vehicle/extensions/auto/scratches_detect.lua  # VLUA contact detection
lua/ge/extensions/scratches/paint.lua             # GELUA dynamic-decal painter
art/dynamicDecals/textures/                       # scratch brush PNGs + metadata
docs/plans/                                       # implementation notes
investigations/                                   # BeamNG API investigations
tools/                                            # brush generation utilities
```

## Development

This repo is junctioned into the BeamNG userfolder so edits hot-reload:

```text
C:\Users\sforr\AppData\Local\BeamNG\BeamNG.drive\current\mods\unpacked\scratches_mod
  -> C:\Users\sforr\Documents\Code\Games\beamng-scratches-mod
```

Reload steps:

- `Ctrl+L` reloads GELUA.
- `Ctrl+R` respawns the vehicle and reloads VLUA.
- After changing detector constants, reset/respawn the vehicle so
  `scratches_detect.lua` reloads.
- Full game restart is still safest after changing textures, material files, or
  JBeam/skin data.

## Debugging

Useful BeamNG console commands:

```lua
extensions.load("scratches_paint")
scratches_paint.toggleUI()
scratches_paint.dumpPaintStats()
scratches_paint.deepProbe()
scratches_paint.clearStamps()
```

Vehicle-side full dump from the GE console:

```lua
be:getPlayerVehicle(0):queueLuaCommand("scratches_detect.pushFullDumpToGE()")
```

The debug UI includes presets, live counters, paint-canvas controls, aggregate
cap, and cluster radius. If the UI is already open after a code reload, use
`Reset defaults` once to push the current defaults back into the vehicle-side
detector.

## Notes

- The mod relies on BeamNG's Dynamic Decals support and vehicles with a
  `dynamicTextures` skin.
- It does not replace BeamNG soft-body deformation. It paints cosmetic texture
  damage based on contact events emitted by the physics system.
- Glass and selected mechanical/internal parts are filtered out to avoid
  projection rays stamping unrelated body panels.
