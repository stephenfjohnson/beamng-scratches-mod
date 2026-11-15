"""Generate seamless soil micro-relief (numpy, scipy, Pillow; no game assets).

This is a static material detail normal, masked by the dynamic soil opacity.
It does not use the decal normal output or change splash silhouettes.
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter


def generate():
    rng = np.random.default_rng(143)
    height = np.zeros((256, 256))
    # Rounded clods, smaller grains and subdued fine texture. Wrapped filtering
    # and derivatives avoid borders when the material repeats the texture.
    for sigma, amplitude in ((9, 2.4), (3, 1.1), (0.9, 0.12)):
        band = gaussian_filter(rng.standard_normal(height.shape), sigma, mode='wrap')
        height += band * (amplitude / band.std())
    dx = (np.roll(height, -1, axis=1) - np.roll(height, 1, axis=1)) * 0.5
    dy = (np.roll(height, -1, axis=0) - np.roll(height, 1, axis=0)) * 0.5
    normal = np.stack((-dx, -dy, np.ones_like(height)), axis=-1)
    normal /= np.linalg.norm(normal, axis=-1, keepdims=True)
    pixels = np.rint((normal * 0.5 + 0.5) * 255).astype(np.uint8)
    path = Path(__file__).resolve().parents[1] / 'art/dynamicDecals/textures/soil_relief_detail.normal.png'
    Image.fromarray(pixels).save(path)
    print(path)


if __name__ == '__main__':
    generate()
