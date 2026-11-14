# Milestone 4: scratch and impact polish



Work starts at merged milestone 3 `2e9fffe`. Milestone 5 and stable release are

outside this thread. The target remains the private ETK 800 main-body adapter,

empty Paint Design or stock Police; no new body/vehicle compatibility is implied.



## Selective prior-art review



- `t3/improve-wreck-scratches-dings` (`b4e4036`): selected the seeded nested-depth

  raster algorithm (primer, dark coating, sparse highlights) into

  `tools/generate_damage.py`. Ten new named brushes avoid stale engine caches.

  No detector, livery replacement, transfer/soil or material-class heuristics

  were imported. Plastic/metal classification is not certified here.

- `t3/mod-review-improvements` (`e93737c`): reviewed node-local packets,

  `ingestContacts`, node anchoring and queued layer pinning. This replaces both

  sides of the collision protocol and predates wheel soil/water integration;

  not transplanted wholesale. This milestone reduces contact jitter and band

  extent while retaining the current projection architecture. Deformation-time

  drift and hull-camera approximations are still limits.

- `t3/council-crash-realism-loop` (`37ddfeb`): reviewed its material-channel

  reassignment, contact-front scanner, impact composition and handoff. Its

  factory-material rewrites and multi-layer replacement are incompatible with

  the current preservation contract. The useful principle of restraining haze

  and localizing damage is applied without those mutations or extra scans.



## Final implementation



Four scrape and four chip variants, plus two gouges, carry irregular nested

color detail in a single existing decal. A family-keyed alternate choice avoids

immediate repeats even when haze selection intervenes. Existing brushes remain

for legacy developer probes. Seeded generation is byte-reproducible.



Impact scale is 0.045–0.13 before existing wobble (nominal 9–26 cm across),

gouges 0.025–0.08; bands are 18–42 cm long and 5.5–11 cm wide. Position jitter

falls from 3 cm to 8 mm. Slide orientation still follows displacement projected

onto the contact plane. Impact orientation is still randomized: there is no

new per-contact slip-vector protocol. Haze alpha falls to 0.05–0.09.



The ETK damage stage uses a 0.75 diffuse factor (0.15 for plain paint with

primary luminance >= 0.5, sampled only at setup/reset), while coverage remains

sampled from the original brush canvas. This darkens visible marks without

reducing coverage again. The soil stage explicitly keeps factor 1. Original

paint/livery stages, material maps, stage count, editor ownership, water sensor,

wash target and damage persistence architecture remain unchanged. Roughness

stays 0.65, metallic/clearcoat response zero on the damage stage. There are no

new per-frame scans, texture targets, projections or extra per-impact layers.



## Rejected experiments (retained as real engine evidence)



Both [roughness-mask](../docs/evidence/milestone4/rejected-roughness-mask/shot_1_left.jpg)

and [metallic-mask](../docs/evidence/milestone4/rejected-metallic-mask/shot_1_left.jpg)

experiments obscure Police lettering. Installed

`shaders/common/dynamicDecals/combine.cs.hlsl` clears both scalar canvases to 1;

using either directly as opacity is invalid. Original-stage field equality

alone did not detect this. Those changes were reverted. The original baseline

[sideslide](../docs/evidence/milestone4/baseline/shot_1_left.jpg) shows the bright

brush-like marks being addressed. Its separate physics run is not a pixel-matched

old/new comparison.



An intermediate diffuse factor 0.45 made dark marks too weak. Those captures

are exploratory, not final acceptance. Color-derived coverage remains a known

constraint; dark fine detail is weaker, and white paint needs careful viewing.

This is not physical fracture, real exposed-metal shading or new dent geometry.



## Engine and capture protocol



BeamNG 0.40.5.0 x64 build 302427, D3D12, RTX 3090, Windows 11. See

[renderer log](../docs/evidence/milestone4/build-renderer.txt). Gridmap v2,

3840x2160 Custom, Ultra lighting, High shaders, Normal textures, SMAA, dynamic

reflections on. Genuine unretouched 1920x1080 engine screenshots (0.5 scale).

`vehicles/etk800/rennspecht_8r_A.pc` with plain/stock Police explicitly selected.

All three paints use RGB 0.025 (dark) or 0.75 (light); other PBR paint properties

are retained and recorded in each JSON.



Bench sideslides and roof drops use actual physics, not injected collision events.

The bench uprights the vehicle for photography without repairing deformation.

`tools/damage_probe.py` freezes simulation and keeps camera/pose/light settings

fixed while showing damage, the original two stages alone, and cleared cosmetics.

Thus each pair isolates rendering on the same car, not different collision runs.

Minor temporal cloud/reflection/HUD differences remain possible. The original-stage

view is not a separately spawned untouched stock car. Original material fields

are independently compared against the source and must match. Source hashes are

stored beside final captures.



## Acceptance evidence



All cases below include matched damaged/original-stage/reset PNGs and raw JSON.



| Case | Damage | Original stages | Reset | Record |

| --- | --- | --- | --- | --- |



| Dark plain slide | [damage](../docs/evidence/milestone4/accepted-plain-dark/damaged.png) | [original](../docs/evidence/milestone4/accepted-plain-dark/original-stages.png) | [reset](../docs/evidence/milestone4/accepted-plain-dark/reset.png) | [JSON](../docs/evidence/milestone4/accepted-plain-dark/state.json) |

| Light plain slide, final tone | [damage](../docs/evidence/milestone4/tone-plain-light/damaged.png) | [original](../docs/evidence/milestone4/tone-plain-light/original-stages.png) | [reset](../docs/evidence/milestone4/tone-plain-light/reset.png) | [JSON](../docs/evidence/milestone4/tone-plain-light/state.json) |

| Dark Police roof impact | [damage](../docs/evidence/milestone4/accepted-police-dark-roof/damaged.png) | [original](../docs/evidence/milestone4/accepted-police-dark-roof/original-stages.png) | [reset](../docs/evidence/milestone4/accepted-police-dark-roof/reset.png) | [JSON](../docs/evidence/milestone4/accepted-police-dark-roof/state.json) |

| Light Police slide | [damage](../docs/evidence/milestone4/accepted-police-light/damaged.png) | [original](../docs/evidence/milestone4/accepted-police-light/original-stages.png) | [reset](../docs/evidence/milestone4/accepted-police-light/reset.png) | [JSON](../docs/evidence/milestone4/accepted-police-light/state.json) |

| Police nose impact | [damage](../docs/evidence/milestone4/impact-police/damaged.png) | [original](../docs/evidence/milestone4/impact-police/original-stages.png) | [reset](../docs/evidence/milestone4/impact-police/reset.png) | [JSON](../docs/evidence/milestone4/impact-police/state.json) |



The final light-paint adjustment supersedes `accepted-plain-light`, whose early

folder name is historical, not final visual acceptance. Its first pass was too

pale and had a 1098 ms projection stall. The final repeat (`tone-plain-light`)

shows restrained gray scuffs on the doors/fender, peaking at 60.9 ms. Dark paint

shows smaller gray chips/scuffs without the old white brush puffs. Police

lettering remains readable. Roof/nose impacts remain conservative: small marks

are visible around hood/bumper contacts; the crushed roof is still too clean in

places. Stock glass breakage/deformation is not a mod improvement.



[Raw run summary](../docs/evidence/milestone4/run-summary.json) retains all final

scenario counters/timings; each folder also has the bench report, frame samples,

front and top photographs. Final dark/plain/Police runs drain every queue with

no failed jobs. Most retained final peaks are 50.7–62.3 ms. An earlier roof pass

peaked at 605.7 ms; subsequent roof repeats peaked at 79.1 and 54.0 ms. These are

whole painter CPU timings, not GPU or FPS guarantees. Outliers occur inside

projection, not growing queues; their root cause is not established. Do not

infer a performance improvement from different collision outcomes or warm caches.



Water evidence: [mud cleaning](../docs/evidence/milestone4/accepted-water/water.json)

records 36 deposits, shallow unchanged, partial attenuation, full removal, pause

invariance, drying to original fields, and 26 fresh deposits. The first camera

was on the opposite side from the slide, so it establishes soil behavior but is

not used as scratch-persistence proof. The separate

[persistence run](../docs/evidence/milestone4/persistence/water.json) starts with

an actual sideslide, moves the same damaged car with `setClusterPosRelRot` (no

reset), rolls through real mud, and photographs the scratched left side while

washing. The WaterBlock is restored afterward. No collision/sensor values are

fabricated; assisted rolling and temporary water relocation are test fixtures.



`python tools/package.py`: **222 mock checks**, syntax/globals and sidecars.

`python tools/check_damage_evidence.py` checks recorded material, queue and water

invariants; screenshots are reviewed separately. Brush regeneration is byte-identical.

Source hashes in captures identify deployed Lua. The last adaptive tone change

only affects light plain paint; the retained dark/Police matrix precedes that

change and its identical dark/Police behavior is also exercised in the final

nose-impact and persistence runs. No renderer/build switch occurred.



## Limits



Only the narrow ETK configuration has been tested. The roadmap's broader body-type

coverage is not claimed; other designs remain skipped and legacy plain vehicles

remain unverified. Repeated silhouettes are reduced, not eliminated. Small marks

and light-on-light scuffs can be subtle; severely crushed panels may remain too

clean because projection geometry is approximate. No induced-damage scanner,

paint transfer, normal-map gouges or generic compatibility is added.



The shared limits remain 160 inputs, 64 queued jobs, 6 projection passes/flush,

6 baked layers/frame, 96 soil attempts and bounded per-cell counts. New brushes

add ten 512x512 RGBA assets, not runtime history or a new render target. This is

not GPU-memory, long-session or broad frame-time certification. Projection/bake

stalls remain milestone 5 work; no stable release is made.



## Completion

Within the explicitly scoped ETK configurations, milestone 4 visual-polish
acceptance passes with the limitations above. This completes this feature/run,
not the release sequence. No milestone 5 work, broad compatibility claim or
stable release is included. The persistence pair visibly retains the gray rear
quarter and front-fender marks after the brown soil disappears:
[dirty](../docs/evidence/milestone4/persistence/dirty.png),
[dry after wash](../docs/evidence/milestone4/persistence/dry.png).
