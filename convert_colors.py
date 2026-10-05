#!/usr/bin/env python3
"""Convert colors from UGentish to matplotlib and gnuplot formats.

This script ensures there is just a single source of truth for the colors.
"""

import sys
import tomllib

from stepup.core.api import call
from stepup.core.call import driver

COLORS_TOML = "typst/packages/ugentish/ugentish/0.1.0/colors.toml"


def plan():
    call(
        sys.argv[0],
        "convert_matplotlib",
        inp=["matplotlib/matplotlibrc_template", COLORS_TOML],
        out=["matplotlib/matplotlibrc"],
    )
    call(sys.argv[0], "convert_gpl", inp=[COLORS_TOML], out=["inkscape/ugentish.gpl"])
    call(sys.argv[0], "convert_svg", inp=[COLORS_TOML], out=["inkscape/colors.svg"])


def load_colors(path_toml):
    with open(path_toml, "rb") as fh:
        return tomllib.load(fh)


def convert_matplotlib(inp, out):
    path_template, path_toml = inp
    colors = load_colors(path_toml)
    with open(path_template) as fh:
        lines = fh.read().rstrip("\n").split("\n")
    cycle = ", ".join(f"'{value[1:]}'" for value in colors["normal"].values())
    lines.append(f"axes.prop_cycle: cycler('color', [{cycle}])")
    with open(out[0], "w") as fh:
        fh.write("\n".join(lines) + "\n")


def hex_to_rgb(value):
    return tuple(int(value[i : i + 2], 16) for i in (1, 3, 5))


def convert_gpl(inp, out):
    colors = load_colors(inp[0])
    entries = list(colors["extra"].items())
    for name in colors["normal"]:
        entries.append((f"text {name}", colors["text"][name]))
        entries.append((name, colors["normal"][name]))
        entries.append((f"light {name}", colors["light"][name]))
    with open(out[0], "w") as fh:
        fh.write("GIMP Palette\nName: UGent 33\nColumns: 1\n#\n")
        for name, value in entries:
            r, g, b = hex_to_rgb(value)
            fh.write(f"{r:3d} {g:4d} {b:4d} {name}\n")


def relative_luminance(value):
    def linearize(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = (linearize(c) for c in hex_to_rgb(value))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(value1, value2):
    """Compute the WCAG contrast ratio between two colors."""
    l1, l2 = sorted([relative_luminance(value1), relative_luminance(value2)], reverse=True)
    return (l1 + 0.05) / (l2 + 0.05)


def convert_svg(inp, out):
    colors = load_colors(inp[0])
    white = colors["extra"]["white"]
    ink = colors["extra"]["ink"]
    font = 'font-family="Fira Sans, sans-serif"'
    row_height = 50
    top = 50
    x_name, x_text, x_normal, x_light = 20, 110, 330, 480
    swatch_width = 130
    width = x_light + 2 * swatch_width + 40
    names = list(colors["normal"])
    height = top + row_height * (len(names) + 1) + 20

    parts = [
        f'<rect x="0" y="0" width="{width}" height="{height}" fill="{white}"/>',
        f'<g {font} font-size="13" font-weight="bold" fill="{ink}">',
        f'<text x="{x_text}" y="30">text (contrast on white)</text>',
        f'<text x="{x_normal}" y="30">normal</text>',
        f'<text x="{x_light}" y="30">light (contrast with normal line)</text>',
        "</g>",
    ]
    for i, name in enumerate(names):
        y = top + i * row_height
        text, normal, light = colors["text"][name], colors["normal"][name], colors["light"][name]
        ym = y + row_height / 2 - 5
        parts.extend(
            [
                f'<text x="{x_name}" y="{ym + 5}" {font} font-size="14" fill="{ink}">{name}</text>',
                # Text color as text fill on white
                (
                    f'<text x="{x_text}" y="{ym}" {font} font-size="16" fill="{text}">'
                    "Readable text</text>"
                ),
                (
                    f'<text x="{x_text}" y="{ym + 16}" {font} font-size="10" fill="{text}">'
                    f"{text} · {contrast_ratio(text, white):.1f}:1</text>"
                ),
                # Normal color swatch
                (
                    f'<rect x="{x_normal}" y="{y}" width="{swatch_width}" '
                    f'height="{row_height - 10}" fill="{normal}"/>'
                ),
                (
                    f'<text x="{x_normal + 5}" y="{y + row_height - 15}" {font} font-size="10" '
                    f'fill="{white if contrast_ratio(normal, white) > 3 else ink}">{normal}</text>'
                ),
                # Light color as background, with a line and text on top
                (
                    f'<rect x="{x_light}" y="{y}" width="{2 * swatch_width}" '
                    f'height="{row_height - 10}" fill="{light}"/>'
                ),
                (
                    f'<path d="M {x_light + 10} {y + 28} C {x_light + 50} {y + 2} '
                    f'{x_light + 80} {y + 38} {x_light + 120} {y + 12}" fill="none" '
                    f'stroke="{normal}" stroke-width="2.5" stroke-linecap="round"/>'
                ),
                (
                    f'<text x="{x_light + 135}" y="{ym - 2}" {font} font-size="13" fill="{text}">'
                    "Text on light</text>"
                ),
                (
                    f'<text x="{x_light + 135}" y="{ym + 14}" {font} font-size="10" fill="{text}">'
                    f"{light} · {contrast_ratio(normal, light):.1f}:1</text>"
                ),
            ]
        )

    # Extra colors
    y = top + len(names) * row_height
    parts.append(
        f'<text x="{x_name}" y="{y + row_height / 2}" {font} font-size="14" fill="{ink}">'
        "extra</text>"
    )
    for j, (name, value) in enumerate(colors["extra"].items()):
        x = x_text + j * 140
        parts.extend(
            [
                (
                    f'<rect x="{x}" y="{y}" width="{swatch_width}" height="{row_height - 10}" '
                    f'fill="{value}" stroke="{ink}" stroke-width="0.5"/>'
                ),
                (
                    f'<text x="{x + 5}" y="{y + row_height - 15}" {font} font-size="10" '
                    f'fill="{white if contrast_ratio(value, white) > 3 else ink}">'
                    f"{name} {value}</text>"
                ),
            ]
        )

    with open(out[0], "w") as fh:
        fh.write(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
            f'viewBox="0 0 {width} {height}">\n'
        )
        for part in parts:
            fh.write(f"  {part}\n")
        fh.write("</svg>\n")


if __name__ == "__main__":
    driver()
