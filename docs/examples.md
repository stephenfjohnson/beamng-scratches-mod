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
| Stutters when scraping | Record a bench run; lower projection budget in the debug panel and compare; no guaranteed FPS target yet |

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

For supported ETKs, `comparison.originalStages=2`, `activeStages="3"` and an
empty `differences` object/array indicate identical original fields in the
clone. That structural check accompanies screenshots; it is not a render test.

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
