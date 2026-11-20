# Contact patches: realistic scrapes and the Vulkan crash hitch

2026-11-20. BeamNG.drive 0.40.6.0, RTX 3090, 3840×2160, Gridmap v2. Starts from
`66db5f8`. The first pass (down to "Results") was measured on Vulkan with the
Sunburst rally (`rally_pro_gravel`, NGRC livery) only. The second pass adds
smaller brushes, ten more vehicles, D3D12 and the mud fling.

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

These are first-pass numbers with 1024×512 brushes; the second pass below
brings the worst painter frame to 5–8 ms.

The eight runs after the change have 26 frames above 25 ms. Eleven of them
(25–28 ms, three or four per sideslide, one per rollover) contain a single
10–16 ms bake; see the next section. The other fifteen have under 2 ms of painter
time and are engine phases (FramePresent 21–25 ms, RenderShadows 24–26 ms) that
also occur in the idle tail of the baseline run. The 81.9 ms frame was 65 ms in
`UImsgLoop` with 0.04 ms of painter time; its cause is unknown.

Captures: [sideslide](../docs/evidence/contact-patches/after-sideslide-left.jpg),
[door close-up](../docs/evidence/contact-patches/after-sideslide-closeup.jpg),
[detail](../docs/evidence/contact-patches/after-sideslide-detail.jpg),
[rollover](../docs/evidence/contact-patches/after-rollover-left.jpg),
[roof drop](../docs/evidence/contact-patches/after-roofdrop-top.jpg).

## Brush textures: the engine keeps about two

The first explanation for those 10–16 ms bakes (a brush reloads when unused for
a few seconds) was wrong. Stamping one brush repeatedly stays fast for at least
31 s. What evicts it is using other brushes:

| Colour-only stamps, in order | Bake ms |
| --- | --- |
| scuff_a, scuff_b, scuff_a, scuff_b | 8.2, 10.0, 1.1, 1.5 |
| chip_a, scuff_a, scuff_b, chip_a | 5.2, 1.1, 1.5, 6.0 |
| chip_b, scuff_a, scuff_b, chip_a, chip_b | 4.6, 9.6, 7.6, 4.6, 4.9 |

Two brushes alternate for free; a third evicts the oldest. A tiny extra
`DecalProjection` holding the paths does not pin them (it never loads them). A
reload costs time in proportion to pixel count, on top of ~1.2 ms for a cached
bake: 1024×512 8–10 ms, 768×384 ~5 ms, 512×256 3–4 ms, 256×128 ~2 ms. The first
load of a file in a process costs about 8 ms more, whatever its size.

So, in the second pass:

- Brush files are half size: 512×256 slide fields, 256×256 chips, maps at half
  that again. A 512 px brush still matches the 1.5 mm canvas on a 0.8 m decal.
- The painter reuses the loaded brush for the next patch of the same family
  four times in five, and a due patch of that family may jump the queue by up
  to 0.35 s.
- The spawn-time warm-up stays, for the one-time first load only.

## Second pass results

Same machine and day. "Cold" restarts the game before one sideslide.

| Vulkan, Sunburst, cold | Layers | Bake total / worst | Worst painter frame | Frame p95 / worst |
| --- | ---: | ---: | ---: | ---: |
| Painting on, six runs | 46–50 | 78–101 / 4.9–7.9 ms | 5.0–8.0 ms | 13.3–16.0 / 25.2–34.5 ms |
| Painting off, six runs | 0 | 0 | 0.1–0.2 ms | 13.3–15.0 / 20.4–41.1 ms |

| D3D12, Sunburst | Layers | Bake total / worst | Worst painter frame | Frame p95 / worst |
| --- | ---: | ---: | ---: | ---: |
| Sideslide, cold, three runs | 46–58 | 314–426 / 10.0–14.9 ms | 10.0–15.1 ms | 14.4–18.2 / 25.6, 35.4, 318.6 ms |
| Rollover / roof drop / sideslide, warm | 60 / 18 / 46 | 377 / 117 / 323 ms | 9.2 / 8.9 / 11.5 ms | 16.6, 14.9, 15.6 / 23.1, 26.0, 22.7 ms |

A D3D12 bake costs about 7 ms against about 2 ms on Vulkan.

Fleet, one sideslide each (`tools/showcase_fleet.py --out ...`). Every clone
kept its original stages (0 differing fields). Columns: slide / impact patches,
layers, worst painter frame, frame p95 / worst.

| Vehicle | Paint | Vulkan | D3D12 |
| --- | --- | --- | --- |
| ETK 800 | black (brushed-trim skin) | 16 / 21, 42, 6.3 ms, 15.5 / 32.1 ms | 16 / 20, 41, **309.3 ms**, 16.7 / 322.0 ms |
| ETK 800 | white (brushed-trim skin) | 16 / 22, 45, 6.2 ms, 16.4 / 27.4 ms | |
| Pickup | red | 18 / 3, 31, 6.6 ms, 17.1 / 27.6 ms | 21 / 2, 34, 10.4 ms, 16.9 / 22.4 ms |
| Vivace | blue | 24 / 30, 55, 6.9 ms, 18.6 / 29.3 ms | 26 / 35, 62, 13.4 ms, 19.7 / 52.1 ms |
| ETK I | white, plain | 13 / 13, 35, 7.5 ms, 14.3 / 17.6 ms | 12 / 14, 36, 9.8 ms, 16.3 / 20.7 ms |
| Covet | yellow, plain | 13 / 10, 39, 6.6 ms, 15.2 / 26.5 ms | |
| Moonhawk | green | 30 / 8, 48, 6.6 ms, 15.9 / 27.0 ms | |
| Bluebuck | two-tone livery | 10 / 14, 24, 5.5 ms, 15.0 / 24.3 ms | 9 / 14, 23, 10.9 ms, 15.4 / 23.8 ms |
| Scintilla | black-roof livery | 21 / 33, 64, **30.8 ms**, 14.6 / 41.7 ms | |
| City bus | Transit livery | 120 / 24, 100, 6.1 ms, 15.1 / 27.6 ms | 114 / 30, 96, 13.3 ms, 18.4 / 24.8 ms |

The Covet, ETK I and Scintilla rows are their second Vulkan run, after two
fixes the first run exposed: plain light paint showed exposed material at 0.30
grey, which read as black, and is now 0.46; and every glancing chip used one of
two brushes, now six. Images: [Vulkan](../docs/evidence/contact-patches/fleet-vulkan),
[D3D12](../docs/evidence/contact-patches/fleet-d3d12).

## Rare long frames

Long frames with under 1 ms of painter time, in every run of the second pass:

| Run | Frame | Where |
| --- | ---: | --- |
| Vulkan, Sunburst, cold, first crash | 562 ms | OtherRender 549; one frame after a 1.2 ms bake |
| Vulkan, Covet, first fleet run | 91 ms | OtherRender 81; one frame after a bake |
| Vulkan, Scintilla, first fleet run | 638 ms | UIpixelsToGPU 625; 0.8 s after the last bake |
| D3D12, Sunburst, cold, first crash | 319 ms | game Lua 295 |

D3D12 had thirteen painted runs in all.

That is three in 22 painted Vulkan runs (seven cold first crashes, two warm,
thirteen fleet runs) and none in six painting-off cold runs. With a rate near one
in ten, six clean controls are expected about half the time by chance, so this
does not show the mod causes them; it matches the render-phase pauses
[investigation 12](12-synthetic-anchors.md) tied to per-layer allocation churn,
and does not prove that either. The mod's ingest path, the only mod code that
runs in game Lua outside the timed update, measured 0.32 ms at most over 88
calls in a D3D12 sideslide, so the 319 ms Lua frame was not spent there.

Inside the painter, two bakes were far above the rest: 30.8 ms on Vulkan
(Scintilla, second run) and 309.3 ms on D3D12 (ETK 800, first bake after spawn).
The second is the D3D12 bake stall [investigation 12](12-synthetic-anchors.md)
describes; the first is unexplained.

## Mud and dirt fling

Wheel deposits were horizontal splash decals 1.8–2.8 m long. They are now fans
thrown from the rear of the tyre: the brush has its source 7 % in from the left
edge and the throw along +x (`tools/generate_fling.py`), and each deposit takes
the next of six throw angles (70, 35, 52, 84, 24, 60 degrees above horizontal,
less 1.1 degrees per m/s, at least 16). Length is 0.6 m plus 5 cm per m/s, at
most 1.45 m, width half that. The soil target is 2048×1024 so drops a few
millimetres wide survive.

Driven through the Gridmap mud strip in an ETK 800 at about 25 km/h: 36 deposits
on Vulkan (78 ms of bake, worst 13.3 ms) and 37 on D3D12 (85 ms, worst 6.9 ms).
[Vulkan](../docs/evidence/contact-patches/mud-fling/after-left.jpg),
[detail](../docs/evidence/contact-patches/mud-fling/after-left-detail.jpg),
[D3D12](../docs/evidence/contact-patches/mud-fling-d3d12/after-left.jpg).
Reversing and dirt are covered by the mock checks only.

## Not established

- What causes the rare long frames, and whether fewer or smaller layers
  change their rate. Six controls are too few.
- The 30.8 ms Vulkan bake.
- Snow and dirt were not driven after these changes (the wash cycle was: 37
  deposits washed to 0 and 26 collected again, on D3D12,
  [record](../docs/evidence/contact-patches/wash/water.json)). The mock harness
  (398 checks) covers the adapter fields, patch logic and fling geometry, not
  rendering.
- Soft brush edges get a faint metallic fringe, because the metallic canvas
  clears to 1 and decals blend toward their value by alpha.
- The `setContactPatches(false)` pipeline now shares the changed damage stage
  and was not re-captured in game.
