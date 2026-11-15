# Soil detail-normal check

Added a deterministic, seamless 256x256 detail normal to soil stage 3. The
factory body normal remains in place. Scale is 8x8 on UV1, strength 0.65.
The existing dynamic soil opacity masks the detail, including its washing fade.
This uses the supported static material detail channel, not an assumed
`@ScratchesSoilNormal` output. No new decal layers, projection targets or
per-deposit work were added; the material does perform an extra texture sample.

## Live evidence

BeamNG 0.40.5.0, Vulkan, ETK800 with stock Police paint, Gridmap v2.
The existing muddy car was preserved: no reset, driving, teleport or new stamps.
A short paused comparison toggled only the soil detail-normal texture, then
repeated with soil opacity zero. Camera, pause state, background limiter and
material fields were restored afterward; the new relief remains enabled.

- [Before: flat-colored mud](before.png)
- [After: visible small lumps within the same deposits](after.png)
- [Soil hidden, normal disabled](hidden-before.png)
- [Soil hidden, normal enabled](hidden-after.png)
- [Vehicle and surface state](state.json)

The close-up shows mottled lighting relief inside the front-fender mud while
the clean paint and scratch pattern remain intact. The hidden-soil pair shows
no visible mud relief. Clouds and the pause indicator change between captures;
these are not pixel-identical frame comparisons. The zero-opacity check tests
material masking, not a new physical water/washing run.

## Reproduce

1. Run `python tools/generate_soil_normal.py` to rebuild the asset (numpy,
   scipy and Pillow, also used by the damage-art tooling).
2. Run `python tools/package.py` for preflight and the installable ZIP.
3. Install/deploy, accumulate mud on a supported ETK, then run
   `python tools/soil_relief_probe.py` for the short current-car comparison.

Preflight: 278 mock checks passed, Lua syntax/global checks and brush sidecars
passed. The generated normal is a static material map, so it intentionally
does not have a decal-brush sidecar.

## Limits

This is tiled micro-relief, not per-droplet thickness, displacement, fluid flow
or a fix for cross-panel splash placement. All three soil types share the
detail normal; only mud was visually checked here. Factory UV seams can change
the detail's phase. Wet/dry roughness still uses the existing soil behavior.
D3D12, plain paint and performance were not rerun for this small material change.
