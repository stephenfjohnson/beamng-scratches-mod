# Investigation #4 — Crash-damage realism

**Date:** 2026-10-18
**Build investigated:** 0.39.4 (game source under `E:\SteamLibrary\steamapps\common\BeamNG.drive\`)
**Question:** what does real crash damage look like, how far is the mod from it,
and what can the engine actually do about the gap?

---

## Summary

Real wrecks keep most of their paint. Scratches, paint loss and transfer sit
where something actually touched the car (*contact* damage). Panels that
merely buckled away from the contact keep their paint (*induced* damage),
apart from cracking along sharp folds. That supports the mod's
collision-driven design, and the dropped deformation scanner (see memory
`project_no_deformation_scanner`).

The gap is in what the marks look like, not where they go:

| Real damage | Mod today |
| --- | --- |
| Look depends on what was hit: asphalt rash, mud/grass smear, guardrail zinc, other car's paint | Same grey marks on every surface. The detector knows the surface material but doesn't send it to GE |
| Plastic bumpers whiten, then show black plastic. Never silver | Bumpers get primer/bare-metal silver like steel panels |
| Paint exposes in nested bands: milky clear → matte colour → primer → near-black e-coat → steel | One flat tone per decal (primer *or* metal); no e-coat band |
| Light taps leave only haze, transfer or whitening | 800 N impacts already chip to primer/metal |
| Slides go through the ~0.1 mm stack within centimetres; longer slides make the band *wider*, not deeper | Severity rises with slide distance (`dist/3`) |
| Scratches are asymmetric: thin start, debris piled at the end | Scrape brushes fade symmetrically at both ends |
| Scuffs show mostly as gloss loss | M/R moved off the canvas (paint-seam fix); marks are colour-only, so a haze halo reads as a white puff |
| Car-vs-car: the other car's colour smeared on top, plus black rubber | None |

A look-dev render made during this investigation (not in the repo) built each
mark from **one damage-depth field thresholded into the paint stack**. The
layers below the basecoat (primer, e-coat, steel) don't depend on body colour,
so a full-colour brush carries all of them in one decal at today's layer
count. Only the haze and transfer layers need a per-car tint.

---

## Part A — Real-world field guide

Sources are cited inline. **[inf]** marks inference rather than a source.

### Paint stack (steel/aluminium body panels)

| Layer | Dry film | Exposed look |
| --- | --- | --- |
| Clearcoat | ~40–45 µm | Whitish haze or lines from scattered light; colour unchanged ([EngineerFix](https://www.engineerfix.com/what-does-a-clear-coat-scratch-look-like/)) |
| Basecoat | 10–25 µm | Body colour, matte |
| Primer-surfacer | 25–45 µm | White or grey, often keyed to the topcoat shade ([patent](https://patents.justia.com/patent/20060051513)) |
| Cathodic e-coat | 15–20 µm | Smooth black, grey or dark green-grey ([Surface Finishing](https://www.surfacefinishing.com/doc/single-component-liquid-coating-finish-0001)) |
| Zinc (galvanised) | 5–7.5 µm | Dull matte grey [inf] |
| Steel / aluminium | — | Bright jagged silver / whiter silver ([Dr Beasley's](https://www.drbeasleys.com/blog/2011/04/28/surface-science-car-scratches)) |

The total stack is 90–120 µm ([Elementis](https://www.elementis.com/fileadmin/elementis/About_Elementis/03-businesses/Performance_Specialties/Adding_Future/Papers_Leaflets/finntalc/0102030901_Talc_automotive.pdf),
[Ford/NIST](https://www.nist.gov/document/nichols-paintmaterialsandprocessesfromanautomotiveoempersppdf)).
Steep cuts (chips) show the layers as hairline rings. Shallow scrapes feather
the cut, so the bands are mm to cm wide.

**Plastic bumper covers (TPO/PP):** conductive primer, then base and clear,
with no e-coat. The paint is softer and more flexible.
- Shallow scuffs stress-whiten ([PlasticsTech](https://ptonline.com/articles/how-to-prevent-stress-whitening-in-pp-copolymers)).
- Deeper damage shows black, waxy raw plastic ([Consumerist](https://consumerist.com/2007/06/27/how-to-repair-a-plastic-bumper)).
- Direct hits craze the paint into a spiderweb ([forum](https://forums.anandtech.com/threads/any-car-painters-here.2430760/post-37388362)).
- Never silver.

### Damage types that matter for decals

- **Road rash:** wide bands of parallel striations along the slide vector,
  with abraded material "plowed towards and accumulat[ing] at the end of the
  scratches" ([SAE 2015-01-1421](https://saemobilus.sae.org/papers/directionality-rollover-damage-abrasions-2015-01-1421)).
  Each roll adds a new set of angles ([Advocate](https://www.advocatemagazine.com/article/2016-october/roadway-and-vehicle-evidence-in-rollover-collisions)).
  Paint is stripped on crowns and survives in hollows [inf].
- **Chips/flakes:** angular and stepped, showing nested layer rings. In
  crashes they cluster along fold lines [inf].
- **Crease cracking:** sharply creased or stretched panels crack their paint
  along the ridge ([BodyShop Business](https://www.bodyshopbusiness.com/working-magic-paintless-dent-repair-pdr/)).
- **Paint transfer:** the other object's colour, streaky and feathered,
  sitting *on top of* the clear ([Chemical Guys](https://www.chemicalguys.com/blogs/exterior-how-tos/how-to-remove-paint-transfer-from-car)).
  A galvanised guardrail leaves zinc residue and paired impressions about
  18 cm apart ([TAR](https://tarorigin.com/ARnews/ARnews9-98/0365.html)).
- **Gouges:** a metal-deep groove with raised lips and debris at the end. Lug
  nuts leave repeating loops ([SAE 2008-01-0179](https://saemobilus.sae.org/content/2008-01-0179)).
- **Dents without paint loss:** show only as reflection distortion.
  BeamNG's soft-body already does this.
- **Dirt, mud and grass:** brown or green-brown matte smears and spray fans,
  low on the body and behind the wheels [inf].

### By surface [inf except where cited]

| Hit | Mark |
| --- | --- |
| Asphalt | Dense fine parallel striations, dark grime, through to primer/metal fast |
| Concrete barrier | Broader, flatter abrasion; grey dust; long straight band at barrier height |
| Gravel | 1–3 mm chip peppering, low on the body |
| Grass / dirt / mud | Little paint loss; soil smears and spray |
| Guardrail | Zinc transfer and paired horizontal bands ([TAR](https://tarorigin.com/ARnews/ARnews9-98/0365.html)) |
| Another car | Its paint colour smeared on, black rubber, wheel loops |
| Tree / pole | Narrow vertical crush band, few scratches ([Herts](https://researchprofiles.herts.ac.uk/en/publications/structural-crashworthiness-analysis-of-a-pickup-truck-subjected-t/)) |

### Contact vs induced damage

*Contact* damage carries scratches, paint removal and transfer. *Induced*
damage is deformation only
([Taylor & Francis](https://www.taylorfrancis.com/books/9780429074196/chapters/10.1201/b15542-26)).
Gradient from the epicentre outward [inf]:

1. Torn or bare metal and gouges.
2. Fold-line cracks and flakes (primer, e-coat).
3. Scattered chips.
4. Haze and transfer halo.
5. Clean paint.

Low-speed taps (Part 581: 2.5 mph front/rear, 1.5 mph corners) leave only
haze, transfer and whitening on bumpers
([CFR 581.5](https://www.gpo.gov/fdsys/pkg/CFR-2011-title49-vol7/pdf/CFR-2011-title49-vol7-sec581-5.pdf)).

### What reads as fake

- No coherent direction.
- Symmetric scratch ends.
- Single-tone marks.
- Silver on plastic.
- Uniform noise everywhere instead of placement that follows the hits.
- Stretched projection at grazing angles: fade by angle
  ([Unity tracker](https://issuetracker.unity.com/issues/15719/the-projected-decals-contain-stretch-like-artifacts-when-used-on-curves-or-edges)).
- Colour change where real damage is gloss change.

---

## Part B — Engine capabilities (0.39.4 source)

### Car-vs-car contact

- **Does `onNodeCollision` fire for it?** Probably. Collision triangles carry
  ground models (`lua/vehicle/jbeam/stage2.lua:491-493`; pigeon tags metal
  ×18 and plastic ×20). `particles.json:47` has a METAL-on-METAL spark row,
  which can only match a node hitting another car or a metal prop.
- **Material IDs:** METAL=2, PLASTIC=3. Argument order for plastic-node-on-
  metal-triangle is unverified (`particles.lua:67-71` sorts IDs).
- **Which car:**
  - GE: `map.objects[vehId].objectCollisions[otherId] == 1` (`lua/ge/map.lua:3810-3826`).
  - Vehicle Lua: `mapmgr.objectCollisionIds` (`lua/vehicle/mapmgr.lua:115-117`).
  - Neither is per node, so match by timing.
- **The other car's paint:**
  - Object fields `veh.color`, `veh.colorPalette0`, `veh.colorPalette1` (Point4F).
  - Full PBR: `core_vehicle_manager.getVehicleData(id).config.paints[i]`
    (`core/vehicle/colors.lua:74-82`).
  - Probably safe to pass straight to `setDecalColor` (the decal editor does).

### Beam signals

- Extension hook `onBeamBroke(id, energy)` (`lua/vehicle/main.lua:360`).
  Note the name: not `onBeamBroken`. Reliable.
- `onBeamDeformed` (`main.lua:367`) fires only for beams with a
  `deformationTriggerRatio`, which are mostly glass, lights and driveshafts,
  not body panels.
- Location helpers:
  - `obj:getImpactDeformEnergyNode()` returns the impact node, energies and both materials (`sounds.lua:224`).
  - GE `veh:getSectionBeamDamage(i)` / `getSectionCollisionDamage(i)` cover a 27-cell grid (`gameplay/util/damageAssessment.lua:210-235`).
  - `damageTracker.getDamage("body", zone)` covers six zones.

### Dynamic decals

- **Layer types:** decal 0, fill 1, textureFill 2, group 3, brushStroke 4,
  path 5, linkedSet 6 (`editor/api/dynamicDecals.lua:784-792`).
- **Blend modes:** Clear, Normal, Add, Subtract, Multiply, Eraser. Add,
  Subtract and Multiply affect colour only; normal and M/R fall back to
  Normal (`combine.cs.hlsl:106-129`).
- **`setDecalColor`** multiplies straight into the colour texture
  (`decal.ps.hlsl:211`, `:305`). A white tint therefore shows a full-colour
  brush as authored.
- **`colorPaletteMapId` 1–3** makes the decal take the car's own paint
  (`decal.ps.hlsl:407-414`).
- **Normal channel:**
  - The decal shader writes one (`decal.ps.hlsl:72`, `:306`), but `normalIntensity` is unused.
  - No `.skin.dynamicTextures` material reads it. All 57 bind only BaseColor, ColorPalette, Metallic and Roughness.
  - Normal-map dents would need a custom material per car. Not worth it: the soft-body deforms real geometry.
- **Clearcoat:** not writable from decals. The skin material has a static
  clearcoat (factor 1, roughness 0.06) over everything, including exposed
  "metal".
- **Fill layers** write baseColor only (handoff doc). Whether `textureFill`
  can carry M/R is still untested.

### Built-in damage visuals

- No dirt or damage mask exists in vehicle materials or shaders.
- `veh:setMeshPaintData(mesh, ColorI(roughness, metallic, clearcoat,
  clearcoatRoughness)×3)` overrides paint per mesh (`vehicle/partCondition.lua:297-301`).
  It could dull a whole panel, but probably only the palette-coloured areas.

---

## Open hypotheses (need the game)

1. **Metallic back on the canvas without seeding.** A `clearBakedTextures`
   wipe may leave the dynamic metallic canvas at 0, and the factory metallic
   the mod now binds is `_zero.png` anyway. If so, re-binding `metallicMap`
   to `@DynamicTextureMetallic` needs no seed, and bare-steel marks could
   write metallic 1. Test: wipe, re-bind, look for seams.
2. **Gloss loss via clearcoat roughness.** Bind the dynamic roughness canvas
   to the clearcoat-roughness slot instead of base roughness. A wiped
   canvas (0) would then be factory gloss, and scuffs would write matte. That
   would make the haze halo read as gloss loss rather than a white puff.
3. **Car-vs-car material IDs.** Log `(mat1, mat2)` and `objectCollisions`
   during a deliberate car-on-car scrape to confirm the order and IDs.
