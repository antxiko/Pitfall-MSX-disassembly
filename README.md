# Pitfall! (Activision, 1984, MSX1) — a commented disassembly

A 16 KB cartridge from 1984, taken apart byte by byte. All 16,384 bytes are
bounded and owned, and there is no map stored inside: the jungle's 255 screens
come out of an eight-bit register, and the 32 treasures are exactly the 32
scenes of one kind.

📖 **[Full documentation](https://antxiko.github.io/Pitfall-MSX-disassembly/)**
· [En castellano](https://antxiko.github.io/Pitfall-MSX-disassembly/es/)
· [README en castellano](README.es.md)

---

## What this is

*Pitfall!* for the MSX is Activision's 1984 conversion of its 1982 Atari 2600
game. This repository holds its code, commented, along with the tools to
rebuild it and check that the result is the original.

The machine maps the 16 KB at 0x8000-0xBFFF —page 2—, the BIOS calls the entry
point at 0x8013, and from there the code never comes back: the startup drops
into an empty two-byte loop and **the whole game runs inside the interrupt**,
fifty or sixty times a second. All the state lives in RAM from 0xE000 up.

## Why this can be trusted

`make` traces the flow, builds the listing and demands that assembling it gives
back exactly the original:

```
  ensamblado : 16384 bytes  4d899d62...82c8be58
  original   : 16384 bytes  4d899d62...82c8be58
OK: reproducible byte a byte
```

A listing can reassemble perfectly and still be wrong —if drawings are read as
instructions, the bytes do not change—, so two more checks run alongside: no
range declared as data may come out as code, and no entry point may fall inside
one.

## The numbers

| | |
|---|---|
| bytes of code | 9,467 |
| bytes of data | 6,917 |
| bytes unexplained | **0** |
| named labels | 337 |
| anchored comments | 988 |
| data ranges with an explanation | 130 |

## A few things that turned up

- **The world is not stored: it is generated.** The screen you are in *is* one
  byte of RAM, 0xE222, and changing screen is stepping a feedback shift
  register once. The ring is maximal: 255 screens, always in the same order,
  out of 33 bytes of code.
- **The 32 treasures are exactly the 32 scenes of one kind**, and the game's
  ceiling —114,000 points— is counted without playing: eight treasures of each
  of the four values, plus the score's starting 2,000.
- **A treasure already taken has its return address eaten.** 0xAAFF rotates its
  bit into the carry and, if it was set, does `pop hl` and `ret`: the code that
  would draw the treasure never runs.
- **The underground crosses the world at triple speed**: crossing a screen down
  there steps the register three places instead of one. The route that collects
  the 32 treasures is 189 screens, against 238 never going down.
- **One clock tick is 60 interrupts**, measured in a real game: at 60 Hz the
  20:00 last twenty wall-clock minutes, and at 50 Hz, twenty-four.
- **The vine is drawn frame by frame, and there is no picture of it stored.**
  Every frame the code plots a sixteen-point straight line onto a bitmap in RAM
  and sends it to video memory as a sprite pattern. Its slope comes out of a
  table, so the rope you see is arithmetic, not a graphic.
- **There is not one written word in the cartridge.** The font is ten digits,
  the colon and a blank; everything that looks like text is drawing. The only
  thing the cartridge signs is the **Copyright 1982, 1984** at the foot of the
  intro.

More, with the evidence next to it, on
[the findings page](https://antxiko.github.io/Pitfall-MSX-disassembly/FINDINGS.html).

## What stays open

No victory condition shows up in the code: no treasure counter, no comparison
against 32. The 189-screen route is a calculation over the cartridge's rules,
not validated by playing it. And the 16 bytes at 0xBAA2 have no consumer. They
are on
[the open questions page](https://antxiko.github.io/Pitfall-MSX-disassembly/OPEN-QUESTIONS.html).

## Getting started

You need `pasmo`, `z80dasm` and Python 3. The cartridge is **not** distributed
here: put your copy in the root as `pitfall.rom`, 16384 bytes, sha256
`4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58`.

```sh
make          # trace, build the listing and check everything
make verify   # assemble and compare with the cartridge
make sanity   # what reassembly cannot catch
```

Full instructions on
[Getting started](https://antxiko.github.io/Pitfall-MSX-disassembly/GETTING-STARTED.html).

## Licence and attribution

The game is not ours: *Pitfall!* belongs to Activision, and all rights remain
with their holders. What is ours —the tools, the comments and the
documentation— is published under the licence in `LICENSE`. The cartridge image is not
distributed. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
