# Legal notice and attribution

*(También disponible [en castellano](AVISO-LEGAL.md).)*

## Who owns what

**The game is not ours.** *Pitfall!* for the MSX was published by **Activision**
in 1984, and is that company's own conversion of its 1982 Atari 2600 game. All
rights in the game remain with their holders.

**What is ours** are this repository's tools, the listing's comments, the analysis
and the documentation. Those are published under the licence in `LICENSE`.

## What this repository contains

The file `src/pitfall.asm` is the commented disassembly of the cartridge. It is
published for the **preservation, study and documentation** of a 1984 title that
is part of the MSX's software history.

The cartridge image (`.rom`) is **not** distributed here. Anyone wanting to
rebuild the listing has to supply their own, and the `Makefile` checks its sha256
before doing anything.

The pictures under `docs/` come from two different places, and it is worth saying
which is which:

- the world map, the eight sample scenes and the title banner **are screen
  captures**, made by driving the cartridge in an emulator with this repository's
  scripts —the emulator is told which value to put in the screen register and
  asked for a photograph of each scene—;
- the strip of the main character's frames is not a drawing: it is the game's own
  sprite patterns, read out of the dumped video memory and put back together
  exactly as the code composes them;
- and the walkthrough diagram is generated, not photographed: it is the shortest
  route worked out over the world the cartridge itself produces.

None of them is artwork brought in from elsewhere, and all of them are part of the
proof that the reading of the binary is right: get the reading wrong and the
pictures come out crooked.

## What it leans on

Nothing of anyone else's. Everything claimed here comes from reading this binary,
and each claim carries its evidence alongside: the instruction that reads a piece
of data, the table that closes exactly where it must, or the arithmetic that adds
up on its own. What isn't settled is stated as such on the open-questions page.

## If you're one of the authors

If you worked on *Pitfall!* or hold rights in the game, and you'd rather this
material weren't published, **say so and it comes down, no argument**. The intent
of this work is the exact opposite of harming you: it's to put on record how it
was made.
