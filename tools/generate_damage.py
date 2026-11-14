"""Generate the ten milestone-4 body-damage brushes (512x512 RGBA).
Selected nested-depth raster algorithm from b4e4036; no material/runtime code.
Fixed seeds, premultiplied downsampling, primer/dark-coating/highlight variation.
Requires numpy, Pillow, scipy. Does not replace soil or legacy probe brushes.
Run: python tools/generate_damage.py
"""

import json
import os

import numpy as np
from PIL import Image, ImageDraw
from scipy.spatial import cKDTree

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.normpath(os.path.join(HERE, "..", "art", "dynamicDecals", "textures"))
SIZE = 512
SS = 2                    # supersampling factor
N = SIZE * SS             # working canvas size

# ------------------------------------------------------------ paint stack --
# (depth threshold, sRGB colour, opacity, ramp), outermost first. A pixel
# shows every layer whose threshold its depth passes; deeper layers cover the
# rest. ramp > 0 fades the layer in over that much depth instead of a hard
# edge, so the scuffed clear coat follows the streaks rather than forming a
# flat milky slab.
WHITE = (1.0, 1.0, 1.0)
PRIMER = (0.74, 0.74, 0.72)       # light grey surfacer; the painter darkens it on dark cars
ECOAT = (0.19, 0.20, 0.21)        # cathodic e-coat: near-black grey
STEEL = (0.80, 0.81, 0.83)
WHITENED = (0.87, 0.86, 0.84)     # stress-whitened bumper paint
ADHESION = (0.31, 0.32, 0.33)     # plastic adhesion primer
RAW_PP = (0.12, 0.12, 0.13)       # raw black polypropylene

STACKS = {
    "m": [(0.08, WHITE, 0.32, 0.36),   # clear coat scuffed milky
          (0.42, WHITE, 0.35, 0.0),    # fractured clear-coat edge catches light
          (0.47, PRIMER, 1.0, 0.0),
          (0.66, ECOAT, 1.0, 0.0),
          (0.80, STEEL, 1.0, 0.0)],
    "p": [(0.08, WHITE, 0.32, 0.36),
          (0.42, WHITENED, 0.80, 0.06),
          (0.66, ADHESION, 1.0, 0.0),
          (0.78, RAW_PP, 1.0, 0.0)],
}
# Depth gain per tier: how far into the stack the same field reaches.
# Tier 1 tops out in the primer (scuff + flecks), tier 3 reaches the metal.
TIER_GAIN = {1: 0.55, 2: 0.82, 3: 1.10}


# ---------------------------------------------------------------- helpers --

def _rng(seed):
    return np.random.default_rng(seed)


def _up(a, h=N, w=N):
    """Bicubic upscale of a small float array to h x w."""
    im = Image.fromarray(np.asarray(a, np.float32), mode="F")
    return np.asarray(im.resize((w, h), Image.BICUBIC), np.float32)


def _fbm(rng, cells, octaves=4, aniso=(1.0, 1.0)):
    """Fractal value noise in ~[0, 1]. aniso=(rows, cols) scales the cell count
    per axis, so (8, 0.5) gives streaks long along x."""
    out = np.zeros((N, N), np.float32)
    amp, tot = 1.0, 0.0
    for o in range(octaves):
        ch = max(2, int(cells * aniso[0] * 2 ** o))
        cw = max(2, int(cells * aniso[1] * 2 ** o))
        out += amp * _up(rng.random((ch, cw)))
        tot += amp
        amp *= 0.5
    return np.clip(out / tot, 0, 1)


def _grid():
    """Normalised pixel coordinates x (along the brush), y (across), 0..1."""
    c = (np.arange(N, dtype=np.float32) + 0.5) / N
    return np.meshgrid(c, c)


def _cells(rng, n, region=(0.0, 1.0, 0.0, 1.0)):
    """Voronoi flakes: per-pixel random value of the nearest site, and the
    distance (px at working size) to the nearest cell border."""
    x0, x1, y0, y1 = region
    sites = np.column_stack([rng.uniform(y0, y1, n), rng.uniform(x0, x1, n)]) * N
    yy, xx = np.mgrid[0:N, 0:N]
    d, idx = cKDTree(sites).query(np.column_stack([yy.ravel(), xx.ravel()]), k=2)
    value = rng.random(n)[idx[:, 0]].reshape(N, N).astype(np.float32)
    border = (d[:, 1] - d[:, 0]).reshape(N, N).astype(np.float32)
    return value, border


def _smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def _x_fade(x, lo=0.08, hi=0.08):
    """Fade the brush out at both x ends so stretched, overlapping segments
    blend instead of showing seams."""
    return _smoothstep(0, lo, x) * _smoothstep(0, hi, 1 - x)


def _stack(depth, panel, tint_noise=None):
    """Threshold a depth field into the paint stack. Returns premultiplied
    RGBA (N x N x 4), sRGB."""
    out = np.zeros((N, N, 4), np.float32)
    for thr, col, alpha, ramp in STACKS[panel]:
        if ramp > 0:
            m = _smoothstep(thr, thr + ramp, depth) * alpha
        else:
            m = (depth >= thr).astype(np.float32) * alpha
        rgb = np.broadcast_to(np.asarray(col, np.float32), (N, N, 3))
        if tint_noise is not None and alpha >= 1.0:
            # Deeper layers aren't flat: brushed metal, uneven primer.
            amp = 0.07 if col == STEEL else 0.03
            rgb = np.clip(rgb + amp * (tint_noise[..., None] - 0.5) * 2, 0, 1)
        out[..., :3] = rgb * m[..., None] + out[..., :3] * (1 - m[..., None])
        out[..., 3] = m + out[..., 3] * (1 - m)
    return out


def _alpha_only(alpha):
    """White RGB, shape in alpha (premultiplied)."""
    a = np.clip(alpha, 0, 1).astype(np.float32)
    return np.stack([a, a, a, a], axis=-1)


def _save(prem: np.ndarray, name: str) -> None:
    """prem: N x N x 4 premultiplied RGBA in [0, 1]. Downsample, un-premultiply
    (fully transparent texels get white, matching the outermost scuff layer, so
    bilinear sampling at mark edges doesn't fringe dark), write the sidecar."""
    chans = [np.asarray(Image.fromarray(prem[..., c], mode="F").resize((SIZE, SIZE), Image.LANCZOS))
             for c in range(4)]
    a = np.clip(chans[3], 0, 1)
    rgb = np.ones((SIZE, SIZE, 3), np.float32)
    nz = a > 1.0 / 512
    for c in range(3):
        rgb[..., c][nz] = np.clip(chans[c][nz] / a[nz], 0, 1)
    img = np.dstack([rgb, a[..., None]])
    out = os.path.join(OUT_DIR, name + ".png")
    Image.fromarray((img * 255 + 0.5).astype(np.uint8), mode="RGBA").save(out, optimize=True)
    # Without this sidecar the dynamic-decals system registers nothing and the
    # brush stamps invisibly.
    with open(out + ".dynDecalTexture.json", "w") as f:
        json.dump({"version": 2, "vehicle": "", "isSdfCompatible": False,
                   "tags": ["shape", "scratch"], "type": 0}, f)
    print(f"wrote {out}")


def _track(x, y, rng, y0, x0, x1, width, depth, slope=0.0):
    """A deep score from x0 to x1 along +x, gaussian cross-section (width in
    512 px). Thin where the point bit in, tapering out where it lifted off."""
    yc = y0 + slope * (x - x0) + 0.004 * np.sin(x * rng.uniform(6, 14) + rng.uniform(0, 6)) \
        + 0.006 * (_up(rng.random((1, 16)), N, N) - 0.5)
    life = _smoothstep(x0, x0 + 0.2, x) * (1 - _smoothstep(x1 - 0.18, x1, x))
    w = width / SIZE * (0.35 + 0.65 * life)
    t = np.exp(-((y - yc) / np.maximum(w, 1e-4)) ** 2)
    return depth * t * (0.4 + 0.6 * life) * ((x >= x0) & (x <= x1))


def _polygon(draw, cx, cy, size, rng, k=None):
    """Irregular angular flake outline (pixel units at working size)."""
    k = k or int(rng.integers(5, 9))
    angs = np.sort(rng.uniform(0, 2 * np.pi, k))
    rad = size * rng.uniform(0.55, 1.0, k)
    draw.polygon([(cx + r * np.cos(a), cy + r * np.sin(a)) for a, r in zip(angs, rad)], fill=255)


def _cracks(rng, count, r0, r1, cx=0.5, cy=0.5, width=2):
    """Straight-ish jagged radial cracks (paint crazing on flexed plastic),
    as a 0..1 mask."""
    img = Image.new("L", (N, N), 0)
    d = ImageDraw.Draw(img)
    for a0 in rng.uniform(0, 2 * np.pi, count):
        r, a = r0, a0
        pts = [(cx * N + r * N * np.cos(a), cy * N + r * N * np.sin(a))]
        end = rng.uniform(r0 + 0.08, r1)
        while r < end:
            r += rng.uniform(0.02, 0.04)
            a += rng.normal(0, 0.12)
            pts.append((cx * N + r * N * np.cos(a), cy * N + r * N * np.sin(a)))
            if rng.random() < 0.15:                                  # short side branch
                b = a + rng.choice([-1, 1]) * rng.uniform(0.4, 0.9)
                q = r + rng.uniform(0.02, 0.05)
                d.line([pts[-1], (cx * N + q * N * np.cos(b), cy * N + q * N * np.sin(b))],
                       fill=200, width=width * SS)
        d.line(pts, fill=255, width=width * SS)
    return np.asarray(img, np.float32) / 255


# ---------------------------------------------------------------- families --

def rash(name, seed, panel, tier):
    """Slide band (road rash): dense striations along x, a few deep tracks,
    thin where it starts, debris piled near the trailing end."""
    rng = _rng(seed)
    x, y = _grid()
    centre = 0.5 + 0.06 * (_up(rng.random((1, 6)), N, N) - 0.5)
    half = (0.30 + 0.07 * (_up(rng.random((1, 10)), N, N) - 0.5)) * (0.55 + 0.45 * _smoothstep(0, 0.45, x))
    rag = 0.30 * (_fbm(rng, 5, 3, (1, 6)) - 0.5)                       # ragged band edges
    across = np.clip(1 - np.abs(y - centre) / half + rag, 0, 1) ** 0.6
    streak = _fbm(rng, 3, 5, (14, 0.5))                                # long along x
    depth = across * (0.22 + 1.0 * streak ** 1.7)
    for _ in range(rng.integers(2, 5)):
        x0 = rng.uniform(0.0, 0.3)
        depth = np.maximum(depth, _track(x, y, rng, float(np.clip(rng.normal(0.5, 0.09), 0.3, 0.7)),
                                         x0, rng.uniform(0.75, 1.0), rng.uniform(5, 10),
                                         rng.uniform(0.9, 1.1), rng.uniform(-0.03, 0.03))
                           * (across > 0.05))
    # Plowed paint and grit pile up where the scratch ends.
    flakes, border = _cells(rng, 70, (0.72, 0.98, 0.2, 0.8))
    pile = np.exp(-((x - 0.86) / 0.07) ** 2) * across
    depth = depth + 0.45 * pile * (0.4 + 0.6 * flakes) * (border > 1.6)
    depth *= TIER_GAIN[tier] * _x_fade(x, 0.06, 0.07)
    _save(_stack(depth, panel, _fbm(rng, 3, 3, (8, 1))), name)


def chip(name, seed, panel, tier):
    """Impact: paint knocked off in angular flakes, deepest at the centre,
    with smaller flakes knocked loose around it. Plastic tier 2+ adds the
    spiderweb crazing a flexed bumper cover gets."""
    rng = _rng(seed)
    x, y = _grid()
    rx, ry = rng.uniform(0.20, 0.27), rng.uniform(0.17, 0.24)
    r = np.sqrt(((x - 0.5) / rx) ** 2 + ((y - 0.5) / ry) ** 2)
    env = np.clip(1 - r + 0.9 * (_fbm(rng, 6, 4) - 0.5), 0, 1)
    cv, border = _cells(rng, 90)
    depth = env * 1.05 + 0.40 * (cv - 0.5) * (env > 0.08) + 0.30 * (_fbm(rng, 10, 4) - 0.5)
    depth = np.where(border < 3.2, depth - 0.10, depth)              # flakes part along borders
    depth = np.where(env < 0.04, 0, depth) * TIER_GAIN[tier]
    # Loose flakes around the crater: primer at most, whatever the tier.
    img = Image.new("L", (N, N), 0)
    d = ImageDraw.Draw(img)
    for _ in range(int(rng.integers(8, 16))):
        a, rr = rng.uniform(0, 2 * np.pi), rng.uniform(1.15, 1.9)
        _polygon(d, (0.5 + rr * rx * np.cos(a)) * N, (0.5 + rr * ry * np.sin(a)) * N,
                 rng.uniform(4, 11) * SS, rng)
    loose = np.asarray(img, np.float32) / 255
    depth = np.maximum(depth, loose * (0.30 + 0.09 * tier))
    if panel == "p" and tier >= 2:
        depth = np.maximum(depth, 0.45 * _cracks(rng, int(rng.integers(4, 7)), 0.10, 0.34))
    _save(_stack(depth, panel, _fbm(rng, 4, 3)), name)


def gouge(name, seed, panel):
    """Hard dig-in at the left, deep scores tapering out toward +x, flakes
    piled where each one ends."""
    rng = _rng(seed)
    x, y = _grid()
    cx, cy = 0.24, 0.5
    r = np.sqrt(((x - cx) / 0.09) ** 2 + ((y - cy) / 0.11) ** 2)
    env = np.clip(1 - r + 0.7 * (_fbm(rng, 8, 3) - 0.5), 0, 1)
    cv, border = _cells(rng, 60, (0.1, 0.4, 0.3, 0.7))
    depth = env * 1.3 + 0.3 * (cv - 0.5) * (env > 0.05)
    depth = np.where((border < 3.0) & (env > 0), depth - 0.12, depth)
    img = Image.new("L", (N, N), 0)
    d = ImageDraw.Draw(img)
    for _ in range(int(rng.integers(1, 4))):
        y0 = cy + rng.normal(0, 0.04)
        x1 = rng.uniform(0.6, 0.92)
        slope = rng.uniform(-0.06, 0.06)
        depth = np.maximum(depth, _track(x, y, rng, y0, cx - 0.04, x1, rng.uniform(6, 11), 1.15, slope))
        ey = y0 + slope * (x1 - cx)
        for _ in range(int(rng.integers(3, 7))):                       # flakes at the score's end
            _polygon(d, (x1 + rng.normal(0, 0.03)) * N, (ey + rng.normal(0, 0.03)) * N,
                     rng.uniform(3, 8) * SS, rng)
    depth = np.maximum(depth, 0.55 * np.asarray(img, np.float32) / 255)
    wake = np.clip(1 - np.abs(y - cy) / 0.10, 0, 1) * (1 - _smoothstep(0.4, 0.9, x)) * (x > cx)
    depth = np.maximum(depth, 0.30 * wake * _fbm(rng, 3, 4, (10, 0.6)))  # scuffed wake
    depth *= _x_fade(x, 0.04, 0.06)
    _save(_stack(depth, panel, _fbm(rng, 3, 3, (8, 1))), name)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    for variant, seed in (("a",1003),("b",1004),("c",1005),("d",1006)):
        rash("m4_rash_"+variant, seed, "m", 2)
        chip("m4_chip_"+variant, seed+500, "m", 2)
    gouge("m4_gouge_a",1907,"m")
    gouge("m4_gouge_b",1908,"m")

if __name__ == "__main__":
    main()
