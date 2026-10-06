# UGentish

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)

A collection of templates and style configuration files for Typst, matplotlib and Inkscape
that give documents, slides and figures a consistent look,
loosely based on the [UGent style guide](https://styleguide.ugent.be/).
This is not an official Ghent University (UGent) project.
It is not endorsed by the university, and it contains no UGent logos or fonts.

## Status

This repository is in draft mode.
Files are still being added and refined as they are used in practice.

## Overview

| Path                                   | Contents                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `typst/packages/ugentish/ugentish/`    | `@ugentish/ugentish`: the basic style settings (colors and fonts) shared by all UGentish Typst packages, see its [README](typst/packages/ugentish/ugentish/0.1.0/README.md) |
| `typst/packages/ugentish/animo-ugentish/` | `@ugentish/animo-ugentish`: a slide template built on [Animo](https://github.com/reproducible-reporting/animo), see its [README](typst/packages/ugentish/animo-ugentish/0.1.1/README.md) |
| `matplotlib/`                          | a `matplotlibrc` template, completed with the color cycle from the palette                       |
| `inkscape/`                            | a Typst preamble for TexText and a generated GIMP/Inkscape color palette                         |
| `plan.py`                              | the [StepUp](https://reproducible-reporting.github.io/stepup-core/) workflow that generates the derived files |

The colors are defined once, in
[`colors.toml`](typst/packages/ugentish/ugentish/0.1.0/colors.toml).
All other color definitions are generated from this file:

- `matplotlib/matplotlibrc`: the Matplotlib configuration, with the palette as `axes.prop_cycle`,
- `inkscape/ugentish.gpl`: a palette file for Inkscape (and GIMP),
- `inkscape/colors.svg`: an overview of all colors, with their contrast ratios.

## Design Philosophy

The files in this repository adopt the less contestable elements of the UGent style guide,
most notably the UGent blue and yellow,
and deliberately deviate from it where readability, accessibility or openness are at stake.

- **Open and readable fonts:**
  UGent Panno is the official UGent font family,
  but it has limited functionality and a restrictive license.
  The official fallback, Arial, is widely available,
  but it is proprietary and a fairly poor choice in terms of readability,
  especially for dyslexic readers.
  Instead, all templates use the following open-source fonts:

  - [Source Sans 3](https://github.com/adobe-fonts/source-sans) for text (default),
  - [Source Serif 4](https://github.com/adobe-fonts/source-serif) for text (optional),
  - [Source Code Pro](https://github.com/adobe-fonts/source-code-pro) for code,
  - [Erewhon Math](https://ctan.org/pkg/erewhon-math) for math.

  The contrast between a serif font for math and a sans-serif font for text is somewhat off-beat,
  but it clarifies the distinction between the two, which helps readability.
  Templates that favor a more classical look can use Source Serif 4 instead.

- **Visual restraint:**
  Strong visual elements, such as the heavy underline of titles in the UGent style guide,
  draw attention away from the content.
  The templates avoid them by default.

- **An extended, accessible color palette:**
  The official UGent blue and yellow are extrapolated
  to a palette of ten visually distinct colors.
  Each color comes in three variants:
  `normal` for lines and markers,
  `light` for backgrounds,
  and `text` for text on a white background, with sufficient (WCAG) contrast.

- **A single source of truth:**
  Slides, documents, plots and drawings should look like they belong together.
  Hence, fonts and colors are defined once and converted automatically to the formats of each tool,
  rather than being copied by hand.

- **No logos:**
  This repository contains no logos.
  Templates that can show logos take them as an argument.
  Make sure you are allowed to use them and follow the usage terms of their owners.

## Setup

First clone this repository to a permanent location:

```bash
git clone https://github.com/tovrstra/ugentish.git
```

The commands below assume that `UGENTISH` is the absolute path of this clone.

### Fonts

Install the static OTF or TTF versions of the fonts, not (only) the variable fonts,
because Matplotlib does not support variable fonts.
Download them from:

- Source Sans 3: <https://github.com/adobe-fonts/source-sans/releases>
- Source Serif 4: <https://github.com/adobe-fonts/source-serif/releases>
- Source Code Pro: <https://github.com/adobe-fonts/source-code-pro/releases>
- Erewhon Math: <https://ctan.org/pkg/erewhon-math> (the file `Erewhon-Math.otf`)

Then install them as follows:

- **Linux:**
  Copy the font files to `~/.local/share/fonts/` (for your user only)
  or `/usr/local/share/fonts/` (for all users), and refresh the font cache:

  ```bash
  mkdir -p ~/.local/share/fonts
  cp *.otf ~/.local/share/fonts/
  fc-cache -f
  ```

  Some distributions also package these fonts,
  e.g. `adobe-source-code-pro-fonts` on Fedora,
  but packaged versions may be outdated or lack the static instances.

- **macOS:**
  Double-click each font file and click *Install Font* in Font Book,
  or copy them to `~/Library/Fonts/`.
  With [Homebrew](https://brew.sh/), you can also install the first three with:

  ```bash
  brew install --cask font-source-sans-3 font-source-serif-4 font-source-code-pro
  ```

- **Windows:**
  Select the font files in the File Explorer, right-click
  and choose *Install for all users*.
  (Fonts installed only for the current user are not found by all applications.)

To verify that Typst finds the fonts, run:

```bash
typst fonts | grep -E "Source Sans 3|Source Serif 4|Source Code Pro|Erewhon Math"
```

If you cannot install fonts system-wide,
point Typst to a directory with font files instead,
by setting the environment variable `TYPST_FONT_PATHS` (see below).

### Generated Files

The Matplotlib configuration and the Inkscape palette are generated with StepUp.
Install it (e.g. in a virtual environment) and run it in the root of this repository:

```bash
pip install stepup
cd ${UGENTISH}
stepup build
```

Rerun `stepup build` after changing `colors.toml` or `matplotlibrc_template`.

### Environment Variables

Typst looks for packages in the `@ugentish` namespace in the directory `TYPST_PACKAGE_PATH`,
and Matplotlib loads the configuration file in `MATPLOTLIBRC`.

- **Linux and macOS:**
  Add the following lines to your shell startup file
  (e.g. `~/.bashrc` for Bash or `~/.zshrc` for Zsh),
  replacing the path with the location of your clone:

  ```bash
  export UGENTISH="${HOME}/path/to/ugentish"
  export TYPST_PACKAGE_PATH="${UGENTISH}/typst/packages"
  export MATPLOTLIBRC="${UGENTISH}/matplotlib/matplotlibrc"
  # Only needed if the fonts are not installed system-wide:
  # export TYPST_FONT_PATHS="${HOME}/path/to/fonts"
  ```

  Open a new terminal, or run `source ~/.bashrc`, to apply the changes.

- **Windows:**
  Run the following in a Command Prompt or PowerShell,
  replacing the path with the location of your clone:

  ```bat
  setx TYPST_PACKAGE_PATH "C:\path\to\ugentish\typst\packages"
  setx MATPLOTLIBRC "C:\path\to\ugentish\matplotlib\matplotlibrc"
  ```

  Alternatively, set them under
  *Settings > System > About > Advanced system settings > Environment Variables*.
  The changes only take effect in newly started programs.

Note that `TYPST_PACKAGE_PATH` replaces Typst's default directory for local packages.
If you also have packages in the `@local` namespace,
symlink `typst/packages/ugentish` into Typst's default package directory instead
(`~/.local/share/typst/packages/` on Linux,
`~/Library/Application Support/typst/packages/` on macOS,
`%APPDATA%\typst\packages\` on Windows).
Packages from `@preview` (such as Animo) are downloaded automatically and are not affected.

Editors and IDEs only see these variables
when they are started from an environment in which they are set.
For example, restart VS Code after changing them, so that extensions like Tinymist pick them up.

### Verification

Matplotlib caches the list of available fonts.
If it cannot find Source Sans 3 after installing it, remove the cache directory and try again:

```bash
python -c "import matplotlib; print(matplotlib.get_cachedir())"
```

To check that both the configuration and the font are picked up, run:

```bash
python -c "import matplotlib; print(matplotlib.matplotlib_fname())"
python -c "from matplotlib.font_manager import findfont; print(findfont('Source Sans 3'))"
```

For Typst, compile a minimal document:

```typst
#import "@ugentish/ugentish:0.1.0": *
#show: base-ugentish
Hello, #text(fill: ugt.blue)[world] and $x^2$!
```

### Inkscape (Optional)

To use the palette in Inkscape, copy `inkscape/ugentish.gpl`
to the `palettes` subdirectory of Inkscape's user configuration directory.
(Its location is shown under *Edit > Preferences > System > User config*.)
After restarting Inkscape, the palette appears as *UGent 33* in the *Swatches* dialog.

The file `inkscape/ugentish_textext.typ` is a preamble for the
[TexText](https://textext.github.io/textext/) extension,
for typesetting labels in Typst with the same fonts.

## License

[![License: CC BY 4.0](https://i.creativecommons.org/l/by/4.0/88x31.png)](https://creativecommons.org/licenses/by/4.0/)

All files in this repository are licensed under a
[Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
Contributions are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md) for more details.
