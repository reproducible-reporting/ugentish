// SPDX-FileCopyrightText: © 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: CC-BY-4.0

#import "@preview/animo:0.1.1": *
#import "@preview/cetz:0.5.2"
#import "@ugentish/ugentish:0.1.0": ugl, ugc, ugt, ink, fonts, base-ugentish

// The names imported above are part of this module's scope, so a deck that star-imports
// this package gets them along with everything below.
// The _plain-slide name is private to this module,
// so that the public `#slide` wrapper can add the recurring elements of the deck.
#let _plain-slide = slide

// Geometry
// --------
//
// Animo has no paper names: a deck states its two lengths. These are the ones typst calls
// "presentation-16-9", and with the 10mm margin they leave a body of 10.69 x 5.58 inch,
// which is exactly the `figure.figsize` a matplotlib figure needs to fill a slide.
#let deck-width = 13.333in
#let deck-height = 7.5in
#let deck-margin = 1cm
#let deck-pad = 0.75cm

// What the whole deck knows about itself, so that the recurring elements do not have to be
// repeated on every slide.
// Written once by the `animo-ugentish` show rule and read back in the overlay.
// This package ships no logos: `logos` is a list of content supplied by the user.
#let _deck = state("ugentish-animo-deck", (
  short: none,
  sections: (:),
  logos: [],
))

// The mnemonic of the current section, written by `outline-slide` and shown in the footer.
#let _section = state("ugentish-animo-section", none)

// Helper functions and overrides
#let vector = it => $upright(bold(it))$

// The slide indicator
// -------------------
//
// Animo has no footer machinery, so a recurring element is a wrapper around `#slide` that
// fills the overlay layer. The overlay is the place for it: it is rendered once per slide
// rather than once per epoch, and it belongs to the viewport rather than to the canvas.
//
// A slide declared with `numbered: false` shows no indicator and does not count towards
// the total, because `slide-number()` hands back `none` there and `slide-count()` counts
// only the slides that carry a number.
//
// The subslide letter needs `per-subslide`: one rendering of a slide covers a whole run of
// subslides, so a number written straight into the overlay would be the same on all of
// them. Its callback is laid out once per subslide and the browser (or the page of a
// paged output) shows the one that belongs to the state on screen.
#let _slide-indicator(islide, nslide, isub, nsub) = {
  let slide-radius = 0.5cm
  let sub-radius = 0.3cm
  let sub-shift = 0.62cm
  let progstroke = (paint: ugc.gray, thickness: 0.6mm, cap: "round")
  cetz.canvas({
    import cetz.draw: *
    // An invisible rectangle around both disks, so that the indicator keeps the same size
    // and lands in the same corner whether or not the subslide disk is drawn.
    rect(
      (-slide-radius, -sub-shift - sub-radius),
      (sub-shift + sub-radius, slide-radius),
      fill: none,
      stroke: none,
    )
    if nsub > 1 {
      let sub-angle = -isub / nsub * 360deg
      circle(
        (sub-shift, -sub-shift),
        fill: white.transparentize(30%),
        radius: sub-radius,
        stroke: none,
      )
      arc(
        (sub-shift, -sub-shift),
        anchor: "origin",
        start: 90deg,
        delta: sub-angle,
        radius: sub-radius - 0.5mm,
        fill: none,
        stroke: progstroke,
      )
      content(
        (sub-shift, -sub-shift),
        text(size: 11pt, fill: ugc.gray, numbering("a", isub)),
      )
    }

    let slide-angle = -islide / nslide * 360deg
    circle((0, 0), fill: white.transparentize(30%), radius: slide-radius, stroke: none)
    arc(
      (0, 0),
      anchor: "origin",
      start: 90deg,
      delta: slide-angle,
      radius: slide-radius - 0.5mm,
      fill: none,
      stroke: progstroke,
    )
    content((0, 0), text(size: 12pt, fill: ugc.gray, numbering("1", islide)))
  })
}

// The overlay of an ordinary slide: the part name at the left and the indicator at the right.
//
// A `#place` inside the overlay resolves against the full viewport without margins, hence
// the small offsets that push each element back inside the margin.
#let _slide-overlay() = context {
  let islide = slide-number()
  if islide != none {
    let short = _deck.get().short
    let section = _section.get()
    if short != none and section != none {
      short = short + " > " + section
    }
    if short != none {
      place(
        bottom + left,
        dx: 0.5cm,
        dy: -0.45cm,
        text(size: 12pt, fill: ugc.gray, short),
      )
    }
    place(
      bottom + right,
      dx: -0.2cm,
      dy: -0.2cm,
      per-subslide(it => _slide-indicator(islide, slide-count(), it.number, it.count), wrap: box),
    )
  }
}

// Slides
// ------
//
// One slide, with a title bar and the recurring elements of the deck folded in, so that the body below is written the way the Animo manual writes
// it. Every argument of Animo's `#slide` passes straight through.
//
//     #slide(title: "Goals")[...]
#let slide(body, title: none, ..arguments) = _plain-slide(
  {
    if title != none {
      move(dy: -deck-margin, block(
        width: deck-width - deck-margin,
        inset: deck-pad,
        fill: ugl.gray.lighten(50%),
        text(weight: "bold", fill: ugt.gray, title),
      ))
      v(-deck-margin)
    }
    body
  },
  overlay: _slide-overlay(),
  ..arguments,
)

// The title slide: a blue panel with the title, and the logos supplied to the show rule
// below it.
//
// `subtitle`, `authors` and `note` (e.g. a date, venue or copyright line) are optional content.
// `numbered: false` keeps the title slide out of the slide count.
#let title-slide(title, subtitle: none, authors: none, note: none, ..arguments) = _plain-slide(
  numbered: false,
  ..arguments,
)[
  #v(-deck-margin*1.01)
  #rect(
    width: deck-width - 0.99*deck-margin,
    height: deck-height * 0.75,
    fill: ugc.blue,
    inset: deck-margin,
  )[
    #align(bottom)[
      #set text(fill: white)
      #text(size: 16pt, {
        authors
        if authors != none and note != none { linebreak() }
        note
      })

      #v(1fr)

      #text(size: 54pt, weight: "bold", title)

      #if subtitle != none {
        text(size: 24pt, subtitle)
      }
    ]
  ]
  #v(1fr)
  #context _deck.get().logos
]

// The outline slide
// -----------------
//
// The sections of the deck are declared once, in the show rule, as a dictionary from a
// short mnemonic to the section title, or to a title with subsections, which are in turn a
// dictionary from mnemonic to title:
//
//     sections: (
//       comput: "1.1 Physics and Computational Physics",
//       mech: (title: "1.2 Classical Mechanics", subsections: (de: "A.7 Differential Equations")),
//     )
//
// `#outline-slide()` lists all of them. `#outline-slide("mech")` opens that section: it
// highlights it in the list and puts the mnemonic in the footer of this and the following
// slides, e.g. "intro > mech". Without a subsection, only the section title is
// highlighted: all subsections stay gray, including those of the open section.
// `#outline-slide("mech", "de")` also opens a subsection: it highlights only that one among
// the subsections, and the footer shows "intro > mech > de".
#let outline-slide(..arguments) = {
  let current = arguments.pos().at(0, default: none)
  let current-sub = arguments.pos().at(1, default: none)
  let arguments = arguments.named()
  context {
    let sections = _deck.get().sections
    if current != none and current not in sections {
      panic("unknown section: " + repr(current) + ", expected one of " + repr(sections.keys()))
    }
    if current-sub != none {
      if current == none {
        panic("a subsection needs a section")
      }
      let section = sections.at(current)
      let subsections = if type(section) == dictionary {
        section.at("subsections", default: (:))
      } else {
        (:)
      }
      if current-sub not in subsections {
        panic(
          "unknown subsection of " + repr(current) + ": " + repr(current-sub)
            + ", expected one of " + repr(subsections.keys())
        )
      }
    }
  }
  if current != none {
    _section.update(if current-sub == none { current } else { current + " > " + current-sub })
  }
  let light = luma(60%)
  slide(..arguments, context
    align(center + horizon, {
      block({
        set align(left)
        v(1fr)
        for (key, section) in _deck.get().sections {
          if type(section) == str {
            section = (title: section)
          }
          let fill = if current == none {
            ink
          } else if current == key {
            ugc.blue
          } else {
            light
          }
          block(above: 0.8em, below: 0.4em, text(fill: fill, strong(section.title)))
          for (subkey, subsection) in section.at("subsections", default: (:)) {
            v(0.5fr)
            let sub-fill = if current == none {
              ink
            } else if current == key and current-sub == subkey {
              ugc.blue
            } else {
              light
            }
            block(
              above: 0.3em,
              below: 0.3em,
              inset: (left: 1.2em),
              text(size: 0.85em, fill: sub-fill, subsection),
            )
          }
          v(1fr)
        }
        v(1fr)
      })
    })
  )
}

// A beamer-style titled block, for the few places where the slide body is a set of named
// boxes rather than a running list.
//
// `hue` is a color name shared by the ugentish palettes ("blue", "red", "green", ...):
// the title bar takes the normal shade, the border the light one.
#let panel(body, title:none, hue: "blue") = block(
  width: 100%,
  clip: true,
  grid(
    columns: (1fr),
    ..if (title != none) {
      (box(
        width: 100%,
        fill: ugc.at(hue),
        inset: deck-pad,
        text(fill: white, weight: "bold", title),
      ),)
    },
    box(width: 100%, inset: deck-pad, fill: ugl.at(hue), body)
  ),
)

// Emphasis in red, keywords in green, and small gray remarks.
#let alert(body) = text(fill: ugc.red, weight: "bold", body)
#let key(body) = text(fill: ugc.green, weight: "bold", body)
#let aside(body) = text(size: 0.8em, fill: ugc.gray, body)

// The deck
// --------
//
// The document show rule: the shape of the deck, the fonts and the few set rules that make
// plain typst look like UGent. Applied once, at the top of a deck.
//
//     #show: animo-ugentish.with(short: "about", logos: image("my-logo.svg"))
//
// `short` is the abbreviation in the footer of every slide.
// `sections` maps a short mnemonic to each section title, see `outline-slide`.
// `logos` is content shown below the title panel.
// The package contains no logos: provide your own, and respect their usage terms.
// `font` selects the text font, "sans" or "serif", see `base-ugentish` in @ugentish/ugentish.
#let animo-ugentish(
  body,
  short: none,
  sections: (:),
  logos: [],
  font: "sans",
  ..arguments,
) = {
  show: base-ugentish.with(font: font)
  set text(size: 24pt)
  set line(stroke: 0.5mm)
  set enum(spacing: 1em)
  set table(stroke: none)
  show raw.where(block: true): it => block(
    fill: ugl.gray.lighten(50%),
    inset: 0.4cm,
    radius: 0.2cm,
    it,
  )
  show raw.where(block: false): it => highlight(
    fill: ugl.gray.lighten(50%),
    stroke: ugl.gray.lighten(50%) + 0.1cm,
    radius: 0.1cm,
    it,
  )
  animo(
    {
      _deck.update((short: short, sections: sections, logos: logos))
      body
    },
    width: deck-width,
    height: deck-height,
    margin: deck-margin,
    ..arguments,
  )
}
