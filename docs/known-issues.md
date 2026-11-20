# Known issues, supported vehicles and compatibility

[Docs index](README.md) · [Back to the project front page](../README.md)

## Known issues

The full, prioritized list is in **[TODO.md](../TODO.md)**. The ones most likely to
affect you:

- **D3D12 bake stalls.** Each baked layer makes the engine allocate and free
  ~112 MiB of full-resolution transient textures; on D3D12 this occasionally
  surfaces as a ~450 ms hitch. Lua cannot pool it. Prefer Vulkan: **Options →
  Graphics → Vulkan**, or launch with `-gfx vk`.
- **Older D3D12 shader failure (0.39.4).** On the 0.39.4 development install the
  game's own dynamic-decal shader failed to compile under D3D12 and every decal
  draw was dropped (`draw skipped (pipelineBindFailed=1 ... dynamicDecals/decal...)`
  in `beamng.log`). Recorded for that install, not observed on 0.40.5.0.
- **Slightly slower spawns.** Each supported vehicle gets private materials, so
  the mod clears the JBeam cache before it spawns: about +180 ms per spawn,
  traffic included.
- **Rare half-second pauses.** About one painted crash in ten had a single long
  frame (0.3–0.6 s) with no painter time in it, on either renderer. Painting-off
  controls had none, in far fewer runs. Not explained yet.
- **Contact patches are new.** Checked on ten vehicles on Vulkan and six on
  D3D12 with the sideslide only. The wash cycle was re-run on D3D12; snow and
  dirt have not been driven since the damage stage and soil resolution changed.
- **No dark marks on dark paint.** Damage opacity follows the canvas red channel,
  so exposed material is always a grey lighter than black paint.
- **First mud contact hitch.** The first terrain-texture read for soil tint takes
  about 99 ms; later lookups are cached (~0.03 ms).
- **Marks don't persist.** Reset, vehicle switch, reload and editor use clear all
  cosmetic damage and soil.

## Supported vehicles & limitations

- **Requires the Dynamic Decals system** and a vehicle that ships a
  `<jbeam>_skin_dynamicTextures` part. Vehicles without it are unsupported and
  the mod cleanly does nothing (the debug panel reports `NOT READY`).
- **Material-preserving adapter on every supported vehicle:** any paint colour
  or factory livery keeps its original materials beneath damage and soil. Your
  own Dynamic Textures design and other mods' body overrides are skipped. See
  the [adapter survey](evidence/adapter-survey/survey.json).
- **Editor ownership:** the adapter pauses and clears cosmetic marks during
  editor use, then resumes. Concurrent editor use on the legacy non-ETK path
  remains unsupported; unload the painter before editing there.
- **Cosmetic only.** The mod paints texture damage from contact events; it does
  not add or replace soft-body deformation.
- **Glass and selected mechanical/internal parts are filtered out** so stray
  projection rays don't mark unrelated panels.

## Compatibility at a glance

| Setup | Result |
| --- | --- |
| 38 stock cars, trucks and buses with Dynamic Textures, any paint colour | Material-preserving adapter: scratches over the real paint ([survey](evidence/adapter-survey/survey.json)) |
| The same vehicles with a factory livery | Livery cloned and preserved under the damage |
| Mud, snow, washing, wet gloss | Same stages on every vehicle; mud driven live on the ETK 800 and a Covet, snow and washing on the ETK 800 |
| Your own Dynamic Textures editor design, another mod's body override, non-PBR materials | Detected and skipped; paint untouched |
| Percheron and vehicles without Dynamic Textures | Mod stays idle (`NOT READY`) |
| Vulkan | **Recommended.** Meets the native-call and latency targets in measured runs |
| D3D12 | Works; intermittent ~450 ms bake stalls remain (engine-side, [open](../TODO.md#release-blockers)) |

Tested on BeamNG.drive 0.40.5.0 build 302427, Windows 11, RTX 3090 / Ryzen 9
3900XT. Other builds and hardware are untested. Exact configurations are in the
[compatibility matrix](compatibility.md).
