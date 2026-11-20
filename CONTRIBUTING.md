# Contributing

Follow the [sequential release plan](docs/plans/release-sequence.md). Keep one
feature in flight. A feature includes implementation, tests, documentation and
an honest record of engine-only validation gaps.

## Local checks

Install Python 3.10+ and Lua 5.1 with `lua` and `luac` available on PATH.
From the repository root:

```powershell
lua tools/sim/harness.lua
python tools/package.py
git diff --check
```

The packager runs syntax, global allow-list, harness and brush-sidecar checks
when Lua tools are available. Do not accept skipped checks for release work.
Brush generation additionally requires Pillow and NumPy. Game assets and
reference sources are not redistributable project content; do not add them.

## Engine validation

Use `tools/dev.py` and the [examples](docs/examples.md). Only one thread may
control/deploy to the shared running game at a time. Record game build,
renderer, vehicle/configuration, map and settings. Include screenshots for
visual changes and reproducible timings for performance claims.

## Documentation and merging

Update the [feature write-ups](docs/features.md), examples, compatibility notes,
[known issues](docs/known-issues.md) and CHANGELOG in the same change as
implementation. The README is the short player-facing front page: keep it in
plain language and put technical detail in [`docs/`](docs/README.md). Clearly distinguish mock-tested logic from
in-game verification. Do not advertise unsupported features or imply a local
ZIP is a public download. Review older branches before integrating overlapping
work. Merge only after the milestone checks pass; preserve unrelated work.

Before a public release, choose explicit licensing/credits, test a ZIP-only
install and uninstall, and verify the published download without authentication.
