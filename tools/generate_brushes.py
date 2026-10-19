"""
Generate the damage-brush PNGs for the dynamic-decal painter.

Output: art/dynamicDecals/textures/scr_*.png (+ .dynDecalTexture.json sidecars)
Format: 512x512 RGBA.

Real paint is a ~0.1 mm stack: clear coat, colour, primer, e-coat, metal. A
mark shows those layers as nested bands, each deeper layer inside the last
(see investigations/04-crash-damage-realism.md). So most brushes here are
built from ONE damage-depth field, thresholded into the stack, and the layer
colours are baked into RGB. The painter stamps them with a near-white tint,
so a layered mark costs one decal. Only the layers above the primer depend
on the car's colour, and those are translucent white (scuffed clear coat) or
come from the separately tinted haze brush.

Families (all drawn along +x; the painter rotates them):
  scr_rash_<panel><tier><v>   slide band. Thin where the abrading point bit
                              in (x=0), debris piled near x=1, faded at both
                              ends so overlapping segments blend.
  scr_chip_<panel><tier><v>   impact: angular flakes, deepest at the centre.
  scr_gouge_<panel><v>        hard dig-in: crater + scores trailing to +x.
  scr_pepper_<panel><v>       gravel: a cloud of small layered chips.
  scr_smear_<v>               alpha only: streaky transfer (soil, grass, zinc,
                              rubber, bark), tinted by the painter.
  scr_splat_<v>               alpha only: mud/grass spatter for impacts.
  scr_haze_<nn>               alpha only: scuffed clear coat under bands.
panel: m = painted metal (primer, e-coat, steel)
       p = painted plastic bumper (stress-whitening, adhesion primer, black PP)
tier:  1 = scuff (clear coat + primer flecks), 2 = primer with e-coat
       islands, 3 = through to bare steel / raw plastic.

Colours are authored in sRGB. Scale matters more than detail: the car's paint
canvas resolves ~1.5 mm per texel, so a band narrower than ~5 px here (at a
typical 20 cm decal) disappears in game - tools/preview_brushes.py shows each
brush at that resolution. Every brush is drawn at 2x and downsampled
(premultiplied) for clean edges, and has a fixed seed, so re-running produces
identical files.

Run: python tools/generate_brushes.py
"""

import glob
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

# Brushes from earlier generations. Deleted on each run so a renamed brush
# can't linger in the shipped zip.
RETIRED = ["scratch_streak_01", "scratch_streak_02", "scratch_streak_03", "scratch_streak_05",
           "scratch_raptor_claw_01", "scratch_raptor_claw_02", "scratch_chip_cluster",
           "scratch_tbone",
           "scr_scrape_01", "scr_scrape_02", "scr_scrape_03",
           "scr_chips_01", "scr_chips_02", "scr_gouge_01", "scr_gouge_02"]

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


def pepper(name, seed, panel):
    """Gravel: a loose cloud of small angular chips. Bigger chips go deeper
    (primer rim, e-coat or steel core)."""
    rng = _rng(seed)
    x, y = _grid()
    cloud = np.clip(1 - np.sqrt(((x - 0.5) / 0.42) ** 2 + ((y - 0.5) / 0.30) ** 2)
                    + 0.5 * (_fbm(rng, 4, 3) - 0.5), 0, 1)
    levels = [Image.new("L", (N, N), 0) for _ in range(3)]
    draws = [ImageDraw.Draw(im) for im in levels]
    placed = 0
    while placed < 150:
        px, py = rng.random(2)
        if rng.random() > np.interp(cloud[int(py * (N - 1)), int(px * (N - 1))], [0, 0.6], [0, 1]):
            continue
        placed += 1
        size = min(18.0, (rng.pareto(2.5) + 1) * rng.uniform(2.5, 4.5)) * SS   # px at working size
        k = int(rng.integers(5, 8))
        cxp, cyp = px * N, py * N
        _polygon(draws[0], cxp, cyp, size, rng, k)
        if size > 7 * SS:
            _polygon(draws[1], cxp, cyp, size * 0.55, rng, k)
        if size > 11 * SS:
            _polygon(draws[2], cxp, cyp, size * 0.3, rng, k)
    lv = [np.asarray(im, np.float32) / 255 for im in levels]
    depth = np.maximum.reduce([lv[0] * 0.52, lv[1] * 0.72, lv[2] * 0.86])
    depth = np.maximum(depth, 0.22 * cloud * _fbm(rng, 3, 4, (6, 1)))   # dust-dull between chips
    _save(_stack(depth, panel, _fbm(rng, 4, 3)), name)


def smear(name, seed):
    """Transfer streaks along x: grit-textured, ragged, heavier toward the
    trailing end. Alpha only - the painter tints it (soil, grass, zinc,
    rubber, bark)."""
    rng = _rng(seed)
    x, y = _grid()
    centre = 0.5 + 0.05 * (_up(rng.random((1, 6)), N, N) - 0.5)
    half = 0.30 + 0.08 * (_up(rng.random((1, 8)), N, N) - 0.5)
    across = np.clip(1 - np.abs(y - centre) / half + 0.3 * (_fbm(rng, 5, 3, (1, 6)) - 0.5), 0, 1) ** 0.5
    streak = _fbm(rng, 3, 5, (14, 0.5))
    a = across * np.clip((streak - 0.34) * 4.0, 0, 1)
    grit = _fbm(rng, 48, 2)                                           # fine grain at canvas scale
    a *= 0.55 + 0.45 * _smoothstep(0.35, 0.65, grit)
    lumps = _smoothstep(0.66, 0.74, _fbm(rng, 20, 3, (1.6, 0.8)))
    a = np.maximum(a, across * lumps * 0.9)                           # packed lumps
    a *= (0.45 + 0.55 * _smoothstep(0, 0.9, x)) * _x_fade(x, 0.10, 0.08)
    _save(_alpha_only(np.clip(a, 0, 1)), name)


def splat(name, seed):
    """Mud/grass spatter: an irregular packed patch where it hit, droplets
    flung outward (stretching the further they fly). Alpha only - tinted by
    the painter."""
    rng = _rng(seed)
    x, y = _grid()
    r = np.sqrt((x - 0.5) ** 2 + (y - 0.5) ** 2)
    core = _smoothstep(0.50, 0.62, 1 - r / 0.20 + 0.9 * (_fbm(rng, 7, 4) - 0.5))
    img = Image.new("L", (N, N), 0)
    d = ImageDraw.Draw(img)
    for _ in range(220):
        ang = rng.uniform(0, 2 * np.pi)
        dist = (0.10 + abs(rng.normal(0, 0.17)))
        rad = min(13.0, (rng.pareto(2.6) + 0.7) * 2.2) * SS
        stretch = 1 + min(2.5, dist * 6)                              # far drops streak outward
        cxp, cyp = 0.5 * N + np.cos(ang) * dist * N, 0.5 * N + np.sin(ang) * dist * N
        t = np.linspace(0, 2 * np.pi, 14, endpoint=False)
        ex = rad * stretch * np.cos(t) * np.where(np.cos(t) > 0, 1.0, 0.6)   # teardrop: tail inward
        ey = rad * np.sin(t) * (1 - 0.25 * np.maximum(np.cos(t), 0))
        ca, sa = np.cos(ang), np.sin(ang)
        d.polygon([(cxp + ca * a - sa * b, cyp + sa * a + ca * b) for a, b in zip(ex, ey)],
                  fill=int(rng.uniform(170, 255)))
    a = np.maximum(core * (0.75 + 0.25 * _fbm(rng, 24, 2)), np.asarray(img, np.float32) / 255)
    _save(_alpha_only(a), name)


# ------------------------------------------------------- haze (unchanged) --
# The haze brushes predate the depth-field families; their generator is kept
# verbatim so re-running leaves scr_haze_* byte-identical.

def _noise1d(rng: np.random.Generator, n: int, smooth: int) -> np.ndarray:
    raw = rng.standard_normal(n + smooth * 4)
    k = np.hanning(max(3, smooth * 2 + 1))
    v = np.convolve(raw, k / k.sum(), mode="same")[smooth * 2: smooth * 2 + n]
    return v / (np.abs(v).max() + 1e-9)


def _line(canvas, rng, y0, x0, x1, width, strength, gap=0.25, wave=1.5, rough=0.3, slope=0.0):
    xa, xb = int(x0 * SS), int(x1 * SS)
    n = xb - xa
    if n < 4:
        return
    t = np.linspace(0, 1, n)
    yc = (y0 + slope * (t - 0.5) + wave * _noise1d(rng, n, 60)) * SS
    hw = 0.5 * width * SS * (1 + rough * _noise1d(rng, n, 12))
    taper = _smoothstep(0, 0.06 + 0.06 * rng.random(), t) * _smoothstep(0, 0.12 + 0.1 * rng.random(), 1 - t)
    amp = strength * np.ones(n)
    if gap > 0:
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


def _save_alpha_legacy(canvas: np.ndarray, name: str) -> None:
    img = Image.fromarray(np.clip(canvas * 255.0, 0, 255).astype(np.uint8), mode="L")
    a = np.asarray(img.resize((SIZE, SIZE), Image.LANCZOS))
    white = np.full_like(a, 255)
    out = os.path.join(OUT_DIR, name + ".png")
    Image.fromarray(np.stack([white, white, white, a], axis=-1), mode="RGBA").save(out)
    with open(out + ".dynDecalTexture.json", "w") as f:
        json.dump({"version": 2, "vehicle": "", "isSdfCompatible": False,
                   "tags": ["shape", "scratch"], "type": 0}, f)
    print(f"wrote {out}")


def haze(name: str, seed: int) -> None:
    """Scuffed clear coat: streaky soft abrasion with faint micro-lines."""
    rng = np.random.default_rng(seed)
    y = np.linspace(-1, 1, N)[:, None]
    x = np.linspace(0, 1, N)[None, :]
    edge = 0.55 + 0.18 * _noise1d(rng, N, 80)[None, :]
    band = _smoothstep(0, 0.35, edge - np.abs(y - 0.08 * _noise1d(rng, N, 120)[None, :]))
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
    c *= (_smoothstep(0, 0.18, np.linspace(0, 1, N)) * _smoothstep(0, 0.18, 1 - np.linspace(0, 1, N)))[None, :] \
        * (0.85 + 0.15 * x)
    _save_alpha_legacy(np.clip(c, 0, 1), name)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    for old in RETIRED:
        for p in glob.glob(os.path.join(OUT_DIR, old + ".png*")):
            os.remove(p)
            print(f"removed {p}")
    seed = 1000
    for panel in ("m", "p"):
        for tier in (1, 2, 3):
            for v in ("a", "b"):
                seed += 1
                rash(f"scr_rash_{panel}{tier}{v}", seed, panel, tier)
                chip(f"scr_chip_{panel}{tier}{v}", seed + 500, panel, tier)
        for v in ("a", "b"):
            seed += 1
            gouge(f"scr_gouge_{panel}{v}", seed + 900, panel)
    pepper("scr_pepper_ma", 1801, "m")
    pepper("scr_pepper_mb", 1802, "m")
    pepper("scr_pepper_pa", 1803, "p")
    smear("scr_smear_a", 1901)
    smear("scr_smear_b", 1902)
    splat("scr_splat_a", 2001)
    splat("scr_splat_b", 2002)
    haze("scr_haze_01", 404)
    haze("scr_haze_02", 505)


if __name__ == "__main__":
    main()
