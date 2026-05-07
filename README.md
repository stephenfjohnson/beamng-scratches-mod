# scratches_mod

Procedural scratches and scrapes for BeamNG.drive vehicle panels. Whenever a
panel scrapes the ground or hits an object, a scratch appears on the texture
at that location; deep gouges expose primer and bare metal under the paint.
Works alongside the soft-body deformation system, not as a replacement.

## Approach

UV-space damage masks painted by event-driven Lua splats, sampled by a
multi-stage `materials.json` that reveals paint → primer → bare metal as the
mask deepens. Built on BeamNG's Dynamic Decals infrastructure shipped in v0.31.

## Repo layout

```
lua/vehicle/extensions/scrapes/   # VLUA — physics-rate detection
lua/ge/extensions/scrapes/        # GELUA — render-rate painter
art/dynamicDecals/textures/       # scratch brushes, detail textures
investigations/                   # API investigations & findings
reference/                        # gitignored — read-on-demand references
```

## Development

This repo is junctioned into the BeamNG userfolder so edits hot-reload:

```
C:\Users\sforr\AppData\Local\BeamNG\BeamNG.drive\current\mods\unpacked\scratches_mod
  → C:\Users\sforr\Documents\Code\Games\beamng-scratches-mod
```

Reload steps:
- `Ctrl+L` — reload GELUA
- `Ctrl+R` — respawn vehicle (reloads VLUA)
- Full game restart — required for `materials.json` or JBeam changes

## Status

Plan-mode scaffolding. Investigations in progress; no mod code yet.
