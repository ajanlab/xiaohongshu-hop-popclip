#!/usr/bin/env python3
# Generate the PopClip template icon from the official Xiaohongshu SVG
# (rounded square + cut-out "小红书" text, iconfont structure).
# Conventions: monochrome (pure black) + transparent background → PopClip
# renders it as a template, auto-adapting to light/dark toolbars.
# Requires: Google Chrome (full fill-rule support; qlmanage cannot punch
# the text cut-outs). Rebuilds assets/xhs-logo-1024.{svg,png} as byproducts.
# Usage: python3 assets/make_icon.py [SIZE]   (default 256)

import os
import subprocess
import sys

from PIL import Image

SIZE = int(sys.argv[1]) if len(sys.argv) > 1 else 256
BASE = os.path.dirname(os.path.abspath(__file__))
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# 1. Render-size SVG: source declares 200x200; align to the 1024 render window
render_svg = open(os.path.join(BASE, "xhs-logo.svg")).read().replace(
    'width="200" height="200"', 'width="1024" height="1024"')
render_path = os.path.join(BASE, "xhs-logo-1024.svg")
open(render_path, "w").write(render_svg)

# 2. Render via Chrome headless (transparent background; reversed text
#    subpaths punch holes under the nonzero fill rule)
png_path = os.path.join(BASE, "xhs-logo-1024.png")
subprocess.run([CHROME, "--headless", "--disable-gpu",
                f"--screenshot={png_path}", "--window-size=1024,1024",
                "--default-background-color=00000000",
                f"file://{render_path}"],
               capture_output=True, check=True)

# 3. Binarize: drop antialiased gray edges → pure black + pure transparent
img = Image.open(png_path).convert("RGBA")
alpha = img.getchannel("A").point(lambda p: 255 if p > 100 else 0)
black = Image.new("RGBA", img.size, (0, 0, 0, 255))
img = Image.composite(black, Image.new("RGBA", img.size, (0, 0, 0, 0)), alpha)

# 4. Crop transparent margins: the SVG's safe-area padding shrinks the icon
#    in PopClip's toolbar, which scales by canvas proportion
img = img.crop(img.getchannel("A").getbbox())

# 5. Downscale (LANCZOS regenerates antialiased edges)
out = os.path.normpath(os.path.join(BASE, "..", "xiaohongshu-hop.popclipext", "icon.png"))
img.resize((SIZE, SIZE), Image.LANCZOS).save(out)
print("saved", out, f"{SIZE}x{SIZE}")
