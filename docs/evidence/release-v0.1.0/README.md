# v0.1.0-preview install test

2026-11-15, BeamNG.drive 0.40.5.0 build 302427, Vulkan, Windows 11, RTX 3090.

1. Built `dist/scratches_mod.zip` with `python tools/package.py`: Lua syntax and
   global checks, 358 harness checks and brush sidecars passed. Root entries:
   `LICENSE`, `art`, `lua`.
2. Removed the unpacked dev mount, placed only the ZIP in `mods/`, and started
   the game directly (no dev tooling deploy). The VFS showed the ZIP and no
   unpacked copy.
3. The default Rennspecht livery was detected and skipped (livery preserved),
   as designed. After switching to the stock Police skin the adapter activated
   with a private material clone (`scratches_etk800_33151_police`).
4. A `sideslide` bench run on the ZIP-only install: 48 impacts, 118 streams,
   52 layers baked, 0% missed, empty queues at the end
   ([report and screenshots](zip-install-sideslide/report.md)). The bench's
   in-game helper was loaded temporarily from the user folder, outside the mod.
5. Uninstall: removed the ZIP and restarted. `scratches_paint` was absent and no
   mod errors were logged. The only remaining line was
   `Couldn't find action scratches_toggle_ui` from a saved key binding, which
   also appears at every startup before mods mount and is harmless.
