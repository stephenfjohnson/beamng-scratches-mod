"""Generate the tiling wheel/tyre overlay textures used by wheelAdapter.lua.

Output (art/scratches/wheels/, no dynamic-decal sidecars needed: these are
ordinary material textures, not brushes):
  wheel_dirt.color.png     near-white mottled albedo; the stage factor tints it
  wheel_dirt_o.data.png    red = soil coverage (caked clumps, thin film between)
  wheel_scrape.color.png   bare-metal albedo with darker gouge lines
  wheel_scrape_o.data.png  red = abrasion coverage (directional scuffs + pits)

Everything is periodic (noise is shaped in the frequency domain), so the
textures tile on any UV layout. Fixed seeds: re-running is byte-stable.
"""
from pathlib import Path

import numpy as np
from PIL import Image

SIZE = 512
OUT = Path(__file__).resolve().parents[1] / "art" / "scratches" / "wheels"


def periodic_noise(rng, size, beta, stretch=(1.0, 1.0)):
    """1/f^beta noise, periodic by construction, normalised to 0..1."""
    fy = np.fft.fftfreq(size)[:, None] * stretch[0]
    fx = np.fft.fftfreq(size)[None, :] * stretch[1]
    radius = np.sqrt(fx * fx + fy * fy)
    radius[0, 0] = 1.0
    spectrum = (rng.standard_normal((size, size)) + 1j * rng.standard_normal((size, size))) / radius ** beta
    spectrum[0, 0] = 0
    field = np.fft.ifft2(spectrum).real
    lo, hi = np.percentile(field, [1, 99])
    return np.clip((field - lo) / (hi - lo), 0, 1)


def save(name, rgb):
    OUT.mkdir(parents=True, exist_ok=True)
    data = np.clip(rgb * 255 + 0.5, 0, 255).astype(np.uint8)
    Image.fromarray(data, "RGB").save(OUT / name, optimize=True)
    print("wrote", OUT / name)


def main():
    rng = np.random.default_rng(20261120)
    clumps = periodic_noise(rng, SIZE, 1.7)
    grain = periodic_noise(rng, SIZE, 0.7)
    film = periodic_noise(rng, SIZE, 2.4)
    # Coverage: a thin uneven film everywhere, caked clumps on top.
    cake = np.clip((clumps - 0.38) / 0.22, 0, 1)
    coverage = np.clip(0.42 + 0.3 * film + 0.5 * cake - 0.25 * (grain < 0.2), 0, 1)
    save("wheel_dirt_o.data.png", np.stack([coverage, coverage, coverage], -1))
    tone = 0.72 + 0.2 * grain + 0.1 * clumps - 0.12 * cake
    save("wheel_dirt.color.png", np.stack([tone, tone * 0.985, tone * 0.96], -1))

    rng = np.random.default_rng(20261121)
    # Directional scuffs: noise stretched hard along one axis, at two angles.
    scuff_a = periodic_noise(rng, SIZE, 1.1, stretch=(1.0, 14.0))
    scuff_b = periodic_noise(rng, SIZE, 1.1, stretch=(11.0, 1.5))
    patch = periodic_noise(rng, SIZE, 2.2)
    pits = periodic_noise(rng, SIZE, 0.4)
    lines = np.maximum(np.clip((scuff_a - 0.6) / 0.15, 0, 1), np.clip((scuff_b - 0.66) / 0.15, 0, 1))
    area = np.clip((patch - 0.35) / 0.3, 0, 1)
    abrasion = np.clip(lines * (0.35 + 0.65 * area) + 0.55 * area * (pits > 0.55), 0, 1)
    save("wheel_scrape_o.data.png", np.stack([abrasion, abrasion, abrasion], -1))
    metal = 0.8 + 0.15 * pits - 0.3 * np.clip((scuff_a - 0.78) / 0.1, 0, 1)
    save("wheel_scrape.color.png", np.stack([metal, metal, metal * 1.02], -1))


if __name__ == "__main__":
    main()
