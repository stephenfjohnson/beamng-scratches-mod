# Contact patches: realistic scrapes and the Vulkan crash hitch

2026-11-20. BeamNG.drive 0.40.6.0, Vulkan, RTX 3090, 3840×2160, Gridmap v2,
Sunburst rally (`rally_pro_gravel`, NGRC livery, generic body adapter). Starts
from `66db5f8`. Everything below was measured on that one car and renderer.

## What hitched

`tools/bench.py run sideslide` in a fresh process, before any change:

| Frame (t) | Frame ms | Where the time was |
| --- | ---: | --- |
| 0.25 s | 44.6 | painter 31.7 ms: a 2-layer bake |
| 0.47 s | 92.2 | painter 81.7 ms: a 6-layer bake |
| 0.51 s | 58.3 | painter 47.7 ms: a 6-layer bake |
| 1.16 s | 631.3 | GE Lua 456 ms + RenderMisc 87 + UIimgui 75; painter 4.5 ms |

Two separate causes:

1. **First use of a brush texture costs ~15 ms inside the native bake.** Six
   single-layer bakes with brushes not yet used in the session took 90.5 ms;
   the same six again took 9.3 ms. The first crash after launch paid that for
   all twelve brushes in its first half second.
2. **Too many layers.** That one slide baked 301 layers in 57 batches (623 ms of
   bake). A warm single-layer bake is ~1.9 ms on the main thread, a 6-layer batch
   ~6.5 ms, and every layer is a full-canvas pass that allocates ~112 MiB of
   transients ([investigation 12](12-synthetic-anchors.md)). About 50 layers had
   been baked in the second before the 631 ms frame. That frame was outside the
   painter's own update, like the render-phase pauses investigation 12 tied to
   allocation churn; this run does not prove the mechanism.

Halving the canvas does not help the main-thread cost: 1.1 ms per layer at
2048×1024 against 1.45 ms at 4096×2048.

The 301 layers were also nearly invisible on this car
([before](../docs/evidence/contact-patches/before-sideslide-left.jpg)). Stream
bands passed half-sizes to `setDecalScale`, which takes full extents, so each
band was drawn 12–27 cm long and 3–5 cm wide.

## What changed

- **`patches.lua`.** Slide reports join an oriented box on one panel (same
  facing, same slide axis, within 34 cm along and 15 cm across, at most
  95 × 30 cm). Impacts within 17 cm join a disc. A patch is baked as one decal
  spanning its extent. It is repainted only when it has been worn a tier deeper
  (1.2 m and 6 m of summed slide distance; impact energy 0.7 and 2.2) or has
  grown 14 cm along / 7 cm across past what was painted, at most five times
  (three for impacts). The aggregator hands out one decal per 70 ms and the
  painter asks only when nothing is queued, so one bake is in flight at a time.
- **Warm-up.** After setup settles, each of the 16 brush sets is baked once as a
  2 cm, alpha 0.004 stamp at the centre of the cabin, one every third frame
  (388 ms in total, right after spawn).
- **Brushes** (`tools/generate_wear.py`): slide fields with a wandering pressure
  band, combed row ends and stray hairlines; chip clusters from thresholded
  noise with a lifted clear-coat rim. Brushes are full red so the canvas red
  channel is exactly the coverage. Tier 2 and 3 carry metallic and roughness maps.
- **Damage stage**: `metallicMap`/`roughnessMap` bound to the decal canvases,
  opacity factor 1 instead of 1.6 (the layer blend is an unclamped lerp, so 1.6
  overshot), a static abrasion normal and a static opacity break-up map at
  detail scale 26. The soil stage drops those maps again; its live fields were
  read back and match the previous build.
- **Detector**: impacts carry the slip velocity.

## Results

Worst values per run; [all numbers](../docs/evidence/contact-patches/summary.json).

| Run | Layers | Bake total / worst | Worst painter frame | Frames >25 / >50 ms | Frame p95 / p99 / worst |
| --- | ---: | ---: | ---: | ---: | ---: |
| Sideslide, before, cold | 301 | 623 / 81.6 ms | 81.7 ms | 23 / 5 | 22.5 / 35.8 / 631.3 ms |
| Rollover, before | 136 | 244 / 30.1 ms | 30.2 ms | 5 / 0 | 20.8 / 26.3 / 41.9 ms |
| Sideslide, after, cold | 47 | 190 / 15.9 ms | 16.0 ms | 6 / 0 | 15.6 / 22.2 / 31.1 ms |
| Rollover, after | 86 | 178 / 12.0 ms | 12.1 ms | 3 / 0 | 17.1 / 20.4 / 37.7 ms |
| Roof drop, after | 20 | 76 / 10.5 ms | 10.6 ms | 2 / 0 | 16.8 / 21.2 / 35.5 ms |
| Nose dive, after | 10 | 52 / 10.9 ms | 11.0 ms | 0 / 0 | 16.1 / 18.8 / 21.0 ms |
| Sideslide, after, warm | 50 | 201 / 15.9 ms | 16.0 ms | 6 / 1 | 15.7 / 23.6 / 81.9 ms |
| Rollover, after, warm | 70 | 154 / 15.4 ms | 15.5 ms | 2 / 0 | 17.1 / 21.2 / 25.7 ms |
| Roof drop, after, second cold process | 23 | 32 / 2.0 ms | 2.1 ms | 3 / 0 | 18.1 / 24.6 / 27.5 ms |
| Sideslide, after, second cold process | 53 | 182 / 15.5 ms | 15.6 ms | 4 / 0 | 14.9 / 19.3 / 30.2 ms |

The eight runs after the change have 26 frames above 25 ms. Eleven of them
(25–28 ms, three or four per sideslide, one per rollover) contain a single
10–16 ms bake; see the next section. The other fifteen have under 2 ms of painter
time and are engine phases (FramePresent 21–25 ms, RenderShadows 24–26 ms) that
also occur in the idle tail of the baseline run. The 81.9 ms frame was 65 ms in
`UImsgLoop` with 0.04 ms of painter time; its cause is unknown.

## The warm-up does not hold

The remaining 10–16 ms bakes are texture loads again. On a parked car, after the
warm-up and several crashes in the same process:

| Three stamps in one bake | Bake ms |
| --- | ---: |
| `w2_gouge_a` with its maps, 10 cm | 40.7 |
| the same brush again, 100 × 30 cm | 3.6 |
| `w2_scuff_a`, 100 × 30 cm | 11.4 |
| `w2_gouge_b` with its maps, mirrored | 14.1 |
| `w2_gouge_c` with its maps | 14.2 |

Decal size, mirroring and depth make no difference; a brush that was not used in
the last few seconds pays the load again, so the engine does not keep these
textures resident between uses. The spawn-time warm-up therefore buys little:
its benefit over one-layer-at-a-time baking was not demonstrated, and it costs
388 ms after spawn. The improvement measured above comes from baking six times
fewer layers, one per frame. Keeping the textures resident (a held texture
handle, or fewer and smaller brush files) is the next step.

Captures: [sideslide](../docs/evidence/contact-patches/after-sideslide-left.jpg),
[door close-up](../docs/evidence/contact-patches/after-sideslide-closeup.jpg),
[detail](../docs/evidence/contact-patches/after-sideslide-detail.jpg),
[rollover](../docs/evidence/contact-patches/after-rollover-left.jpg),
[roof drop](../docs/evidence/contact-patches/after-roofdrop-top.jpg).

## Not established

- No painting-disabled control was run today, so the before/after comparison is
  the only attribution for the 631 ms frame. Eight clean runs don't rule out a
  rare pause.
- Whether the warm-up should stay, and how to keep brush textures resident.
- Plain paints, the ETK, other vehicles, D3D12, and mud/snow/washing were not
  driven with this build. The mock harness (394 checks) covers the adapter
  fields and the patch logic, not rendering.
- Soft brush edges get a faint metallic fringe, because the metallic canvas
  clears to 1 and decals blend toward their value by alpha.
- The `setContactPatches(false)` pipeline now shares the changed damage stage
  and was not re-captured in game.
