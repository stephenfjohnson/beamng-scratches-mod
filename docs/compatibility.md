# Compatibility

**Development branch; milestone 5 acceptance failed, stable release blocked.**
The table records actual tests, not a promise of all configurations or hardware.
[Performance failures, criteria and raw evidence](../investigations/10-performance-compatibility.md).

Exact installed engine: **BeamNG.drive 0.40.5.0 x64 build 302427**, Windows 11,
RTX 3090 / Ryzen 9 3900XT. Settings: 3840x2160 Custom, Ultra lighting, High shader,
Normal texture, SMAA, dynamic reflections enabled except the named diagnostic.
Process-cold tests retain shader caches. No other build, GPU or OS is certified.

| Exact configuration / fixture | D3D12 evidence | Vulkan evidence | Boundary |
| --- | --- | --- | --- |
| ETK `rennspecht_8r_A.pc`, empty Paint Design | Matched damaged/original/reset captures; original fields identical | Same matched visual/material check | Main body only; light-paint scuffs can be weak |
| ETK `rennspecht_8r_A.pc` + `etk800_skin_police` | Repeated warm/cold slides/roof impacts, sustained/endurance, lifecycle, real mud/water/scratch regression | Three process-cold sets, sustained scraping, matched captures, real mud/water/scratch regression | Police livery on Rennspecht, not the full stock Police config; performance blocked |
| Stock ETK `844_150_A.pc`, empty Paint Design | Actual sideslide, matched captures, unchanged originals, empty final queue | Not tested as this exact config | Narrow functional check, one slide; no config-specific endurance certification |
| Stock ETK `844_police_A.pc`, `etk800_skin_police` | Actual sideslide, matched captures, Police lettering preserved, empty final queue | Not tested as this exact config | Narrow functional check, one slide |
| Stock ETK `854_police_A.pc`, `etk800_skin_polizei` | Skipped; design retained | Not tested | Unsupported German Polizei design is distinct from supported Police |
| ETK Heritage design | Skipped; return to Police ready | Not separately tested | No generic livery support |
| Stock unicycle | Skipped; ETK return ready | Not tested | No unusual-vehicle placement certification |
| Installed Scintilla GT3 `vehicles/scintilla/gt3_balanced.pc`, `scintilla_skin_exblue` | Loaded, skipped without replacing design; previous disabled mod state restored | Not tested | Safe skip only; archive SHA256 retained, no GT3/plain Scintilla support claim |
| Three moving stock `simple_traffic` NPCs | Zero NPC detector impacts/streams; player 83 projections | Not tested | Player-only functional check, not heavy-traffic FPS certification |
| Gridmap v2 / Automation Test Track transitions | Reset/switch/vehicle reload and five extension reload checks | Four actual alternating map transitions, ready/original fields retained | No certification of arbitrary maps |
| Dynamic Decals editor with an existing test layer | Sentinel layer UID retained across mod clear/reload, then fixture removed | Not separately repeated | Mod suspends/discards its cosmetics for editor isolation |
| Other stock/mod vehicles, parts and liveries | Not certified | Not certified | Legacy plain-vehicle path exists; availability is not fidelity/support evidence |

[Stock configs and captures](evidence/milestone5/stock-configs),
[GT3 archive identity and restoration](evidence/milestone5/mod-config),
[plain/Police render captures](evidence/milestone5/visual),
[lifecycle](evidence/milestone5/candidate-lifecycle),
[unsupported/reload checks](evidence/milestone5/candidate-matrix),
[traffic](evidence/milestone5/candidate-traffic),
[map changes](evidence/milestone5/candidate-vulkan-maps),
[editor isolation](evidence/milestone5/editor.json).

Actual D3D12 mud/dirt/snow deposits were verified in
[milestone 2](../investigations/07-progressive-deposits.md), with water behavior in
[milestone 3](../investigations/08-water-washing.md). Milestone 5 repeats mud/water
on [D3D12](evidence/milestone5/wash) and [Vulkan](evidence/milestone5/vulkan-wash).
Vulkan dirt/snow washing has not been separately certified. Water tests temporarily
reposition a real Gridmap WaterBlock and restore it; they are controlled physics
fixtures, not an unassisted stock-pool driving demonstration.

The ETK adapter preserves original PBR stages in per-vehicle clones, with full
4096x2048 damage and separate 1024x512 soil. Washing removes soil while scratches
remain; partial washing attenuates the whole soil cycle. This is not a spatial
waterline/spray simulation. Drying restores original fields. Reset, switching,
reload and editor suspension discard cosmetics. Extra body materials and unusual
or severely deformed geometry remain outside the verified scope.

Milestone 4's fixed damage roughness (0.65), muted diffuse and depth-colored
brushes remain; there is no per-mark physical metal/paint-layer simulation.
[Visual limitations](../investigations/09-scratch-impact-polish.md).

D3D12 native projection still reached **738 ms**, with **663 ms bake batches** in
the longer run. Sustained input drops or delays marks. Vulkan had lower measured
bake costs in this sample, but aggregate drops and non-painter frame stalls remain.
Ten minutes of sampled process memory does not certify multi-hour native/GPU
resource behavior. Neither renderer is a stable performance recommendation;
no all-hardware FPS guarantee or public release is made.
