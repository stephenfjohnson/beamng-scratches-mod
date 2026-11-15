# Fleet showcase and adapter validation

2026-11-15, BeamNG.drive 0.40.5.0 build 302427, Vulkan, Gridmap v2.
Captured with [`tools/showcase_fleet.py`](../../../../tools/showcase_fleet.py).

For each vehicle: spawn the default configuration, apply the paint (or keep the
factory livery), wait for the generic body adapter, then crash it with the bench
`sideslide` (on its side at 14 m/s). `left/damaged.jpg` and
`left/original-stages.jpg` are the same frozen frame with the appended damage
and soil stages switched on and off on every clone. `state.json` records the
source material, body keys, bench marks and the number of original-stage fields
that differ between source and clone. The number was 0 for every vehicle.

| Vehicle | Paint | Source material | Body keys | Impacts / streams / layers baked | Missed |
| --- | --- | --- | --- | --- | --- |
| Pickup | red | `pickup_main` | pickup | 14 / 84 / 35 | 0% |
| Vivace | blue | `vivace_main` | vivace | 75 / 94 / 58 | 0.8% |
| ETK I | white | `etki_main` | etki, etki_modparts | 49 / 121 / 51 | 0% |
| Covet | yellow | `covet_main` | covet | 24 / 93 / 42 | 0% |
| Sunburst | gunmetal | `sunburst2_main` | sunburst2_main | 78 / 130 / 65 | 0% |
| Moonhawk | green | `moonhawk_main` | moonhawk, moonhawk_nosecone_alt | 15 / 149 / 57 | 2.4% |
| Bluebuck | two-tone livery | `bluebuck.skin.twotone` | bluebuck | 18 / 17 / 14 | 0% |
| Scintilla | black-roof livery | `scintilla_main.skin.blackroof` | scintilla_main | 80 / 59 / 46 | 0% |
| City bus | Transit livery | `citybus.skin.transit` | citybus | 34 / 343 / 102 | 0% |
| ETK 800 | brushed-trim livery | `etk800.skin.brushedtrim` | etk800, etk800_extra | 41 / 90 / 44 | 0% |

Physics contacts differ per body, so mark counts are not comparable between
vehicles. Captures are stored as 2560x1440 q90 JPEG (shot at 3840x2160). Mud, snow and washing were not
exercised in this run.
