"""Generate the floor-pan soil fills (soil_floor_fill_1..6.png).

A car's skin UV layout holds its exterior panels only. Every other face of the
body material (the painted floor pan, inner arches) has no skin coordinates and
reads a single texel of the dynamic-decal canvas: its bottom-left corner. No
projected decal can reach those faces, but a texture fill of that corner can.

Each texture is laid over the whole soil canvas as a UV-space fill, so it is
transparent everywhere except a small block in that corner. What the engine
does with such a fill, found in game on 2026-11-20:

- it maps the texture onto the canvas texel for texel, not stretched (a
  512x256 version left the floor clean), so these are made at the soil canvas
  size, 2048x1024 (bodyAdapter.lua); they compress to a few kilobytes;
- the block's alpha is the strength of the film;
- a fill whose texture path was already baked since the last clear is skipped,
  so each step of the film needs its own file. There are six, from thin to
  solid;
- the block is a few texels wide, not one: a 16 px block read 72 % as strong
  as a full fill, a 4 px block 60 %.

The film stops at PEAK, short of solid: the same texel is read by everything
else outside the skin layout, which on the Sunburst rally car includes the top
of the rear wing. Each fill blends over the last, so step k carries the alpha
that takes the film from (k-1)/6 to k/6 of PEAK.

White RGB, shape in alpha; the painter tints it with the soil colour.
Byte-reproducible. Requires Pillow.
Run: python tools/generate_floor_fill.py
"""

import json
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.normpath(os.path.join(HERE, "..", "art", "dynamicDecals", "textures"))
W, H = 2048, 1024  # the soil canvas size
BLOCK = 24


STEPS = 6
PEAK = 0.72


def main():
    for step in range(1, STEPS + 1):
        image = Image.new("RGBA", (W, H), (255, 255, 255, 0))
        before, after = PEAK * (step - 1) / STEPS, PEAK * step / STEPS
        alpha = (after - before) / (1 - before)
        image.paste((255, 255, 255, round(255 * alpha)), (0, H - BLOCK, BLOCK, H))
        path = os.path.join(OUT_DIR, "soil_floor_fill_%d.png" % step)
        image.save(path, optimize=True)
        with open(path + ".dynDecalTexture.json", "w", encoding="utf-8") as f:
            json.dump({"version": 2, "vehicle": "", "isSdfCompatible": False,
                       "tags": ["shape", "soil", "floor"], "type": 0}, f)
            f.write("\n")
        print("  " + os.path.basename(path))


if __name__ == "__main__":
    main()
