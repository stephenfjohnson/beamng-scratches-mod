"""Generate the contact-patch wear brushes (w2_*) and the damage-stage detail maps.

One decal now covers a whole contact patch, so each brush is a complete picture
of one severity of damage rather than a single mark:

  w2_scuff_*   tier 1 slide: clear-coat hairlines, no bare material
  w2_scrape_*  tier 2 slide: primer ground through along the streaks
  w2_gouge_*   tier 3 slide: bare-metal bands inside a primer margin
  w2_chip_*    impact flakes (a/b light, c/d medium, e/f heavy)
  w2_score_*   impact flakes dragged along +x (a glancing hit)

Every brush is drawn along +x. Colour brushes are RGBA with RED = 1 wherever
there is coverage: the damage stage takes its opacity from the canvas red
channel, so a full-red brush makes opacity equal coverage exactly. Green/blue
carry the tint (warm primer, neutral metal). Tier 2+ brushes ship a matching
`_m` (metallic) and `_r` (roughness) map so bare metal glints and primer stays
matte.

Detail maps (static, tiling, bound by bodyAdapter.lua in the damage stage):
  w2_grit.normal.png   fine abrasion relief
  w2_grit_o.data.png   opacity break-up: specks of surviving paint

Fixed seeds; output is byte-reproducible. Requires numpy and Pillow.
Run: python tools/generate_wear.py
"""

import json
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.normpath(os.path.join(HERE, "..", "art", "dynamicDecals", "textures"))
SS = 2  # supersampling factor

SIDECAR = {"version": 2, "vehicle": "", "isSdfCompatible": False, "tags": ["shape", "scratch"], "type": 0}


# ---------------------------------------------------------------- helpers --

def fft_noise(h, w, rng, sx, sy):
    """Periodic gaussian-filtered noise with blur radius (sx, sy) px, as 0..1."""
    f = np.fft.rfft2(rng.standard_normal((h, w)))
    ky = np.fft.fftfreq(h)[:, None]
    kx = np.fft.rfftfreq(w)[None, :]
    f *= np.exp(-2 * np.pi ** 2 * ((kx * sx) ** 2 + (ky * sy) ** 2))
    n = np.fft.irfft2(f, s=(h, w))
    n = (n - n.mean()) / (n.std() + 1e-9)
    return 0.5 * (1 + np.tanh(n * 0.85))


def noise1d(n, rng, sigma):
    return fft_noise(1, n, rng, sigma, 0)[0]


def smooth(lo, hi, x):
    t = np.clip((x - lo) / (hi - lo), 0, 1)
    return t * t * (3 - 2 * t)


def down(a, w, h):
    """Box-downsample a float 0..1 array to (w, h) as uint8."""
    im = Image.fromarray(np.clip(a * 255 + 0.5, 0, 255).astype(np.uint8), mode="L")
    return np.asarray(im.resize((w, h), Image.BOX), np.uint8)


def save_set(name, w, h, alpha, green, blue, metal=None, rough=None):
    """Write the colour brush and, when given, half-size metallic/roughness maps."""
    a = down(alpha, w, h)
    rgba = np.dstack([np.full_like(a, 255), down(green, w, h), down(blue, w, h), a])
    write(name, Image.fromarray(rgba, mode="RGBA"))
    if metal is not None:
        for suffix, arr in (("_m", metal), ("_r", rough)):
            g = down(arr, w // 2, h // 2)
            write(name + suffix, Image.fromarray(np.dstack([g, g, g]), mode="RGB"))


def write(name, image, sidecar=True):
    path = os.path.join(OUT_DIR, name + ".png")
    image.save(path, optimize=True)
    if sidecar:
        with open(path + ".dynDecalTexture.json", "w", encoding="utf-8") as f:
            json.dump(SIDECAR, f)
    print("  " + os.path.basename(path))


# ----------------------------------------------------------- slide fields --

T_SCUFF, T_PRIMER, T_METAL = 0.30, 0.47, 0.68
TIER_GAIN = {1: 0.66, 2: 1.08, 3: 1.55}


def slide_field(name, seed, tier, w=1024, h=512):
    rng = np.random.default_rng(seed)
    hs, ws = h * SS, w * SS
    y = np.linspace(-1, 1, hs)[:, None]
    x = np.linspace(-1, 1, ws)[None, :]

    # Pressure envelope: a wandering band, wider and narrower along its length,
    # whose rows start and stop at different places so the ends are combed.
    centre = (noise1d(ws, rng, 420) - 0.5) * 0.22
    half = 0.78 * (0.72 + 0.28 * noise1d(ws, rng, 300))
    ey = np.clip(1 - ((y - centre[None, :]) / half[None, :]) ** 2, 0, 1) ** 0.55
    # Rows stay inside the texture (|x| < 0.97) so a decal never ends on a
    # straight cut where the brush met its own border.
    row = lambda: (noise1d(hs, rng, 26) - 0.5) * 0.36 + (noise1d(hs, rng, 3) - 0.5) * 0.20
    x0 = (-0.69 + row())[:, None]
    x1 = (0.69 + row())[:, None]
    ex = np.clip((x - x0) / 0.32, 0, 1) * np.clip((x1 - x) / 0.32, 0, 1)
    ex = ex * np.clip((0.985 - np.abs(x)) / 0.05, 0, 1)
    env = ey * ex ** 0.7

    # Streaks: long along x, a few canvas texels across; blotches of harder contact.
    streak = (0.50 * fft_noise(hs, ws, rng, 300, 4.5)
              + 0.32 * fft_noise(hs, ws, rng, 130, 2.6)
              + 0.18 * fft_noise(hs, ws, rng, 46, 7.0))
    streak = smooth(0.18, 0.86, streak)
    blot = fft_noise(hs, ws, rng, 170, 30)
    grit = fft_noise(hs, ws, rng, 2.2, 2.2)
    depth = env * (0.22 + 0.78 * streak) * (0.62 + 0.62 * blot) * TIER_GAIN[tier]
    depth = depth * (0.93 + 0.14 * grit)

    alpha = smooth(T_SCUFF - 0.035, T_SCUFF + 0.035, depth)
    primer = smooth(T_PRIMER - 0.025, T_PRIMER + 0.025, depth)
    metal = smooth(T_METAL - 0.025, T_METAL + 0.025, depth)

    # Stray hairlines beyond the band: single grains dragged on their own.
    lines = Image.new("L", (ws, hs), 0)
    draw = ImageDraw.Draw(lines)
    for _ in range({1: 70, 2: 46, 3: 38}[tier]):
        ly = (rng.normal(0, 0.42)) * hs / 2 + hs / 2
        lx0 = rng.uniform(0.02, 0.75) * ws
        length = rng.uniform(0.10, 0.55) * ws
        slope = np.tan(np.radians(rng.normal(0, 1.6)))
        width = int(rng.integers(3, 7))
        value = int(rng.uniform(0.55, 1.0) * 255)
        draw.line([(lx0, ly), (lx0 + length, ly + slope * length)], fill=value, width=width)
    lines = np.asarray(lines.filter(ImageFilter.GaussianBlur(1.2)), np.float32) / 255
    lines *= np.clip((1 - np.abs(x)) / 0.12, 0, 1) * np.clip((1 - np.abs(y)) / 0.10, 0, 1)
    alpha = np.maximum(alpha, lines)
    if tier == 1:
        alpha *= 0.92

    bare = primer * (1 - metal)
    green = 1 - 0.05 * bare
    blue = 1 - 0.13 * bare
    if tier == 1:
        save_set(name, w, h, alpha, green, blue)
        return
    sheen = fft_noise(hs, ws, rng, 90, 1.8)
    m = metal * (0.82 + 0.18 * sheen)
    r = (0.50 + 0.36 * primer) * (1 - metal) + (0.28 + 0.24 * sheen) * metal
    save_set(name, w, h, alpha, green, blue, m, r)


# ------------------------------------------------------------ impact chips --

def chips(name, seed, tier, scored=False, size=512):
    rng = np.random.default_rng(seed)
    n = size * SS
    y = np.linspace(-0.5, 0.5, n)[:, None]
    x = np.linspace(-0.5, 0.5, n)[None, :]
    sx, sy = (0.25, 0.085) if scored else ((0.10, 0.10), (0.135, 0.135), (0.17, 0.17))[tier - 1]
    if not scored:
        # An off-round, lumpy footprint: no two clusters share a silhouette.
        turn = rng.uniform(0, np.pi)
        xr, yr = x * np.cos(turn) + y * np.sin(turn), y * np.cos(turn) - x * np.sin(turn)
        env = np.exp(-((xr / sx) ** 2 + (yr / (sy * rng.uniform(0.55, 0.85))) ** 2))
        env = env * (0.45 + 0.95 * fft_noise(n, n, rng, 34 * SS, 34 * SS))
    else:
        env = np.exp(-((x / sx) ** 2 + (y / sy) ** 2))
    if scored:
        shape = 0.6 * fft_noise(n, n, rng, 26 * SS, 4.5 * SS) + 0.4 * fft_noise(n, n, rng, 9 * SS, 2.2 * SS)
    else:
        shape = 0.6 * fft_noise(n, n, rng, 6.5 * SS, 6.5 * SS) + 0.4 * fft_noise(n, n, rng, 2.4 * SS, 2.4 * SS)
    shape = smooth(0.2, 0.8, shape)
    depth = env ** 0.7 * (0.30 + 0.70 * shape) * {1: 0.78, 2: 1.0, 3: 1.22}[tier]
    core = smooth(0.43, 0.46, depth)
    metal = smooth(0.66, 0.69, depth)
    # Satellite specks thrown around the main flakes.
    fine = fft_noise(n, n, rng, 1.7 * SS, 1.7 * SS)
    wide = np.exp(-((x / (sx * 1.9)) ** 2 + (y / (sy * 1.9)) ** 2))
    speck = smooth(0.0, 0.02, fine * (0.55 + 0.45 * wide) - np.quantile(fine, 0.992 - 0.004 * tier))
    core = np.maximum(core, speck * (wide > 0.08))
    if scored or tier == 3:
        # Dragged tails: the edge that dug in kept moving along +x.
        tails = Image.new("L", (n, n), 0)
        draw = ImageDraw.Draw(tails)
        for _ in range(9 if scored else 5):
            tx = (rng.normal(0, sx * 0.6) + 0.5) * n
            ty = (rng.normal(0, sy * 0.7) + 0.5) * n
            length = rng.uniform(0.08, 0.30 if scored else 0.16) * n
            slope = np.tan(np.radians(rng.normal(0, 4)))
            draw.line([(tx, ty), (tx + length, ty + slope * length)], fill=int(rng.uniform(150, 255)),
                      width=int(rng.integers(3, 7)))
        tails = np.asarray(tails.filter(ImageFilter.GaussianBlur(1.0)), np.float32) / 255
        tails *= np.clip((0.46 - np.abs(x)) / 0.05, 0, 1) * np.clip((0.46 - np.abs(y)) / 0.05, 0, 1)
    else:
        tails = 0
    # Lifted clear-coat rim: a pale ring just outside each flake.
    hard = Image.fromarray((core * 255).astype(np.uint8), "L")
    ring = np.asarray(hard.filter(ImageFilter.MaxFilter(2 * SS + 1)).filter(
        ImageFilter.GaussianBlur(0.9)), np.float32) / 255
    alpha = np.maximum(np.maximum(core, ring * 0.85), tails)
    bare = core * (1 - metal)
    green = 1 - 0.05 * bare
    blue = 1 - 0.13 * bare
    if tier == 1:
        save_set(name, size, size, alpha, green, blue)
        return
    sheen = fft_noise(n, n, rng, 8, 8)
    m = metal * (0.85 + 0.15 * sheen)
    r = (0.52 + 0.34 * core) * (1 - metal) + (0.30 + 0.22 * sheen) * metal
    save_set(name, size, size, alpha, green, blue, m, r)


# ------------------------------------------------------------ detail maps --

def detail_maps(size=512):
    rng = np.random.default_rng(9107)
    # Height: isotropic grit plus short scratches in every direction, drawn
    # with wrap-around so the tile repeats without a seam.
    height = (fft_noise(size, size, rng, 1.6, 1.6) - 0.5) * 0.9
    lines = Image.new("L", (size * 3, size * 3), 0)
    draw = ImageDraw.Draw(lines)
    for _ in range(260):
        x0, y0 = rng.uniform(0, size, 2)
        ang = rng.uniform(0, np.pi)
        length = rng.uniform(12, 90)
        dx, dy = np.cos(ang) * length, np.sin(ang) * length
        value = int(rng.uniform(90, 255))
        for ox in (0, size, 2 * size):
            for oy in (0, size, 2 * size):
                draw.line([(x0 + ox, y0 + oy), (x0 + ox + dx, y0 + oy + dy)], fill=value, width=1)
    lines = np.asarray(lines.filter(ImageFilter.GaussianBlur(0.6)), np.float32)[size:2 * size, size:2 * size] / 255
    height -= lines * 1.4
    gx = (np.roll(height, -1, 1) - np.roll(height, 1, 1)) * 1.6
    gy = (np.roll(height, -1, 0) - np.roll(height, 1, 0)) * 1.6
    nz = 1 / np.sqrt(gx * gx + gy * gy + 1)
    normal = np.dstack([(-gx * nz) * 0.5 + 0.5, (-gy * nz) * 0.5 + 0.5, nz * 0.5 + 0.5])
    write("w2_grit.normal", Image.fromarray(np.clip(normal * 255 + 0.5, 0, 255).astype(np.uint8), "RGB"),
          sidecar=False)

    # Opacity break-up: >= 0.5 leaves the damage alone, darker values let the
    # paint show through. About a tenth of the area, as small specks.
    speck = fft_noise(size, size, rng, 1.5, 1.5) * 0.65 + fft_noise(size, size, rng, 5, 5) * 0.35
    cut = np.quantile(speck, 0.10)
    opacity = np.where(speck < cut, 0.5 * smooth(cut - 0.06, cut, speck), 1.0)
    g = np.clip(opacity * 255 + 0.5, 0, 255).astype(np.uint8)
    write("w2_grit_o.data", Image.fromarray(np.dstack([g, g, g]), "RGB"), sidecar=False)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("slide fields")
    for i, letter in enumerate("ab"):
        slide_field("w2_scuff_" + letter, 4100 + i, 1)
    for i, letter in enumerate("abc"):
        slide_field("w2_scrape_" + letter, 4200 + i, 2)
    for i, letter in enumerate("abc"):
        slide_field("w2_gouge_" + letter, 4300 + i, 3)
    print("impact chips")
    for i, letter in enumerate("abcdef"):
        chips("w2_chip_" + letter, 4400 + i, i // 2 + 1)
    chips("w2_score_a", 4500, 2, scored=True)
    chips("w2_score_b", 4501, 3, scored=True)
    print("detail maps")
    detail_maps()


if __name__ == "__main__":
    main()
