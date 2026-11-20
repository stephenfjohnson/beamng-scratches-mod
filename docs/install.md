# Installing, using and uninstalling

[Docs index](README.md) · [Back to the project front page](../README.md)

The mod is two Lua extensions, three helper modules (body material adapter,
terrain soil color, coverage accounting) and brush/soil art. It targets a
recent version of BeamNG.drive that includes the **Dynamic Decals** system.
Development began on 0.38; the current build is tested on 0.40.5.0 build 302427
with both Vulkan and D3D12. Other builds are unverified.

## Players — packaged mod

1. Download `scratches_mod.zip` from the [latest release](https://github.com/stephenfjohnson/beamng-scratches-mod/releases/tag/v0.2.0-preview) and check it
   against `scratches_mod.zip.sha256` if you like (or [build it](development.md#packaging-for-release)).
2. Open the active user folder using the BeamNG launcher and place the ZIP
   in its `mods/` directory without extracting it. The default used by the
   development tools is `%LOCALAPPDATA%\BeamNG\BeamNG.drive\current\mods\`;
   custom user folders can differ.
3. Launch BeamNG; the mod manager picks it up automatically.
4. Spawn a [supported vehicle](known-issues.md#supported-vehicles--limitations) and drive.

Nothing else is required — both halves of the mod load themselves (see
[How it works](how-it-works.md)). No console commands.

## Developers — unpacked

See [the development page](development.md#developers--unpacked).

## Using the mod

Once installed, the mod is automatic: drive, crash, get dirty, wash it off.

| Action | Effect |
| --- | --- |
| Slide a panel along a surface | A band of parallel scrape lines over a scuffed haze at each contact, running the way the car slid; longer drags scrape deeper (more bare metal) |
| Hit something hard | Chipped paint, plus a gouge on harder hits, sized by impact force |
| Drive over mud, dirt or snow | Soil builds up behind the wheels and on the lower panels, tinted like the ground |
| Drive into water deep enough to reach the body | Soil fades off while scratches stay; the clearcoat looks wet, then dries in ~20 s |
| **Reset Car** (`Ctrl+R`) | Clears all scratches and soil and resets the vehicle |
| **Toggle Scratches Debug Panel** | Opens/closes the in-game debug + tuning panel |

The panel toggle is a **bindable key**. After first launch, open
**Options → Controls → Bindings**, find **"Toggle Scratches Debug Panel"** in
the **Debug** category, and assign a key. It works in any context.

## Uninstalling

To uninstall, remove `scratches_mod.zip` from the active `mods/` folder and
disable/remove any unpacked copy, then restart the game. If a saved vehicle
configuration still selects Dynamic Textures, select its desired Paint Design
again; uninstalling does not rewrite saved configurations. If you bound a key to
**Toggle Scratches Debug Panel**, the game logs a harmless
`Couldn't find action scratches_toggle_ui` until you clear that binding.
