"""Generate the ground-mark textures (art/scratches/ground/).

Paint a scraping panel leaves on the road is a dry-brushed transfer: thin
parallel bristle lines along the direction of travel, broken where the
aggregate did not touch, soft at the sides and tapered at both ends so
consecutive segments overlap without a visible joint.

  streak_1..3  paint transfer, travel runs along the image's vertical axis
  rubber_1     denser, softer smear for a dragged rim / sidewall
  chips_1      scatter of small flecks for a hard hit on the ground

White RGB, shape in alpha; groundPaint.lua tints it through the decal colour.
These are drawn by Engine.Render.DynamicDecalMgr, not the dynamic-decal brush
pipeline, so they need no .dynDecalTexture.json sidecar.
Fixed seeds, byte-reproducible. Requires numpy and Pillow.
Run: python tools/generate_ground.py
"""

import os

import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.normpath(os.path.join(HERE, "..", "art", "scratches", "ground"))
W, H = 64, 256


def smooth_noise(rng, w, h, cell_x, cell_y):
    """Value noise stretched by (cell_x, cell_y) pixels, 0..1."""
    gw, gh = max(2, w // cell_x + 2), max(2, h // cell_y + 2)
    small = Image.fromarray((rng.random((gh, gw)) * 255).astype(np.uint8), "L")
    big = small.resize((w, h), Image.BICUBIC)
    return np.asarray(big, dtype=np.float32) / 255.0


def envelope(w, h, side_soft, end_soft):
    x = np.linspace(-1.0, 1.0, w, dtype=np.float32)[None, :]
    y = np.linspace(-1.0, 1.0, h, dtype=np.float32)[:, None]
    side = np.clip((1.0 - np.abs(x)) / side_soft, 0.0, 1.0)
    end = np.clip((1.0 - np.abs(y)) / end_soft, 0.0, 1.0)
    return (side * side * (3 - 2 * side)) * (end * end * (3 - 2 * end))


def streak(seed, density, breakup):
    rng = np.random.default_rng(seed)
    # Bristles: each column has its own strength, so the mark is made of lines.
    bristle = rng.random(W).astype(np.float32)
    bristle = np.convolve(bristle, [0.25, 0.5, 0.25], mode="same")
    bristle = np.clip((bristle - (1.0 - density)) / 0.25, 0.0, 1.0)[None, :]
    # Breaks along the travel: long thin gaps where the road's low spots missed.
    gaps = smooth_noise(rng, W, H, 5, 22)
    grit = smooth_noise(rng, W, H, 2, 3)
    body = np.clip((gaps * 0.75 + grit * 0.45 - breakup) / 0.22, 0.0, 1.0)
    # A wandering centre line keeps the edges from being ruler straight.
    wander = (smooth_noise(rng, 1, H, 1, 40) - 0.5) * 0.35
    x = np.linspace(-1.0, 1.0, W, dtype=np.float32)[None, :]
    lane = np.clip((0.82 - np.abs(x - wander)) / 0.30, 0.0, 1.0)
    alpha = bristle * body * lane * envelope(W, H, 0.35, 0.22)
    return alpha


def rubber(seed):
    rng = np.random.default_rng(seed)
    grain = smooth_noise(rng, W, H, 3, 30)
    grit = smooth_noise(rng, W, H, 2, 2)
    body = np.clip(0.45 + grain * 0.55 - grit * 0.25, 0.0, 1.0)
    return body * envelope(W, H, 0.55, 0.25)


def chips(seed, size=128):
    rng = np.random.default_rng(seed)
    alpha = np.zeros((size, size), dtype=np.float32)
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32)
    for _ in range(46):
        r = abs(rng.normal(0.0, 0.22)) * size * 0.5
        a = rng.uniform(0.0, 2.0 * np.pi)
        cx, cy = size / 2 + np.cos(a) * r, size / 2 + np.sin(a) * r
        rx, ry = rng.uniform(1.2, 5.0), rng.uniform(1.0, 3.2)
        t = rng.uniform(0.0, np.pi)
        dx, dy = xx - cx, yy - cy
        u = (dx * np.cos(t) + dy * np.sin(t)) / rx
        v = (-dx * np.sin(t) + dy * np.cos(t)) / ry
        fleck = np.clip(1.25 - (u * u + v * v), 0.0, 1.0) * rng.uniform(0.5, 1.0)
        alpha = np.maximum(alpha, fleck)
    return alpha * envelope(size, size, 0.2, 0.2)


def save(name, alpha, blur=0.6):
    a = Image.fromarray((np.clip(alpha, 0.0, 1.0) * 255).astype(np.uint8), "L")
    a = a.filter(ImageFilter.GaussianBlur(blur))
    h, w = alpha.shape
    white = Image.new("L", (w, h), 255)
    img = Image.merge("RGBA", (white, white, white, a))
    path = os.path.join(OUT_DIR, name + ".png")
    img.save(path, optimize=False)
    print("wrote", os.path.relpath(path, os.path.join(HERE, "..")))


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    save("streak_1", streak(4101, density=0.62, breakup=0.42))
    save("streak_2", streak(4102, density=0.48, breakup=0.50))
    save("streak_3", streak(4103, density=0.74, breakup=0.36))
    save("rubber_1", rubber(4201), blur=1.0)
    save("chips_1", chips(4301), blur=0.5)


if __name__ == "__main__":
    main()
