# Examples and troubleshooting

## First drive

1. Install one copy of the mod using the README instructions.
2. Spawn an ETK 800 on Gridmap v2. Choose an empty Paint Design; the mod selects
   Dynamic Textures automatically. Paint color and Paint Design are different:
   an ordinary body color is allowed, but an existing livery is skipped.
3. Slide the side of the car against a hard surface. Expect cosmetic scrape
   marks; the mod does not add physical deformation.
4. Reset the car with Ctrl+R. Expect all accumulated marks to clear.

The [captured example](images/etk800-sideslide.png) is an actual asphalt sideslide,
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
| ETK 800, Dynamic Textures, Gridmap asphalt | Scratch rendering captured on 2026-11-14; exact build not recorded |
| Existing livery | Intentionally skipped to preserve it |
| Vehicle without dynamicTextures part | Unsupported; painter remains not ready |
| Traffic and parked vehicles | Not painted; player vehicle only |
| Mud/dirt/snow | Mock checks pass; terrain rendering validation pending |
| Water | State tracking only; no visual washing or wet gloss |
| Mod vehicles / multiplayer | Not validated; no compatibility guarantee |

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| No marks, painter NOT READY | Existing livery or missing Dynamic Textures part; try the ETK 800 with empty Paint Design |
| Painter ready, contacts counted, nothing visible | Check renderer/shader errors and the vanilla Dynamic Decals editor; see README known issues |
| Changes do not load | Remove duplicate ZIP/unpacked installations, restart; check active user folder |
| Terrain does not dirty the car | Collision material, slip threshold, deposit cap and approximate wheel projection |
| Water does not clean the car | Visual cleaning is not implemented |
| Stutters when scraping | Record a bench run; lower projection budget in the debug panel and compare; no guaranteed FPS target yet |

For bug reports, include game build, renderer, vehicle/configuration, map,
reproduction steps, installed version/commit and the panel's Copy debug report.
Include before/after images when reporting appearance problems.
