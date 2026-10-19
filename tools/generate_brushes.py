"""
Generate the scratch-brush PNGs for the dynamic-decal painter.

Output: art/dynamicDecals/textures/scr_*.png (+ .dynDecalTexture.json sidecars)
Format: 512x512 RGBA, RGB = white, shape in alpha. The painter tints each
        stamp with setDecalColor (primer grey, bare metal, clear-coat haze).

Brush families, all drawn along +x (the painter rotates them):
  scr_scrape_*  slide bands: parallel lines of uneven weight with gaps,
                tapered ragged ends and a few deep gouges. Stretched along
                the slide path, so they must fade out at the x ends where
                consecutive segments overlap.
  scr_haze_*    soft streaky abrasion - scuffed clear coat. Laid under the
                scrape lines at low opacity.
  scr_chips_*   impact paint loss: sharp-edged flakes, dense at the centre.
  scr_gouge_*   impact dig-in: a chipped crater with short deep scores
                trailing away from it.

Scale matters more than detail: a scrape decal is ~10-22 cm across but 512 px
in the brush, and the car's paint canvas resolves ~1.5 mm per texel, so a line
narrower than ~8 px here disappears in game. Lines are drawn at 2x and
downsampled for clean anti-aliased edges.

Every brush has a fixed seed, so re-running produces identical files.

Run: python tools/generate_brushes.py
"""

import glob
import json
import math
import os
import random

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.normpath(os.path.join(HERE, "..", "art", "dynamicDecals", "textures"))
SIZE = 512
SS = 2                    # supersampling factor
N = SIZE * SS             # working canvas size

# Brushes from earlier generations. Deleted on each run so a renamed brush
# can't linger in the shipped zip.
RETIRED = ["scratch_streak_01", "scratch_streak_02", "scratch_streak_03", "scratch_streak_05",
           "scratch_raptor_claw_01", "scratch_raptor_claw_02", "scratch_chip_cluster",
           "scratch_tbone"]


# ---------------------------------------------------------------- helpers --

def _save(canvas: np.ndarray, name: str) -> None:
    """canvas: N x N float alpha in [0, 1]. Downsample, store as white + alpha
    (vanilla brush format - shape in RGB would darken the tint), write sidecar."""
    img = Image.fromarray(np.clip(canvas * 255.0, 0, 255).astype(np.uint8), mode="L")
    a = np.asarray(img.resize((SIZE, SIZE), Image.LANCZOS))
    white = np.full_like(a, 255)
    out = os.path.join(OUT_DIR, name + ".png")
    Image.fromarray(np.stack([white, white, white, a], axis=-1), mode="RGBA").save(out)
    # Without this sidecar the dynamic-decals system registers nothing and the
    # brush stamps invisibly.
    with open(out + ".dynDecalTexture.json", "w") as f:
        json.dump({"version": 2, "vehicle": "", "isSdfCompatible": False,
                   "tags": ["shape", "scratch"], "type": 0}, f)
    print(f"wrote {out}")


def _noise1d(rng: np.random.Generator, n: int, smooth: int) -> np.ndarray:
    """Smooth 1D noise in roughly [-1, 1]."""
    raw = rng.standard_normal(n + smooth * 4)
    k = np.hanning(max(3, smooth * 2 + 1))
    v = np.convolve(raw, k / k.sum(), mode="same")[smooth * 2: smooth * 2 + n]
    return v / (np.abs(v).max() + 1e-9)


def _smoothstep(e0: float, e1: float, x: np.ndarray) -> np.ndarray:
    t = np.clip((x - e0) / (e1 - e0), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def _x_fade(fade: float = 0.10) -> np.ndarray:
    """Per-column envelope fading the brush out at both x ends, so consecutive
    stretched segments blend where they overlap instead of showing seams."""
    x = np.linspace(0, 1, N)
    return _smoothstep(0, fade, x) * _smoothstep(0, fade, 1 - x)


def _line(canvas: np.ndarray, rng: np.random.Generator, y0: float, x0: float, x1: float,
          width: float, strength: float, gap: float = 0.25, wave: float = 1.5,
          rough: float = 0.3, slope: float = 0.0) -> None:
    """One scratch along +x (all units in final 512-px brush pixels).
    width: mean full width; gap: fraction of the length that breaks up;
    rough: width variation; wave: low-frequency wander amplitude."""
    xa, xb = int(x0 * SS), int(x1 * SS)
    n = xb - xa
    if n < 4:
        return
    t = np.linspace(0, 1, n)
    yc = (y0 + slope * (t - 0.5) + wave * _noise1d(rng, n, 60)) * SS
    hw = 0.5 * width * SS * (1 + rough * _noise1d(rng, n, 12))
    # Taper both ends, the start a little more sharply (where the edge bit in).
    taper = _smoothstep(0, 0.06 + 0.06 * rng.random(), t) * _smoothstep(0, 0.12 + 0.1 * rng.random(), 1 - t)
    amp = strength * np.ones(n)
    if gap > 0:
        # Worn stretches: the line thins and fades where the noise peaks,
        # rather than breaking into dashes.
        g = _noise1d(rng, n, 40)
        wear = np.clip(1 - 2 * (g - (1 - 2 * gap)), 0.3, 1.0)
        amp *= wear
        hw *= 0.5 + 0.5 * wear
    hw = np.maximum(hw * taper, 0)
    lo = int(max(0, np.floor((yc - hw).min()) - 2))
    hi = int(min(N, np.ceil((yc + hw).max()) + 3))
    if hi <= lo:
        return
    rows = np.arange(lo, hi)[:, None]
    cov = np.clip(hw[None, :] - np.abs(rows - yc[None, :]) + 0.5, 0, 1) * amp[None, :]
    region = canvas[lo:hi, xa:xb]
    np.maximum(region, cov, out=region)


def _flake(draw: ImageDraw.ImageDraw, rng: random.Random, cx: float, cy: float,
           size: float, fill: int = 255) -> None:
    """Sharp-edged irregular paint flake (polygon), size in final px."""
    k = rng.randint(5, 9)
    pts = []
    for i in range(k):
        ang = 2 * math.pi * (i + rng.uniform(-0.3, 0.3)) / k
        r = size * SS * rng.uniform(0.45, 1.0)
        pts.append((cx * SS + r * math.cos(ang), cy * SS + r * 0.8 * math.sin(ang)))
    draw.polygon(pts, fill=fill)


def _flake_canvas(fn) -> np.ndarray:
    img = Image.new("L", (N, N), 0)
    fn(ImageDraw.Draw(img))
    return np.asarray(img, dtype=np.float32) / 255.0


# ------------------------------------------------------------- scrapes --

def scrape(name: str, seed: int, lines: int, spread: float, gouges: int) -> None:
    """Slide band. spread = std-dev of line positions as a fraction of height."""
    rng = np.random.default_rng(seed)
    c = np.zeros((N, N), np.float32)
    for _ in range(lines):
        y = float(np.clip(rng.normal(0.5, spread), 0.12, 0.88)) * SIZE
        length = rng.uniform(0.45, 1.0)
        x0 = rng.uniform(0.0, 1.0 - length) * SIZE
        heavy = rng.random()
        width = 9 + heavy ** 2 * 10                     # 9..19 px
        _line(c, rng, y, x0, x0 + length * SIZE, width,
              strength=0.45 + 0.5 * heavy, gap=0.10 + 0.25 * rng.random(),
              wave=rng.uniform(0.5, 2.5), rough=0.35, slope=rng.uniform(-6, 6))
    for _ in range(lines // 2):  # finer hairlines between the main strokes
        y = float(np.clip(rng.normal(0.5, spread * 1.1), 0.1, 0.9)) * SIZE
        length = rng.uniform(0.3, 0.9)
        x0 = rng.uniform(0.0, 1.0 - length) * SIZE
        _line(c, rng, y, x0, x0 + length * SIZE, rng.uniform(5, 8),
              strength=rng.uniform(0.4, 0.7), gap=0.3, wave=rng.uniform(0.5, 2), rough=0.25,
              slope=rng.uniform(-5, 5))
    for _ in range(gouges):
        y = float(np.clip(rng.normal(0.5, spread * 0.7), 0.2, 0.8)) * SIZE
        length = rng.uniform(0.3, 0.75)
        x0 = rng.uniform(0.0, 1.0 - length) * SIZE
        _line(c, rng, y, x0, x0 + length * SIZE, rng.uniform(16, 26),
              strength=1.0, gap=0.05, wave=1.0, rough=0.55, slope=rng.uniform(-4, 4))
    c *= _x_fade(0.10)[None, :]
    _save(c, name)


def haze(name: str, seed: int) -> None:
    """Scuffed clear coat: streaky soft abrasion with faint micro-lines."""
    rng = np.random.default_rng(seed)
    y = np.linspace(-1, 1, N)[:, None]
    x = np.linspace(0, 1, N)[None, :]
    # Ragged elliptical band: edges wander along x.
    edge = 0.55 + 0.18 * _noise1d(rng, N, 80)[None, :]
    band = _smoothstep(0, 0.35, edge - np.abs(y - 0.08 * _noise1d(rng, N, 120)[None, :]))
    # Streaks: noise that varies fast across y and slowly along x.
    coarse = rng.random((96, 10)).astype(np.float32)
    streak = np.asarray(Image.fromarray((coarse * 255).astype(np.uint8)).resize((N, N), Image.BICUBIC),
                        np.float32)[:, :] / 255.0
    c = band * (0.25 + 0.75 * streak ** 1.5) * 0.8
    for _ in range(110):
        yy = float(np.clip(rng.normal(0.5, 0.17), 0.1, 0.9)) * SIZE
        length = rng.uniform(0.15, 0.8)
        x0 = rng.uniform(0, 1 - length) * SIZE
        _line(c, rng, yy, x0, x0 + length * SIZE, rng.uniform(2, 4),
              strength=rng.uniform(0.15, 0.4), gap=0.35, wave=1.0, rough=0.3)
    c *= (_x_fade(0.18)[None, :] * (0.85 + 0.15 * x))
    _save(np.clip(c, 0, 1), name)


# ------------------------------------------------------------- impacts --

def chips(name: str, seed: int, count: int, radius: float) -> None:
    """Impact paint loss: one irregular sharp-edged patch where the paint
    flaked off, with smaller flakes around it. Sized for the paint canvas -
    detail finer than ~16 px here blurs into a soft puff in game."""
    rng = random.Random(seed)

    def draw(d):
        for _ in range(9):  # overlapping large flakes form the jagged core
            _flake(d, rng, SIZE / 2 + rng.gauss(0, radius * SIZE * 0.35),
                   SIZE / 2 + rng.gauss(0, radius * SIZE * 0.3), rng.uniform(18, 42))
        for _ in range(count):
            r = abs(rng.gauss(0, radius)) * SIZE + radius * SIZE * 0.5
            a = rng.uniform(0, 2 * math.pi)
            _flake(d, rng, SIZE / 2 + r * math.cos(a), SIZE / 2 + r * 0.8 * math.sin(a),
                   6 + 12 * rng.random() ** 2)

    _save(_flake_canvas(draw), name)


def gouge(name: str, seed: int, scores: int) -> None:
    """Dig-in crater at the left with short deep scores trailing to the right."""
    rng = random.Random(seed)
    nrng = np.random.default_rng(seed)
    cx, cy = SIZE * 0.28, SIZE * 0.5

    def draw(d):
        for _ in range(26):
            _flake(d, rng, cx + rng.gauss(0, 14), cy + rng.gauss(0, 18), 4 + 16 * rng.random() ** 2)
        for _ in range(40):  # chips flicked off along the scores
            _flake(d, rng, cx + rng.uniform(10, 260), cy + rng.gauss(0, 34), 2 + 7 * rng.random() ** 2)

    c = _flake_canvas(draw)
    for i in range(scores):
        y = cy + (i - (scores - 1) / 2) * rng.uniform(16, 26) + rng.gauss(0, 4)
        _line(c, nrng, y, cx - 10, cx + rng.uniform(0.35, 0.62) * SIZE, rng.uniform(10, 22),
              strength=1.0, gap=0.08, wave=2, rough=0.5, slope=rng.uniform(-10, 10))
    c *= _x_fade(0.06)[None, :]
    _save(c, name)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    for old in RETIRED:
        for p in glob.glob(os.path.join(OUT_DIR, old + ".png*")):
            os.remove(p)
            print(f"removed {p}")
    scrape("scr_scrape_01", 101, lines=16, spread=0.16, gouges=1)
    scrape("scr_scrape_02", 202, lines=22, spread=0.20, gouges=2)
    scrape("scr_scrape_03", 303, lines=11, spread=0.11, gouges=0)
    haze("scr_haze_01", 404)
    haze("scr_haze_02", 505)
    chips("scr_chips_01", 606, count=22, radius=0.10)
    chips("scr_chips_02", 707, count=14, radius=0.07)
    gouge("scr_gouge_01", 808, scores=3)
    gouge("scr_gouge_02", 909, scores=2)


if __name__ == "__main__":
    main()
