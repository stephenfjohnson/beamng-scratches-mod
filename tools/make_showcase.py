"""Build the README feature showcase from committed in-game evidence captures.

    python tools/make_showcase.py        # -> docs/showcase/*.jpg, *.gif

Every image is a crop of a real capture under docs/evidence/ (no retouching
beyond cropping, resizing and a caption chip). Before/after pairs are matched
captures from the same run: "original-stages" frames are the same car and
camera with the mod's damage stage switched off. Needs Pillow.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
EV = ROOT / "docs" / "evidence"
OUT = ROOT / "docs" / "showcase"

# Crop boxes are in 1920x1080 capture coordinates and stay clear of the HUD:
# minimap (x < 315, y > 840), gauge circle (centre ~1750,910, r ~170),
# start/stop and ESC buttons (x > 1495, y > 935), camera help (top-left).
SIDE = (470, 380, 1470, 760)      # full car, side camera
WIDE = (360, 240, 1490, 876)      # 16:9 around the car, water/snow runs
HERO_W, HERO_H = 800, 400         # 2:1 hero cells


def font(size: int) -> ImageFont.ImageFont:
    for name in ("arialbd.ttf", "DejaVuSans-Bold.ttf", "Arial Bold.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def load(rel: str, box: tuple[int, int, int, int]) -> Image.Image:
    return Image.open(EV / rel).convert("RGB").crop(box)


def fit(im: Image.Image, width: int) -> Image.Image:
    if im.width == width:
        return im
    return im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)


def chip(im: Image.Image, text: str, size: int = 26) -> Image.Image:
    """Caption chip in the bottom-left corner."""
    im = im.copy()
    overlay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    f = font(size)
    l, t, r, b = draw.textbbox((0, 0), text, font=f)
    pad, margin = size // 2, size // 2
    x0, y1 = margin, im.height - margin
    y0 = y1 - (b - t) - 2 * pad
    draw.rounded_rectangle((x0, y0, x0 + (r - l) + 2 * pad, y1), radius=size // 3,
                           fill=(12, 12, 12, 190))
    draw.text((x0 + pad - l, y0 + pad - t), text, font=f, fill=(255, 255, 255, 255))
    return Image.alpha_composite(im.convert("RGBA"), overlay).convert("RGB")


def stack(panels: list[Image.Image], width: int, gap: int = 6) -> Image.Image:
    panels = [fit(p, width) for p in panels]
    sheet = Image.new("RGB", (width, sum(p.height for p in panels) + gap * (len(panels) - 1)),
                      (255, 255, 255))
    y = 0
    for p in panels:
        sheet.paste(p, (0, y))
        y += p.height + gap
    return sheet


def grid(cells: list[Image.Image], cols: int, cell_w: int, cell_h: int, gap: int = 6) -> Image.Image:
    rows = (len(cells) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * cell_w + gap * (cols - 1), rows * cell_h + gap * (rows - 1)),
                      (255, 255, 255))
    for i, c in enumerate(cells):
        c = c.resize((cell_w, cell_h), Image.LANCZOS) if c.size != (cell_w, cell_h) else c
        sheet.paste(c, ((i % cols) * (cell_w + gap), (i // cols) * (cell_h + gap)))
    return sheet


def save(im: Image.Image, name: str) -> None:
    path = OUT / name
    im.save(path, quality=86, optimize=True, progressive=True)
    print(f"  {path.relative_to(ROOT)}  {im.width}x{im.height}  {path.stat().st_size // 1024} KB")


def wash_gif() -> None:
    steps = [
        ("dirty.png", "1  Muddy after a drive"),
        ("partial-water.png", "2  Wading in"),
        ("deep-progress.png", "3  Submerged: soil fading"),
        ("deep-washed.png", "4  Soil fully washed"),
        ("washed-wet.png", "5  Out of the water: wet clearcoat"),
        ("dry.png", "6  Dried back to factory gloss"),
        ("redirty.png", "7  Fresh mud collects again"),
    ]
    frames = [chip(fit(load(f"contact-patches/wash/{f.replace('.png', '.jpg')}", WIDE), 800), label, 22)
              for f, label in steps]
    path = OUT / "washing-cycle.gif"
    pal = [f.quantize(colors=192, method=Image.MEDIANCUT, dither=Image.FLOYDSTEINBERG) for f in frames]
    pal[0].save(path, save_all=True, append_images=pal[1:], loop=0, optimize=True,
                duration=[1500] * (len(pal) - 1) + [2600], disposal=1)
    print(f"  {path.relative_to(ROOT)}  {frames[0].width}x{frames[0].height}  {path.stat().st_size // 1024} KB")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    print("building showcase from docs/evidence:")
    cp = "contact-patches/"  # 2026-11-20 captures; HUD-free ones are 2560x1440

    hero = grid([
        chip(fit(load(cp + "slide-dark/close/damaged.jpg", (560, 150, 2560, 1150)), HERO_W), "Scrapes"),
        chip(load(cp + "mud-fling/after-left.jpg", (500, 250, 1600, 800)), "Mud fling"),
        chip(load("milestone3/snow-final/dirty.png", (360, 260, 1490, 825)), "Snow"),
        chip(load(cp + "wash/deep-progress.jpg", (360, 250, 1490, 815)), "Washing"),
    ], cols=2, cell_w=HERO_W, cell_h=HERO_H)
    save(hero, "hero.jpg")

    # tools/showcase_capture.py aim_auto frames: the car fills this band.
    band = (253, 413, 2307, 1187)        # 2560x1440
    band_small = (190, 310, 1730, 890)   # the same band in 1920x1080 fleet captures

    save(stack([
        chip(load(cp + "slide-dark/left/original-stages.jpg", band), "Before", 50),
        chip(load(cp + "slide-dark/left/damaged.jpg", band), "After one sideslide", 50),
    ], 1200), "scrapes-before-after.jpg")

    save(chip(fit(load(cp + "slide-dark/close/damaged.jpg", (500, 200, 2560, 1250)), 1300),
              "Bare metal, primer and surviving paint", 30), "scrapes-closeup.jpg")

    save(stack([
        chip(load(cp + "police/left/original-stages.jpg", band), "Stock Polizei livery", 50),
        chip(load(cp + "police/left/damaged.jpg", band), "After one sideslide", 50),
    ], 1200), "livery-before-after.jpg")

    save(chip(fit(load(cp + "police-mud/close/damaged.jpg", (300, 380, 2300, 1300)), 1200),
              "Mud flung over fresh scrapes", 30), "closeup-relief.jpg")

    save(chip(load(cp + "mud-fling/after-left.jpg", (530, 300, 1560, 700)), "Mud flung up and back from the wheels"),
         "mud-fling.jpg")

    save(chip(load("soil-continuity/police/close.png", (300, 340, 1588, 850)), "Tapered wheel splashes"),
         "mud-splashes.jpg")

    save(stack([
        chip(load("soil-continuity/plain/before-material-fix.png", (380, 380, 1500, 830)),
             "Before: mud stopped at the rear door"),
        chip(load("soil-continuity/plain/seams-left.png", (380, 380, 1500, 830)),
             "After: one splash crosses every panel"),
    ], 1000), "panel-seams-before-after.jpg")

    save(stack([
        chip(load("terrain-color/before.png", (330, 500, 1588, 845)), "Before: fixed orange tint"),
        chip(load("terrain-color/after.png", (330, 500, 1588, 845)), "After: sampled from the ground"),
    ], 1000), "terrain-color-before-after.jpg")

    save(chip(load("milestone3/snow-final/dirty.png", (380, 300, 1570, 900)), "Snow buildup"),
         "snow.jpg")

    # Roof drop on a black ETK 800, looking down at the bonnet and roof.
    impact_box = (860, 690, 2100, 1440)
    save(stack([
        chip(fit(load(cp + "roofdrop/close2/original-stages.jpg", impact_box), 1200), "Before", 34),
        chip(fit(load(cp + "roofdrop/close2/damaged.jpg", impact_box), 1200),
             "After a roof drop: chipped paint where it landed", 34),
    ], 1200), "impacts-before-after.jpg")

    save(fit(Image.open(EV / "showcase/debug-panel/panel.jpg").convert("RGB"), 1400), "debug-panel.jpg")

    # Fleet: tools/showcase_fleet.py --out docs/evidence/contact-patches/fleet-vulkan,
    # one bench sideslide each, left flank.
    def fleet(name: str, label: str, size: tuple[int, int] = (780, 294)) -> Image.Image:
        return chip(load(cp + f"fleet-vulkan/{name}/left/damaged.jpg", band_small).resize(size, Image.LANCZOS),
                    label, 20)

    save(grid([
        fleet("pickup-red", "Pickup · red"), fleet("vivace-blue", "Vivace · blue"),
        fleet("etki-white", "ETK I · white"), fleet("covet-yellow", "Covet · yellow"),
        fleet("etk800-black", "ETK 800 · black"), fleet("moonhawk-green", "Moonhawk · green"),
    ], cols=2, cell_w=780, cell_h=294), "fleet-paints.jpg")

    save(grid([
        fleet("bluebuck-livery", "Bluebuck · two-tone livery"),
        fleet("citybus-livery", "City bus · Transit livery"),
        chip(load(cp + "police/left/damaged.jpg", band).resize((780, 294), Image.LANCZOS),
             "ETK 800 · Polizei livery", 20),
        chip(load(cp + "after-sideslide-left.jpg", (430, 440, 1490, 840)).resize((780, 294), Image.LANCZOS),
             "Sunburst · NGRC rally livery", 20),
    ], cols=2, cell_w=780, cell_h=294), "fleet-liveries.jpg")

    save(stack([
        chip(load(cp + "fleet-vulkan/moonhawk-green/left/original-stages.jpg", band_small), "Before", 40),
        chip(load(cp + "fleet-vulkan/moonhawk-green/left/damaged.jpg", band_small), "After one sideslide", 40),
    ], 1200), "fleet-before-after.jpg")

    wash_gif()


if __name__ == "__main__":
    main()
