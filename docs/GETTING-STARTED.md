# Getting started

## What you need

`pasmo` and `z80dasm` to assemble and disassemble, and Python 3 for the tools.
Nothing else: there are no dependencies to install and no environment to set up.

The cartridge is not distributed with this repository, only the documentation
work, so you need your own copy named `pitfall.rom` in the root of the project.
It is 16384 bytes exactly and has to give this sha256:

    4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58

If yours doesn't, it is another dump and the listing will not reassemble. `make
comprueba` tells you in one line.

## The commands

```sh
make          # traces, generates the listing and checks everything
make verify   # just the acid test: does the cartridge come back out?
make sanity   # what reassembling CANNOT catch
make test     # the 17 tests on the listing, which don't need the cartridge
```

Plain `make` does the whole cycle and fails if anything doesn't add up: if the
listing stops reproducing the cartridge byte for byte, if the tracer has walked
into an area declared as data, if an entry point falls inside that area, or if a
single one of the 16384 bytes is left without an owner.

## The test that decides

The only thing that makes a disassembly trustworthy is that it gives the
original back. Here that is `make verify`, and what it does is assemble the
published listing and compare its sha256 with the cartridge's:

    ensamblado : 16384 bytes  4d899d62...82c8be58
    original   : 16384 bytes  4d899d62...82c8be58
    OK: reproducible byte a byte

As long as that line comes out, not one comment in this repository can have
eaten a byte along the way.

## The second test, the one almost nobody runs

A listing can reassemble perfectly and still be lying: if some artwork is being
read as instructions, the bytes don't change —only what we say about them
does— and the sha256 comes out the same. `make sanity` is exactly that check,
and it ends with the full share-out:

      codigo trazado              9467   57.78 %
      datos identificados         6917   42.22 %
      sin explicar                   0    0.00 %
      ==========================================
      explicado                  16384  100.00 %

## Without the cartridge

You can still read the listing in `src/pitfall.asm` and the notes, which is
where the work is: 5725 lines with 337 routines and tables named, 305 comments
anchored to their address and 130 ranges of data with their explanation beside
them. The 17 tests run just the same, because not one of them needs the
binary.

## How it is organised

The listing is **never edited by hand**. It is generated, and three files
govern it:

| | |
|---|---|
| `src/pitfall.entries` | the entry points: where the tracing starts |
| `src/pitfall.nocode` | the areas that are NOT code, and how we know |
| `src/pitfall.notes` | the names, the comments and the data ranges |

`src/pitfall.asm` comes out of those. If you want to change a comment or name a
routine, it goes in the `.notes`, anchored to its address; that way the comment
survives a re-trace and never comes unstuck from the instruction it explains.

The `.entries` is longer here than usual: this cartridge declares **a single
entry point** —the BIOS reads the header and calls 0x8013— and everything else
arrives by paths no static tracer can follow. The interrupt hook (0x80F7), the
object handlers that travel inside templates copied into RAM, the four dispatch
tables and the sound vectors are declared one by one, each with the instruction
that writes it noted beside it.

## The tools

Everything is in `tools/`, and each one carries in its header what it does and
why it was done that way:

| | |
|---|---|
| `z80trace.py` | follows the flow from the entry points |
| `mkasm.py` | builds the listing with the notes anchored in place |
| `presupuesto.py` | the share-out of the 16384 bytes, and what is left ownerless |
| `refs.py` | which instructions point into a range, without inventing pointers |
| `quien_apunta.py` | for each gap, who reads it from the traced code |
| `busca_autoescritura.py` | looks for writes to the ROM: the effect of a protection, not one particular shape of it |
| `mapa_escenas.py` | reproduces the ring of 255 scenes from the cartridge |
| `busca_escaleras.py` | which scenes let you climb down to the tunnel |
| `ruta_optima.py` | the shortest route that collects all 32 treasures |
| `monta_mapa_guion.py` | the 255 scenes in a labelled grid |
| `dibuja_guion.py` | that route drawn out, one cell per screen |
| `omsx_*.tcl` | the openMSX harnesses: boot, captures and the walk around the world |
