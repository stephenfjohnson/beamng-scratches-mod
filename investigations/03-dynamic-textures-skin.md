# Investigation #3 — Dynamic Textures skin (vehicle wiring)

**Build investigated:** 0.38.5.0 build 19602
**Status:** Skin format fully reverse-engineered. The hard gate is real (40 of ~70 vehicles support it; the rest are silently incompatible). One important plan delta: only 4 PBR channels are dynamically writable — **`baseColor`, `colorPalette`, `metallic`, `roughness`** — *no `@DynamicTextureNormal`*. Plan's per-scratch normal mask must be revised.

---

## 0. Coverage: which vehicles support dynamic textures

40 of the vanilla vehicles ship with a `vehicles/{name}/dynamicDecals/` subdirectory inside their zip:

```
atv, autobello, barstow, bastion, bluebuck, bolide, burnside, bx, citybus, covet,
dryvan, dumptruck, etk800, etkc, etki, fullsize, hopper, lansdale, legran,
md_series, midsize, midtruck, miramar, moonhawk, nine, pessima, pickup, pigeon,
racetruck, roamer, rockbouncer, sbr, scintilla, sunburst2, us_semi, utv, van,
vivace, wendover, wigeon
```

Vehicles **without** the subdir (props, simple objects, some special vehicles like `simple_traffic`, `unicycle`, etc.) cannot use the dynamic decals system; the API will load and not crash, but no surface gets painted.

**Notable exception:** `md_series` ships its part as `md_series_TEMPORARILYDISABLED_skin_dynamicTextures` — i.e. defined but inactive. So the count of *currently-selectable* dynamic-decals vehicles is 39. Reason isn't documented in the file; likely a UV/multi-material issue Beamng is still resolving.

For Phase 2 testing, the **Pigeon is the ideal first target** — single body material, simplest layout, fastest to iterate.

## 1. The skin part — JBeam side

`vehicles/pigeon/dynamicDecals/main.jbeam` (264 bytes total):

```json
{
  "pigeon_skin_dynamicTextures": {
    "information": {
      "authors": "BeamNG",
      "name": "Dynamic Textures",
      "isAuxiliary": true,
      "value": 1350
    },
    "slotType": "paint_design",
    "globalSkin": "dynamicTextures"
  }
}
```

That's the entire definition. Key fields:

- **Part name** follows the convention `{jbeam}_skin_dynamicTextures` — exactly what the editor's check expects (`dynamicDecalsTool.lua:646`).
- **`slotType: "paint_design"`** — slots into the vehicle's `paint_design` slot, replacing the default factory paint design.
- **`globalSkin: "dynamicTextures"`** — instructs the materials system that wherever a material has a `.skin.dynamicTextures` variant, use *that* variant instead of the default. This is the key wire: it's how a single skin choice swaps every body material on the vehicle to its `dynamicTextures` flavor.
- **`isAuxiliary: true`** — selectable but optional (won't be auto-installed).

Multi-material vehicles add one more field, `dynDecalMaterials`. From `vehicles/md_series/dynamicDecals/main.jbeam`:

```json
"dynDecalMaterials": ["pickup", "md_series_main", "md_series_main_alt"]
```

This is the **canonical list of materials the dynamic-decals system should bind to**. `findPartMaterials()` in `dynamicDecals.lua:1367` reads it and feeds the names into `addMaterialIdx()` for each. Without `dynDecalMaterials`, the api falls back to a heuristic (find a material whose name ends in `_main` or `_body`) — which works for single-material vehicles like the Pigeon but is brittle for anything with separate front-bumper, hood, fender materials.

**For our mod's authored test skin (Phase 4) we will explicitly declare `dynDecalMaterials`** even on single-material vehicles, to remove the heuristic dependency.

## 2. The materials.json — where the magic lives

`vehicles/pigeon/dynamicDecals/main.materials.json`:

```json
{
  "pigeon.skin.dynamicTextures": {
    "name": "pigeon.skin.dynamicTextures",
    "mapTo": "pigeon.skin.dynamicTextures",
    "class": "Material",
    "Stages": [
      {
        "ambientOcclusionMap": "/vehicles/pigeon/pigeon_main_ao.data.png",
        "baseColorMap": "/vehicles/pigeon/pigeon_main_b.color.png",
        "metallicFactor": 1,
        "roughnessFactor": 1,
        "metallicMap": "/vehicles/pigeon/pigeon_main_m.data.png",
        "normalMap": "vehicles/pigeon/pigeon_main_nm.normal.png",
        "roughnessMap": "/vehicles/pigeon/pigeon_main_r.data.png",
        "useAnisotropic": true
      },
      {
        "ambientOcclusionMap": "/vehicles/pigeon/pigeon_main_ao.data.png",
        "diffuseMapUseUV": 1,
        "colorPaletteMapUseUV": 1,
        "instanceDiffuse": true,
        "clearCoatFactor": 1,
        "clearCoatRoughnessFactor": 0.06,
        "clearCoatMap": "/vehicles/pigeon/pigeon_main_cc.data.png",
        "metallicMap": "@DynamicTextureMetallic",
        "metallicMapUseUV": 1,
        "roughnessMap": "@DynamicTextureRoughness",
        "roughnessMapUseUV": 1,
        "normalMap": "/vehicles/pigeon/pigeon_main_nm.normal.png",
        "opacityMap": "/vehicles/pigeon/pigeon_main_c.data.png",
        "baseColorMap": "@DynamicTextureBaseColor",
        "colorPaletteMap": "@DynamicTextureColorPalette",
        "useAnisotropic": true
      },
      {},
      {}
    ],
    "activeLayers": 2,
    "dynamicCubemap": true,
    "materialTag0": "beamng",
    "materialTag1": "vehicle",
    "order_simset": 0,
    "version": 1.5
  }
}
```

### What this tells us

**Materials format is v1.5, 4-stage capable.** Currently only 2 stages active (`activeLayers: 2`). Stages 2 and 3 are empty placeholders. **The 4-stage paint→primer→metal→clearcoat plan is structurally allowed.**

**Stage 0 = static factory paint**, all maps from disk, default UV layer (UV0 — mirrored).

**Stage 1 = the dynamic-decal layer**, with these `@DynamicTexture*` channels wired in:

| Channel name in materials.json | What we write to it |
| --- | --- |
| `@DynamicTextureBaseColor` | RGB color (the paint-layer recolor — current usage = livery base color) |
| `@DynamicTextureColorPalette` | Palette index (livery palette indexing) |
| `@DynamicTextureMetallic` | Metallic value (0 = dielectric, 1 = metal) |
| `@DynamicTextureRoughness` | Roughness value (0 = mirror, 1 = matte) |

**Important plan delta: there is NO `@DynamicTextureNormal`.** The `normalMap` on stage 1 stays a static disk file (`pigeon_main_nm.normal.png`). Looking through the API surface, the `setDecalTexturePath("normal", path)` setter exists, but the *source brush's* normal map is baked into the metallic/roughness channels (or dropped) — there is no path for outputting a per-pixel normal mask back to the material. **We cannot drive a per-scratch normal map.**

The available output channels are: **`baseColor` (RGB), `colorPalette` (index), `metallic` (scalar), `roughness` (scalar)**. That's effectively 4 + 1 + 1 = 6 free-running scalar channels (R, G, B in baseColor, plus metallic, plus roughness, plus colorPalette index).

**All Stage 1 maps use UV1** — `*UseUV: 1` is set on `diffuseMap`, `colorPaletteMap`, `metallicMap`, `roughnessMap`. UV1 is the non-mirrored livery channel. UV0 (mirrored, used for the diffuse-cost-halving factory paint) is *not* used for any dynamic content. **Plan is correct: UV1 is the canonical livery/decal UV channel and the dynamic decals system already targets it.**

**`opacityMap`** on Stage 1 is a *static* disk file (`pigeon_main_c.data.png`). This is the per-mesh "where can the dynamic layer apply" mask — windows, lights, badges are masked off so we don't paint over them. **We do not author this; the vehicle author already did.**

**`clearCoatMap`** is a static disk file. Defines per-pixel clearcoat factor for the painted body (1 = clearcoated paint, 0 = no clearcoat e.g. on plastic trim).

**`instanceDiffuse: true`** — per-vehicle-instance overrides are enabled. Required for our use case (each vehicle's mask must be unique).

**`useAnisotropic: true`** on both stages — anisotropic shading enabled, important for paint metallic-flake look.

**`dynamicCubemap: true`** — environment reflections enabled.

## 3. Multi-material vehicles — the md_series pattern

`vehicles/md_series/dynamicDecals/main.materials.json` declares *three* materials in one file:

- `pickup.skin.dynamicTextures` (the pickup base, shared)
- `md_series_main.skin.dynamicTextures`
- `md_series_main_alt.skin.dynamicTextures`

Each follows the same 2-stage layout. They all share the same `@DynamicTexture*` channel set — meaning *all three materials read from the same dynamic-texture set on the vehicle.* The `setMaterialIdx`/`addMaterialIdx` calls on `decalProjection` (investigation #1 §2) bind the projection to multiple material indices, and the C++ side composes one set of dynamic textures that all bound materials sample.

**Implication for us:** we don't get separate masks per material on the same vehicle. A multi-material vehicle with both `pickup_main` and `pickup_main_alt` sharing UV1 means a scrape on either contributes to the *same* mask. That's fine for our use case (the bumper and hood damage both compose into the same vehicle's damage texture), and it simplifies memory (one set per vehicle, regardless of material count).

## 4. The 4-stage paint → primer → metal → clearcoat plan, revised

Material format supports `Stages[0..3]` with `activeLayers: 4`. The plan's table:

| Stage | Role | Metallic | Roughness | Clearcoat |
| --- | --- | --- | --- | --- |
| 0 | Bare steel | 1.0 | 0.3–0.5 aniso | none |
| 1 | Primer | 0 | ~0.6 matte | none |
| 2 | Color paint | 0 | ~0.25 | yes |
| 3 | Clearcoat | 0 | layer | clearcoat |

…is structurally achievable, but the **opacity for each upper stage must be a static texture file** (the materials format takes a path, not an expression). The plan calls for *"Upper layer opacities driven by `@DynamicTexture*` mask. Use smoothstep thresholds (NOT step) to avoid cartoon contour bands. Jitter thresholds per-texel with tileable noise…"* — this requires a shader-side computation, but the materials format only does declarative texture sampling. **We cannot do `opacityMap = smoothstep(0.6, 0.8, dynamicMetallic)` in materials.json.**

Two practical workarounds, neither perfect:

### Workaround A — encode thresholds in the brush textures (preferred for v1)

Author each stamp brush as a **radial depth gradient** (bright center, dim edge). Stage 0 (bare metal) is opaque where `@DynamicTextureMetallic > 0.85`; stage 1 (primer) opaque where `> 0.5`; stage 2 (paint) opaque where `> 0.05`. The smoothstep falloff between them comes from the brush texture's own grayscale gradient.

Where the materials format wants a literal texture, we put a *channel of the dynamic texture* directly: `opacityMap = "@DynamicTextureMetallic"`. The engine treats the channel as the opacity. Stage thresholds are then "opacity > 0.5" implicitly via alpha blending, with the brush gradient providing the soft transition.

**Limitation:** all stages use the same channel, so we can only encode ONE depth axis. Multi-axis damage (e.g. dent depth vs scratch density) would need to encode in multiple channels — possible but more complex.

### Workaround B — pre-bake per-stage masks via Lua

Maintain three or four separate baked masks in our painter logic — `paintMask`, `primerMask`, `metalMask` — and compose them ourselves before pushing to the dynamic texture. Each scrape event updates all three masks with depth-appropriate brightness. The materials.json then maps each stage's `opacityMap` to a different `@DynamicTexture*` channel.

This loses one of the four channels (we'd dedicate `Metallic` and `Roughness` to two stages each, leaving only `BaseColor.rgb` for actual color work). Cleaner threshold control, more memory, more Lua-side composition cost.

**Plan delta:** Phase 4 needs to pick A or B before authoring brushes. Default to A. Promote to B if A's transitions look bad.

## 5. The skin selection mechanism

`core_vehicle_partmgmt.setSkin("dynamicTextures")` is what activates the skin. It looks for any auxiliary part with `globalSkin == "dynamicTextures"` in the `paint_design` slot and selects it. This is exactly what the editor calls (`dynamicDecalsTool.lua:631`). **Our painter, on init, must do the same thing** — otherwise our masks have nowhere to render to.

In free-roam, the user can also do this manually via Vehicle → Edit → Paint Design → "Dynamic Textures" — but that's bad UX. Our extension's `onVehicleSpawned` hook should auto-set the skin.

There's a snag for **non-supported vehicles** — `core_vehicle_partmgmt.setSkin("dynamicTextures")` on a vehicle without the part will silently no-op. We need to guard:

```lua
if extensions.core_vehicle_partmgmt.hasAvailablePart(playerVehicle.JBeam .. "_skin_dynamicTextures") then
  core_vehicle_partmgmt.setSkin("dynamicTextures")
else
  -- emit "vehicle not supported" message; disable our system for this vehicle
end
```

This is the same check the editor tool does. **Reuse it.**

## 6. Mirrored UVs — confirmed not an issue

The plan worried that *"many vanilla bodies use left/right mirrored UV0 to halve diffuse cost; livery system uses non-mirrored UV1."* Confirmed by every dynamic-decals materials.json:

- Stage 0 (factory paint): no `useUV` field → defaults to **UV0** (mirrored, halved-cost layout)
- Stage 1 (dynamic decals + livery): explicit `*UseUV: 1` on every map → **UV1** (non-mirrored, full body)

**Our scrape masks are written to a UV1-sampled texture.** Left/right asymmetry is preserved. No special handling needed.

## 7. What the dynamic-texture set actually looks like (per-vehicle)

Per-vehicle the engine allocates a *texture set* containing 4 named textures:

- `@DynamicTextureBaseColor` (4096×2048 default, color RGB)
- `@DynamicTextureColorPalette` (palette index, probably R8 or smaller)
- `@DynamicTextureMetallic` (scalar, R8 likely)
- `@DynamicTextureRoughness` (scalar, R8 likely)

Memory back-of-envelope (assuming defaults and uncompressed, format unverified — would need `dump(textureSet)` in-game to confirm):

- BaseColor: 4096 × 2048 × 4 bytes = ~33 MB (RGBA8)
- ColorPalette: 4096 × 2048 × 1 byte = ~8 MB (R8)
- Metallic: ~8 MB
- Roughness: ~8 MB
- **Total per vehicle at full res: ~57 MB**

That's *bigger* than the plan's "12–16 MB per close vehicle" estimate. At LOD 2048², it's ~14 MB. At 1024², ~4 MB. At 512², ~1 MB.

The plan's "100 MB for 8 visible cars at full resolution" needs to become **"~450 MB for 8 cars at 4096×2048" or "~110 MB at 2048²"**. Update Phase 5's LOD math accordingly. Player-only at 4096² is acceptable; nearest 2 AI at 2048², all others at 512² — keeps total comfortably under 100 MB.

`api.setTextureResolution(Point2I(w, h))` (investigation #1 §7) lets us downscale per-vehicle at runtime; that's our LOD primitive.

## 8. What the skin system does NOT give us

- **No per-scratch normal map.** Solved with a tileable scratch detail-normal-map (authored once, applied via `normalMap` + `detailNormalMapStrength`, intensity modulated by depth mask).
- **No shader-side smoothstep / noise expressions.** We bake those into brush textures (Workaround A above) or compute them in Lua (Workaround B).
- **No per-material masks within one vehicle.** All bound materials share one mask set. Acceptable for our use case.
- **No save/load to vehicle preset.** The skin is a JBeam part choice; the dynamic-texture *content* is not persisted by the JBeam system. Persistence is our responsibility (investigation #1 §3 covers `exportLayerMask` / `loadLayerStackFromFile`).

## 9. Author-side checklist — what we'll need to ship

For the mod's own materials (when we want to override the default 2-stage with our 3- or 4-stage paint/primer/metal stack on a chosen test vehicle):

1. Drop a `lua/vehicle/extensions/scrapes/detect.lua` (VLUA detector — investigation #2).
2. Drop a `lua/ge/extensions/scrapes/paint.lua` (GELUA painter — investigation #1).
3. Drop our brush textures into `art/dynamicDecals/textures/` with sidecar `.dynDecalTexture.json` files (per investigation #1, the textures system auto-discovers these).
4. **Author one test vehicle's override**: a `vehicles/pigeon/scratches/main.materials.json` that overrides `pigeon.skin.dynamicTextures` with our 3-stage layout (paint / primer / metal). Mods can override existing materials by re-defining them with the same `mapTo` name — to be confirmed in Phase 4 by experiment.
5. **Author a JBeam skin part** for the test vehicle: `vehicles/pigeon/scratches/main.jbeam` declaring our own `paint_design` part (or just override the existing `_skin_dynamicTextures` if BeamNG's mod loader allows).

## 10. Plan deltas

1. **No `@DynamicTextureNormal` channel.** Per-scratch normal masks are not possible. Use a tileable detail normal map for scratch micro-relief, intensity modulated by the depth mask.
2. **Materials.json is declarative — no shader-side smoothstep.** Phase 4's "smoothstep thresholds, jittered with noise" must move into the brush textures (Workaround A) or be pre-composed in Lua (Workaround B). Decision deferred to Phase 4 start.
3. **Memory budget needs updating.** ~57 MB per vehicle at 4096² (default), not 12–16 MB. Player @ 4096², nearest 2 @ 2048², rest @ 512² gives a ~110 MB total for 8 cars — still acceptable, but the plan's per-vehicle number was too low.
4. **40 vehicles supported, 1 explicitly disabled (md_series).** Phase 2 picks the Pigeon. Phase 5 stress test should pick a derby map populated with vehicles known to support the skin.
5. **`dynDecalMaterials` array in JBeam is the canonical multi-material binding.** Use it explicitly even on single-material vehicles.
6. **All dynamic decals universally write to UV1.** Mirror-UV concern confirmed handled by upstream.
7. **Auto-set the skin on vehicle spawn.** `core_vehicle_partmgmt.setSkin("dynamicTextures")`, gated by `hasAvailablePart` check. Without it, our painter has no surface to write to.
8. **Mod can author its own materials.json override** on a chosen test vehicle for the multi-stage paint/primer/metal stack. Need to validate that mods can override (vs. having to fork the entire vehicle).
