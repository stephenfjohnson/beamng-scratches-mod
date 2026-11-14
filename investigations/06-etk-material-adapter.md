# Milestone 1: implemented ETK material adapter (2026-11-14)

The scoped acceptance checks pass for the ETK 800 main body with empty Paint
Design or stock Police (`etk800_skin_police`). This is a narrow development
adapter, **not generic livery support**. It supersedes the incomplete checkpoint
in [investigation 05](05-livery-preservation.md). Milestone 2 has not started.

## Engine-backed implementation

The adapter copies all material fields into a unique per-vehicle material,
retains the original two active stages and appends one damage stage. It never
writes the source material or the configured Paint Design. Main-body flexbodies
use a construction-time override from `etk800` to the clone. Other materials and
unrelated overrides are retained; an existing custom body override is rejected.

Installed source examined at `E:/SteamLibrary/steamapps/common/BeamNG.drive`:

- `lua/common/jbeam/loader.lua:271` calls `onJbeamLoadingPhase2` before mesh
  construction; `lua/common/jbeam/sections/meshs.lua:298` applies the nested
  `materialOverride` list with `f:setMaterialOverride`.
- `lua/ge/extensions/editor/api/dynamicDecals.lua:1452` creates its projection
  and texture set in `setup`; its app binds the set through
  `veh:setTextureSet("@DynamicTexture", set)`. The adapter executes this installed
  Lua module into a private table. It does not register the private module's
  editor extension hooks or share the editor layer stack/projection.
- The same API supplies `getShapeMaterialNames`, `setMaterialIdx`, `bakeLayers`,
  clear/flush/combine operations. Supported `debug.getupvalue` exposes its app
  and projection, as in the existing painter. The private `updateVehicleMaterials`
  callback is disabled before setup so its deferred heuristic cannot replace
  the exact clone index.
- `content/vehicles/etk800.zip` contains the two-stage v1.5 police material in
  `vehicles/etk800/skin.materials.json`. The current plain body is `etk800_main`
  in `vehicles/common/etk/etk.materials.json` (common vehicle archive), **not**
  the legacy `etk800` v1 DDS material. Both source layouts are guarded.

Original base color, palette, opacity, normals/detail normals, metallic,
roughness and clearcoat remain below damage. The new UV1 stage samples
`@DynamicTextureBaseColor` for color and opacity (red channel). Empty black
means zero opacity. It has fixed roughness 0.65 and no metallic/clearcoat
response. There is no whole-car color capture, palette flattening or copied
proprietary game texture in the repository.

Reset clears only the private damage projection. Switch/unload disables the
appended stage. Existing constructed clones are adopted on painter reload;
initial activation on a previously built car may reload/repair it once to
install the override. The adapter yields to active world/editor rendering and
resumes clean after closure. Pre-existing Dynamic Textures designs and every
other livery remain skipped, including on same-id part changes.

## Concrete experiments and corrections

- Runtime `vehicle:setSkin` did not replace already-constructed meshes; runtime
  switches to an unprepared clone rendered chrome. Construction-time overrides
  rendered correctly (first checked with a solid diagnostic color).
- The engine's deferred material heuristic replaced clone index 7 with original
  index 5. Disabling that callback only in the private API fixed scratch targeting.
- Metallic and palette clear values produced opaque/unsuitable masks. The
  base-color red channel gave a clear empty canvas and visible police scratches.
- `debug.setupvalue` is rejected by the engine sandbox. No bypass was used;
  normal API setup plus supported upvalue reading supplies the private app.
- The first plain experiment copied legacy `etk800` and visibly changed paint.
  It was rejected. The final adapter uses current PBR `etk800_main`; the final
  plain comparison has zero original-stage differences and visible scratches.
- No unrelated contact-accuracy/realism branch was merged. The three prior
  branches and overlap findings are recorded in investigation 05.

## Reproducible live evidence

BeamNG **0.40.5.0 x64 build 302427**, Vulkan, NVIDIA RTX 3090, Windows 11;
Gridmap v2 (`gridmap_v2`). 3840x2160, Custom preset, Ultra lighting, High shaders,
Normal textures, SMAA, dynamic reflections enabled. Real engine captures are
1920x1080 (0.5 scale); none are generated or retouched.

Vehicle: `vehicles/etk800/rennspecht_8r_A.pc`, with empty or Police Paint Design
explicitly selected. Primary paint RGB 0.08/0.18/0.105, alpha 1.2, metallic 0.8,
roughness 0.65, clearcoat 1, coat roughness 0.05. Probe JSON retains all three
paints, selected part, graphics settings and material fields. Other trims have
not been certified.

| Case | Result and evidence |
| --- | --- |
| Plain PBR scratches | [Actual sideslide](../docs/evidence/milestone1/adapter-plain-sideslide.jpg), [raw result](../docs/evidence/milestone1/adapter-plain-sideslide-result.json); run `20261114-131140_sideslide_etk-plain-pbr` |
| Police + scratches, final code | [Actual sideslide](../docs/evidence/milestone1/adapter-police-sideslide.jpg), [raw result](../docs/evidence/milestone1/adapter-police-sideslide-result.json), [channels/status](../docs/evidence/milestone1/adapter-police-final.json); run `20261114-131856_sideslide_etk-police-final` |
| Police reset after that sideslide | [Clean capture](../docs/evidence/milestone1/adapter-police-reset.jpg), [raw result](../docs/evidence/milestone1/adapter-police-reset-result.json); 0 impacts, streams and projections, run `20261114-132009_baseline_etk-police-final-reset` |
| Plain original vs clean overlay | [Original stages](../docs/evidence/milestone1/adapter-plain-compare-original-stages.png), [clean overlay](../docs/evidence/milestone1/adapter-plain-compare-clean-overlay.png), [zero field differences](../docs/evidence/milestone1/adapter-plain-compare.json) |
| Police original vs clean overlay | [Original stages](../docs/evidence/milestone1/adapter-police-compare-original-stages.png), [clean overlay](../docs/evidence/milestone1/adapter-police-compare-clean-overlay.png), [zero field differences](../docs/evidence/milestone1/adapter-police-compare.json) |
| Vehicle reload; extension hot reload | [Vehicle reload](../docs/evidence/milestone1/adapter-police-reload.json), [hot reload](../docs/evidence/milestone1/adapter-hot-reload.json): same police selection, ready, original fields equal |
| Two same-model cars; unicycle | [Switching](../docs/evidence/milestone1/adapter-switching.json): distinct clone names; inactive clone returns to 2 layers; unicycle skipped; returning ETK ready |
| Unsupported stock Heritage design | [Status](../docs/evidence/milestone1/adapter-unsupported-livery.json): skipped, selected part preserved |
| Unowned Dynamic Textures | [Status](../docs/evidence/milestone1/adapter-unowned-dynamic.json): skipped |
| Editor artwork survives reset/reload | [Before/after layer stack](../docs/evidence/milestone1/adapter-editor-ownership.json): test sentinel UID FE4C-5D92 unchanged; also retained through two-car switching |
| Actual editor activation/closure | [Active](../docs/evidence/milestone1/adapter-editor-active.json): skipped; [return](../docs/evidence/milestone1/adapter-editor-return.json): private adapter ready again, original fields equal |

`tools/etk_compare.py` captures the same clone with its original two stages,
then with the clean damage stage enabled. This is not a separate untouched
stock-car comparison: `tools/livery_probe.py` independently checks every original
active-stage field against the source material (excluding identity and layer
count). Both comparisons had zero differences; screenshots were visually
inspected for paint/lettering, reflections and clean surfaces. Minor temporal
lighting/HUD differences are possible, so pixel identity is not asserted.

The final police sideslide also shows the second car clean beside the scratched
player car. It recorded 104 impacts, 99 streams and 86 projections. The reset
baseline runs for four seconds; the bench labels the end “timed out”, which is
its duration limit, not a crash. These runs establish rendering/lifecycle
behavior, not performance certification. The plain capture preceded the final
editor-resume fix; its material implementation is the final one.

## Validation, supported boundary and outstanding limits

`python tools/package.py` passes Lua syntax/global checks, brush sidecars and
**192 mocked-engine checks**. Twenty new adapter checks cover original channels,
exact material targeting, private clearing, detach/unload, hot adoption, editor
rejection, custom-body override rejection and current plain-PBR selection.
The archive contains only `lua/` and `art/`; no engine source/assets or test
helpers are packaged. Mock checks do not replace the rendering evidence above.

- Enabled scope: ETK 800 main body, empty Paint Design or stock Police. Extra
  materials keep their appearance but receive no adapter damage. Arbitrary
  mods, source-material replacements, multi-material liveries, other builds and
  other renderers are unverified. Layout/index failures leave original paint.
- Generic livery composition remains deferred. Other plain cars retain the
  legacy Dynamic Textures path and its unverified exact PBR fidelity; concurrent
  editor use on that path remains unsupported.
- Color-derived opacity makes dark damage/deposits weaker. Original unmarked
  channels are retained, but per-scratch material realism remains future work.
- Reset, switch, reload and editor suspension discard cosmetic damage. The
  first installation on an existing car may reload/repair it once.
- Disabled clone scene objects are retained for mesh references and reused by
  name. Long-session material/projection resource cost has not been measured;
  this is not a broad performance or packaged-release certification.
- Experimental deposits keep their existing code/mock coverage, not new live
  mud/snow evidence. Water visual wash/gloss and milestone 2 remain deferred.

Within this explicit scope, milestone 1 is implemented and its acceptance
checks pass. README, examples, compatibility notes, changelog and roadmap are
updated together. The unchanged generic safeguard remains essential.
