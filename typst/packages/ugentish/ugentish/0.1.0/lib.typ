// SPDX-FileCopyrightText: © 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: CC-BY-4.0

// Colors
// ------
//
// The extended UGent palette, loaded from the single source of truth in colors.toml:
// `ugl` for backgrounds, `ugc` for lines and markers, `ugt` for text on white,
// and `ink` for body text.
#let _colors_toml = toml("colors.toml")

#let ugl = (:
  ..for (name, value) in _colors_toml.light.pairs() { (str(name): rgb(value)) }
)
#let ugc = (:
  ..for (name, value) in _colors_toml.normal.pairs() { (str(name): rgb(value)) }
)
#let ugt = (:
  ..for (name, value) in _colors_toml.text.pairs() { (str(name): rgb(value)) }
)
#let ink = rgb(_colors_toml.extra.ink)

// Fonts
// -----
//
// Open-source fonts only. The text font is either sans-serif or serif,
// while code and math use the same fonts in both cases.
#let fonts = (
  sans: "Source Sans 3",
  serif: "Source Serif 4",
  mono: "Source Code Pro",
  math: "Erewhon Math",
)

// The show rule with the basic style settings that all UGentish templates share:
// fonts, text color, links, underlines and highlights.
// Templates apply it first and add their own settings on top.
//
//     #show: base-ugentish.with(font: "serif")
//
// `font` selects the text font: "sans" (Source Sans 3, the default) or "serif" (Source Serif 4).
#let base-ugentish(body, font: "sans") = {
  assert(
    font in ("sans", "serif"),
    message: "font must be \"sans\" or \"serif\", got " + repr(font),
  )
  set text(font: fonts.at(font), fill: ink)
  show raw: set text(font: fonts.mono)
  show math.equation: set text(font: fonts.math)
  // Blue links, a light underline and a yellow highlight.
  show link: it => underline(text(fill: ugc.blue, it))
  set underline(offset: 0.13em, stroke: 0.065em)
  set highlight(fill: ugc.yellow, stroke: none)
  body
}
