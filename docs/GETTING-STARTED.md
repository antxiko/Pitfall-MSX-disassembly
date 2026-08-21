# Getting started

## What you need

`pasmo` and `z80dasm` to assemble and disassemble, and Python 3 for the tools.
No other dependencies.

The cartridge is not distributed with this repository: you need your own copy,
named `pitfall.rom` in the project root. It is exactly 16384 bytes with this
sha256:

    4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58

With any other dump the listing will not reassemble. `make comprueba` tells you
in one line.

## The commands

```sh
make          # trace, build the listing and check everything
make verify   # assemble the listing and compare its sha256 with the cartridge
make sanity   # what reassembly cannot catch
make test     # the 17 tests over the listing, no cartridge needed
```

`make` fails if the listing stops reproducing the cartridge byte for byte, if
the tracer walks into an area declared as data, if an entry point falls inside
one, or if a single byte of the 16384 is left unaccounted for.

## The proof that decides

A disassembly is trustworthy if assembling it gives back the original. That is
`make verify`:

    ensamblado : 16384 bytes  4d899d62...82c8be58
    original   : 16384 bytes  4d899d62...82c8be58
    OK: reproducible byte a byte

## The second proof

A listing can reassemble perfectly and still be wrong: if drawings are being
read as instructions, the bytes do not change —only what is said about them
does—. `make sanity` crosses the data ranges against the trace and ends with
the split:

      codigo trazado              9467   57.78 %
      datos identificados         6917   42.22 %
      sin explicar                   0    0.00 %
      ==========================================
      explicado                  16384  100.00 %

## Without the cartridge

The work is in `src/pitfall.asm` and the notes: 6,569 lines with 337 routines
and tables named, 988 line comments anchored to their address and 130 ranges of
data with their explanation next to them. The 17 tests run without the binary.

## How it is organised

The listing is **never edited by hand**: it is generated, governed by three
files.

| | |
|---|---|
| `src/pitfall.entries` | the entry points: where tracing starts |
| `src/pitfall.nocode` | the areas that are NOT code, and how that is known |
| `src/pitfall.notes` | the names, the comments and the data ranges |

From those, `src/pitfall.asm`. Every note is anchored to its address, so it
survives a retrace.

The `.entries` file is long because the cartridge declares **one single entry
point** —the BIOS reads the header and calls 0x8013— and everything else
arrives by paths no static tracer can follow: the interrupt hook (0x80F7), the
handlers that travel inside templates copied to RAM, the four dispatch tables
and the sound vectors, declared one by one with the instruction that writes
them noted alongside.

### How the data blocks are laid out

Every data range declared in the `.notes` comes out as a block of its own: its
own heading saying what it is for, its own label, and the dump aligned to its
first byte, so where one table ends and the next begins is visible at a glance.
An optional line gives the block the row width of its real structure -one
eight-byte pattern per row, four bytes per animation record, `defw` for a table
of pointers- and where a pointer lands on a block that has a name, that name is
written next to it.

## The tools

In `tools/`, each with its own header:

| | |
|---|---|
| `z80trace.py` | follows the flow from the entry points |
| `mkasm.py` | builds the listing with the notes anchored |
| `presupuesto.py` | the split of the 16384 bytes, and what is left unowned |
| `refs.py` | which instructions point into a range, without inventing pointers |
| `quien_apunta.py` | for each gap, who reads it from traced code |
| `busca_autoescritura.py` | looks for writes into the ROM |
| `mapa_escenas.py` | reproduces the ring of 255 scenes from the cartridge |
| `busca_escaleras.py` | which scenes have a way down to the underground |
| `ruta_optima.py` | the shortest route that collects the 32 treasures |
| `monta_mapa_guion.py` | the 255 scenes on a grid, labelled |
| `dibuja_guion.py` | that route drawn, one cell per screen |
| `omsx_*.tcl` | the openMSX harnesses: boot, captures and walking the world |
