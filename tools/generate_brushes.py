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
    """Single key-scratch — one dominant gouge with parallel hairs."""
    rng = random.Random(1)
    c = _new_canvas()
    # Main gouge: thicker than v1 (14 → 16) for more visible presence.
    _stamp_streak(c, 50, 256, 462, 256, width=16.0, taper=True, intensity=1.0, blur=1.2)
    # Secondary parallel hairs. v1 used 8 hairs in a ±30 px band → ~5% pixel
    # coverage. Bumped to 18 hairs in a ±55 px band so streak_01 reads as a
    # cluster of scratches rather than a lonely single gouge.
    for _ in range(18):
        offset = rng.uniform(-55, 55)
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


def _stamp_dot(canvas: np.ndarray, cx: float, cy: float,
               radius: float, intensity: float, blur: float = 0.5) -> None:
    """Paint a soft dot (max-blended) at (cx, cy)."""
    img = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(img).ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=int(255 * intensity))
    if blur > 0:
        img = img.filter(ImageFilter.GaussianBlur(radius=blur))
    arr = np.asarray(img, dtype=np.float32) / 255.0
    np.maximum(canvas, arr, out=canvas)


def impact_splat() -> None:
    """Radial spray with a dense central core — for the normalForce branch.

    Reads as material blasted outward from a point of impact: a bright disc
    surrounded by emanating streaks and scattered chips. Designed for short
    radial extent so it stays readable at typical stamp sizes (~10-20 cm)."""
    rng = random.Random(5)
    c = _new_canvas()
    cx, cy = 256, 256

    # Bright central core — the impact point itself.
    _stamp_dot(c, cx, cy, radius=24, intensity=1.0, blur=4.0)

    # Inner halo of diffuse damage.
    _stamp_dot(c, cx, cy, radius=58, intensity=0.55, blur=12.0)

    # Radial streaks emanating outward.
    for _ in range(34):
        angle = rng.uniform(0, 2 * math.pi)
        length = rng.uniform(40, 170)
        x_start = cx + math.cos(angle) * 10
        y_start = cy + math.sin(angle) * 10
        x_end = cx + math.cos(angle) * length
        y_end = cy + math.sin(angle) * length
        width = rng.uniform(2.5, 5.5)
        intensity = rng.uniform(0.7, 1.0)
        _stamp_streak(c, x_start, y_start, x_end, y_end,
                      width=width, taper=True, intensity=intensity, blur=0.9)

    # Scattered chips farther out.
    for _ in range(70):
        angle = rng.uniform(0, 2 * math.pi)
        radius = rng.uniform(70, 220)
        x = cx + math.cos(angle) * radius + rng.uniform(-12, 12)
        y = cy + math.sin(angle) * radius + rng.uniform(-12, 12)
        size = rng.uniform(1.5, 4.5)
        intensity = rng.uniform(0.5, 0.9)
        _stamp_dot(c, x, y, radius=size, intensity=intensity, blur=0.6)

    _save(c, "scratch_impact_splat.png")


def chip_cluster() -> None:
    """Paint-chip cluster — many small flecks concentrated near center.

    For minor-impact follow-on damage where paint flakes off in a cluster
    rather than as a continuous scratch."""
    rng = random.Random(6)
    c = _new_canvas()
    cx, cy = 256, 256

    # Dense central cluster — gaussian-distributed dots.
    for _ in range(180):
        x = cx + rng.gauss(0, 55)
        y = cy + rng.gauss(0, 55)
        size = rng.uniform(1.5, 5.0)
        intensity = rng.uniform(0.65, 1.0)
        _stamp_dot(c, x, y, radius=size, intensity=intensity, blur=0.5)

    # Sparse outliers so the edge isn't a hard cutoff.
    for _ in range(45):
        x = cx + rng.uniform(-200, 200)
        y = cy + rng.uniform(-200, 200)
        size = rng.uniform(1.0, 2.8)
        intensity = rng.uniform(0.4, 0.7)
        _stamp_dot(c, x, y, radius=size, intensity=intensity, blur=0.4)

    _save(c, "scratch_chip_cluster.png")


def tbone() -> None:
    """Right-angle scuff — main scratch with a perpendicular branch.

    Reads as a corner/edge impact: one long primary line and a shorter
    branch joining at one end."""
    rng = random.Random(7)
    c = _new_canvas()

    # Main horizontal scratch.
    _stamp_streak(c, 60, 256, 460, 256,
                  width=12.0, taper=True, intensity=1.0, blur=1.0)
    # Perpendicular branch joining near the right end of the main scratch.
    _stamp_streak(c, 380, 90, 380, 422,
                  width=10.5, taper=True, intensity=0.95, blur=1.0)

    # Secondary hairs around both axes.
    for _ in range(14):
        if rng.random() < 0.5:
            y = 256 + rng.uniform(-22, 22)
            x_start = 70 + rng.uniform(-20, 20)
            x_end = 460 + rng.uniform(-20, 20)
            _stamp_streak(c, x_start, y, x_end, y,
                          width=rng.uniform(1.5, 3.0), taper=True,
                          intensity=rng.uniform(0.45, 0.75), blur=0.9)
        else:
            x = 380 + rng.uniform(-22, 22)
            y_start = 100 + rng.uniform(-20, 20)
            y_end = 412 + rng.uniform(-20, 20)
            _stamp_streak(c, x, y_start, x, y_end,
                          width=rng.uniform(1.5, 3.0), taper=True,
                          intensity=rng.uniform(0.45, 0.75), blur=0.9)

    _save(c, "scratch_tbone.png")


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    streak_01()
    streak_02()
    streak_03()
    streak_04()
    impact_splat()
    chip_cluster()
    tbone()
    print("done.")


if __name__ == "__main__":
    main()
