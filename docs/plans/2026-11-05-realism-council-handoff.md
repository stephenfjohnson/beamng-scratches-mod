# Handoff: paint-damage realism loop (council review)

Date: 2026-11-05. Paused by the user to preview and re-set the goal.

Goal that drove this work: best-in-class scratches and paint damage on top of
BeamNG's own deformation, matched against five real crash photos, through an
automated loop - crash the car in game, photograph it, compare with the
references, and have a review council (T3 delegated reviewers) judge and
steer each round.

## Where things are

- Worktree `C:\Users\sforr\.t3\worktrees\beamng-scratches-mod\t3-284d6534`,
  branch `t3/council-crash-realism-loop`. **Nothing is committed** (about 50
  changed/new files on top of `0ae029b`).
- Harness `"C:\Program Files (x86)\Lua\5.1\lua.exe" tools/sim/harness.lua`:
  169 checks, all passing. `python tools/package.py` preflight green.
- `bench/` is gitignored and lives only in this worktree. It holds the
  reference photos (`bench/reference/ref1..5_*.png` - keep them), every council
  round (`bench/council/roundN/BRIEF.md`, `RESULTS.md`, evidence JPGs), bench
  runs (`bench/runs/`) and scratch patch scripts (`bench/scratch/`).
- README.md is up to date with the current behaviour.

## Scores (overall /10, paint damage only)

| Round | Claude Opus | GPT Sol | Notes |
|---|---|---|---|
| 1 | 1 | 1.2 | |
| 2 | 4 | 3.2 | |
| 3 | 4.5 | 3.6 | |
| 4 | 5 | 4.3 | |
| 5 | 5.5 | 4.8 | |
| 6 | 6 | 5.1 | |
| 7 | 5.5 | 4.6 | new `cornerscuff` test exposed ref 1 (not a regression) |
| 8 | 5.5 | 4.7 | Claude: shippable on code; Sol: no (both its findings since fixed) |
| 9 | - | - | brief + evidence ready; review cancelled when paused |

Per reference (round 8, Claude/Sol): ref1 corner scuff 4/2, ref2 bumper streaks
7/6.5, ref3 silver side scrape 6/6.5, ref4 gouge 4.5/4.5, ref5 crushed door 4.5/4.

## The loop (how to run a round)

1. Change code; run the harness; `python tools/package.py`.
2. Evidence (game running on Vulkan; `tools/dev.py status`):
   - `python tools/bench.py car etk800_blue` then `gallery --tag rN` and
     `run ref --footage --tag rN`
   - `python tools/bench.py car etk800_silver`, `gallery --tag rN_silver`,
     `run {cornerscuff,wallscrape,carswipe,cornerpost} --tag rN_silver`
   - Each run folder has `sheet.jpg` (reference photos on top), `shot_*`,
     `footage.jpg`, `report.md` (with a **Placement** line: deepened, gap drops,
     unmeasured, re-aims, retracted, lampSnapped, overshoot bins).
3. Copy sheets/macros/footage into `bench/council/roundN/`, add before/after
   crops (`cmp_*.jpg`, see earlier rounds' scripts in `bench/scratch/`), write
   `BRIEF.md` (template: round9/BRIEF.md - read-only rules, changes, evidence,
   the five asks, reply format).
4. Two `delegate_task` reviews (role review), same task text, pointing at the
   brief:
   - Claude: `providerInstanceId claudeAgent`, `model claude-opus-5-5`,
     options `effort high`, `fastMode false`.
   - Sol: `providerInstanceId codex`, `model gpt-6.1-sol`, option
     `reasoningEffort high`.
   - Gemini (third seat) is unavailable: T3's `antigravity` provider lists no
     models. The user has to enable/sign in to Antigravity in T3 Code.
5. Record `RESULTS.md` (scores table, shared gaps, findings), fix, repeat.
   Every fix gets a harness check that fails on the old code (mutation-check).

Prototyping while a review is running: bench/dev scripts deploy from the
folder they run in, so copy the worktree to a sibling folder (outside git,
excluding `bench/runs`), work and run the bench from there, and merge back
once the review returns. Deploy from the worktree afterwards.

## What's built (pointers)

- `lua/vehicle/extensions/auto/scratches_detect.lua` - contact detector:
  impacts (with slide direction; falls back to the car's velocity along the
  surface, minus vertical bounce, when the node has stopped), slide streams,
  brief slides (one-point fallback with slip direction), lamp contacts snapped
  to the nearest paintable node at rest (`findLampSnap`), body-node list for
  car-on-car.
- `lua/ge/extensions/scratches/paint.lua` - the painter:
  - Damage layer (`setupDamageLayer`): canvas roughness = "paint intact",
    canvas metallic = exposed roughness; looks in `damageLook`
    (haze, abrasion, scuff, primer, chip, metal, plastic, transfer;
    `LOOK_DEPTH`).
  - Composition: `enqueueImpact` (glancing: abrasion/haze patch, drag
    streaks, chips, gouge; square-on: crush scuff, chips), `enqueueSlide` /
    `enqueueStreamLocal` / `runStreamJob` (scrape bands), car-on-car
    (`updateCarContacts`, contact front only).
  - Claims (`newClaim`/`stampSettled`/`claimDone`): spots + mark log settle at
    bake, reconcile to what baked, retract when nothing did; `dropJob(s)` on
    every drop path.
  - Projection (`runClusterJob`): clusters keyed by camera face; camera aimed
    through a real contact; overshoot read once per pass; compensation along
    the camera axis; borrowing within 15 cm; hole readings retried (8 cm nudge
    toward the car's middle, then the nearest hull face, then revert).
- `tools/generate_brushes.py` - all brush art (haze, streak, drag, gouge,
  chips, smear) + detail maps; every PNG needs its `.dynDecalTexture.json`.
- `tools/bench.py`, `tools/ingame/scratches_bench.lua` - scenarios (ref set:
  cornerscuff, cornerpost, wallscrape, poledoor, rearpost, tbone, carswipe),
  gallery, contact sheets, footage.

## Engine facts learned (see also memory notes)

- `getDecalData().decalPos` is ONE hit per projection pass (screen centre at
  project time); `setDecalLocalPos` moves only the cursor; `Engine.castRay`
  misses vehicles. Hence the aimed camera.
- A decal is a depth box; `setUseSurfaceNormal(false)` lays it along the
  camera axis (verified on a flat panel).
- Lua 5.1/LuaJIT: max 200 locals in a chunk. The painter's main chunk is near
  the cap; group new constants into tables (`SPOT`, `GAP`, `IMPACT`, ...).
- Python text-mode writes produce CRLF on Windows; `core.autocrlf=true`
  normalises on commit (mixed endings in the working tree are harmless).
- D3D12 drops decal draws: run the game on Vulkan.

## Open gaps (reviewers' current list)

1. Ref 1 corner scuff: a walking-pace bumper-corner clip gives BeamNG only
   1-4 qualifying contacts (static friction at the post; many ticks below
   thresholds), so little paint lands. The bollard scenario is
   physics-sensitive (0.32 m offset stops the car, 0.37 m misses; 0.345 used).
   A "drag along a low wall" scenario was tried (barely touched) and not kept.
2. Ref 5 crushed panels too clean: a crease-scuff attempt (thin scuff lines
   per 30 cm cell on hard metal crushes) drew crossed white lines and was
   dropped. The deformation-scanner route was rejected earlier - don't revive
   it without the user's say-so.
3. Bands: better (sparse, tapered, no haze slab under light bands) but still
   somewhat stamped; silver scores could pair dark lines with lighter dulling.
4. Gouge: wide core + torn lip landed in round 9 (not yet reviewed).
5. Judgement calls for the user: the matte "abrasion" look on light rubs; how
   visible a gentle corner clip should be.

## To resume in a new session

1. Read this file, `README.md`, `bench/council/round8/RESULTS.md` and
   `round9/BRIEF.md` + `RESULTS.md`.
2. Start the game on Vulkan with MCP (`python tools/dev.py launch`), check
   `python tools/dev.py status`, run the harness.
3. Either rerun round 9 from its folder (evidence is current except the
   round-9 nudge retry), or regenerate evidence and write round 10.
4. Decide with the user whether to commit this work first.
