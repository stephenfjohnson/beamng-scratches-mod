"""Deterministic soil alpha masks; no game assets. Run python tools/generate_soil.py."""
import math
import json
import random
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

out = Path(__file__).resolve().parents[1] / 'art/dynamicDecals/textures'
for kind, seed, count, radius in [('mud',41,65,24),('dirt',42,360,17),('snow',43,95,28)]:
    rng = random.Random(seed)
    mask = Image.new('L',(512,512))
    draw = ImageDraw.Draw(mask)
    for _ in range(count):
        x,y = rng.gauss(256,90),rng.gauss(256,78)
        r = rng.uniform(radius*.3,radius)
        if not (35<x<477 and 35<y<477): continue
        points=[]
        for i in range(12):
            angle=i*math.tau/12;rr=r*rng.uniform(.55,1.3)
            points.append((x+math.cos(angle)*rr,y+math.sin(angle)*rr*.8))
        draw.polygon(points,fill=rng.randint(120,255))
    mask = mask.filter(ImageFilter.GaussianBlur(2 if kind=='snow' else .6))
    img = Image.new('RGBA',mask.size,(255,255,255,255));img.putalpha(mask)
    path = out / f'soil_{kind}_coverage.png';img.save(path)
    Path(str(path)+'.dynDecalTexture.json').write_text(json.dumps(dict(version=2,vehicle='',isSdfCompatible=False,tags=['shape','soil',kind],type=0))+'\n')

# Wheel spray: discrete droplet heads with tapering downstream tails (+image X).
# Keep separate names from the old isotropic masks for body contact/snow.
for kind, seed in [('mud', 141), ('dirt', 142)]:
    for variant in (1, 2):
        rng = random.Random(seed + variant * 17)
        mask = Image.new('L', (512, 512))
        draw = ImageDraw.Draw(mask)
        for _ in range(42 if kind == 'mud' else 70):
            x = rng.uniform(65, 315)
            y = 256 + rng.gauss(0, 48 + (x - 65) * .16)
            r = rng.uniform(3, 13 if kind == 'mud' else 8)
            if not 45 < y < 467:
                continue
            opacity = rng.randint(150, 245)
            length = rng.uniform(18, 100) * (r / 10) ** .5
            drift = (y - 256) * .13
            draw.polygon([(x, y-r*.65), (min(465, x+length), y+drift),
                          (x, y+r*.65)], fill=int(opacity*.55))
            draw.ellipse((x-r, y-r, x+r, y+r), fill=opacity)
        mask = mask.filter(ImageFilter.GaussianBlur(.45))
        img = Image.new('RGBA', mask.size, (255, 255, 255, 255))
        img.putalpha(mask)
        path = out / f'soil_{kind}_splash_{variant}.png'
        img.save(path)
        Path(str(path)+'.dynDecalTexture.json').write_text(json.dumps(dict(
            version=2, vehicle='', isSdfCompatible=False,
            tags=['shape', 'soil', kind, 'splash'], type=0))+'\n')
