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
| Slide a panel along a surface | A band of fine scrape lines over dulled clear coat, running the way the car slid; pressing harder cuts down to primer, then bare metal (or a bumper's dark plastic) |
| Hit something at an angle | Abraded clear coat over the contact patch, streaks along the slide; chips on a firm hit, a torn gouge on a hard one |
| Hit something square-on | Paint mostly stays on (it's crushed, not scraped): a hard hit dulls the clear coat it pressed on and chips it |
| Rub or hit another car | The same marks, plus the other car's paint transferred where the panels wiped along each other |
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

- **Impacts** — the onset of a hard contact (a node that was contact-free
  starting to bear force past a threshold). Each carries the node's body
  material and, when the panel was really sliding along what it hit, the
  slide direction and speed (by the time a crash contact reports, the node
  itself has mostly stopped; the car's own motion along the surface then
  stands in - minus its vertical bounce against an upright surface - so a
  corner raked past a post doesn't read as square-on).
- **Slides** — sustained slipping contact, accumulated into multi-point
  *streams* that describe the scrape path, with the body material and the
  hardest the node pressed. A slide too brief to trace (a bumper corner raked
  across a post for a few physics ticks) is sent as a single contact with its
  slip direction and speed.

A lamp's contact (headlight, taillight, fog light) is moved to the paintable
body node nearest the lamp at rest (within 12 cm), or dropped: through a
broken lens the mark landed on whatever was behind it.

Contacts with another car never reach `onNodeCollision` (in either car), so
the detector also sends the painter the car's paintable body-node list for
the painter's car-on-car probe (below).

Each render frame, the frame's impacts and every slide stream that ended are
batched and shipped to the game-engine side in **one** `queueGameEngineLua`
call (`scratches_paint.ingest`), tagged with the vehicle id.

### 2. Painting — game-engine Lua (`scratches_paint.lua`)

Owns a **Dynamic Decals** projection for the player vehicle. On setup it
selects the vehicle's `dynamicTextures` skin (the canvas the decal system
paints onto), seeds the canvas with the paint colour, and splits the skin
material's paint stage into a **damage layer** (below).

**The damage layer (gloss loss).** Real paint damage reads mostly through
gloss: abraded clear coat goes satin, primer is matte, scraped metal is
satin-shiny. The shipped skin paints the body in one stage under a glossy
clear coat, so a mark could only ever be a colour under glass. The painter
splits it in two: the original stage becomes the *exposed surface* (canvas
colour, no clear coat, roughness from the canvas metallic channel, tiling
micro-scratch detail maps finer than the canvas can hold), and a copy of the
factory paint (the car's own metallic/roughness) is drawn over it, faded by
the canvas **roughness** channel. So on the canvas, roughness means "paint
intact" and metallic means "roughness of what's exposed". Both clear to 1, so
an untouched car is exactly factory paint, with no seed and no seams. Cars
whose paint stage can't be split keep colour-only marks; unloading the
painter puts the material back.

Incoming batches become **projection jobs** — one synthetic-camera projection
plus the decal layers captured under it:

- **Impacts** → composed by how the panel met what it hit. A glancing hit
  abrades the clear coat over the contact patch (BeamNG reports contacts per
  physics node, ~30 cm apart, so one event stands for that area) with streaks
  dragged along the slide; a square-on press leaves the paint on but scuffs
  a small, ragged patch of clear coat where it pressed (from ~4 kN against
  concrete or asphalt, much harder against another car's smooth panel).
  A glancing hit on concrete rubs the clear coat off over its patch (whiter
  and more matte than a pressed scuff). Harder hits add a few chipped shards,
  and a hard glancing one tears a gouge: a wide bare core (darker steel, or a
  bumper's dark plastic) inside a torn white primer lip, thick on one side,
  its drag streaks only dulled clear coat so the gouge reads. A brief slide is composed like a glancing hit along its slip.
  The frame's stamps are spatially clustered; each cluster is one job.
- **Slides** → a scrape band at the latest contact point, aligned with the
  slide (the first→last movement of the contact, flattened onto the panel),
  30–70 cm long so neighbouring contacts join into one rash: sparse scores of
  varied length (dulled clear coat under them once it presses harder), cut to
  primer and then a bare core as the contact presses harder. A contact that
  moved mostly into the panel was pressed, not dragged, and is composed like
  a square-on hit instead. Marks within 35 cm share one slide
  direction (strokes of neighbouring marks crossing read as a comb). Each
  stream is one job.
- **Other cars** → while the player car touches another vehicle
  (`map.objects[id].objectCollisions`) and they're moving relative to each
  other, every 0.1 s the painter hashes the other car's nodes (20 cm cells)
  and treats the player body nodes at the contact front (within reach, and no
  more than 6 cm further off than the closest) as contacts: a scrape band
  along the relative motion when they slide past each other, an impact when
  they close. The other car's paint colour is transferred where the panels
  wiped. ~1 ms per probe; cars resting against each other aren't probed.

Every look carries a depth (haze < transfer < scuff < primer < plastic <
metal). Bake lists are sorted shallow-first, and a new mark skips layers that
would lift an earlier, deeper mark under it back toward intact paint (the
canvas blends by plain lerp). Colours are mixed from the paint colour: on dark
paint, exposed layers read light; on light paint, dark. The brushes are
generated by `tools/generate_brushes.py`. The canvas resolves ~3–5 mm per
texel on a car, so finer scratching comes from the damage layer's detail maps.

Two engine facts shape the projection. A decal is a box: it paints every
surface inside its depth, so marks use thin boxes (a 1 m box smeared marks
down nearby panels as long streaks). And on a crumpled panel the projection
ray can pass the visible skin and stop on structure behind it (5-18 cm
measured). The engine reads back one surface hit per projection pass, under
the screen centre, so each pass is aimed through a real contact point (only
contacts that want the same camera axis share a pass) and that point's overshoot is
measured along the projection axis: its stamps' boxes are
laid along that axis and made deep enough to reach back to the contact, and
contacts within 15 cm sharing the pass borrow that (further off they keep a
normal box: a deep one on intact skin would smear). A hit in front of the contact
(a fold over it) is the visible skin and is painted as is; a contact whose ray
overshot by more than 25 cm went through a hole in the wreck, and its marks
are dropped - after up to two retries: the same camera aimed 8 cm in from the
contact toward the car's middle (a node on a panel's edge, such as a bumper's
lower lip, let the ray slip past it), then the hull face nearest the contact
(a post's side face raking a bumper's front corner aims the camera sideways,
past the front face). If neither finds skin, the pass goes back to the first
camera.

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
  pays both costs.

A spot that has already been painted twice (8 cm grid) skips further marks
until the canvas is cleared, so a long slide doesn't pay to repaint the same
contact point over and over. A hit that would paint nothing doesn't use up
its spot, and neither does a mark that never reaches the canvas (refused by
a full backlog, dropped at projection, or lost to a failed job or bake): a
mark's claim settles only when its layers bake, and keeps only the depth that
reached the canvas.

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
art/scratches/                                     # micro-scratch detail maps for the damage layer
tools/generate_brushes.py                          # generates the brushes and detail maps
tools/package.py                                   # release zip builder + preflight
tools/dev.py                                       # dev loop: deploy + hot-reload via BeamNG MCP
tools/bench.py                                     # scripted crash scenarios + frame timing + screenshots
tools/ingame/scratches_bench.lua                   # in-game half of the bench (dev mount only)
tools/sim/harness.lua                              # headless mocked-engine checks
docs/plans/                                        # design notes
investigations/                                    # BeamNG API investigations
```

Every brush PNG must have a matching `.png.dynDecalTexture.json` sidecar next
to it, or the dynamic-decal system loads it invisibly. (The detail maps in
`art/scratches/` are ordinary material maps and need none.)

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

Scripted crashes for tuning and for judging the marks against real damage,
with the cost of every frame recorded:

```
python tools/bench.py car etk800_blue              # spawn a test car with the scratches skin (also _grey, _silver)
python tools/bench.py gallery                      # fixed marks, no physics: impacts 2.5-21 kN, slides, 45 deg
python tools/bench.py run ref --footage            # the reference crashes, with crash footage frames
python tools/bench.py scenarios                    # list them all
python tools/bench.py run sideslide
python tools/bench.py run all --tag before
python tools/bench.py run rollover --set paint.setProjectionBudget=3 --tag budget3
python tools/bench.py run roofdrop --repeat 3 --optick
python tools/bench.py list                         # compare runs side by side
```

The `ref` set is everyday crashes modelled on real damage photos: a bumper
corner raking a knee-high concrete bollard at walking pace (`cornerscuff`), a harder hit
there (`cornerpost`), a sideswipe along a wall ledge
(`wallscrape`), a pole into a door (`poledoor`), reversing into a post
(`rearpost`), and two with another car driven in: a T-bone (`tbone`) and a
car-on-car sideswipe (`carswipe`). Those runs leave the car where it stopped
and take close-ups aimed at where the painter laid marks.

Put real crash photos in `bench/reference/` (gitignored) and every run's
`sheet.jpg` shows them above the in-game shots, so a run can be judged
against the real thing at a glance. `gallery` feeds fixed detector events to
the painter (no physics, fixed seed via `--seed`), so a change to the brushes
or tones can be compared run to run.

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
- `--footage` grabs a frame every 0.2 s from a fixed camera over the crash
  into `footage.jpg`. It costs screenshot time, so frame timings from those
  runs are inflated; time without it.
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

It does not render anything; whether marks *look* right still needs the game.

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
- **Scraped metal has no metallic flake** — the canvas metallic channel is
  used for the exposed surface's roughness (see "The damage layer"), so bare
  metal is a dark grey standing in for steel rather than true metal. Gloss loss on
  scuffs, primer and metal does render.
- **Hairline scratches are a texture, not geometry** — the paint canvas holds
  ~3–5 mm per texel on a car, so the finest scratching comes from the damage
  layer's tiling detail maps and doesn't follow the slide direction exactly.
- **Car-on-car contact is found geometrically** (BeamNG doesn't report it), so
  its placement is accurate to ~20 cm and needs map tracking on (it is in
  normal play).

See `docs/plans/2026-05-21-release-roadmap.md` for the current roadmap.
