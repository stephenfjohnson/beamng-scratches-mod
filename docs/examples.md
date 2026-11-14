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

On terrain whose collision material is MUD, DIRT or SNOW, try wheelspin or body
sliding. The prototype requires slip, so simply driving slowly may do nothing.
It uses tinted haze marks, with a lifetime limit of 96 deposit attempts per
reset. Wheel contact placement is approximate and is not verified splash spray.
Do not infer compatibility from a map's visual terrain name.

To inspect state while the game is running with MCP:

```powershell
python tools/dev.py lua "return jsonEncode(scratches_paint.getSurfaceState())"
```

Expected keys include `mud`, `dirt`, `snow`, `wetness`, `deposits` and
`waterSupported`. `visualCleaningSupported` and `visualWetnessSupported` are
currently false. Entering sufficiently deep water can reduce internal exposure
values, but visible dirt remains until reset. Shallow puddles may be missed.

## Compatibility evidence

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
| Mud/dirt/snow | Mock checks pass; terrain rendering validation pending |
| Water | State tracking only; no visual washing or wet gloss |
| Mod vehicles / multiplayer | Not validated; no compatibility guarantee |

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| No marks, painter NOT READY | Unsupported design, editor active, or missing Dynamic Textures part; try ETK 800 empty/Police Paint Design |
| Painter ready, contacts counted, nothing visible | Check renderer/shader errors and the vanilla Dynamic Decals editor; see README known issues |
| Changes do not load | Remove duplicate ZIP/unpacked installations, restart; check active user folder |
| Terrain does not dirty the car | Collision material, slip threshold, deposit cap and approximate wheel projection |
| Water does not clean the car | Visual cleaning is not implemented |
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
