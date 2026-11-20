# Development

[Docs index](README.md) · [Back to the project front page](../README.md)

Prerequisites: Python 3.10+ and Lua 5.1 (`lua` and `luac` on PATH) for the full
preflight. Packaging uses Python's standard library. Regenerating brush art
additionally needs `python -m pip install pillow numpy`. Live tests require a
local BeamNG installation with MCP enabled. Mock checks cannot verify rendering.

## Developers — unpacked

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

## The dev loop: `tools/dev.py`

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

## Scenario bench: `tools/bench.py`

Scripted crashes for tuning, with the cost of every frame recorded:

```
python tools/bench.py scenarios                    # baseline, roofdrop, sideslide, rollover, bellyflop, nosedive
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

## Testing without the game

The Lua modules use Lua 5.1 syntax. `tools/sim/harness.lua` runs both of them
in one stock Lua 5.1 state against mocked engine objects — the vehicle →
game-engine payload round trip, player-only gating, the per-frame projection
budget, composite gating, vehicle switch, clear, and the debug panel — so
logic regressions show up without launching BeamNG:

```
lua tools/sim/harness.lua
```

It does not render anything; whether marks *look* right still needs the game.

## Debugging

The fastest loop: reproduce a problem, open the debug panel, click **Copy
debug report**, and paste it. Useful console probes (game-engine Lua) still
exist — `scratches_paint.dumpState()`, `scratches_paint.deepProbe()`,
`scratches_paint.dumpPaintStats()`, `scratches_paint.buildDebugReport()` — and
on the vehicle side, `scratches_detect.dumpStats()`.

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

If Lua tools are absent, the packager warns and skips Lua checks. A successful
ZIP build alone is therefore not evidence that preflight ran; release builds
must show successful syntax, globals, harness and sidecar checks.

Uninstall steps are on the [install page](install.md#uninstalling).

Then test it: remove the unpacked dev mount (`python tools/dev.py unmount`), drop the zip into `mods/`, restart
BeamNG, and confirm a [clean install](install.md#players--packaged-mod) works.
