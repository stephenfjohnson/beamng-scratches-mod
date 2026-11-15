# v0.2.0-preview install test

2026-11-15, BeamNG.drive 0.40.5.0 build 302427, Vulkan, Windows 11, RTX 3090.
ZIP built from `19a3ae3` with `python tools/package.py`: Lua syntax and global
checks, 375 harness checks and brush sidecars passed.
SHA-256 `0598407d62756f3cf21f093d5ba7c917a67246d351fb443109e9e2e763ec7368`.

1. Removed the unpacked dev mount, placed only the ZIP in `mods/` and started the
   game directly. The VFS showed the ZIP and no unpacked copy.
2. **Fresh-install default car:** the ETK 800 spawned with its default Rennspecht
   livery and the body adapter attached immediately (`etk800.skin.rennspecht`,
   body keys `etk800` + `etk800_extra`). Version 0.1.0 skipped this car.
3. **Sideslide on the ZIP-only install** (bench helper loaded temporarily from
   the user folder, outside the mod):

   | Vehicle | Source material | Impacts / streams / layers baked | Missed |
   | --- | --- | --- | --- |
   | ETK 800, Rennspecht livery | `etk800.skin.rennspecht` | 74 / 115 / 60 | 0% |
   | Covet, default paint | `covet_main` | 22 / 92 / 41 | 0% |
   | Bluebuck, two-tone livery | `bluebuck.skin.twotone` | 18 / 17 / 13 | 0% |

   Reports and left-side shots: [ETK 800](zip-sideslide-etk800/report.md),
   [Covet](zip-sideslide-covet/report.md), [Bluebuck](zip-sideslide-bluebuck/report.md).
4. **Mud on a non-ETK vehicle:** a fresh Covet driven across the Gridmap v2 mud
   strip (`tools/soil_probe.py mud --x -313 --seconds 6`) collected 9 deposits
   early and 21 late, then held at 26 once stationary. The tint was sampled from
   the local terrain (`terrain-local`). [Captures and state](mud-covet/mud.json):
   grime is visible on the lower doors and rear quarter.
5. **Uninstall:** removed the ZIP and restarted. `scratches_paint` was absent,
   no private `scratches_*` materials existed, and no mod errors were logged,
   apart from the known harmless `scratches_toggle_ui` key-binding line.

Not exercised in this test: snow, water washing and wet gloss on non-ETK
vehicles, D3D12, other builds or hardware.
