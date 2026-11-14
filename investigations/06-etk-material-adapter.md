# ETK material adapter implementation

Work in progress, following investigation 05. This is a narrow ETK 800 adapter,
not generic livery support. Main body material only; extra-material panels still
show their original paint/livery without damage.

The implementation clones all original material fields, appends one damage
stage, and installs the clone through `onJbeamLoadingPhase2` flexbody material
overrides. It leaves the configured Paint Design and source materials intact.
A private instance of the installed Dynamic Decals Lua API owns its layer stack
and projection. The shader samples damage base-color red as opacity; its empty
black canvas leaves every original stage visible. Mark opacity is therefore
coupled to damage color, including experimental deposits.

Concrete experiments: runtime `vehicle:setSkin` did not change loaded materials;
runtime switches to an unprepared clone rendered chrome. Construction-time
overrides made the clone render correctly. The engine API's deferred material
selection then overwrote the exact clone index; disabling that private callback
fixed projection targeting. Metallic and palette clear values were unsuitable
for opacity. Base-color opacity produced visible scratches across police
lettering. `debug.setupvalue` was rejected by the engine sandbox; the working
path uses normal private API setup and supported `debug.getupvalue` inspection.

Initial live success: `20261114-130602_sideslide_etk-police-working`, BeamNG
0.40.5.0 build 302427, Vulkan, Gridmap v2, ETK 800 Rennspecht 8R config with
stock police Paint Design. All original active-stage fields match the source
material in `docs/evidence/milestone1/adapter-police-damaged.json`.

Lifecycle and final scope validation are still underway. Do not treat this
implementation checkpoint as a completed milestone or merge approval.
