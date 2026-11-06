"""
Generate the scratch-brush PNGs and micro-scratch detail maps for the painter.

Brushes: art/dynamicDecals/textures/scr_*.png (+ .dynDecalTexture.json sidecars)
  512x512 RGBA, RGB = white, shape in alpha, drawn along +x (the painter
  rotates them to the slide direction and tints them per stamp).

  scr_haze_*        abraded clear coat: an organic, feathered patch of
                    streaky abrasion running along x (ref photo 1). It fills
                    most of its square; the painter sets the patch's aspect.
  scr_streak_*      a scrape band: primer streaks of very different lengths
                    and weights - blunt heavy starts, tapered tails, dashed
                    breaks, frayed edges, fine scores between (ref photo 2).
  scr_drag_*        an impact's drag marks: a short cluster of the same
                    strokes, starting and stopping inside an oval.
  scr_gouge_NN_rim  a torn gouge's paint edge (primer) and
  scr_gouge_NN_core its bare-metal core: the same gouge, nested (ref photo 4).
  scr_chips_*       a few sharp-edged shards in loose groups downstream of
                    the hit, each its own size and opacity; never radial.
  scr_smear_*       paint/rubber transfer: a streaky, broken smudge.

Detail maps: art/scratches/scratch_detail_{b,r}.data.png, _n.normal.png
  1024x1024, tileable micro-scratches. The damage layer (paint.lua
  setupDamageLayer) tiles them across the paint canvas, so damaged areas get
  scratch texture finer than the canvas itself can hold (~3-5 mm a texel on a
  car): b brightens the scratch lines, r roughens them, n gives them relief.

How brush alpha reads in game: a mark writes the canvas roughness that the
damage layer fades the factory paint by, so gloss is lost where alpha is
above ~0.5 (fully at 1) while colour blends at any alpha. Mark interiors are
kept above 0.55 and the soft outer fringe is a colour-only feather.

Scale: the canvas is the limit, not these PNGs. A streak band is stamped
10-20 cm across 512 px (~0.3 mm/px), so nothing here is narrower than ~12 px
(~4 mm); finer scratching is the detail maps' job.

Every texture has a fixed seed, so re-running produces identical files.

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
DETAIL_DIR = os.path.normpath(os.path.join(HERE, "..", "art", "scratches"))
SIZE = 512
SS = 2                    # supersampling factor
N = SIZE * SS             # working canvas size

# Brushes from earlier generations. Deleted on each run so a renamed brush
# can't linger in the shipped zip.
RETIRED = ["scratch_streak_01", "scratch_streak_02", "scratch_streak_03", "scratch_streak_05",
           "scratch_raptor_claw_01", "scratch_raptor_claw_02", "scratch_chip_cluster",
           "scratch_tbone", "scr_scrape_01", "scr_scrape_02", "scr_scrape_03", "scr_gouge_01",
           "scr_gouge_02"]


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


def _noise2d(rng: np.random.Generator, shape: tuple[int, int], cells: tuple[int, int]) -> np.ndarray:
    """Smooth 2D value noise in [0, 1]; cells = (rows, cols) of the lattice,
    so anisotropic cells stretch features along the axis with fewer cells."""
    coarse = rng.random((cells[0] + 1, cells[1] + 1)).astype(np.float32)
    img = Image.fromarray((coarse * 255).astype(np.uint8)).resize((shape[1], shape[0]), Image.BICUBIC)
    return np.asarray(img, np.float32) / 255.0


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
          rough: float = 0.3, slope: float = 0.0, head: float = 0.08, tail: float = 0.25,
          swell: float = 0.0) -> None:
    """One streak along +x (units: final 512-px brush pixels).
    width: mean full width; gap: fraction of the length broken into real
    gaps; rough: width wobble; wave: low-frequency wander; head/tail: taper
    lengths as a fraction of the length (a blunt start, a long tail);
    swell: extra width near the start (where the edge first bit in)."""
    xa, xb = int(max(0, x0) * SS), int(min(SIZE, x1) * SS)
    n = xb - xa
    if n < 4:
        return
    t = np.linspace(0, 1, n)
    yc = (y0 + slope * (t - 0.5) + wave * _noise1d(rng, n, 60)) * SS
    hw = 0.5 * width * SS * (1 + rough * (0.7 * _noise1d(rng, n, 28) + 0.3 * _noise1d(rng, n, 7)))
    hw *= 1 + swell * np.exp(-t / 0.15)
    taper = _smoothstep(0, head, t) * _smoothstep(0, tail, 1 - t)
    amp = strength * np.ones(n)
    if gap > 0:
        # Skips: where the edge lifted off the panel the line pinches to a
        # point and breaks (width, not opacity, goes to zero).
        g = _noise1d(rng, n, 30)
        cut = 1 - 2 * gap
        taper *= 1 - _smoothstep(cut - 0.25, cut, g)
    hw = np.maximum(hw * taper, 0)
    lo = int(max(0, np.floor((yc - hw).min()) - 2))
    hi = int(min(N, np.ceil((yc + hw).max()) + 3))
    if hi <= lo:
        return
    rows = np.arange(lo, hi)[:, None]
    cov = np.clip(hw[None, :] - np.abs(rows - yc[None, :]) + 0.5, 0, 1) * amp[None, :]
    region = canvas[lo:hi, xa:xb]
    np.maximum(region, cov, out=region)


def _flake_poly(rng: random.Random, cx: float, cy: float, size: float, stretch: float = 1.0):
    """Sharp-edged irregular flake outline (supersampled px)."""
    k = rng.randint(5, 9)
    pts = []
    for i in range(k):
        ang = 2 * math.pi * (i + rng.uniform(-0.35, 0.35)) / k
        r = size * rng.uniform(0.4, 1.0)
        pts.append((cx + r * math.cos(ang) * stretch, cy + r * 0.75 * math.sin(ang)))
    return pts


def _flakes(rng: random.Random, spots: list[tuple[float, float, float]], stretch: float = 1.0) -> np.ndarray:
    """Canvas with a flake at each (x, y, size) in final px."""
    img = Image.new("L", (N, N), 0)
    d = ImageDraw.Draw(img)
    for x, y, s in spots:
        d.polygon(_flake_poly(rng, x * SS, y * SS, s * SS, stretch), fill=255)
    return np.asarray(img, dtype=np.float32) / 255.0


def _blob(rng: np.random.Generator, aspect: float, wobble: float) -> np.ndarray:
    """Organic patch mask: an ellipse (long along x) with an fBm-ragged edge,
    1 inside, feathering to 0 across ~15% of its radius."""
    y = np.linspace(-1, 1, N)[:, None]
    x = np.linspace(-1, 1, N)[None, :]
    r = np.hypot(x, y * aspect)
    edge = 0.78 + wobble * (_noise2d(rng, (N, N), (5, 5)) - 0.5) + 0.5 * wobble * (
        _noise2d(rng, (N, N), (14, 14)) - 0.5)
    return _smoothstep(0, 0.15, edge - r)


# --------------------------------------------------------------- brushes --

def haze(name: str, seed: int, aspect: float) -> None:
    """Abraded clear coat: a ragged patch of streaky abrasion. The interior
    sits at 0.55-1 (dulled to matte), the fringe feathers out as tint only."""
    rng = np.random.default_rng(seed)
    env = _blob(rng, aspect, 0.35)
    streak = _noise2d(rng, (N, N), (90, 6))            # fast across y, slow along x
    fine = _noise2d(rng, (N, N), (220, 18))
    c = env * np.clip(0.55 + 0.32 * streak + 0.2 * (fine - 0.5), 0, 1)
    for _ in range(70):  # brighter score lines through the scuff
        yy = float(np.clip(rng.normal(0.5, 0.16), 0.1, 0.9)) * SIZE
        length = rng.uniform(0.1, 0.6)
        x0 = rng.uniform(0.05, 0.95 - length) * SIZE
        line = np.zeros_like(c)
        _line(line, rng, yy, x0, x0 + length * SIZE, rng.uniform(4, 9), strength=1.0, gap=0.3,
              wave=1.0, rough=0.3, slope=rng.uniform(-4, 4), head=0.2, tail=0.3)
        np.maximum(c, line * env, out=c)
    _save(np.clip(c, 0, 1), name)


def streak(name: str, seed: int, main: int, fine: int, spread: float, weight: float, hair: int = 24) -> None:
    """Scrape band: a few heavy primer streaks among many fine scores and
    faint hairlines (ref photo 2). weight scales stroke width (0..1). A band
    is one stamp, so its ends are the brush's ends: every stroke stops at its
    own point in the outer fifth at each end (all running to the edge drew a
    square end)."""
    rng = np.random.default_rng(seed)
    c = np.zeros((N, N), np.float32)

    def stroke(y0, x0, x1, *args, **kw):
        lo, hi = rng.uniform(0, 0.2) * SIZE, SIZE * (1 - rng.uniform(0, 0.2))
        x0, x1 = max(x0, lo), min(x1, hi)
        if x1 - x0 > 0.06 * SIZE:
            _line(c, rng, y0, x0, x1, *args, **kw)

    for _ in range(main):
        y = float(np.clip(rng.normal(0.5, spread), 0.1, 0.9)) * SIZE
        # Long-tailed lengths: a few cross the whole band, most are short.
        length = min(1.0, 0.18 + rng.pareto(1.6) * 0.18)
        x0 = rng.uniform(0.0, 1.0 - length) * SIZE
        heavy = rng.random() ** 2.2                         # most strokes light
        width = 10 + (6 + 18 * weight) * heavy              # ~3-10 mm
        # Strength varies by stroke: faint scores beside bright cut-through
        # lines (alpha below ~1 blends the tone back toward the paint). Few
        # breaks and a wandering path: dashed, straight heavy strokes baked
        # as chunky rectangular dashes.
        stroke(y, x0, x0 + length * SIZE, width, strength=float(rng.choice([0.55, 0.75, 0.9, 1.0, 1.0])),
              gap=rng.choice([0.0, 0.0, 0.0, 0.12]), wave=rng.uniform(1.5, 5.0), rough=0.5,
              slope=rng.uniform(-10, 10), head=rng.uniform(0.04, 0.1), tail=rng.uniform(0.3, 0.6),
              swell=rng.uniform(0.0, 0.4))
    for _ in range(fine):  # fine scores between the main strokes
        y = float(np.clip(rng.normal(0.5, spread * 1.2), 0.08, 0.92)) * SIZE
        length = rng.uniform(0.15, 0.8)
        x0 = rng.uniform(0.0, 1.0 - length) * SIZE
        stroke(y, x0, x0 + length * SIZE, rng.uniform(10, 14), strength=rng.uniform(0.45, 0.8),
              gap=0.12, wave=rng.uniform(0.5, 2.0), rough=0.25, slope=rng.uniform(-6, 6), head=0.15,
              tail=0.35)
    for _ in range(hair):  # hairlines: under the canvas's resolution they bake as faint, soft lines
        y = float(np.clip(rng.normal(0.5, spread * 1.4), 0.05, 0.95)) * SIZE
        length = rng.uniform(0.2, 0.95)
        x0 = rng.uniform(0.0, 1.0 - length) * SIZE
        stroke(y, x0, x0 + length * SIZE, rng.uniform(5, 8), strength=rng.uniform(0.25, 0.5),
              gap=0.08, wave=rng.uniform(0.5, 2.5), rough=0.2, slope=rng.uniform(-5, 5), head=0.2,
              tail=0.3)
    # A few flakes of paint lifted off the edges of the heaviest strokes.
    frng = random.Random(seed)
    spots = []
    ys, xs = np.nonzero(c[::8, ::8] > 0.95)
    for i in frng.sample(range(len(ys)), min(len(ys), 14)):
        spots.append((xs[i] * 8 / SS + frng.uniform(-6, 6), ys[i] * 8 / SS + frng.choice([-1, 1]) *
                      frng.uniform(5, 10), frng.uniform(5, 8)))
    np.maximum(c, _flakes(frng, spots, stretch=1.2), out=c)
    c *= _x_fade(0.12)[None, :]
    _save(c, name)


def drag(name: str, seed: int, main: int, fine: int, hair: int, weight: float) -> None:
    """An impact's drag marks: a short cluster of streaks that start and stop
    at staggered points inside an oval and taper out at both ends. A scrape
    band's streaks run to the brush ends so segments join; stamped once, that
    showed the brush's box."""
    rng = np.random.default_rng(seed)
    c = np.zeros((N, N), np.float32)

    def stroke(spread: float, frac: tuple[float, float], width: float, **kw) -> None:
        yf = float(np.clip(rng.normal(0.5, spread), 0.12, 0.88))
        half = 0.35 * math.sqrt(max(0.0, 1 - ((yf - 0.5) / 0.38) ** 2))  # the oval's half-length here
        if half < 0.06:
            return
        length = 2 * half * rng.uniform(*frac)
        x0 = 0.5 - half + rng.uniform(0, 2 * half - length)
        _line(c, rng, yf * SIZE, x0 * SIZE, (x0 + length) * SIZE, width, **kw)

    for _ in range(main):
        heavy = rng.random() ** 2.2
        stroke(0.13, (0.45, 1.0), 11 + (8 + 24 * weight) * heavy, strength=float(rng.choice([0.75, 0.9, 1.0])),
               gap=rng.choice([0.0, 0.15, 0.3]), wave=rng.uniform(0.8, 2.5), rough=0.45,
               slope=rng.uniform(-6, 6), head=rng.uniform(0.1, 0.2), tail=rng.uniform(0.35, 0.6),
               swell=rng.uniform(0.0, 0.5))
    for _ in range(fine):
        stroke(0.16, (0.3, 0.9), rng.uniform(10, 14), strength=rng.uniform(0.45, 0.8), gap=0.12,
               wave=rng.uniform(0.5, 2.0), rough=0.25, slope=rng.uniform(-5, 5), head=0.25, tail=0.4)
    for _ in range(hair):
        stroke(0.2, (0.4, 1.0), rng.uniform(5, 8), strength=rng.uniform(0.25, 0.5), gap=0.08,
               wave=rng.uniform(0.5, 2.5), rough=0.2, slope=rng.uniform(-4, 4), head=0.25, tail=0.35)
    c *= _blob(rng, 1.0, 0.3)
    _save(c, name)


def gouge(name: str, seed: int) -> None:
    """A gouge as two nested masks: _rim (torn paint edge, primer) and _core
    (bare metal) - the core always sits inside the rim. The core is most of
    the width and sits off-centre, so one side shows a thick torn primer lip
    and the other a thin one (ref photo 4); torn flakes gather on the thick
    side. (A narrow centred core was a couple of canvas texels wide and read
    as a pale scratch.)"""
    rng = np.random.default_rng(seed)
    frng = random.Random(seed)
    length = rng.uniform(0.62, 0.82) * SIZE
    x0 = (SIZE - length) / 2
    y = SIZE * 0.5
    w = rng.uniform(72, 92)
    lip = frng.choice([-1, 1])              # the side with the thick lip
    core = np.zeros((N, N), np.float32)
    _line(core, rng, y - lip * 0.12 * w, x0 + 0.05 * length, x0 + 0.88 * length, w * 0.72, strength=1.0,
          gap=0.04, wave=4, rough=0.45, head=0.08, tail=0.45, swell=0.35)
    rim = np.zeros((N, N), np.float32)
    _line(rim, np.random.default_rng(seed + 1), y, x0, x0 + length, w, strength=1.0, gap=0.0,
          wave=4, rough=0.6, head=0.06, tail=0.4, swell=0.45)
    np.maximum(rim, core, out=rim)
    spots = []
    for _ in range(40):
        t = frng.uniform(0.02, 0.98)
        side = lip if frng.random() < 0.8 else -lip
        spots.append((x0 + t * length + frng.gauss(0, 4), y + side * w * frng.uniform(0.4, 0.8),
                      frng.uniform(6, 15) * (1.2 - 0.6 * t)))
    for _ in range(8):
        spots.append((x0 + length * frng.uniform(0.85, 1.08), y + frng.gauss(0, w * 0.5), frng.uniform(4, 9)))
    np.maximum(rim, _flakes(frng, spots, stretch=1.4), out=rim)
    _save(rim, name + "_rim")
    _save(core, name + "_core")


def _shard_poly(rng: random.Random, cx: float, cy: float, size: float):
    """A paint shard (supersampled px): 4-7 corners at uneven radii, drawn
    out to one side and turned at random - a chip comes off in a sliver or
    a wedge, not a round flake."""
    k = rng.randint(4, 7)
    elong = rng.uniform(1.0, 2.4)
    turn = rng.uniform(0, math.pi)
    ct, st = math.cos(turn), math.sin(turn)
    pts = []
    for i in range(k):
        ang = 2 * math.pi * (i + rng.uniform(-0.4, 0.4)) / k
        r = size * rng.uniform(0.3, 1.0)
        x, y = r * math.cos(ang) * elong, r * math.sin(ang) / elong
        pts.append((cx + x * ct - y * st, cy + x * st + y * ct))
    return pts


def chips(name: str, seed: int, count: int) -> None:
    """A few sharp-edged shards scattered downstream (+x) of where the hit
    landed, in two or three loose groups: nothing radial, no row. Stamped
    ~8-11 cm across, a shard here is ~3-10 mm - a canvas texel or two
    (smaller ones blurred into a soft white cloud) - with a 3:1 size spread,
    and each its own opacity (0.65-1): where less primer shows through, the
    paint around it tints it darker."""
    rng = random.Random(seed)
    groups = [(SIZE * rng.uniform(0.25, 0.75), SIZE * rng.uniform(0.38, 0.62)) for _ in range(rng.randint(2, 3))]
    spots = []
    tries = 0
    while len(spots) < count and tries < 5000:
        tries += 1
        gx, gy = groups[rng.randrange(len(groups))]
        x = gx + rng.gauss(0, SIZE * 0.09)
        y = gy + rng.gauss(0, SIZE * 0.07)
        size = rng.uniform(16.0, 48.0) * (0.7 + 0.6 * rng.random() ** 2)
        if not (0.06 * SIZE < x < 0.94 * SIZE and 0.08 * SIZE < y < 0.92 * SIZE):
            continue
        if all((x - sx) ** 2 + (y - sy) ** 2 > (0.8 * (size + ss)) ** 2 for sx, sy, ss, _ in spots):
            spots.append((x, y, size, rng.uniform(0.65, 1.0)))
    img = Image.new("L", (N, N), 0)
    d = ImageDraw.Draw(img)
    for x, y, size, a in spots:
        d.polygon(_shard_poly(rng, x * SS, y * SS, size * SS), fill=int(255 * a))
    _save(np.asarray(img, dtype=np.float32) / 255.0, name)


def smear(name: str, seed: int) -> None:
    """Transfer smudge: streaky and broken, mostly mid opacity."""
    rng = np.random.default_rng(seed)
    env = _blob(rng, 2.6, 0.45)
    streak = _noise2d(rng, (N, N), (60, 5))
    breaks = _noise2d(rng, (N, N), (8, 10))
    c = env * np.clip(0.35 + 0.75 * streak - 0.35 * _smoothstep(0.55, 0.75, breaks), 0, 1)
    for _ in range(14):
        yy = float(np.clip(rng.normal(0.5, 0.12), 0.15, 0.85)) * SIZE
        length = rng.uniform(0.2, 0.7)
        x0 = rng.uniform(0.1, 0.9 - length) * SIZE
        line = np.zeros_like(c)
        _line(line, rng, yy, x0, x0 + length * SIZE, rng.uniform(14, 30), strength=0.95, gap=0.25,
              wave=2.0, rough=0.5, head=0.1, tail=0.4)
        np.maximum(c, line * env, out=c)
    _save(np.clip(c, 0, 1), name)


# ----------------------------------------------------------- detail maps --

DS = 1024  # detail tile size


def _wrap_lines(rng: np.random.Generator, count: int) -> np.ndarray:
    """Tileable height map of micro-scratch grooves (1 = deepest)."""
    img = Image.new("L", (DS * 2, DS * 2), 0)  # drawn at 2x, wrapped by tiling
    d = ImageDraw.Draw(img)
    S = DS * 2
    families = rng.uniform(0, math.pi, 4)
    for _ in range(count):
        # Mostly random directions, a third aligned in a few swirl families.
        ang = rng.choice(families) + rng.normal(0, 0.08) if rng.random() < 0.35 else rng.uniform(0, math.pi)
        length = S * 0.004 * (1 + 5 * rng.random() ** 2)
        x, y = rng.uniform(0, S), rng.uniform(0, S)
        bend = rng.normal(0, 0.25)
        steps = 6
        pts = []
        for i in range(steps + 1):
            t = i / steps - 0.5
            a = ang + bend * t
            pts.append((x + math.cos(a) * length * t, y + math.sin(a) * length * t))
        value = int(rng.uniform(90, 255))
        width = int(rng.choice([2, 2, 2, 3]))
        for ox in (-S, 0, S):
            for oy in (-S, 0, S):
                d.line([(px + ox, py + oy) for px, py in pts], fill=value, width=width)
    h = np.asarray(img.resize((DS, DS), Image.LANCZOS), np.float32) / 255.0
    return h


def detail_maps() -> None:
    os.makedirs(DETAIL_DIR, exist_ok=True)
    rng = np.random.default_rng(1234)
    h = _wrap_lines(rng, 9000)
    # Colour detail: neutral 0.5, scratch lines lighter (exposed, scattering).
    b = np.clip(0.5 + 0.5 * h, 0, 1)
    Image.fromarray((b * 255).astype(np.uint8), mode="L").convert("RGB").save(
        os.path.join(DETAIL_DIR, "scratch_detail_b.data.png"))
    # Roughness detail: neutral 0.5, grooves rougher.
    r = np.clip(0.5 + 0.45 * h, 0, 1)
    Image.fromarray((r * 255).astype(np.uint8), mode="L").save(os.path.join(DETAIL_DIR, "scratch_detail_r.data.png"))
    # Normal detail: grooves from the height map's wrapped gradient.
    depth = 3.0
    gx = (np.roll(h, -1, axis=1) - np.roll(h, 1, axis=1)) * 0.5 * depth
    gy = (np.roll(h, -1, axis=0) - np.roll(h, 1, axis=0)) * 0.5 * depth
    nz = 1.0 / np.sqrt(1 + gx * gx + gy * gy)
    nrm = np.stack([gx * nz, gy * nz, nz], axis=-1)        # grooves: height subtracts
    Image.fromarray(((nrm * 0.5 + 0.5) * 255).astype(np.uint8), mode="RGB").save(
        os.path.join(DETAIL_DIR, "scratch_detail_n.normal.png"))
    for n in ("scratch_detail_b.data.png", "scratch_detail_r.data.png", "scratch_detail_n.normal.png"):
        print(f"wrote {os.path.join(DETAIL_DIR, n)}")


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    for old in RETIRED:
        for p in glob.glob(os.path.join(OUT_DIR, old + ".png*")):
            os.remove(p)
            print(f"removed {p}")
    haze("scr_haze_01", 404, aspect=1.15)
    haze("scr_haze_02", 505, aspect=1.35)
    haze("scr_haze_03", 515, aspect=1.0)
    # Sparse: isolated long scores with gaps between (refs 2, 3); dense sets
    # read as a soft brush bundle.
    streak("scr_streak_01", 101, main=5, fine=7, spread=0.2, weight=0.5, hair=14)
    streak("scr_streak_02", 202, main=7, fine=9, spread=0.24, weight=0.8, hair=16)
    streak("scr_streak_03", 303, main=3, fine=6, spread=0.16, weight=0.3, hair=10)
    streak("scr_streak_04", 313, main=5, fine=10, spread=0.19, weight=0.6, hair=18)
    drag("scr_drag_01", 1301, main=6, fine=10, hair=18, weight=0.5)
    drag("scr_drag_02", 1402, main=9, fine=12, hair=24, weight=0.7)
    drag("scr_drag_03", 1503, main=4, fine=8, hair=14, weight=0.3)
    gouge("scr_gouge_01", 808)
    gouge("scr_gouge_02", 909)
    chips("scr_chips_01", 606, count=11)
    chips("scr_chips_02", 707, count=7)
    smear("scr_smear_01", 1101)
    smear("scr_smear_02", 1202)
    detail_maps()


if __name__ == "__main__":
    main()
