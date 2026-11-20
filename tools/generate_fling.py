"""Generate the wheel-fling soil brushes (soil_mud_fling_*, soil_dirt_fling_*).

A turning tyre throws mud off its tread in a fan, up and back from the contact
patch. Where that fan meets the flank it leaves a cake at the arch, drops
stretched along their line of flight, ropes of wet mud, and a mist of specks
thinning out with distance. Each brush is one such fan: the source sits at the
left edge (7 % in, mid height) and the throw runs along +x. The painter rotates
the decal to the throw angle and places the source behind the wheel.

White RGB, shape in alpha; the painter tints it with the terrain colour.
512x256, fixed seeds, byte-reproducible. Requires numpy and Pillow.
Run: python tools/generate_fling.py
"""

import json
import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.normpath(os.path.join(HERE, "..", "art", "dynamicDecals", "textures"))
W, H, SS = 512, 256, 4
SOURCE_X = 0.07  # fraction of the width; bodyAdapter-independent, mirrored in paint.lua


def fan(kind, seed):
    rng = np.random.default_rng(seed)
    ws, hs = W * SS, H * SS
    mask = Image.new("L", (ws, hs), 0)
    draw = ImageDraw.Draw(mask)
    sx, sy = SOURCE_X * ws, hs / 2
    mud = kind == "mud"
    reach = ws * 0.90

    def point(dist, ang):
        return sx + math.cos(ang) * dist, sy + math.sin(ang) * dist

    def inside(x, y, margin):
        return margin < x < ws - margin and margin < y < hs - margin

    # Cake at the arch: overlapping lumps, ragged at the edge.
    for _ in range(46 if mud else 14):
        dist = abs(rng.normal(0, 0.075)) * ws
        ang = rng.normal(0, 0.55)
        x, y = point(dist, ang)
        r = rng.uniform(10, 34 if mud else 20) * SS / 2
        if not inside(x, y, r + 4):
            continue
        pts = []
        for i in range(11):
            a = i * math.tau / 11
            rr = r * rng.uniform(0.6, 1.25)
            pts.append((x + math.cos(a) * rr, y + math.sin(a) * rr))
        draw.polygon(pts, fill=int(rng.uniform(205, 255) if mud else rng.uniform(120, 190)))

    # Drops stretched along their flight: round near end, tail pointing away.
    for _ in range(260 if mud else 150):
        dist = (0.05 + 0.88 * rng.uniform(0, 1) ** 1.5) * reach
        ang = float(np.clip(rng.normal(0, 0.21), -0.46, 0.46))
        far = dist / reach
        r = (rng.uniform(4, 15) * float(np.exp(rng.normal(0, 0.35))) if mud else rng.uniform(3, 8))
        r = max(r * (1.15 - 0.70 * far) * SS / 2, 3.4)
        length = r * rng.uniform(1.2, 2.6) * (1 + 1.3 * far)
        x, y = point(dist, ang)
        tx, ty = point(dist + length, ang)
        if not (inside(x, y, r + 4) and inside(tx, ty, 4)):
            continue
        nx, ny = -math.sin(ang) * r, math.cos(ang) * r
        value = int(rng.uniform(170, 255) if mud else rng.uniform(95, 190))
        draw.polygon([(x + nx * 0.8, y + ny * 0.8), (tx, ty), (x - nx * 0.8, y - ny * 0.8)],
                     fill=int(value * 0.85))
        wob = rng.uniform(0.75, 1.2)
        draw.ellipse([x - r, y - r * wob, x + r, y + r * wob], fill=value)

    # Ropes: wet mud drawn out into strings.
    for _ in range(11 if mud else 3):
        ang = float(np.clip(rng.normal(0, 0.17), -0.4, 0.4))
        start = rng.uniform(0.03, 0.25) * reach
        length = rng.uniform(0.18, 0.55) * reach
        steps, pts = 14, []
        bend = rng.normal(0, 0.05)
        for i in range(steps + 1):
            t = i / steps
            pts.append(point(start + length * t, ang + bend * t * t))
        if all(inside(px, py, 6) for px, py in pts):
            draw.line(pts, fill=int(rng.uniform(150, 235)), width=int(rng.integers(5, 12)))

    # Mist: specks thinning with distance, a little wider than the drops.
    for _ in range(520 if mud else 1500):
        dist = (0.02 + 0.96 * rng.uniform(0, 1) ** 1.25) * reach
        ang = float(np.clip(rng.normal(0, 0.27), -0.56, 0.56))
        x, y = point(dist, ang)
        r = rng.uniform(2.6, 6.0 if mud else 4.4)
        if inside(x, y, r + 3):
            draw.ellipse([x - r, y - r, x + r, y + r],
                         fill=int(rng.uniform(140, 240) if mud else rng.uniform(70, 170)))

    if mud:
        # Wet mud pulls into rounded, merged shapes: blur, then re-harden.
        soft = np.asarray(mask.filter(ImageFilter.GaussianBlur(3.4)), np.float32) / 255
        t = np.clip((soft - 0.30) / 0.26, 0, 1)
        hard = t * t * (3 - 2 * t) * (0.86 + 0.14 * np.clip(soft * 1.4, 0, 1))
        mask = Image.fromarray((hard * 255).astype(np.uint8), "L")
    else:
        mask = mask.filter(ImageFilter.GaussianBlur(2.2))
    alpha = np.asarray(mask.resize((W, H), Image.BOX), np.uint8)
    rgba = np.dstack([np.full_like(alpha, 255)] * 3 + [alpha])
    return Image.fromarray(rgba, "RGBA")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for kind, seed, count in (("mud", 5100, 3), ("dirt", 5200, 2)):
        for variant in range(1, count + 1):
            path = os.path.join(OUT_DIR, "soil_%s_fling_%d.png" % (kind, variant))
            fan(kind, seed + variant).save(path, optimize=True)
            with open(path + ".dynDecalTexture.json", "w", encoding="utf-8") as f:
                json.dump({"version": 2, "vehicle": "", "isSdfCompatible": False,
                           "tags": ["shape", "soil", kind, "fling"], "type": 0}, f)
                f.write("\n")
            print("  " + os.path.basename(path))


if __name__ == "__main__":
    main()
