# Changelog

## Unmerged milestone 1 investigation — 2026-11-14

- Preserve stock liveries on same-id part changes; guard destructive clear.
- Skip unowned Dynamic Textures designs, including after extension reload.
- Add read-only compatibility/material probe and seven regression checks (172 total).
- Record 0.40.5.0 build 302427 Vulkan ETK/plain/police/reset/switch and unicycle evidence.
- Generic compositing and exact paint-material fidelity remain incomplete.
  See [investigation](investigations/05-livery-preservation.md); no milestone 2 work.


## Unreleased

- Experimental bounded mud/dirt/snow contact deposits, using tinted haze brushes.
- Water detection and internal wetness/washing/drying state. Visual washing and
  wet gloss are not implemented.
- 165 mock checks pass; Lua syntax/global and brush sidecar preflight pass.
- Live ETK 800 asphalt sideslide regression captured; environmental rendering
  and broad vehicle compatibility remain unverified.
- Added installation guidance, examples, troubleshooting, compatibility evidence,
  contribution instructions and a sequential release plan.

Existing scratches, impact chips, diagnostic controls and reset behavior remain.
Liveried vehicles are still intentionally skipped. No stable release is tagged.
