"""
Generate scratch-brush PNGs for the dynamic-decal painter.

Output: art/dynamicDecals/textures/scratch_streak_{01..04}.png
Format: 512x512 RGBA. Greyscale value drives both color (white) and alpha,
        so a black background is fully transparent and white pixels are fully
        opaque. The mod's `setDecalColor` tints the white at runtime.

Each brush is procedurally generated with a fixed seed, so re-running the
script produces identical files. To iterate on a single brush, change its
seed or the parameters in its function — not the global SEED.

Run: python tools/generate_brushes.py
"""

import json
import math
import os
import random

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "..", "art", "dynamicDecals", "textures")
SIZE = 512


def _new_canvas() -> np.ndarray:
    return np.zeros((SIZE, SIZE), dtype=np.float32)


def _save(canvas: np.ndarray, name: str) -> None:
    # Vanilla brushes (e.g. shape_circle.png) store RGB = pure white everywhere
    # and put the shape in the alpha channel. Matching that format is required
    # — when we instead put the shape in RGB, the api's shader multiplies our
    # darker RGB into the tint color, dimming decals to near-invisibility on
    # dark vehicles. Keep alpha = greyscale (so anti-aliased edges feather
    # correctly), force RGB = 255.
    a = np.clip(canvas * 255.0, 0, 255).astype(np.uint8)
    white = np.full_like(a, 255)
    rgba = np.stack([white, white, white, a], axis=-1)
    img = Image.fromarray(rgba, mode="RGBA")
    out_path = os.path.normpath(os.path.join(OUT_DIR, name))
    img.save(out_path)
    print(f"wrote {out_path}")
    # BeamNG's dynamic-decals system requires a sidecar JSON next to each PNG
    # to register it as a decal-eligible texture. Without this, setDecalTexturePath
    # accepts the path but the brush never loads visibly.
    sidecar_path = out_path + ".dynDecalTexture.json"
    sidecar = {
        "version": 2,
        "vehicle": "",
        "isSdfCompatible": False,
        "tags": ["shape", "scratch"],
        "type": 0,
    }
    with open(sidecar_path, "w") as f:
        json.dump(sidecar, f)
    print(f"wrote {sidecar_path}")


def _stamp_streak(canvas: np.ndarray,
                  x0: float, y0: float, x1: float, y1: float,
                  width: float,
                  taper: bool = True,
                  intensity: float = 1.0,
                  blur: float = 0.8) -> None:
    """Paint a soft tapered streak from (x0, y0) to (x1, y1) onto canvas
    using max-blend (so overlapping strokes don't blow out)."""
    img = Image.new("L", (SIZE, SIZE), 0)
    draw = ImageDraw.Draw(img)
    n = max(16, int(math.hypot(x1 - x0, y1 - y0) / 2))
    for i in range(n):
        t = i / max(1, n - 1)
        x = x0 + (x1 - x0) * t
        y = y0 + (y1 - y0) * t
        if taper:
            mod = 1.0 - abs(t - 0.5) * 2.0
            mod = max(0.05, mod)
        else:
            mod = 1.0
        w = max(0.5, width * mod)
        draw.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2],
                     fill=int(255 * intensity * mod))
    if blur > 0:
        img = img.filter(ImageFilter.GaussianBlur(radius=blur))
    arr = np.asarray(img, dtype=np.float32) / 255.0
    np.maximum(canvas, arr, out=canvas)


def _hairs_around(canvas: np.ndarray, rng: random.Random,
                  cx: float, cy: float, axis_len: float,
                  count: int, perp_jitter: float,
                  along_jitter: float, intensity_range: tuple,
                  width_range: tuple) -> None:
    """Add fine secondary streaks parallel-ish to a horizontal axis through (cx,cy)."""
    for _ in range(count):
        offset_y = rng.uniform(-perp_jitter, perp_jitter)
        x_start = cx - axis_len / 2 + rng.uniform(-along_jitter, along_jitter)
        x_end = cx + axis_len / 2 + rng.uniform(-along_jitter, along_jitter)
        y_start = cy + offset_y
        y_end = cy + offset_y + rng.uniform(-2, 2)
        intensity = rng.uniform(*intensity_range)
        width = rng.uniform(*width_range)
        _stamp_streak(canvas, x_start, y_start, x_end, y_end,
                      width=width, taper=True, intensity=intensity)


def streak_01() -> None:
    """Single key-scratch — one dominant gouge with a few faint hairs."""
    rng = random.Random(1)
    c = _new_canvas()
    # Main gouge: thick, full-intensity. Width 14 px (~3% of canvas).
    _stamp_streak(c, 50, 256, 462, 256, width=14.0, taper=True, intensity=1.0, blur=1.2)
    # Secondary parallel hairs — also clearly visible, not subliminal.
    for _ in range(8):
        offset = rng.uniform(-30, 30)
        x_start = 60 + rng.uniform(-30, 30)
        x_end = 452 + rng.uniform(-30, 30)
        _stamp_streak(c, x_start, 256 + offset, x_end, 256 + offset,
                      width=rng.uniform(2, 5), taper=True,
                      intensity=rng.uniform(0.5, 0.85), blur=1.0)
    _save(c, "scratch_streak_01.png")


def streak_02() -> None:
    """Parallel scrape — multiple deep parallel streaks (curb drag)."""
    rng = random.Random(2)
    c = _new_canvas()
    n_lines = 9
    tilt = rng.uniform(-0.04, 0.04)
    for i in range(n_lines):
        offset_y = (i - n_lines / 2.0) * 28 + rng.uniform(-6, 6)
        x_start = 40 + rng.uniform(-15, 25)
        x_end = 472 + rng.uniform(-25, 15)
        y_start = 256 + offset_y + tilt * (256 - x_start)
        y_end = 256 + offset_y + tilt * (256 - x_end)
        width = rng.uniform(5, 11)
        intensity = rng.uniform(0.7, 1.0)
        _stamp_streak(c, x_start, y_start, x_end, y_end,
                      width=width, taper=True, intensity=intensity, blur=1.0)
    # Extra fill-in hairs to bump density.
    for _ in range(20):
        offset = rng.uniform(-130, 130)
        x_start = 60 + rng.uniform(-25, 25)
        x_end = 452 + rng.uniform(-25, 25)
        _stamp_streak(c, x_start, 256 + offset, x_end, 256 + offset,
                      width=rng.uniform(1.5, 3), taper=True,
                      intensity=rng.uniform(0.4, 0.7), blur=0.8)
    _save(c, "scratch_streak_02.png")


def streak_03() -> None:
    """Scuff cluster — chaotic scratches densely overlaid at varied angles."""
    rng = random.Random(3)
    c = _new_canvas()
    cx, cy = 256, 256
    for _ in range(40):
        angle = rng.uniform(0, 2 * math.pi)
        length = rng.uniform(80, 280)
        ox = cx + rng.uniform(-110, 110)
        oy = cy + rng.uniform(-110, 110)
        x_end = ox + math.cos(angle) * length
        y_end = oy + math.sin(angle) * length
        width = rng.uniform(2.5, 7)
        intensity = rng.uniform(0.6, 1.0)
        _stamp_streak(c, ox, oy, x_end, y_end,
                      width=width, taper=True, intensity=intensity, blur=0.9)
    _save(c, "scratch_streak_03.png")


def streak_04() -> None:
    """Drag smear — a wide opaque smudge with internal streaking."""
    rng = random.Random(4)
    c = _new_canvas()

    # Stronger base smudge — opacity bumped from 0.45 to 0.85.
    base = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(base).ellipse([40, 180, 472, 332], fill=200)
    base = base.filter(ImageFilter.GaussianBlur(radius=18))
    base_arr = np.asarray(base, dtype=np.float32) / 255.0
    np.maximum(c, base_arr * 0.85, out=c)

    # Many bright streaks woven into the smear.
    for _ in range(80):
        angle = rng.uniform(-0.18, 0.18)
        length = rng.uniform(40, 200)
        x_start = rng.uniform(50, 420)
        y_start = rng.uniform(195, 317)
        x_end = x_start + length
        y_end = y_start + math.sin(angle) * length
        width = rng.uniform(2, 6)
        intensity = rng.uniform(0.7, 1.0)
        _stamp_streak(c, x_start, y_start, x_end, y_end,
                      width=width, taper=True, intensity=intensity, blur=0.9)
    _save(c, "scratch_streak_04.png")


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    streak_01()
    streak_02()
    streak_03()
    streak_04()
    print("done.")


if __name__ == "__main__":
    main()
