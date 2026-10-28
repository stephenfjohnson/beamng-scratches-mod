# scratches_mod

Procedural scratches, scrape streaks, and impact chips for BeamNG.drive vehicle
panels. The mod listens to real physics contact events and bakes cosmetic
scratch decals onto the body where the car actually touched something — slide
on your roof and the roof panels get long scrape marks; clip a wall and that
corner gets a chip cluster.

It is purely cosmetic. It does **not** change BeamNG's soft-body deformation;
it paints texture damage on top of whatever the physics already did.

---

## Installation

The mod is two Lua extensions plus brush art. It targets a recent version of
BeamNG.drive that includes the **Dynamic Decals** system (developed and tested
on 0.38).

### Players — packaged mod

1. Get `scratches_mod.zip` (see [Packaging for release](#packaging-for-release)
   if you are building it yourself).
2. Drop the zip into your BeamNG user folder's `mods/` directory:
   `Documents/BeamNG.drive/<version>/mods/`  *(or `%LOCALAPPDATA%\BeamNG\
   BeamNG.drive\<version>\mods\`)*.
3. Launch BeamNG; the mod manager picks it up automatically.
4. Spawn a [supported vehicle](#supported-vehicles--limitations) and drive.

Nothing else is required — both halves of the mod load themselves (see
[How it works](#how-it-works)). No console commands.

### Developers — unpacked

Let `tools/dev.py` install and reload the mod for you (see
[Development](#development)):

```
python tools/dev.py launch     # deploy, then start BeamNG into Gridmap
```

It mirrors `lua/` and `art/` into the user folder's `mods/unpacked/` directory
(BeamNG treats each folder there as a mounted mod):

```text
%LOCALAPPDATA%\BeamNG\BeamNG.drive\current\mods\unpacked\scratches_mod
```

Don't also have `scratches_mod.zip` in `mods/`; the two copies fight.

---

## Using the mod

Once installed, the mod is automatic — drive, crash, and scratches accumulate.

| Action | Effect |
| --- | --- |
| Slide a panel along a surface | A band of parallel scrape lines over a scuffed haze at each contact, running the way the car slid; longer drags scrape deeper (more bare metal) |
| Hit something hard | Chipped paint, plus a gouge on harder hits, sized by impact force |
| **Reset Car** (`Ctrl+R`) | Clears all baked scratches and resets the vehicle |
| **Toggle Scratches Debug Panel** | Opens/closes the in-game debug + tuning panel |

The panel toggle is a **bindable key**. After first launch, open
**Options → Controls → Bindings**, find **"Toggle Scratches Debug Panel"** in
the **Debug** category, and assign a key. It works in any context.

---

## The debug panel

A two-pane in-game window for diagnosing and tuning the mod.

**Left — log pane.** A live, color-coded feed of every mod log line, merged
from both Lua VMs and tagged `[GE]` (painter) or `[VEH]` (detector). Includes a
`W/E only` filter and a `Clear log` button.

**Right — controls.**

- **Copy debug report** — one click copies a compact, paste-ready report
  (environment, stats, tunables, relevant log lines) to the clipboard. This is
  the fastest way to report a bug.
- **Status header** — `Painter: READY` / `NOT READY` plus the current vehicle.
- **Presets** — `Light` · `Default` · `Heavy` · `Max` · `Extreme`, one click to
  swap every tunable.
- **Live counters** — impacts, streams, baked stamps, projection cost, job
  backlog, and how often the canvas is re-composited.
- **Sliders** — slide/impact thresholds, bake limits (aggregate cap,
  projections per frame, cluster radius), and the paint-color seed.
- **Full-rate composite (debug)** — restores the stock every-frame canvas
  composite. Leave it off; it exists only to rule the composite skip out when
  diagnosing missing marks.
- **Buttons** — reset stats, restore defaults, clear stamps, dump full stats.

Controls that need a bound projection grey out until the painter is ready.

---

## How it works

The mod spans BeamNG's two Lua virtual machines and a texture pipeline.

### 1. Detection — vehicle Lua (`scratches_detect.lua`)

Auto-loaded into every vehicle (from `lua/vehicle/extensions/auto/`), but it
only does work in the car the player is driving — AI traffic and parked cars
return immediately. It wraps the global `onNodeCollision` callback and filters
the firehose of contacts down to *paintable body contacts*: body-material
nodes touching a hard surface, with glass, wheels, and internal/mechanical
parts rejected. Each node's verdict is computed once and cached, so the
per-contact cost on the physics tick is a table lookup.

Surviving contacts split into two event kinds:

- **Impacts** — the first hard hit past a normal-force threshold in each
  contact. A soft initial touch stays armed while force builds; sustained
  pressure cannot repeatedly trigger impacts. Separation re-arms the node.
- **Slides** — sustained slipping contact, accumulated into multi-point
  *streams* that describe the scrape path.

Each render frame, the frame's impacts and every slide stream that ended are
batched and shipped to the game-engine side in **one** `queueGameEngineLua`
call (`scratches_paint.ingest`), tagged with the vehicle id.

### 2. Painting — game-engine Lua (`scratches_paint.lua`)

Owns a **Dynamic Decals** projection for the player vehicle. On setup it
selects the vehicle's `dynamicTextures` skin (the canvas the decal system
paints onto) and seeds the canvas with a PBR paint baseline.

Incoming batches become **projection jobs** — one synthetic-camera projection
plus the decal layers captured under it:

- **Impacts** → chipped paint (sharp flakes), plus a gouge on harder hits,
  scaled by force. The frame's stamps are spatially clustered; each cluster is
  one job.
- **Slides** → a scrape band at the latest contact point, aligned with the
  slide (the first→last movement of the contact, flattened onto the panel),
  30–70 cm long so neighbouring contacts join into one rash. It's drawn as a
  translucent clear-coat haze under parallel scrape lines, one brush and tone
  per slide, in overlapping segments. Each stream is one job.

Damage is coloured like layered paint: scuffed clear coat (haze), primer grey,
and bare metal on harder or longer contacts. On light paint the palette shifts
darker so damage contrasts the right way. The brushes are generated by
`tools/generate_brushes.py` at line widths the 4096×2048 canvas can resolve
(~1.5 mm per texel on a car); finer detail just blurs.

Work is scheduled around two measured engine costs:

- **Projection** has a per-frame toll: the first `projectDynamicDecals` in a
  frame costs ~14 ms (an engine-side sync, whether or not physics runs), and
  each further pass ~1.4 ms. So new marks accumulate and are projected in
  batches every 0.2 s (`setFlushInterval`), up to 6 passes per batch
  (`setProjectionBudget`). The first mark after a quiet spell goes out on the
  next frame. Slides within 35 cm of a queued slide on a panel facing the same
  way share its projection, with the camera backed off to fit every band.
- **Baking** costs ~0.85 ms per layer with no toll, so captured layers are
  baked on the frames *between* projection batches, 6 at a time. No frame
  pays both costs. Each captured batch drains before another is projected,
  so low frame rates or a zero flush interval cannot starve baking or grow
  its backlog indefinitely.

A spot that has already been painted twice (8 cm grid) skips further marks
until the canvas is cleared, so a long slide doesn't pay to repaint the same
contact point over and over.

The canvas is only composited onto the car on frames that baked or cleared;
the stock API does it every frame. Nearly all of the stock update's cost is
re-binding the texture set to the car's materials (`veh:setTextureSet`,
24–55 ms per call), so the painter re-binds only when the binding can be
stale (setup, and when the car spawns, resets, is switched to, or is cleared).
Every other composite refreshes the projection shape and transforms and calls
`combineTextures`, which costs ~0 ms. Counters and tunables are pushed from
the detector every 0.25 s to drive the debug panel.

### Loading

The vehicle side auto-loads (it lives in an `extensions/auto/` directory). The
game-engine side has no auto-load directory, so the vehicle side bootstraps it
with `extensions.load('scratches_paint')` on its lifecycle hooks. The result:
both sides come up on their own with no console commands.

For the full design history, see `docs/plans/` and `investigations/`.

---

## Supported vehicles & limitations

- **Requires the Dynamic Decals system** and a vehicle that ships a
  `<jbeam>_skin_dynamicTextures` part. Vehicles without it are unsupported and
  the mod cleanly does nothing (the debug panel reports `NOT READY`).
- **Liveried vehicles are skipped.** A livery and the dynamic-decal canvas both
  occupy BeamNG's single skin slot. Rather than evict a livery, the mod leaves
  liveried cars untouched — they keep their livery but get no scratches.
  Livery + scratches together is planned (see [Known issues](#known-issues)).
- **Cosmetic only.** The mod paints texture damage from contact events; it does
  not add or replace soft-body deformation.
- **Glass and selected mechanical/internal parts are filtered out** so stray
  projection rays don't mark unrelated panels.

---

## Repo layout

```text
lua/vehicle/extensions/auto/scratches_detect.lua   # VLUA contact detection
lua/ge/extensions/scratches/paint.lua              # GELUA dynamic-decal painter
lua/ge/extensions/core/input/actions/scratches.json # bindable panel hotkey
art/dynamicDecals/textures/                        # scratch brush PNGs + metadata
tools/generate_brushes.py                          # brush generation utility
tools/package.py                                   # release zip builder + preflight
tools/dev.py                                       # dev loop: deploy + hot-reload via BeamNG MCP
tools/bench.py                                     # scripted crash scenarios + frame timing + screenshots
tools/ingame/scratches_bench.lua                   # in-game half of the bench (dev mount only)
tools/sim/harness.lua                              # headless mocked-engine checks
docs/plans/                                        # design notes
investigations/                                    # BeamNG API investigations
```

Every brush PNG must have a matching `.png.dynDecalTexture.json` sidecar next
to it, or the dynamic-decal system loads it invisibly.

---

## Development

### The dev loop: `tools/dev.py`

Edit, save, and the running game picks up the change in a few seconds:

```
python tools/dev.py launch     # deploy, start BeamNG into Gridmap with MCP on, wait for the car
python tools/dev.py watch      # deploy + hot-reload on every save (Ctrl+C to stop)
python tools/dev.py deploy     # one-shot deploy + hot-reload
python tools/dev.py restart    # quit the game cleanly and launch it again
python tools/dev.py lua "return scratches_paint ~= nil"   # run game-engine Lua
python tools/dev.py status     # paths, game, MCP and mount state
```

Every deploy first runs the same preflight as `package.py` (`luac -p`, the
stray-global check, the harness, brush sidecars). Code that fails it never
reaches the game. The deploy then copies only what changed into
`mods/unpacked/scratches_mod/` and reloads only the affected part:

| Changed | Reload | Typical time |
| --- | --- | --- |
| `lua/ge/` (`paint.lua`) | `extensions.reload('scratches_paint')` | ~2.5 s |
| `lua/vehicle/` (detector) | player vehicle reload (`Ctrl+R` equivalent; clears scratches) | ~4 s |
| input action `.json` | full game-engine Lua reload (`Ctrl+L` equivalent) | ~6 s |
| `art/` (brushes) | painter reload; new brushes load on first use, an edited existing brush needs `dev.py restart` | ~2.5 s |

It then prints the mod's log lines from the reload and fails if any of them is
an error. Errors the game itself logs (shader compiles, level scans) are counted
but don't fail the deploy. A full restart is still safest after changing
material, JBeam or skin data.

**How it talks to the game.** BeamNG 0.39+ ships a local MCP server
(`http://127.0.0.1:29292/mcp`, localhost only) that can run game-engine Lua.
`launch`/`restart` turn it on with `-enablemcp`. For a game you start yourself,
enable **Options → Advanced → Enable MCP server** once. Without MCP, `deploy`
still copies the files and tells you to press `Ctrl+L` / `Ctrl+R`. Log output
is read through `Engine.getFrameLog()`, because `beamng.log` on disk lags by
seconds. That buffer is shared with the in-game console window, so while the
console is open, reload output shows there instead.

**Claude Code.** `.claude/settings.json` has a Stop hook that runs
`dev.py hook` after every Claude turn. If no file changed it does nothing
(about 0.3 s). Otherwise it deploys and hot-reloads, and on a preflight or
in-game error it hands the error back to Claude to fix. `.mcp.json` registers
the game's MCP server as `beamng`, so Claude can also run Lua, read logs, reload
the vehicle and take screenshots of the running game directly.

Overrides: `BEAMNG_USER`, `BEAMNG_GAME`, `BEAMNG_MCP_PORT`, `BEAMNG_LEVEL`
(default `gridmap_v2`). `python tools/dev.py unmount` removes the dev copy.

### Scenario bench: `tools/bench.py`

Scripted crashes for tuning, with the cost of every frame recorded:

```
python tools/bench.py scenarios                    # baseline, roofdrop, sideslide, rollover, nosedive
python tools/bench.py run sideslide
python tools/bench.py run all --tag before
python tools/bench.py run rollover --set paint.setProjectionBudget=3 --tag budget3
python tools/bench.py run roofdrop --repeat 3 --optick
python tools/bench.py list                         # compare runs side by side
```

Each run resets the car (repaired, canvas wiped) at a fixed home pose,
launches it, and records every frame until it settles and the painter's
backlog drains. It then stands the car upright without a reset, with painting
paused, and photographs it from the left, right, front, rear and top with the
HUD hidden. `bench/runs/<run>/` gets `report.md` (marks, rejection reasons,
painter/detector/engine cost, worst frames, screenshots), `frames.csv` (every
engine frame-section timing per frame), `result.json` and the `shot_*.jpg`
files. One summary row per run goes to `bench/runs/index.csv`.

- `--set paint.<fn>=args` / `detect.<fn>=args` call the mod's tuning
  functions before the run (e.g. `detect.setThresholds=0.6,0.8,10`). They're
  undone afterwards by reloading the module, unless you pass `--keep`.
- `--optick` saves an Optick capture of the run (`capture.opt`).
- The background FPS limiter is lifted for the run and restored afterwards,
  so an unfocused game window isn't capped at a few FPS.
- Timing comes from the mod itself: the painter always measures its own frame
  (`scratches_paint.getStats()`, also in the debug report). The detector times
  every contact only while the bench turns profiling on
  (`scratches_detect.setProfile`).
- The in-game half, `tools/ingame/scratches_bench.lua`, is copied into the dev
  mount by `dev.py` and never into the release zip.
- Homes are per level (`gridmap_v2` is built in). On another map, park
  somewhere open and flat and run `python tools/bench.py home --save`.

### Testing without the game

Both Lua files are plain Lua 5.1. `tools/sim/harness.lua` runs both of them
in one stock Lua 5.1 state against mocked engine objects — the vehicle →
game-engine payload round trip, player-only gating, the per-frame projection
budget, composite gating, vehicle switch, clear, and the debug panel — so
logic regressions show up without launching BeamNG:

```
lua tools/sim/harness.lua
```

Regression checks also cover force ramp-up and impact re-arming, merged
scrape layer counts, continuous-input bake progress at zero flush intervals
and low frame rates, and diagnostics on skipped vehicles or without a car.

It does not render anything; whether marks *look* right still needs the game.

### Repeatable accuracy tests

```powershell
python tools/test_accuracy.py                       # Lua regressions, no game needed
python -m pip install -r tools/requirements-accuracy.txt
python tools/dev.py launch --game-arg=-gfx --game-arg=vk
python tools/test_accuracy.py --ingame --repeat 2    # frozen rendered fixtures
python tools/test_accuracy.py --physics --repeat 2   # fixtures + five crash scenarios
```

The in-game suite requires Gridmap v2 and the local BeamNG MCP connection.
It deploys the current source and **replaces the player vehicle** with the
stock D15 4WD automatic configuration. Each repetition starts from that
configuration at the same coordinates, with a private painter RNG seed of
1977. It restores the prior pause, HUD, exposure and background-FPS settings afterward;
it leaves the test pickup in the level.

The rendered fixtures inject the same node contacts while physics is paused:
roof contact must mark the roof and leave the bed clean; outside-bed contact
must leave the floor and inner wall clean; direct floor contact must visibly
mark the bed. Captures use fixed exposure (10.3 EV, automatic exposure off).
Every camera has clean-to-clean control captures to detect lighting/camera
instability. The test compares lossless PNGs in the central
60% of each view, counting pixels whose largest RGB-channel change exceeds
20/255. Targets require at least 25 changed pixels and less than 5% changed
area; controls and protected regions allow at most 10 pixels. Bake or
projection errors also fail the run. These checks prevent an entirely broken
renderer from passing simply because it painted nothing.

`bench/accuracy/<timestamp>/` contains the exact contact packets, node names,
camera poses, before/control/after PNGs, difference masks, game logs, painter
counters and a JSON manifest with source hashes and engine version. The
process exits nonzero on failure or an interrupted run. `--physics` also
writes the existing crash reports under `bench/runs/`. Physics runs check
positive bakes, empty queues and errors. Roofdrop and rollover also freeze the
wreck, capture it, then clear only cosmetic damage and capture the same
deformation again: the body must show paint damage and the bed floor must
remain unchanged. The rollover must reach an up-vector Z below -0.7; merely
tipping onto its side fails. These are not pixel-identical crash trajectories. Fixed inputs make comparisons repeatable,
but engine timing and soft-body simulation can change the final deformation.

The headless suite additionally checks rotation and translation between
collision and delivery, node deformation between projection and bake,
mesh ownership, shallow non-mirrored projection, malformed packets,
deterministic brush selection and recovery from a native bake failure.
The image-comparison checks themselves are tested with:

```powershell
python -m unittest discover -s tools/sim -p "test_*.py"
```

### Debugging

The fastest loop: reproduce a problem, open the debug panel, click **Copy
debug report**, and paste it. Useful console probes (game-engine Lua) still
exist — `scratches_paint.dumpState()`, `scratches_paint.deepProbe()`,
`scratches_paint.dumpPaintStats()`, `scratches_paint.buildDebugReport()` — and
on the vehicle side, `scratches_detect.dumpStats()`.

---

## Packaging for release

The mod is the `lua/` and `art/` directory trees. Build the distributable zip
with:

```
python tools/package.py          # -> dist/scratches_mod.zip
```

It packs `lua/` and `art/` at the **zip root** (a zip with the trees nested one
folder deeper installs without error and then does nothing), and refuses to
build if a Lua file fails `luac -p`, reads or writes an unexpected global (the
signature of a `local` used above its declaration, which compiles fine and
crashes in game), fails the harness, or a brush PNG is missing its
`.dynDecalTexture.json` sidecar. `docs/`, `investigations/`, `tools/`,
`reference/` and `README.md` are repo-only and are never included.

Then test it: remove the unpacked dev mount (`python tools/dev.py unmount`), drop the zip into `mods/`, restart
BeamNG, and confirm a [clean install](#players--packaged-mod) works.

---

## Known issues

- **Contact placement is conservative, not triangle-exact.** Live contacts
  stay anchored to the collision node, use its part's paintable flexbodies,
  and project through only 4 cm of depth with no mirror or position jitter.
  This prevents the old metre-deep projection from reaching unrelated panels.
  BeamNG's collision nodes approximate the visual mesh; badly folded panels,
  shared UVs and surfaces closer than that depth can still be ambiguous.
  Unknown paintable ownership is rejected, so some vehicles may show less
  damage rather than put it on an unrelated panel. No global shader override
  or vehicle-specific mesh edits are installed.
- **No scratches on the D3D12 renderer (BeamNG 0.39.4).** The game's own
  dynamic-decal shader (`shaders/common/dynamicDecals/decal.ps.hlsl`) fails to
  compile under D3D12, so every decal draw is dropped
  (`D3D12 cmd: draw skipped (pipelineBindFailed=1 ... dynamicDecals/decal...)`
  in `beamng.log`). This also breaks the vanilla decal editor. The mod still
  detects and queues marks; nothing reaches the paint. Use Vulkan: **Options →
  Graphics → Vulkan**, or launch with `-gfx vk` for one session
  (`python tools/dev.py launch --game-arg=-gfx --game-arg=vk`).
- **Liveried cars get no scratches** — they are skipped to preserve the livery.
  Livery + scratches compositing (capturing the livery into the dynamic canvas
  so scratches layer on top) is planned future work.
- **Scratches have no metal glint** — metallic and roughness are served from
  static factory maps instead of the dynamic canvas (the fix that removed the
  paint seam), so scratch decals read as colour marks only. Base gloss is
  uniform and correct across the whole body; per-scratch shine is the
  trade-off.

See `docs/plans/2026-05-21-release-roadmap.md` for the current roadmap.
