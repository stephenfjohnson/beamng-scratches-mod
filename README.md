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

For iteration, work on the mod unpacked so edits hot-reload. Junction (or copy)
the repo into the user folder's `mods/unpacked/` directory:

```text
%LOCALAPPDATA%\BeamNG\BeamNG.drive\current\mods\unpacked\scratches_mod
  ->  <this repo>
```

BeamNG treats each folder under `mods/unpacked/` as a mounted mod.

---

## Using the mod

Once installed, the mod is automatic — drive, crash, and scratches accumulate.

| Action | Effect |
| --- | --- |
| Slide a panel along a surface | Long stretched scrape streaks along the contact path |
| Hit something hard | Chip / claw / splatter decals, sized by impact force |
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
- **Live counters** — impacts, streams, baked stamps, projection cost, etc.
- **Sliders** — slide/impact thresholds, bake limits, and the PBR paint seed.
- **Buttons** — reset stats, restore defaults, clear stamps, dump full stats.

Controls that need a bound projection grey out until the painter is ready.

---

## How it works

The mod spans BeamNG's two Lua virtual machines and a texture pipeline.

### 1. Detection — vehicle Lua (`scratches_detect.lua`)

Runs per vehicle (auto-loaded from `lua/vehicle/extensions/auto/`). It wraps
the global `onNodeCollision` callback and filters the firehose of contacts
down to *paintable body contacts*: body-material nodes touching a hard surface,
with glass, wheels, and internal/mechanical parts rejected.

Surviving contacts split into two event kinds:

- **Impacts** — single hard hits past a normal-force threshold.
- **Slides** — sustained slipping contact, accumulated into multi-point
  *streams* that describe the scrape path.

Each render frame, all new events are batched and shipped to the game-engine
side in **one** `queueGameEngineLua` call — cheap even during a violent roll.

### 2. Painting — game-engine Lua (`scratches_paint.lua`)

Owns a **Dynamic Decals** projection for the player vehicle. On setup it
selects the vehicle's `dynamicTextures` skin (the canvas the decal system
paints onto) and seeds the canvas with a PBR paint baseline.

For each batched event it bakes decals:

- **Impacts** → discrete chip/claw/splatter decals, scaled by force. Nearby
  stamps are spatially clustered so one synthetic camera projection serves the
  whole cluster.
- **Slides** → elongated, stretched scrape decals following the stream path,
  split into 1–3 segments by curvature.

Decals are baked into the vehicle's dynamic texture set. Counters and tunables
are pushed back to the detector ↔ painter every 0.25 s to drive the debug panel.

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
docs/plans/                                        # design notes
investigations/                                    # BeamNG API investigations
```

Every brush PNG must have a matching `.png.dynDecalTexture.json` sidecar next
to it, or the dynamic-decal system loads it invisibly.

---

## Development

With the repo mounted under `mods/unpacked/` (see
[Installation](#developers--unpacked)):

| Key | Reloads |
| --- | --- |
| `Ctrl+L` | Game-engine Lua (`paint.lua`) |
| `Ctrl+R` | Respawns the vehicle, reloads vehicle Lua (`scratches_detect.lua`); also clears baked scratches |

After changing detector constants, respawn the vehicle so the new values load.
A full game restart is safest after changing textures, material/JBeam, or skin
data.

Both Lua files are plain Lua 5.1 and can be syntax-checked with `luac -p`.

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
build if a Lua file fails `luac -p` or a brush PNG is missing its
`.dynDecalTexture.json` sidecar. `docs/`, `investigations/`, `tools/`,
`reference/` and `README.md` are repo-only and are never included.

Then test it: remove the unpacked dev mount, drop the zip into `mods/`, restart
BeamNG, and confirm a [clean install](#players--packaged-mod) works.

---

## Known issues

- **Liveried cars get no scratches** — they are skipped to preserve the livery.
  Livery + scratches compositing (capturing the livery into the dynamic canvas
  so scratches layer on top) is planned future work.
- **Scratches have no metal glint** — metallic and roughness are served from
  static factory maps instead of the dynamic canvas (the fix that removed the
  paint seam), so scratch decals read as colour marks only. Base gloss is
  uniform and correct across the whole body; per-scratch shine is the
  trade-off.

See `docs/plans/2026-05-21-release-roadmap.md` for the current roadmap.
