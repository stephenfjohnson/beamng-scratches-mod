# Performance: stays out of your frame time

[Docs index](README.md) · [Back to the project front page](../README.md)

What the mod costs per frame and how that was measured. Open performance work
is tracked in [TODO.md](../TODO.md#release-blockers); renderer notes are in
[known issues](known-issues.md).

- **Player car only.** AI traffic and parked cars return immediately; three
  moving traffic cars produced zero detector calls during a player scrape.
- **Cheap detection.** Each node's paintable/not-paintable verdict is cached, so
  the per-contact cost on the physics tick is a table lookup.
- **No native projection.** Baked layers are anchored directly at their own
  contact point and hull-resolved normal (*synthetic anchors*) instead of reading
  the anchor back from a GPU projection pass. Measured on BeamNG 0.40.5.0, RTX 3090,
  full 4096×2048 detail, every accepted mark kept:

  | Worst case per run | Before (projected) | Now (synthetic anchors) |
  | --- | ---: | ---: |
  | Vulkan, native call, 10-minute endurance | 508.5 ms | **35.4 ms** |
  | Vulkan, contact to finished mark | 1,012 ms | **318 ms** |
  | D3D12, native call | 443.8 ms | 446–447 ms ([open](../TODO.md#release-blockers)) |

- **One rich decal per contact patch.** Every baked layer costs a full-canvas
  pass in the engine, so the painter no longer bakes a decal per contact report.
  Contacts fold into patches and at most one decal is baked every 70 ms. The
  engine keeps only about two brush textures loaded and a reload costs time in
  proportion to the image size, so brushes are small (512×256) and the painter
  reuses the loaded brush for the next patch of the same kind. Measured on
  BeamNG 0.40.6.0, RTX 3090, 4K, one 14 m/s sideslide in a fresh process:

  | One sideslide | Before (Vulkan) | Now, Vulkan (6 runs) | Now, D3D12 (3 runs) |
  | --- | ---: | ---: | ---: |
  | Layers baked | 301 | 46–50 | 46–58 |
  | Bake time in total | 623 ms | 78–101 ms | 314–426 ms |
  | Worst painter frame | 81.7 ms | **5.0–8.0 ms** | 10.0–15.1 ms |
  | Frame time p95 | 22.5 ms | 13.3–16.0 ms | 14.4–18.2 ms |
  | Worst frame | 631 ms | 25–35 ms | 26–35 ms, and one 319 ms |

  Rare long frames remain and are not explained: on Vulkan one 562 ms and one
  638 ms GPU-side pause in 22 painted runs (none in six runs with painting off),
  and on D3D12 one 309 ms bake and one 319 ms game-Lua frame in thirteen runs.
  [All runs](evidence/contact-patches/summary.json) and
  [investigation 13](../investigations/13-contact-patches.md).
- **Composite only when needed.** The canvas is re-composited only on frames
  that baked or cleared, and the expensive texture-set re-bind (24–55 ms) happens
  only when the binding can actually be stale.
- **Bounded everything.** 220 patches per kind, at most five decals per slide
  patch and three per impact patch, one bake in flight, 96 soil deposits.

Details: [investigation 12](../investigations/12-synthetic-anchors.md) and the
[measured cohorts](evidence/milestone5/resumed-summary.md).
