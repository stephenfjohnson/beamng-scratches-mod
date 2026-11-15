# Examples and troubleshooting

## First drive

1. Install one copy of the mod using the README instructions.
2. Spawn an ETK 800 on Gridmap v2. Choose an empty Paint Design or the stock
   Police design. The adapter preserves that selection and its main-body
   material. Initial activation may reload/repair the car once. Other liveries
   and pre-existing Dynamic Textures designs are skipped; keep saved artwork.
3. Slide the side of the car against a hard surface. Expect cosmetic scrape
   marks; the mod does not add physical deformation.
4. Reset the car with Ctrl+R. Expect all accumulated marks to clear.

The [police example](evidence/milestone1/adapter-police-sideslide.jpg) is an actual asphalt sideslide,
not a mockup. Appearance is still under development.

## Reproduce a screenshot and performance run

From the repository root, with Python and Lua 5.1 installed:

```powershell
python tools/dev.py launch
python tools/bench.py run sideslide --tag example --shot-scale 1
```

This resets and moves the current player vehicle in Gridmap v2. Save any setup
you want to keep first. The bench captures five angles and writes report.md,
result.json and frames.csv under `bench/runs/`. These artifacts are ignored by
Git; copy selected verified images into `docs/images/` for public documentation.
Use the same vehicle, renderer, build, settings and scenario for comparisons.

## Experimental terrain checks

Drive above 0.75 m/s over actual MUD, DIRT or SNOW collision terrain. Ordinary
rolling now works; stationary wheelspin does not. Mud clumps, finer dirt and
snow patches progressively overlap near the wheels and lower side panels.
Expect the stock livery to remain underneath. Reset clears all cosmetics.

Try Gridmap v2 ground-model strips for mud/dirt, and the snowy hillside of
Automation Test Track. Roadside snow artwork may sit over asphalt, rock or
vegetation: collision material, not appearance, determines deposition.

For repeatable developer runs with MCP and a supported ETK already selected:

```powershell
# Gridmap v2; these commands reposition and drive the current car
python tools/soil_probe.py mud --x -313
python tools/soil_probe.py dirt --x -350 --seconds 5
# Load Automation Test Track first
python tools/soil_probe.py snow --x -500 --y 900 --z 270 --seconds 5
```

[Early/late images and measured limits](../investigations/07-progressive-deposits.md).
There are 96 deposit attempts per reset, up to 12 per kind per local cell.
The surface packet and job queues remain bounded. A cap is not a frame-time
guarantee: projection/bake spikes are still observable.

To inspect state while the game is running with MCP:

```powershell
python tools/dev.py lua "return jsonEncode(scratches_paint.getSurfaceState())"
```

Expected keys include `mud`, `dirt`, `snow`, `wetness`, `deposits` and
`waterSupported`. `lastSample` reports the last accepted contact kind, wheel
flag and approximate local panel target; it is not a rendered-pixel measurement. `visualCleaningSupported` and `visualWetnessSupported` are
true only with the scoped ETK adapter. `waterFraction` reports sampled body
immersion; `soilRemaining` is the current soil-cycle opacity (returns to 1 for
a fresh empty cycle after full washing). These counters do not prove rendering.
See the [water examples and real captures](../investigations/08-water-washing.md).
Stay in body-deep water to wash, then leave it and wait about 20 simulated
seconds to dry. Wheel-only puddles may be missed; pausing freezes progress.

## Compatibility evidence

[Current supported matrix and limits](compatibility.md). Milestone 2 adds real
D3D12 mud/dirt/snow driving evidence for the same narrow ETK adapter.

| Configuration | Evidence / expected behavior |
| --- | --- |
| ETK 800, empty Paint Design, main body | Original PBR stages retained; clean/damaged captures on 0.40.5.0 build 302427, Vulkan |
| ETK 800, stock Police, main body | Livery + scratches verified on the same build; reset, switching, reload and editor pause/resume pass |
| ETK extra-material panels | Original appearance retained; adapter does not add damage |
| Other existing liveries; pre-existing Dynamic Textures | Skipped to preserve artwork; ETK Heritage and unowned dynamic design tested |
| Other plain vehicles | Legacy Dynamic Textures path; exact PBR fidelity unverified |
| Custom ETK body material override | Adapter rejected; conflicting-override mock check passes |
| Vehicle without dynamicTextures part | Unsupported; painter remains not ready |
| Traffic and parked vehicles | Not painted; player vehicle only |
| Mud/dirt/snow | Actual terrain deposition and water-removal captures in investigations 07/08 |
| Water | Separate soil fading and drying on scoped ETK; whole-body approximation |
| Mod vehicles / multiplayer | Not validated; no compatibility guarantee |

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| No marks, painter NOT READY | Unsupported design, editor active, or missing Dynamic Textures part; try ETK 800 empty/Police Paint Design |
| Painter ready, contacts counted, nothing visible | Check renderer/shader errors and the vanilla Dynamic Decals editor; see README known issues |
| Changes do not load | Remove duplicate ZIP/unpacked installations, restart; check active user folder |
| Terrain does not dirty the car | Collision material, slip threshold, deposit cap and approximate wheel projection |
| Water does not clean the car | Check supported ETK design, body immersion and pause; allow eight simulated seconds at full immersion |
| Stutters when scraping | Record native worst time and queue age with the experimental presets below; smaller budgets can increase backlog, and native hitches remain unresolved |

For bug reports, include game build, renderer, vehicle/configuration, map,
reproduction steps, installed version/commit and the panel's Copy debug report.
Include before/after images when reporting appearance problems.

## Milestone 1 preservation checks

Tested configuration: ETK 800 `vehicles/etk800/rennspecht_8r_A.pc` on Gridmap v2,
with empty Paint Design, then stock Police. Renderer: Vulkan, RTX 3090;
3840x2160, Custom/Ultra lighting/High shaders/Normal textures/SMAA, dynamic
reflections enabled. This does not certify other trims, mods or renderers.

1. Choose empty Paint Design; drive or run the sideslide scenario. Expect
   `ready=true`, `adapter="etk800_main"`, and scratches over the original paint.
2. Select stock Police. Expect `adapter="etk800.skin.police"`; police lettering
   stays beneath scratches. Reset/Clear stamps removes only cosmetic marks.
3. Switch between two ETKs. Only the active car gets a damage stage; returning
   starts with a clean canvas. Switch to unicycle: expect `ready=false`.
4. Select Heritage or a saved Dynamic Textures design: expect `skipped=true`.
   Reset and Clear stamps must leave it alone. Do not remove wanted artwork.
5. Reload the vehicle or painter: supported ETK reinitializes without changing
   its design. Open world/livery editor: adapter pauses; close it: it resumes.
   Cosmetic marks are discarded. Existing editor layers are not cleared.

Read-only status and material-channel comparison (running game with MCP):

```powershell
python tools/dev.py lua "return jsonEncode(scratches_paint.getCompatibility())"
python tools/livery_probe.py --output bench/livery-status.json
```

For supported ETKs, `comparison.originalStages=2`, `activeStages="4"` and an
empty `differences` object/array indicate identical original fields in the
clone (two original stages, damage, soil). That structural check accompanies screenshots; it is not a render test.

To reproduce the clean material comparison, first run a baseline at rest:

```powershell
python tools/bench.py run baseline --tag clean
python tools/etk_compare.py --output bench/etk-clean
```

This **clears cosmetic marks**, then captures the same clone with its original
two stages and with the clean third stage enabled. It leaves source materials
and Paint Design unchanged. It does not compare two separate stock vehicles;
lighting/cloud movement and HUD may differ between captures.

[Full evidence, tested approaches and limits](../investigations/06-etk-material-adapter.md).

## Scratch/impact polish (milestone 4)

With the supported ETK selected and the game/MCP running on Gridmap v2:

```powershell
python tools/dev.py deploy
python tools/damage_probe.py plain-dark --skin plain
python tools/bench.py run sideslide --tag polish-plain-dark
python tools/damage_probe.py plain-dark
# Configure light plain, or Police (add --light for light primary paints):
python tools/damage_probe.py police-light --skin police --light
python tools/bench.py run roofdrop --tag polish-police-light
python tools/damage_probe.py police-light-roof
```

The configuration command changes the current vehicle's Paint Design and all
three paints; it does not save a configuration. The bench performs real physics
and uprights the car without repairing it for photography. The capture helper
pauses simulation, holds one camera, records damage/original-two-stage/reset
images and raw material comparisons, then resumes. `original-stages` hides
cosmetics on the same deformed car; it is not an untouched stock-car comparison.
It clears cosmetics at the end. Output: `docs/evidence/milestone4/<label>/`.

See [milestone 4 evidence](../investigations/09-scratch-impact-polish.md) for exact
build/settings, the retained opacity limitation and rejected mask experiments.

For scratch-through-wash regression, keep the sideslide damage (do not run the
clearing capture helper), then use real assisted mud rolling and the left camera:

```powershell
python tools/bench.py run sideslide --tag persistence
python tools/damage_soil_fixture.py
python tools/water_probe.py --output docs/evidence/milestone4/persistence --left --redirty-x -313
python tools/check_damage_evidence.py
```

The fixture moves the current damaged car to Gridmap's mud strip without reset;
the water probe relocates/restores the real water volume. These are developer
test fixtures, not a natural stock-pool driving demonstration.


## Milestone 5 reproducible performance investigation

Use a disposable driving session: these commands reset/reposition the player car;
`--restart` restarts BeamNG. Select ETK 800 Rennspecht 8R, plain or stock Police.
Close the editor. Development helpers require Python, Lua 5.1 tools on PATH and
BeamNG MCP enabled. They are excluded from the install ZIP.

```powershell
python tools/dev.py deploy
# Three warm repeats, same real-physics launch, no screenshot timing overhead:
python tools/bench.py run sideslide roofdrop --repeat 3 --no-shots --tag enabled
python tools/bench.py run sideslide roofdrop --repeat 3 --no-shots --tag disabled --set detect.setPaintEnabled=false
# Separate fresh processes, retaining shader caches (use a new label each time):
python tools/perf_probe.py --label local-d3d12-cold --restart --rounds 3
python tools/perf_probe.py --label local-d3d12-disabled --restart --rounds 3 --disabled
python tools/perf_probe.py --label local-vulkan-cold --restart --renderer vk --rounds 3
# Diagnostic budget comparison; does not make a single native call preemptible:
python tools/perf_probe.py --label local-one-project --budget 1 --rounds 3
python tools/perf_lifecycle.py --label local-lifecycle --cycles 10
python tools/perf_report.py
```

`perf_probe` saves settings, source hashes, engine startup lines, raw frame arrays,
CSV and reports under `docs/evidence/milestone5/<label>`. Painting-disabled means
submission is disabled; the detector and adapter remain loaded. This is not a
clean uninstall baseline. `baseline` is four seconds of coasting, not scraping.
Process-cold is not shader-cache-cold. Settings and exact configuration must be
compared before interpreting results. Frame metrics include the whole game;
native CPU-call timers can include GPU waits and do not measure GPU execution.

See [acceptance gates and evidence](../investigations/10-performance-compatibility.md).


For sustained scraping and a longer latency observation window (assisted roof
motion, real physics contacts; this can damage the car):

```powershell
python tools/bench.py run sustained --repeat 3 --no-shots --tag local-stress
python tools/bench.py run sustained --repeat 3 --no-shots --drain-timeout 15 --tag local-fastflush --set paint.setFlushInterval=0.05
# Graphics-workload diagnostic; the helper restores the previous reflection setting:
python tools/perf_probe.py --label local-no-reflections --reflections-off --rounds 3
python tools/perf_traffic.py --label local-traffic
python tools/perf_matrix.py --label local-compatibility
python tools/perf_maps.py --label local-map-transitions
```

The faster interval and one-project budget are experiments, not recommended
settings. The retained results include dropped work and multi-second latency.
`bench.py` saves to ignored `bench/runs/`; archival probes copy their runs to
`docs/evidence/milestone5/`. To include a new sustained series in the static
report, archive its folders explicitly:

```powershell
New-Item -ItemType Directory docs/evidence/milestone5/local-stress
Get-ChildItem bench/runs -Directory -Filter '*_sustained_local-stress*' | Copy-Item -Destination docs/evidence/milestone5/local-stress -Recurse
# Matplotlib is required only for the offline static charts:
python -m pip install matplotlib
python tools/perf_report.py
```

Reports expose remaining queues and distinguish model-time duration from sampled
wall-clock frame intervals. `drainWallSeconds` measures the post-run drain window
in wall time in newer runs; it is not a measurement of every individual mark's
latency. A nonempty queue at timeout is a failed latency check, even if FPS or
frame p95 looks better. Native calls cannot be interrupted by a Lua budget.


The ten-minute same-instance probe resets the car between real-physics scenarios
but never reloads the painter. Use fresh labels; existing evidence is not replaced.
Run probes sequentially, with no concurrent game controller:

```powershell
python tools/dev.py restart --game-arg=-gfx --game-arg=d3d12
python tools/perf_endurance.py --label local-endurance --minutes 10
python tools/perf_unloaded.py --label local-unloaded
# These exact-fixture helpers write fixed folders; use a fresh evidence checkout:
python tools/perf_stock_configs.py
python tools/perf_mod_config.py
```

`perf_stock_configs` replaces the current car with stock 844 plain, 844 Police and
854 Polizei, captures the supported slides and restores Rennspecht/Police.
`perf_mod_config` requires the already-installed `mods/repo/scintilla_gt3.zip`;
it records its hash, temporarily activates it if disabled, loads GT3 Balanced,
records the skip, restores the ETK and the mod's prior activation state. Neither
helper saves a vehicle configuration. The unloaded control disables detection,
unloads the painter and restores both afterwards; this is not a clean uninstall.
The endurance probe records process-private memory and optional `nvidia-smi`
total-device memory; neither isolates mod GPU allocations.

For an Optick attempt, use a profiling-capable engine build:

```powershell
python tools/bench.py run sustained --no-shots --drain-timeout 15 --optick --tag local-optick
```

On the tested installed build, both this request and official MCP `profiler_run`
returned planned paths without creating a trace. Confirm an actual `capture.opt`
exists before claiming attribution. The report warns when the file is absent.

Restore diagnostic settings explicitly after standalone bench tuning:

```powershell
python tools/dev.py lua "scratches_paint.setProjectionBudget(6); scratches_paint.setFlushInterval(0.2); settings.setValue('GraphicDynReflectionEnabled',true); getPlayerVehicle(0):queueLuaCommand([[scratches_detect.setEnabled(true); scratches_detect.setPaintEnabled(true)]]); return true"
```

Default bake batches remain six layers; `getStats().config.layerBudget=24` is the
projection layer cap, not the per-frame bake count. `perf_probe --renderer vk`
selects that backend only with `--restart`; always verify its saved startup log.
The final [acceptance table](../investigations/10-performance-compatibility.md#acceptance-disposition-and-remaining-gates)
is blocked despite passing mock checks. These settings are reproducible test
conditions, not guaranteed FPS recommendations.


## Resumed quality and throughput experiments

Use this **development branch**, BeamNG 0.40.5.0 build 302427, Gridmap v2 and the
verified ETK 800 main body with empty Paint Design or `etk800_skin_police`.
These controls are experiments, not a stable preset or a renderer recommendation.
For an isolated checkout of the published milestone branch, use PowerShell:

```powershell
git clone --branch t3/milestone5-projection-stall-perf https://github.com/stephenfjohnson/beamng-scratches-mod.git beamng-scratches-m5
cd beamng-scratches-m5
```

With the game running and its local MCP server available, deploy the dev mount:

```powershell
python tools/dev.py deploy
python tools/dev.py lua 'return jsonEncode(scratches_paint.getCompatibility())'
```

When `ready` is true, the explicit **half-resolution experimental preset** is:

```powershell
python tools/dev.py lua 'scratches_paint.setDamageResolution(2048);scratches_paint.setBakeBudget(3);scratches_paint.setFlushInterval(0.05);scratches_paint.setProjectionBudget(6);scratches_paint.setLayerBudget(24);scratches_paint.setCoverageCoalescing(true);scratches_paint.setPanelGrouping(true);return jsonEncode(scratches_paint.getStats())'
```

Changing damage resolution or coalescing mode clears existing cosmetics. The
2048x1024 damage target has one quarter of the texels of 4096x2048, so small marks
can soften. It does not resize the original livery/PBR maps or 1024x512 soil.
The installed API initially constructs its default target before resizing; this
is not proof of a quarter-sized peak allocation or suitability for low-VRAM GPUs.
Allowed damage widths are 4096, 2048 and 1024. Quarter width is a tested tradeoff,
not an accepted quality recommendation. Bake budget is layers per native call,
clamped to 1–24. The scheduler cannot interrupt a slow native call.

Grouping shares cameras but retains layers. Discrete coalescing intentionally
represents contained same-family/severity footprints with an existing brush;
random brush composites are not pixel-identical. `coverage` reports merged,
completed, pending and lost requests and 8 cm footprint-proxy coverage. It excludes
stream shaping and detector/spot saturation; inspect `stamp` and detector counters
too. Zero proxy loss does not prove visible pixel coverage. `latency.oldestMs`
is current pending age; `perf.inputToBakeMaxMs` conservatively ages each layer
from its job's oldest input. A reset during a bench measurement invalidates it.

Use **fresh labels** (the tools refuse overwriting evidence):

```powershell
# Same v2 physics fixture, full-resolution control and experimental candidate.
python tools/perf_candidate.py --label my-control-v2 --repeat 3 --capture
python tools/perf_candidate.py --label my-grouped-half --width 2048 --bake 3 --flush .05 --coalesce --group --repeat 3 --capture
# Fresh process; existing shader caches are retained. Repeat separately per backend.
python tools/perf_candidate.py --label my-grouped-half-cold --width 2048 --bake 3 --flush .05 --coalesce --group --repeat 3 --restart --renderer d3d12
python tools/perf_candidate.py --label my-grouped-half-vulkan --width 2048 --bake 3 --flush .05 --coalesce --group --repeat 3 --restart --renderer vk
# Current backend: no reset during a continuous 10-minute real-contact scrape.
python tools/perf_endurance.py --label my-half-circle --minutes 10 --continuous --width 2048 --bake 3 --flush .05 --coalesce --group
# Omit --continuous for repeated fresh-contact fixtures, same painter instance.
python tools/perf_endurance.py --label my-half-repeated --minutes 10 --width 2048 --bake 3 --flush .05 --coalesce --group
```

The circle fixture adds horizontal translation around a 25 m radius; it preserves
internal and vertical motion. This is controlled assisted scraping, not normal
driving or fake contacts. Review contact activity throughout, final queue,
completed-layer age, lost requests, native maxima, p95/p99/worst frames and memory.
Tools restore the full-resolution/default controls afterward; evidence records the
actual measured settings. Process-private memory is not dedicated GPU allocation.

For **D3D12 diagnostics only**, the bounded ETW tool stops at a native outlier:

```powershell
python tools/perf_trace.py --label my-native-trace --runs 6
python tools/perf_resumed_report.py
```

It uses user-provider ETW without elevation; Windows policy can still deny it.
Diagnostic trace timings are excluded from untraced acceptance. The raw system-wide
ETL stays under ignored `bench/`; export only the game-owned window with
`tools/perf_trace_report.py`, not unrelated process data. Retain failures and invalid
runs. [Trace interpretation and limits](../investigations/11-quality-throughput.md#native-resource-trace-obtained-during-resumed-implementation).

Restore the developer defaults explicitly if an interrupted experiment left them:

```powershell
python tools/dev.py lua 'scratches_paint.setDamageResolution(4096);scratches_paint.setBakeBudget(6);scratches_paint.setFlushInterval(0.2);scratches_paint.setProjectionBudget(6);scratches_paint.setLayerBudget(24);scratches_paint.setCoverageCoalescing(false);scratches_paint.setPanelGrouping(false);return jsonEncode(scratches_paint.getStats())'
```


For the retained local ETW diagnostic, the exact sanitized export can be regenerated
on this workspace (the system-wide ETL is intentionally not published):

```powershell
$q = "*[System[TimeCreated[@SystemTime >= '2026-11-15T01:37:50.557Z' and @SystemTime <= '2026-11-15T01:37:51.083Z']]]"
Get-WinEvent -Path bench/resumed-native-ring.etl -Oldest -FilterXPath $q | ForEach-Object { $_.ToXml() } | Set-Content -Encoding utf8 bench/m5-stall-events.xml
python tools/perf_trace_report.py --xml bench/m5-stall-events.xml --out docs/evidence/milestone5/resumed-native-ring --run docs/evidence/milestone5/resumed-native-ring/20261114-183730_sustained_resumed-native-ring_r3/result.json --pid 578736
python tools/perf_trace_plot.py
```

For a new recording, use its actual game PID, outlier interval and clock-sync metadata
instead of those retained values. The script matches kernel packet completions by
queue, packet and sequence; it removes graphics addresses and unrelated process events.
The graph shows elapsed call/packet intervals and event timestamps, not CPU stacks or
GPU execution durations.

Full-detail grouped experiments keep every accepted layer (coalescing off):

```powershell
python tools/dev.py lua 'scratches_paint.setDamageResolution(4096);scratches_paint.setBakeBudget(3);scratches_paint.setFlushInterval(0.05);scratches_paint.setProjectionBudget(6);scratches_paint.setLayerBudget(24);scratches_paint.setCoverageCoalescing(false);scratches_paint.setPanelGrouping(true);return jsonEncode(scratches_paint.getStats())'
python tools/perf_candidate.py --label my-fixed-full-warm --width 4096 --bake 3 --flush .05 --group --repeat 3 --capture
python tools/perf_candidate.py --label my-fixed-full-cold --width 4096 --bake 3 --flush .05 --group --repeat 3 --restart --renderer vk
python tools/perf_endurance.py --label my-fixed-full-endurance --width 4096 --bake 3 --flush .05 --group --minutes 10
python tools/perf_material_lifetime.py --label my-material-lifetime --cycles 10
# Same fixture and current renderer, painting disabled; isolate ordinary frame tails.
python tools/perf_endurance.py --label my-control-v2-disabled-endurance --width 4096 --bake 3 --flush .05 --group --disabled --minutes 10
# Compare native batch size while retaining full resolution and every accepted layer.
python tools/perf_candidate.py --label my-grouped-full-b6-cold --width 4096 --bake 6 --flush .05 --group --repeat 3 --restart --renderer vk --capture
```

The backend is unchanged unless `--restart --renderer ...` is specified. For dry
collision runs, check `stamp.streamLayersExpected == stamp.streamSubstrokesTotal`,
`stamp.stampsAttempted == stamp.stampsEnqueued == perf.bakeLayersTotal -
stamp.streamSubstrokesTotal`, zero failures/misses/drops and empty final queues.
The report records full-layer conservation separately from representative coverage.
This does not waive detector/spot saturation, native timing or visual checks.

Functional regression can be repeated with an explicit preset on each backend:

```powershell
python tools/dev.py restart --game-arg=-gfx --game-arg=d3d12
python tools/perf_functional_candidate.py --label my-half-d3d12-functional --width 2048 --coalesce
python tools/dev.py restart --game-arg=-gfx --game-arg=vk
python tools/perf_functional_candidate.py --label my-full-vulkan-functional --width 4096
```

It uses the requested width, bake3/flush0.05/grouping and optional coalescing, exact stock configs, 20 player
switches and 10 vehicle reloads, three traffic NPCs, extension reloads, editor
isolation, map changes, the installed GT3 safe skip and actual mud/water fixtures.
The GT3 check requires the existing `mods/repo/scintilla_gt3.zip`; it restores its
prior activation state. The editor check refuses to replace existing user artwork.
Water state checks do not replace inspection of the genuine PNGs for scratch
persistence and material fidelity. Fixtures restore their temporary objects; the
suite leaves the verified ETK and full-resolution developer defaults selected.

To repeat only the guarded washing regression on the current renderer:

```powershell
python tools/perf_wash_candidate.py --label my-full-wash --width 4096 --near-mud
```

This rejects any cosmetic-generation change from the initial asphalt scrape through
mud, water, drying and fresh mud. `--near-mud` scrapes beside the strip, then uses
assisted physical translation into mud and reverses there after washing. It never
teleports the damaged car. The older transfer mode remains available for reproducing
historical evidence, but even non-resetting safe placement sometimes invalidated
the generation. A passing water state after a reset does not establish persistence. Keep
builds, uploads, tracing and other heavy host work outside measured cohorts.
