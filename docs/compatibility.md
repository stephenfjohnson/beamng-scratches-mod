# Compatibility

**Development branch; milestone 5 acceptance failed, stable release blocked.**
The table records actual tests, not a promise of all configurations or hardware.
[Resumed quality/throughput implementation and current evidence](../investigations/11-quality-throughput.md).
The historical matrix below remains separate from the resumed-build checks.

Exact installed engine: **BeamNG.drive 0.40.5.0 x64 build 302427**, Windows 11,
RTX 3090 / Ryzen 9 3900XT. Settings: 3840x2160 Custom, Ultra lighting, High shader,
Normal texture, SMAA, dynamic reflections enabled except the named diagnostic.
Process-cold tests retain shader caches. No other build, GPU or OS is certified.

## Resumed construction-hook build

Vulkan full-detail checks use 4096x2048 damage, bake3, flush0.05, grouping enabled
and representative coalescing disabled. The final D3D12 regression is recorded
separately when complete; the historical D3D12 rows are not promoted automatically.

| Exact configuration / boundary | Resumed Vulkan result |
| --- | --- |
| `rennspecht_8r_A.pc` + `etk800_skin_police` | Nine fresh-process, nine warm and 39 endurance fixtures; visible side/roof marks and unchanged original fields. Native 508 ms and completed-layer age 1012 ms fail performance gates. |
| Stock `844_150_A.pc` plain / `844_police_A.pc` Police | One real sideslide each, matched damaged/original/reset captures; original material fields unchanged. No config-specific endurance claim. |
| Stock `854_police_A.pc` Polizei, ETK Heritage, stock unicycle | Skipped; ETK Police return ready. |
| Installed Scintilla GT3 `gt3_balanced.pc` / `scintilla_skin_exblue` | Skipped; prior mod activation restored. No Scintilla support claim. |
| Two identical background ETKs plus selected player | Distinct private clones; only selected player's damage/soil stages active. |
| Three moving `simple_traffic` NPCs | Zero NPC detector calls/impacts/streams during the player scrape. |
| Lifecycle | 20 switches, 10 vehicle reloads, five extension reloads, four Automation/Gridmap transitions; ready and original fields retained. Experimental controls reapplied after extension/map changes. |
| Dynamic Decals editor | Sentinel artwork retained across clear/reload. |
| Actual mud/water/drying | Guarded retry preserved one cosmetic generation through asphalt damage, mud, washing, drying and fresh mud; original scuffs visibly persisted. Initial transfer-reset trial is retained as invalid persistence evidence. |

[Functional snapshots and checks](evidence/milestone5/resumed-full-vk-func),
[stock captures](evidence/milestone5/resumed-full-vk-func-stock),
[guarded washing captures](evidence/milestone5/resumed-full-vk-wash-safe),
[final-build performance cohorts](evidence/milestone5/resumed-summary.md).

Ten clean-process spawn/delete cycles returned to one live private material after
each deletion. Cleanup requires explicit ownership and no live owner or mesh
reference. ETK construction invalidates the entire JBeam bundle cache, which can
increase spawn/reload work. These are scoped object-lifetime observations, not
a proof that all engine/GPU allocations are leak-free over multi-hour sessions.

## Historical full-resolution cohort

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

The ETK adapter preserves original PBR stages in per-vehicle clones. Default damage
is 4096x2048; explicit 2048x1024 and 1024x512 experimental damage targets are available.
Separate soil stays 1024x512; original maps are never resized. Washing removes soil while scratches
remain; partial washing attenuates the whole soil cycle. This is not a spatial
waterline/spray simulation. Drying restores original fields. Reset, switching,
reload and editor suspension discard cosmetics. Extra body materials and unusual
or severely deformed geometry remain outside the verified scope.

Milestone 4's fixed damage roughness (0.65), muted diffuse and depth-colored
brushes remain; there is no per-mark physical metal/paint-layer simulation.
[Visual limitations](../investigations/09-scratch-impact-polish.md).

The historical full-resolution cohort reproduced 738 ms projection and 663 ms bake
batches. Its sustained velocity fixture was later found to erase internal node
motion and sometimes reset/delete the vehicle; its throughput figures are not
comparable to the corrected v2 fixture. Native stall timings remain actual observations.

In the corrected untraced grouped half-resolution warm cohort, every tracked discrete
request completed, with no queue-cap drops or missing footprint-proxy cells. Native
stalls still reached 613 ms projection and 402 ms bake. Reduced resolution trades fine
mark detail for lower typical bake cost; it does not establish a stall-free renderer.
[Separate cohort results, settings and acceptance limits](evidence/milestone5/resumed-summary.md).
Ten minutes of sampled process memory does not certify multi-hour native/GPU resource
behavior. Neither renderer is a stable performance recommendation; no all-hardware FPS
guarantee or public release is made.
