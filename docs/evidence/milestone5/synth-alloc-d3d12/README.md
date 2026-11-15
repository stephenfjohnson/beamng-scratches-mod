# Native allocation probe (D3D12, 4096x2048 private damage target)

Short user-provider ETW captures (Direct3D12 mask 0x484, no elevation) around isolated
GE Lua loops on a parked ETK800 Police, game process only. Diagnostic, not untraced
performance evidence; raw system-wide ETLs stay local. [Counts](alloc-counts.json).

| Loop (20 calls) | Resource creations attributed to the game |
| --- | --- |
| idle | ~92/s 658x655 RGBA8 and ~24/s 8,294,400-byte buffers (engine/UI baseline) |
| `combineTextures` | baseline only |
| `bakeLayers`, 1 layer | 60 x 4096x2048 RGBA8 + 40 x 4096x2048 R8 + 20 x 256 B + 8 x 32 MiB buffers |
| `bakeLayers`, 3 layers | 180 RGBA8 + 120 R8 full-size: scales with layers, not calls |
| `projectDynamicDecals` after the 3-layer loop | no creations; waited >30 s behind 300 deferred full-size destroys |

Each baked layer creates and destroys three full-target RGBA8 and two full-target R8
textures (~112 MiB at 4096x2048) inside the native call. This is the engine bake
implementation; the Lua API exposes no pooling or allocator control.
