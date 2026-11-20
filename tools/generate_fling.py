"""Generate the wheel-fling soil brushes (soil_mud_fling_*, soil_dirt_fling_*,
soil_snow_fling_*) and the deep-soil sill bands (soil_mud_band_*, soil_snow_band_*).

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


def _window(ws, hs, left, right, top, bottom):
    """Soft fade to zero at the image borders (fractions of each dimension)."""
    def ramp(n, a, b):
        t = np.arange(n, dtype=np.float32) / max(1, n - 1)
        out = np.ones(n, np.float32)
        if a > 0:
            out *= np.clip(t / a, 0, 1)
        if b > 0:
            out *= np.clip((1 - t) / b, 0, 1)
        return out * out * (3 - 2 * out)
    return np.outer(ramp(hs, top, bottom), ramp(ws, left, right))


def _finish(alpha_f):
    small = Image.fromarray((np.clip(alpha_f, 0, 1) * 255).astype(np.uint8), "L")
    alpha = np.asarray(small.resize((W, H), Image.BOX), np.uint8)
    return Image.fromarray(np.dstack([np.full_like(alpha, 255)] * 3 + [alpha]), "RGBA")


def snow_fan(seed):
    """Snow is not wet: no ropes. A broad powder plume, soft clumps of packed
    snow that hit and stick, and a wide fine spray. Same source point as fan()."""
    rng = np.random.default_rng(seed)
    ws, hs = W * SS, H * SS
    sx, sy = SOURCE_X * ws, hs / 2
    reach = ws * 0.90
    plume = Image.new("L", (ws, hs), 0)
    clumps = Image.new("L", (ws, hs), 0)
    spray = Image.new("L", (ws, hs), 0)
    dp, dc, ds = ImageDraw.Draw(plume), ImageDraw.Draw(clumps), ImageDraw.Draw(spray)

    def point(dist, ang):
        return sx + math.cos(ang) * dist, sy + math.sin(ang) * dist

    def inside(x, y, margin):
        return margin < x < ws - margin and margin < y < hs - margin

    # Powder plume: big soft puffs, growing as the cloud opens out.
    for _ in range(70):
        dist = (0.03 + 0.80 * rng.uniform(0, 1) ** 1.2) * reach
        ang = float(np.clip(rng.normal(0, 0.30), -0.62, 0.62))
        x, y = point(dist, ang)
        r = (26 + 70 * dist / reach) * rng.uniform(0.7, 1.3) * SS / 2
        if inside(x, y, r * 0.5):
            dp.ellipse([x - r, y - r * 0.8, x + r, y + r * 0.8],
                       fill=int(rng.uniform(70, 150) * (1.1 - 0.6 * dist / reach)))

    # Packed clumps: a pile at the arch, then lumps that flew and stuck.
    for i in range(96):
        if i < 34:
            dist = abs(rng.normal(0, 0.07)) * ws
            ang = rng.normal(0, 0.7)
            r = rng.uniform(9, 26) * SS / 2
        else:
            dist = (0.06 + 0.80 * rng.uniform(0, 1) ** 1.6) * reach
            ang = float(np.clip(rng.normal(0, 0.30), -0.60, 0.60))
            r = rng.uniform(5, 17) * (1.1 - 0.6 * dist / reach) * SS / 2
        x, y = point(dist, ang)
        if not inside(x, y, r + 8):
            continue
        pts = []
        for k in range(10):
            a = k * math.tau / 10
            rr = r * rng.uniform(0.7, 1.2)
            pts.append((x + math.cos(a) * rr, y + math.sin(a) * rr))
        dc.polygon(pts, fill=int(rng.uniform(200, 255)))

    # Fine spray: wide, dense near the wheel, thinning out.
    for _ in range(2600):
        dist = (0.02 + 0.96 * rng.uniform(0, 1) ** 1.15) * reach
        ang = float(np.clip(rng.normal(0, 0.36), -0.70, 0.70))
        x, y = point(dist, ang)
        r = rng.uniform(2.4, 5.2)
        if inside(x, y, r + 3):
            ds.ellipse([x - r, y - r, x + r, y + r], fill=int(rng.uniform(90, 215)))

    def arr(img, blur):
        return np.asarray(img.filter(ImageFilter.GaussianBlur(blur)), np.float32) / 255

    alpha = np.maximum(np.maximum(arr(clumps, 3.0) * 1.15, arr(spray, 1.6)),
                       arr(plume, 30.0) * 0.85)
    return _finish(alpha * _window(ws, hs, 0.0, 0.05, 0.06, 0.06))


def band(kind, seed):
    """What deep mud or snow leaves along a sill: heavy and solid along the
    bottom edge, ragged and spattered on top. Laid horizontally, image top up."""
    rng = np.random.default_rng(seed)
    ws, hs = W * SS, H * SS
    mud = kind == "mud"
    mask = Image.new("L", (ws, hs), 0)
    draw = ImageDraw.Draw(mask)

    # Cake line: a wandering top edge over a solid body down to the bottom.
    xs = np.linspace(0, ws, 65)
    top = np.full(65, 0.50 if mud else 0.46)
    for octave, amp in ((2, 0.07), (5, 0.05), (11, 0.035)):
        top += amp * np.sin(xs / ws * math.tau * octave + rng.uniform(0, math.tau))
    top += rng.normal(0, 0.02, 65)
    top = np.clip(top, 0.26, 0.72) * hs
    draw.polygon([(0, hs)] + list(zip(xs.tolist(), top.tolist())) + [(ws, hs)], fill=245)

    # Lumps riding the cake line, and mottling inside it.
    for _ in range(90 if mud else 70):
        x = rng.uniform(0, ws)
        edge = float(np.interp(x, xs, top))
        r = rng.uniform(9, 30 if mud else 40) * SS / 2
        y = edge + rng.normal(0, r * 0.5)
        if y - r < hs * 0.06:
            continue
        pts = []
        for k in range(11):
            a = k * math.tau / 11
            rr = r * rng.uniform(0.65, 1.25)
            pts.append((x + math.cos(a) * rr, y + math.sin(a) * rr * (0.8 if mud else 0.95)))
        draw.polygon(pts, fill=int(rng.uniform(215, 255)))
    for _ in range(60):
        x, y = rng.uniform(0, ws), rng.uniform(0.6, 1.0) * hs
        r = rng.uniform(8, 26) * SS / 2
        draw.ellipse([x - r, y - r * 0.7, x + r, y + r * 0.7], fill=int(rng.uniform(200, 255)))

    # Spatter thrown above the cake: drops (mud runs down a little), specks.
    for _ in range(170 if mud else 60):
        x = rng.uniform(0, ws)
        edge = float(np.interp(x, xs, top))
        y = edge - abs(rng.normal(0, 0.16)) * hs - 6
        r = rng.uniform(3.5, 12 if mud else 16) * SS / 2
        if y - r < hs * 0.05:
            continue
        draw.ellipse([x - r, y - r, x + r, y + r], fill=int(rng.uniform(170, 250)))
        if mud and rng.uniform() < 0.45:
            run = r * rng.uniform(1.5, 4.0)
            draw.polygon([(x - r * 0.7, y), (x + r * 0.7, y), (x, y + run)], fill=200)
    for _ in range(700 if mud else 1100):
        x = rng.uniform(0, ws)
        edge = float(np.interp(x, xs, top))
        y = edge - abs(rng.normal(0, 0.20)) * hs
        r = rng.uniform(2.4, 5.0)
        if y - r > hs * 0.04:
            draw.ellipse([x - r, y - r, x + r, y + r], fill=int(rng.uniform(110, 230)))

    soft = np.asarray(mask.filter(ImageFilter.GaussianBlur(3.2 if mud else 4.5)), np.float32) / 255
    if mud:
        t = np.clip((soft - 0.30) / 0.26, 0, 1)
        soft = t * t * (3 - 2 * t) * (0.86 + 0.14 * np.clip(soft * 1.4, 0, 1))
    # Ends fade so successive bands overlap without a seam; a short fade at the
    # very bottom avoids a ruled line where the band overhangs the sill.
    return _finish(soft * _window(ws, hs, 0.07, 0.07, 0.04, 0.05))


def _save(image, name, kind, tag):
    path = os.path.join(OUT_DIR, name)
    image.save(path, optimize=True)
    with open(path + ".dynDecalTexture.json", "w", encoding="utf-8") as f:
        json.dump({"version": 2, "vehicle": "", "isSdfCompatible": False,
                   "tags": ["shape", "soil", kind, tag], "type": 0}, f)
        f.write("\n")
    print("  " + name)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for kind, seed, count in (("mud", 5100, 3), ("dirt", 5200, 2)):
        for variant in range(1, count + 1):
            _save(fan(kind, seed + variant), "soil_%s_fling_%d.png" % (kind, variant), kind, "fling")
    for variant in range(1, 4):
        _save(snow_fan(5300 + variant), "soil_snow_fling_%d.png" % variant, "snow", "fling")
    for kind, seed in (("mud", 5400), ("snow", 5500)):
        for variant in range(1, 3):
            _save(band(kind, seed + variant), "soil_%s_band_%d.png" % (kind, variant), kind, "band")


if __name__ == "__main__":
    main()
