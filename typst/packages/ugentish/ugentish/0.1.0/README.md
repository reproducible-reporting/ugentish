# UGentish

The basic UGentish Typst style.
This is an unofficial package, not endorsed by Ghent University (UGent),
and it contains no UGent logos.

This package is the common denominator of all UGentish Typst packages.
It defines the basic style settings that every template shares,
such as the extended UGent color palette and the fonts,
so that slides, documents and figures made with different templates look like they belong together.
Templates build on top of it, rather than repeating these settings.
You only need to import it directly when you are not using one of the templates,
or when you are writing a new template.

## Usage

```typst
#import "@ugentish/ugentish:0.1.0": *

#show: base-ugentish.with(font: "serif")

Text in Source Serif 4, #text(fill: ugt.blue)[blue text] and $E = m c^2$.
```

## What It Exports

| Name            | What it is                                                                       |
| --------------- | -------------------------------------------------------------------------------- |
| `base-ugentish` | the show rule that sets the fonts, text color, links, underlines and highlights  |
| `fonts`         | the font names: `fonts.sans`, `fonts.serif`, `fonts.mono` and `fonts.math`       |
| `ugc`           | the normal colors, for lines and markers, e.g. `ugc.blue`, `ugc.yellow`          |
| `ugl`           | the light colors, for backgrounds                                                |
| `ugt`           | the text colors, with sufficient contrast on a white background                  |
| `ink`           | the color of body text                                                           |

### `base-ugentish(font: "sans")`

`font` selects the text font:

- `"sans"` (default): [Source Sans 3](https://github.com/adobe-fonts/source-sans)
- `"serif"`: [Source Serif 4](https://github.com/adobe-fonts/source-serif)

In both cases, code is set in [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)
and math in [Erewhon Math](https://ctan.org/pkg/erewhon-math).

The show rule also styles a few common elements:

- links are blue (`ugc.blue`) and underlined,
- `#underline()` uses a light stroke with some offset from the text,
  in contrast to the heavy underline of the UGent style guide,
- `#highlight()` uses the UGent yellow (`ugc.yellow`) as background.

## Colors

All colors are defined in [`colors.toml`](colors.toml).
This file is the single source of truth for the colors in the whole UGentish repository:
the Matplotlib and Inkscape configuration files are generated from it.
Each of the ten colors (`blue`, `red`, `green`, `purple`, `brown`,
`teal`, `pink`, `gray`, `orange` and `yellow`)
comes in a light, a normal and a text variant.
