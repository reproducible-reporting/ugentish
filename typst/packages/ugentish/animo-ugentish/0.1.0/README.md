# Animo UGentish

A slide template that follows *a subset* of the UGent style guide,
built on [Animo](https://github.com/reproducible-reporting/animo).
This is an unofficial package, not endorsed by Ghent University (UGent),
and it contains no UGent logos.

See the [UGent style guide](https://www.ugent.be/en/communication/house-style) for the official rules.

## Usage

```typst
#import "@ugentish/animo-ugentish:0.1.0": *

#show: animo-ugentish.with(
  short: "intro",
  logos: (image("logo-a.svg"), image("logo-b.svg")),
)

#title-slide(
  "Title of the talk",
  subtitle: "Subtitle",
  authors: "Jane Doe",
  note: "Venue, 2026",
)

#slide(title: "Goals", animation: {
  import anim: *
  sub(reveal("second"))
})[
  + A first goal.

  #tag("second")[A second goal, #text(fill: ugc.red)[revealed later].]
]
```

One source compiles to the three outputs Animo offers:

```bash
typst compile --format html --features html slides.typ slides.html
typst compile --input animo=presentation slides.typ slides-presentation.pdf
typst compile slides.typ slides-handout.pdf
```

## Logos

This package contains no logos.
Pass your own as content through the `logos:` option of the show rule,
either a single item or an array.
They appear in a row at the bottom left of the title slide.
Make sure you are allowed to use them and follow the usage terms of their owners.

## What It Exports

| Name                          | What it is                                                                 |
| ----------------------------- | -------------------------------------------------------------------------- |
| `animo-ugentish`              | the document show rule: deck shape, fonts, colors, list and link styles   |
| `slide`                       | a slide with a `title:` and the deck's recurring parts                     |
| `title-slide`                 | the blue title panel, with the logos you supplied below it                 |
| `outline-slide`               | the list of sections, optionally opening one of them                       |
| `panel`                       | a beamer-style titled block                                                |
| `alert`, `key`, `aside`       | emphasis in bold red, keywords in bold green, small gray remarks           |
| `vector`                      | a vector in math, upright and bold, e.g. `$vector(r)$`                     |
| `ugl`, `ugc`, `ugt`, `ink`    | the extended UGent palette, e.g. `ugc.blue`, `ugc.yellow`, `ugc.green`     |
| `fonts`, `base-ugentish`      | the font names and the basic show rule from `@ugentish/ugentish`           |
| `deck-width`, `deck-height`, `deck-margin` | the deck's geometry, for figures that have to match it |
| Animo's own names             | `tag`, `region`, `per-subslide`, `slide-number`, `slide-count`, `anim`     |

### `animo-ugentish(short, sections: (:), logos: (), font: "sans")`

`short` is the abbreviation in the footer, `sections` is explained under `outline-slide`,
`logos` is described above.
`font` selects the text font: `"sans"` (Source Sans 3) or `"serif"` (Source Serif 4).

### `title-slide(title, subtitle: none, authors: none, note: none, ..)`

All arguments except `title` are optional content.

### `slide(title: none, ..)`

`title:` puts a heading.

Every other argument passes straight through to Animo's `#slide`,
so `animation:`, `background:`, `canvas:`, `numbered:` and the rest work as documented.

### `outline-slide(current, subsection, title: "Outline", ..)`

The sections are declared once, in the show rule,
as a dictionary from a short mnemonic to a title,
or to a title with a dictionary of subsections, again from mnemonic to title:

```typst
#show: animo-ugentish.with(
  short: "intro",
  sections: (
    motiv: "1. Motivation",
    method: (
      title: "2. Method",
      subsections: (
        theory: "2.1 Theory",
        setup: "2.2 Setup",
      ),
    ),
  ),
)
```

`#outline-slide()` lists all sections.
`#outline-slide("method")` opens a section:
it highlights that section in the list,
and the footer of this and all following slides shows `intro > method`.
`#outline-slide("method", "theory")` also opens a subsection:
it highlights the section and only that subsection,
and the footer shows `intro > method > theory`.
Keep the mnemonics short, so the footer stays unobtrusive.
