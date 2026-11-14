# Compatibility

Development scope, not a stable public release.

| Configuration | Verified scope |
| --- | --- |
| ETK 800 main body, empty Paint Design | Original PBR stages retained; snow buildup on plain paint in milestone 2 |
| ETK 800 main body, stock Police | Mud/dirt/snow buildup; livery and scratches coexist; reset and switching |
| BeamNG 0.40.5.0 build 302427, RTX 3090 | Milestone 1 adapter evidence uses Vulkan; milestone 2 soil evidence uses D3D12 |
| Gridmap v2 | Actual MUD and DIRT strips; stationary checks and sustained rolling cap |
| Automation Test Track | Actual SNOW hillside with occasional dirt contacts; Police and plain paint |
| Other designs / existing Dynamic Textures artwork | Safely skipped, not certified |
| Other plain vehicles | Existing legacy path; no new fidelity or soil-placement certification |
| Extra body materials, mods, other builds/renderers | Not certified |

Exact trim: `vehicles/etk800/rennspecht_8r_A.pc`, with Paint Design explicitly
changed to empty or `etk800_skin_police`. Four-wheel preference and AABB-based
placement can be unsuitable for unusual vehicles or severely deformed panels.

[Milestone 2 captures, raw configuration, original-material comparisons and
measurements](../investigations/07-progressive-deposits.md).
[Milestone 1 editor isolation and material evidence](../investigations/06-etk-material-adapter.md).

Reset/switch/reload/editor suspension discard cosmetics. Three coalesced samples
per quarter second and 96 deposit attempts bound added work, but measured
projection/bake spikes remain. There is no GPU/memory or broad FPS certification.
Milestone 3 adds a separate 1024x512 soil target and wet/dry clone clearcoat.
Water fades soil without clearing the damage target. Full washing reopens the
96-attempt allowance; partial washing attenuates the entire current soil cycle.
This is not a spatial waterline or spray simulation. Original fields return on
drying; unsupported designs remain skipped. [Water evidence and exact test
methods](../investigations/08-water-washing.md) include a controlled real water
volume, not an unassisted drive through a stock pool. D3D12 is the tested renderer.
