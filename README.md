# Pitfall! (Activision, 1984, MSX1) — a commented disassembly

A 16 KB cartridge from 1984, taken apart byte by byte. All 16,384 bytes are
bounded and owned, and inside there is no map at all: the jungle's 255 screens
are made up as it goes by an eight-bit register, the 32 treasures are exactly the
32 scenes of one kind, and the vine isn't drawn anywhere.

📖 **[Full documentation](https://antxiko.github.io/Pitfall-MSX-disassembly/)**
· [En castellano](https://antxiko.github.io/Pitfall-MSX-disassembly/es/)
· [README en castellano](README.es.md)

---

## What this is

*Pitfall!* for the MSX is Activision's 1984 conversion of its own 1982 Atari 2600
game. This repository holds its code, commented, along with the tools to rebuild
it and to check that the result really is the original.

Being a cartridge changes the shape of the job. There is no loader and no blocks
to wait for: the machine maps the 16 KB at 0x8000-0xBFFF —page 2— and that is the
whole picture, one snapshot of memory with no overlaps. The BIOS reads an "AB"
header, calls the entry point at 0x8013, and from there the code never comes
back: the startup drops into an empty two-byte loop and **the whole game runs
inside the interrupt**, fifty or sixty times a second.

There isn't a single variable in the cartridge either, because it is ROM. All the
state lives in the machine's RAM from 0xE000 up, which is why the listing is full
of addresses starting 0xE0 that are not data at all.

## How you know this is true

`make` traces the flow, generates the listing and demands that assembling it
gives back exactly the original:

```
  ensamblado : 16384 bytes  4d899d62...82c8be58
  original   : 16384 bytes  4d899d62...82c8be58
OK: reproducible byte a byte
```

That is the test that settles whether a disassembly can be trusted, but it isn't
the only one here, because a listing can reassemble perfectly and still be lying:
if some artwork is read as instructions the bytes don't change, only what we say
about them does. So two more checks run alongside:

- no range declared as data may come out as code;
- and no entry point may fall inside one.

## The numbers

| | |
|---|---|
| bytes of code | 9,467 |
| bytes of data | 6,917 |
| bytes unexplained | **0** |
| named labels | 337 |
| anchored comments | 305 |
| data ranges with an explanation | 130 |

## A few things that turned up

- **The world isn't stored, it's generated.** The screen you are on *is* one byte
  of RAM, 0xE222, and changing screen is turning it one step with a feedback
  shift register. The ring is maximal: 255 screens, always in the same order, out
  of 33 bytes of code. That is the entire map of this game.
- **The 32 treasures are exactly the 32 scenes of one kind**, and the ceiling of
  the game —114,000 points— can be counted without playing: eight treasures of
  each of the four values, plus the 2,000 the score starts at.
- **A treasure already taken has its return address eaten.** 0xAAFF rotates its
  «already got it» bit into the carry, and if it was set it does `pop hl` and
  `ret`: it swallows its caller's return address, so the code that would have
  drawn the treasure never runs.
- **The tunnel crosses the world three times as fast**: crossing a screen down
  there turns the register three steps instead of one, which is why the route
  that collects everything is 190 screens instead of 238.
- **The vine isn't drawn anywhere.** Every frame a sixteen-point straight line is
  traced onto a bitmap in RAM and sent to video memory as a sprite pattern.
- **There isn't one written word in the cartridge.** The font is ten digits, a
  colon and a blank; everything that looks like text is drawing cut into cells.
  The only thing the cartridge signs is the **Copyright 1982, 1984** at the foot
  of the title screen.

There is more, with the evidence, on
[the findings page](https://antxiko.github.io/Pitfall-MSX-disassembly/FINDINGS.html).

## What's still open

Every byte has an owner, but not everything is settled. The clock is the clearest
case: the code ticks once every 60 frames and a measurement in the emulator gave
something of the order of nine real seconds per tick, and that difference is
still unexplained. The 190-screen route is a calculation over the cartridge's own
rules, not a recorded game. And no winning condition turns up in the code: there
isn't a single comparison against 32 anywhere. Those and the rest are on
[the open-questions page](https://antxiko.github.io/Pitfall-MSX-disassembly/OPEN-QUESTIONS.html).

## Getting started

You need `pasmo`, `z80dasm` and Python 3. The cartridge is **not** distributed
here: put your own copy in the project root as `pitfall.rom`, 16384 bytes, sha256
`4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58`.

```sh
make          # trace, build the listing and check everything
make verify   # just the acid test
make sanity   # what reassembling cannot catch
```

Full instructions are in
[Getting started](https://antxiko.github.io/Pitfall-MSX-disassembly/GETTING-STARTED.html).

## Licence and attribution

The game is not ours: *Pitfall!* is Activision's, and all rights in it remain
with their holders. What is ours —the tools, the comments, the analysis and the
documentation— is published under the licence in `LICENSE`. The cartridge image
is not distributed. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
