"""Generate the floor-pan soil fill (soil_floor_fill.png).

A car's skin UV layout holds its exterior panels only. Every other face of the
body material (the painted floor pan, inner arches, some aero) has no skin
coordinates and reads a single texel of the dynamic-decal canvas: its
bottom-left corner. No projected decal can reach those faces, but a texture
fill of that corner can.

This texture is laid over the whole soil canvas as a UV-space fill, so it is
transparent everywhere except a small block in that corner. The block is a few
texels wide, not one, so the floor still reads it through mip levels: a 16 px
block read 72 % as strong as a full fill, a 4 px block 60 %.

The fill maps the texture onto the canvas texel for texel, not stretched: a
512x256 version left the floor clean. So it is made at the soil canvas size,
2048x1024 (bodyAdapter.lua); it is almost all transparent and compresses to a
few kilobytes.

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


def main():
    image = Image.new("RGBA", (W, H), (255, 255, 255, 0))
    image.paste((255, 255, 255, 255), (0, H - BLOCK, BLOCK, H))
    path = os.path.join(OUT_DIR, "soil_floor_fill.png")
    image.save(path, optimize=True)
    with open(path + ".dynDecalTexture.json", "w", encoding="utf-8") as f:
        json.dump({"version": 2, "vehicle": "", "isSdfCompatible": False,
                   "tags": ["shape", "soil", "floor"], "type": 0}, f)
        f.write("\n")
    print("  " + os.path.basename(path))


if __name__ == "__main__":
    main()
