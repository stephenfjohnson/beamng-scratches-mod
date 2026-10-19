"""
Preview the damage brushes the way the painter lays them down, without the game.

Each brush is first reduced to the paint canvas's resolution (~1.5 mm per
texel at its typical in-game size: bands ~55 x 15 cm, chips ~30 cm), so detail
that can't survive in game blurs here too. It is then tinted and blended the
way paint.lua does: linear-space tint multiply, alpha over the paint colour,
with the haze underlay beneath slide bands.

Output: bench/brush_preview/*.png (bench/ is gitignored)
Run:    python tools/preview_brushes.py
"""

import os

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
TEX = os.path.join(ROOT, "art", "dynamicDecals", "textures")
OUT = os.path.join(ROOT, "bench", "brush_preview")

TEXEL_M = 0.0015                     # paint canvas texel on a typical car
DISPLAY = 2.0                        # display pixels per canvas texel
PAINTS = [("blue", (28, 52, 120)), ("red", (150, 22, 22)), ("white", (232, 232, 230)),
          ("black", (22, 22, 24))]


def to_lin(c):
    c = np.asarray(c, np.float32)
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def to_srgb(c):
    c = np.clip(c, 0, 1)
    return np.where(c <= 0.0031308, c * 12.92, 1.055 * c ** (1 / 2.4) - 0.055)


def srgb(r, g, b):
    """Same helper as paint.lua: sRGB 0-255 -> linear tint."""
    return tuple(float(v) for v in to_lin(np.array([r, g, b], np.float32) / 255))


def paint_lum(rgb255):
    lin = to_lin(np.array(rgb255, np.float32) / 255)
    return float(0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2])


def exposure_tint(lum):
    """Mirror of paint.lua exposureTint(): darker primer on dark paint."""
    t = min(1.0, max(0.0, (lum - 0.35) / 0.3))
    return 0.80 + 0.20 * t


def haze_tone(lum):
    """Mirror of paint.lua damageTone('haze') (mean, no jitter)."""
    t = min(1.0, max(0.0, (lum - 0.35) / 0.3))
    v = 0.86 + (lum * 0.72 - 0.86) * t
    return (v, v, min(1.0, v + 0.015)), 0.23


def load(name, w_m, h_m):
    """Brush as straight RGBA float, resampled to canvas texels for a w_m x h_m
    decal, then up to display size."""
    im = np.asarray(Image.open(os.path.join(TEX, name + ".png")).convert("RGBA"), np.float32) / 255
    prem = im.copy()
    prem[..., :3] *= prem[..., 3:4]
    tw, th = max(2, int(w_m / TEXEL_M)), max(2, int(h_m / TEXEL_M))
    dw, dh = int(tw * DISPLAY), int(th * DISPLAY)

    def rs(a, w, h, f):
        return np.asarray(Image.fromarray(a, mode="F").resize((w, h), f))
    chans = [rs(rs(prem[..., c], tw, th, Image.BOX), dw, dh, Image.BILINEAR) for c in range(4)]
    a = np.clip(chans[3], 0, 1)
    rgb = np.ones((dh, dw, 3), np.float32)
    nz = a > 1e-3
    for c in range(3):
        rgb[..., c][nz] = np.clip(chans[c][nz] / a[nz], 0, 1)
    return rgb, a


def over(base_lin, brush_rgb_srgb, alpha, tint_lin, master_a=1.0):
    col = to_lin(brush_rgb_srgb) * np.asarray(tint_lin, np.float32)
    a = (alpha * master_a)[..., None]
    return base_lin * (1 - a) + col * a


def panel(rgb255, w, h):
    base = to_lin(np.array(rgb255, np.float32) / 255)
    y = np.linspace(0, 1, h)[:, None, None]
    img = base * (0.85 + 0.2 * (1 - y)) + 0.03 * np.exp(-((y - 0.2) / 0.1) ** 2)
    return np.broadcast_to(img, (h, w, 3)).copy()


def tile(name, w_m, h_m, paint_rgb, kind, tint=None, master_a=1.0, haze=None):
    lum = paint_lum(paint_rgb)
    rgb, a = load(name, w_m, h_m)
    h, w = a.shape
    pad = 12
    img = panel(paint_rgb, w + 2 * pad, h + 2 * pad)
    if haze:
        hrgb, ha = load(haze, w_m * 1.0, h_m * 0.95)
        hh, hw = ha.shape
        oy, ox = pad + (h - hh) // 2, pad + (w - hw) // 2
        tone, hal = haze_tone(lum)
        img[oy:oy + hh, ox:ox + hw] = over(img[oy:oy + hh, ox:ox + hw], hrgb, ha, tone, hal)
    t = tint if tint is not None else (exposure_tint(lum),) * 3
    img[pad:pad + h, pad:pad + w] = over(img[pad:pad + h, pad:pad + w], rgb, a, t, master_a)
    return Image.fromarray((to_srgb(img) * 255 + 0.5).astype(np.uint8))


def sheet(rows, cols_labels, out_name, title):
    """rows: list of (label, [PIL tiles])."""
    lab_w, head = 110, 22
    tw = max(t.width for _, ts in rows for t in ts)
    th = max(t.height for _, ts in rows for t in ts)
    img = Image.new("RGB", (lab_w + len(cols_labels) * (tw + 4), head * 2 + len(rows) * (th + 4)), (18, 18, 20))
    d = ImageDraw.Draw(img)
    d.text((6, 4), title, fill=(240, 240, 240))
    for j, c in enumerate(cols_labels):
        d.text((lab_w + j * (tw + 4) + 4, head + 2), c, fill=(200, 200, 200))
    for i, (label, ts) in enumerate(rows):
        y = head * 2 + i * (th + 4)
        d.text((6, y + th // 2 - 6), label, fill=(220, 220, 220))
        for j, t in enumerate(ts):
            img.paste(t, (lab_w + j * (tw + 4), y))
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, out_name)
    img.save(path)
    print("wrote", path)


SURFACE_TINTS = {          # mirror of paint.lua SURFACES tints (sRGB 0-255), alpha
    "soil":   ((92, 72, 52), 0.85),
    "grass":  ((78, 92, 44), 0.75),
    "zinc":   ((150, 153, 152), 0.55),
    "rubber": ((24, 24, 26), 0.70),
    "bark":   ((88, 68, 48), 0.60),
}


def main():
    cols = [p for p, _ in PAINTS]
    for panel_k, panel_name in (("m", "metal panel"), ("p", "plastic bumper")):
        rows = []
        for tier in (1, 2, 3):
            for v in ("a", "b"):
                n = f"scr_rash_{panel_k}{tier}{v}"
                rows.append((n[4:], [tile(n, 0.55, 0.15, rgb, "band", haze=f"scr_haze_0{1 if v == 'a' else 2}")
                                     for _, rgb in PAINTS]))
        sheet(rows, cols, f"rash_{panel_k}.png", f"slide bands ({panel_name}), haze underlay, 55 x 15 cm")
        rows = []
        for tier in (1, 2, 3):
            for v in ("a", "b"):
                n = f"scr_chip_{panel_k}{tier}{v}"
                rows.append((n[4:], [tile(n, 0.30, 0.30, rgb, "chip") for _, rgb in PAINTS]))
        for v in ("a", "b"):
            n = f"scr_gouge_{panel_k}{v}"
            rows.append((n[4:], [tile(n, 0.30, 0.30, rgb, "chip") for _, rgb in PAINTS]))
        sheet(rows, cols, f"impact_{panel_k}.png", f"impacts ({panel_name}), 30 cm")
    rows = []
    for n in ("scr_pepper_ma", "scr_pepper_mb", "scr_pepper_pa"):
        rows.append((n[4:], [tile(n, 0.30, 0.30, rgb, "chip") for _, rgb in PAINTS]))
    for n in ("scr_splat_a", "scr_splat_b"):
        for s in ("soil", "grass"):
            c, a = SURFACE_TINTS[s]
            rows.append((f"{n[4:]} {s}", [tile(n, 0.30, 0.30, rgb, "chip", srgb(*c), a) for _, rgb in PAINTS]))
    sheet(rows, cols, "gravel_splat.png", "gravel pepper + impact spatter, 30 cm")
    rows = []
    for n in ("scr_smear_a", "scr_smear_b"):
        for s in ("soil", "grass", "zinc", "rubber", "bark"):
            c, a = SURFACE_TINTS[s]
            rows.append((f"{n[4:]} {s}", [tile(n, 0.55, 0.15, rgb, "band", srgb(*c), a) for _, rgb in PAINTS]))
    sheet(rows, cols, "smears.png", "transfer smears, 55 x 15 cm")


if __name__ == "__main__":
    main()
