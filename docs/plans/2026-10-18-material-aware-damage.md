# Material-aware layered damage — implementation plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make each mark look like what the car hit and what the panel is
made of, with paint exposed in real layers, and depth driven by force.

**Architecture:**
- **Detector.** Already knows the surface material (`mat1`) and the node's
  own material (`METAL` / `PLASTIC`). It now ships both with every event and
  stream, plus each stream's peak normal force.
- **Painter.** Classifies the surface (`road`, `metal`, `gravel`, `soil`,
  `grass`, `snow`, `wood`, `soft`), picks a depth tier from force, and lays
  down one to three layers per mark from a new brush set.
- **Brushes.** One damage-depth field per brush, thresholded into the paint
  stack (primer → e-coat → steel, or whitening → black plastic). These are
  baked into full-colour PNGs and tinted white, so a layered mark costs the
  same single decal as today's flat one. Transfer, smear and spatter brushes
  stay alpha-only and are tinted at runtime: soil, grass, zinc, rubber,
  bark, and later the other car's paint.

**Tech stack:** Lua 5.1 (both VMs), Python + numpy/scipy/PIL (brush
generator), `tools/sim/harness.lua` (mocked engine), `tools/dev.py` and
`tools/bench.py` (in-game check).

Background and sources: `investigations/04-crash-damage-realism.md`.

---

## Decisions

- **Colour space.**
  - `setDecalColor` and the paint fill take **linear** values. The paint fill
    uses `getVehicleColor()` as-is, and a 0.7 grey tint read as white in game.
  - Brush RGB is authored in **sRGB**, as for vanilla's full-colour logos.
  - The painter's tint table is written in sRGB and converted with an
    `srgb()` helper.
  - The texture decode is not proven, so the in-game check (Task 7) confirms
    it. A global exposure tint is the calibration knob.
- **Depth tiers**, picked as `score = severity ± 0.15` jitter:
  - Below 0.2 → tier 1 (scuff: whitened clear, primer flecks).
  - Below 0.55 → tier 2 (primer with e-coat islands).
  - Otherwise → tier 3 (through to steel / black plastic).
- **Impact severity:** unchanged, `(force − 800) / 20000`, clamped 0..1. Light
  taps now land in tier 1 rather than chipping to metal.
- **Slide severity:** `(peakForce − SLIDE_F_LO) / (SLIDE_F_HI − SLIDE_F_LO)`,
  clamped 0..1, defaults 60 N and 960 N, tunable through `setSlideForceRange`.
  Plus +0.35 for each repeat pass over a spot. Slide distance now sets only
  the band length.
- **Primer shade:** each full-colour brush is authored with a light primer. A
  per-car exposure tint, 0.80 on dark paint to 1.0 on light, darkens it on
  dark cars, matching how OEMs key primer to topcoat.
- **Scratch direction:** brushes run thin at x=0 and pile debris near x=1. The
  slide band is built so +x points against the car's motion, i.e. the way an
  asphalt grain travels across the panel. If in-game shows it reversed, flip
  `SCRAPE_TRAIL_SIGN`.
- **Metal surfaces:** `METAL` can be a guardrail or another car. Until paint
  transfer lands it gets a zinc-grey transfer smear; that phase swaps in the
  other car's colour.
- **Out of scope:** paint transfer from cars, gloss/metal glint, crease
  cracking, grazing-angle fade.

## Brush set (all 512², `.png.dynDecalTexture.json` sidecars)

| Family | Files | Tint | Use |
| --- | --- | --- | --- |
| `scr_rash_m{1,2,3}{a,b}` | 6 | exposure | Slide band, metal panel |
| `scr_rash_p{1,2,3}{a,b}` | 6 | exposure | Slide band, plastic panel |
| `scr_chip_m{1,2,3}{a,b}` | 6 | exposure | Impact, metal |
| `scr_chip_p{1,2,3}{a,b}` | 6 | exposure | Impact, plastic |
| `scr_gouge_m{a,b}`, `scr_gouge_p{a,b}` | 4 | exposure | Hard impact dig-in |
| `scr_pepper_m{a,b}`, `scr_pepper_pa` | 3 | exposure | Gravel |
| `scr_smear_{a,b}` | 2 | surface tint | Transfer / soil / grass streaks |
| `scr_splat_{a,b}` | 2 | surface tint | Mud / grass spatter on impact |
| `scr_haze_0{1,2}` | 2 | haze tone | Scuffed clear under bands (kept) |

Retired: `scr_scrape_*`, `scr_chips_*`, `scr_gouge_0*`.

## Surface routing (GE)

| Surface names | Class | Slide layers | Impact layers |
| --- | --- | --- | --- |
| ASPHALT, ASPHALT_WET, SLIPPERY, ROCK, COBBLESTONE, RUMBLE_STRIP, ICE | road | haze + rash | chip (+ gouge on hard hits) |
| METAL | metal | haze + rash + zinc smear | chip (+ gouge) + zinc smear |
| GRAVEL | gravel | haze + pepper | pepper |
| DIRT, DIRT_DUSTY, MUD, SAND, SANDY_ROAD | soil | soil smear (+ faint haze) | soil splat |
| GRASS | grass | grass smear (+ faint haze) | grass splat |
| SNOW | snow | faint haze | none |
| WOOD | wood | haze + rash (≤ tier 2) + bark smear | chip (≤ tier 2) + bark smear |
| PLASTIC, RUBBER | soft | haze + rubber smear | tier-1 chip + rubber smear |
| *unknown* / missing | road | — | — |

The panel material picks the `m` or `p` brush. `GLASS` and missing values
use `m`.

---

## Tasks

### Task 1: Brush generator rewrite
**Files:** modify `tools/generate_brushes.py`; regenerate `art/dynamicDecals/textures/`.
- Shared depth-field helpers: fbm, Voronoi cells via `scipy.spatial.cKDTree`,
  ragged envelopes.
- A `stack(depth, panel)` function produces premultiplied RGBA. Metal: scuff
  (white, α 0.28) → fractured rim → primer → e-coat → steel. Plastic:
  whitening (α 0.7) → adhesion grey → black plastic.
- Families: rash, chip, gouge, pepper, smear, splat, each at the tiers and
  variants above. Fixed seeds. Draw at 2×, downsample premultiplied, then
  un-premultiply.
- `RETIRED` lists the old names so a rerun deletes them.
- Run: `python tools/generate_brushes.py`. Expect 35 new PNGs + sidecars.

### Task 2: Brush preview tool
**Files:** create `tools/preview_brushes.py` (repo-only; `tools/` never ships).
- Composites every brush over blue/red/white/black paint at the painter's
  tints. It first downsamples the brush to the paint canvas's resolution
  (~1.5 mm per texel at its typical in-game size), so detail that can't
  survive in game is visible here.
- Writes `bench/brush_preview.png` (gitignored).

### Task 3: Harness checks first (failing)
**Files:** modify `tools/sim/harness.lua`.
- Mock `setDecalTexturePath("color", p)` to remember `p`, and have
  `getDecalData` stamp it on the layer as `layer.tex`. Record every baked
  layer.
- New checks:
  1. A slide on ASPHALT with a METAL node: the GE stream carries
     `s="ASPHALT"`, `b="METAL"` and a numeric `f`.
  2. An impact event carries surface and body.
  3. 15 kN impact, road/metal → bakes a `scr_chip_m` layer. 900 N →
     `scr_chip_m1`.
  4. Impact with body `PLASTIC` → `scr_chip_p`, never `_m`.
  5. Impact on GRASS → `scr_splat_`, no chip.
  6. Slide stream on DIRT → `scr_smear_` only, no rash.
  7. Slide on ASPHALT → `scr_rash_` + `scr_haze_`.
  8. `paint.allBrushPaths()` → every path exists on disk with a sidecar.
  9. A legacy payload without surface/body fields still paints (road/metal).
- Run: `lua tools/sim/harness.lua`. Expect the new checks to FAIL.

### Task 4: Detector payload
**Files:** modify `lua/vehicle/extensions/auto/scratches_detect.lua`.
- Event record gains fields 9 (`surfaceName`) and 10 (`bodyName`); the
  serializer adds `,%q,%q`.
- Stream entries gain `surf`, `body` and `fmax`. `flushStream` serializes
  `{s=%q,b=%q,f=%.0f,{pt},{pt}...}`. The array part stays the points, so
  `#points` still works. The 1-point fallback event also carries surf/body.
- Run the harness: checks 1–2 pass.

### Task 5: Painter routing
**Files:** modify `lua/ge/extensions/scratches/paint.lua`.
- Replace the brush tables and `lineTone` with: the `SURFACES` table (name →
  class, tint, alpha), `srgb()`, `exposureTint()`, `pickTier()`,
  `brushPath()`, and `M.allBrushPaths()`.
- `styleForEvent` → `impactStamps(force, surf, body)` returns a list of stamp
  opts. `enqueueImpact` enqueues each one.
- `ingest` reads `e[9]`/`e[10]` and stream `.s/.b/.f`, passing them into
  `enqueueSlide`. Slide severity comes from force.
- `enqueueSlide` builds the band with +x along `-dir * SCRAPE_TRAIL_SIGN`.
  `enqueueStreamLocal` stores `class/panel/tint` on the band.
- `runStreamJob` asks `bandLayers(band)` for whole-band and per-segment
  layer specs.
- The job's layer count is stored as `job.layers`, and the flush budget uses
  it.
- `markStats[class .. "/" .. panel]` counters go into `getStats` and the
  debug report, and `resetPaintStats` clears them.
- Update `probeBrushes` to the new set.
- Run the harness: all checks pass.

### Task 6: Docs
**Files:** `README.md` (Using the mod, How it works → Painting, Known issues
on colour calibration), `docs/plans/2026-05-21-release-roadmap.md` (6.1/6.2
entry).

### Task 7: In-game verification (Vulkan)
- `python tools/dev.py launch --game-arg=-gfx --game-arg=vk`
- `python tools/bench.py run all --tag material-aware`
- Check the screenshots for:
  - colours as authored (primer light grey, e-coat near black)
  - no seams
  - scrape direction
  - plastic bumpers not silver
  - grass/dirt runs leave smears, not scrapes
- Confirm cost is unchanged against the last run in `bench/runs/index.csv`.

**Result (2026-10-18, sunburst2 on gridmap_v2, Vulkan):**

- Brush colours come through as authored: black plastic reads near-black and
  the e-coat dark grey. Primer picks up a blue sheen from the static clear coat
  (a known limit).
- Scrape direction is correct: debris piles at the rear of each band on a
  forward slide. `SCRAPE_TRAIL_SIGN` stays 1.
- Three problems turned up, all fixed (commit `d46d54a`):
  1. Every mark drew at **half size**. `setDecalScale` takes the full size,
     and the painter passed half-sizes; this predates the plan.
  2. A side slide on a rally config touches almost only **plastic flares and
     skirts**. Those now paint as metal; only bumper-cover parts get the
     plastic look.
  3. A **hood-long stripe** came from the ±0.5 m projection depth (also on
     master). Depth is now ±0.2 m.
- Painter cost is unchanged against master on sideslide and nosedive.

### Commits
One per task (generator + art, preview tool, harness, detector, painter,
docs).
