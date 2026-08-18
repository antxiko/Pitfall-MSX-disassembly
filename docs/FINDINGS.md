# Findings

What turned up when the cartridge was taken apart, with the evidence next to
it. What is not settled is in [Open questions](OPEN-QUESTIONS.html).

## The world is not stored: it is computed

The 255 screens take up not one byte of map. The screen you are in **is** the
content of one byte of RAM, 0xE222, and changing screen is stepping it once.

The step (0xB68F) is sixteen bytes of `rla` and `xor (hl)`: a feedback shift
register, checked over all 256 possible values:

    new bit = b7 xor b5 xor b4 xor b3      (mask 0xB8)

The ring is **maximal**: it visits the 255 non-zero values and returns to the
start. 0x00 stays outside —a register like this never leaves zero— and the game
uses it for the title screen.

0xB69F is **the exact inverse function**: it shifts the other way and undoes
the step. Leaving to the left brings back the previous screen. The two routines
together take 33 bytes, and they are the whole map of the game.

Seeding with 0xC4 (0x8075) gives the order of the world going right. That order
was reproduced by two independent paths: simulating the two routines, and
capturing all 255 scenes in the emulator. **They agree 255 out of 255.**

## The eight bits of the screen register

When a scene is built (0x9EE6) the byte splits in three:

| bits | what they choose | where they are read |
|---|---|---|
| 6-7 | which of the four sceneries is drawn | 0x9F91 |
| 3-5 | the kind of scene, 0 to 7 | 0x9EFB |
| 0-2 | the variant within that kind | 0x9EEF |

Bit 7 does a second job: it is read again on its own at 0xA9AA, in the pit
scenes, to decide where the **bounce box** goes —class 10, centred at 0xD8 with
the bit set and at 0x31 clear— and whether one pit or three are drawn. The
ladder does not move: both branches draw the same script, 0x8F06.

The ring's share-out is counted without playing: 31 scenes of kind 0 and 32 of
each of the other seven; 63 of scenery 0 and 64 of each of the other three. The
off-by-ones are the missing 0x00.

## The ceiling of the game is 114000 points

The treasures are **exactly** the 32 scenes of kind 5: kind 5 is the only one
dispatched through the table at 0xAEA4, that table holds four routines repeated
two by two, and the eight variants share out four scenes each. One treasure of
each class eight times: 8+8+8+8 = 32.

Each routine writes what its own is worth into 0xE188 —2, 3, 4 or 5, in
thousands— and 0x878C adds it on pickup:

    8 x (2000 + 3000 + 4000 + 5000) = 112000 points

With the 2000 the score starts at (0x8A28), **114000**.

What has been taken is remembered in exactly 32 bits: 0xE21D-0xE220, one byte
per class and one bit per treasure, with the index within the class at 0xE223.

The “already taken” check uses no branch: 0xAAFF rotates the bit into the carry
and, if it was set, does `pop hl` and `ret` (0xAB19): **it eats its own return
address**, and the code that would draw the treasure never runs.

## The underground crosses the world at triple speed

On a screen change, 0x9CD2 checks bit 0 of 0xE2EB —surface or underground— and
steps the register **one place or three**. Down there, three scenes at a time.

That can be measured: the shortest route that collects the 32 treasures is
**189 screens** crossed, against 238 never going down —21 % fewer—. And it does
not all go one way: right until the first treasure, an about-turn, and the
other 31 swept leftwards —13 crossings right and 176 left—. Always going right
would cost 190.

The ladders were counted over the 255 captures of the walk, and the result is
bimodal with no in-between case: a scene has either 3 vertical strokes
—scenery— or 8 —a ladder—. Those with 8 are 63: exactly the scenes of kinds 0
and 1, the same thing the code says. Two independent methods, one number.

The whole ring is [the map of the world](imagenes/mapa-del-mundo.png), and the
route, [the script of the perfect
game](imagenes/guion-de-la-partida-perfecta.png), one cell per screen crossed.

## There is not one letter in this cartridge

Not a string, not an alphabet, not a hidden message. The only font is **twelve
tiles**: the ten digits (0xB8-0xC1), the colon (0xC2) and the blank (0xC3),
just enough for the score and the clock.

Everything else that looks like text is **drawing** cut into consecutive tiles.
That is why searching the ROM for strings returns nothing readable. The only
signature is the line at the foot of the intro, drawing too: two dates, 1982
and 1984.

## The vine is drawn by arithmetic, not stored as a picture

The vine you see on screen is drawn every frame, and it is drawn by code: what
the cartridge does not carry is a graphic of it. On each step, 0xA471 plots a
16-point straight line onto a bitmap in RAM (0xE18A) and uploads it to video
memory as a sprite pattern (0xA594). The slope comes from the table at 0xA61A,
indexed by the phase of the swing (0xE1CB), which runs between 1 and 0x20. So
the rope is a sprite the game builds for itself, sixteen points at a time.

## The left-facing sprites are not in the ROM

Only half is drawn: the left-facing sprites are built at boot by mirroring the
others (0x8B5E). There are two routines: 0xB1D1 reverses each byte bit by bit
—the horizontal mirror— and 0xB20B also swaps the order of the eight bytes. And
the sprite's two halves must be crossed too (0x8BC1), because a 16x16 sprite is
two 16-byte halves.

The animation scripts square it: walking right uses patterns 0x20-0x30 and
walking left 0x44-0x54. The difference, 0x24, is exactly the nine four-pattern
sprites the mirror loop processes in one go.

## Tar and water are the same drawing

Scene kinds 2 and 3 draw the same thing; the only change is that 0xAC7C writes
`1B 1B 1B` at position 0x200B of the colour table —black, tar— and 0xAC6B
writes `7B 7B 7B` —cyan, water—.

The patch takes three bytes of its own (0xB110). The restore takes none: the
water's `7B 7B 7B` is the same one already inside the initial colour table, at
0xB0FB, and 0xAC6B copies it from there.

The same trick in the treasures: the two bars —3000 and 4000— share their
colour (0x4B at 0xAE90 and 0xAE92); the pattern tells them apart.

## The game keeps the interrupt

The hook does not end with a normal `ret` but with **eleven `pop`s in a row**
(0x810F-0x8122) unstacking what the BIOS saved —alternate registers included—
with an `in a,(099h)` in the middle (0x811A) that acknowledges the interrupt.

The first `pop hl` takes the return address to the BIOS, and the `ei` / `ret`
at 0x8123 goes straight back to the interrupted program: the rest of the BIOS
interrupt routine never runs.

## A `rst 0` that tries to overwrite the game's own code

At the end of every frame, at 0x9AE0:

```asm
fin_del_cuadro:
    ld hl,fin_del_cuadro      ; 9ae0
    ld (hl),0c7h              ; 9ae3
```

0xC7 is `rst 0`, and the address written is that same line's: the frame ends by
trying to write over itself a jump to the machine's reset. On a cartridge it
does nothing, because 0x9AE0 is ROM. **What it is for cannot be proven from the
binary**; the reading that fits is a guard against running the game from RAM
—there the write does land, and the game kills itself on the first frame—, but
that is a reading, not a measurement.

## The entry banner is not drawn: it is revealed

The intro (0xB7F1) does not upload a picture: every frame it shifts the ten
patterns loaded at 0xE132 by **one pixel** and uploads them to the pattern
table; every eight frames it reloads the drawing and moves one column on, up to
0x18. Ones come in from the left —the background, the `scf` at 0xB86E— and from
column 12 a sprite appears and starts walking. Not one stored frame.

You do not leave the intro with a key: you leave when the demo's recorded
script has spent seven entries (0xB751).

## The intro runs in one screen mode and the game in another

0xB6B2 sets the video chip's register 0 to 0x02 —graphics mode 2, three
independent banks— for the entry banner; 0xB788 puts it back to 0x00, graphics
mode 1.

Consequences: **the game's colour table is 32 bytes**, not 6144 —in the game's
mode colour goes per group of eight tiles—, and registers 2, 5 and 6 —name
table, sprite attributes and sprite patterns— **are never written in the whole
binary**: the game uses the bases the BIOS left.

## The blocks close one against the next

Knowing where a table ends is usually the worst of a disassembly: the size is
written nowhere and getting it wrong raises no error.

Here almost everything bounds itself, because the data is packed with no gap:
the five big blocks of compressed graphics (0x909E-0x95FE), the nine sprite
blocks of the scene handlers (0x981E-0x99AF), the six of the intro
(0xBAB2-0xBC61), the five cell scripts (0x8F06-0x9090) and the four layouts
(0xA096-0xA33E) each end **exactly** where the next begins. Try N entries and
only one N closes.

## One byte that is three things at once

The floor strips of rows 12 and 13: the layout carries five bytes, and each
byte is at once **offset into the table, copy length and video memory advance**
(0x8DA7). Each strip copies from `tabla+N` to `tabla+2N`.

A side effect that bounds the data: the Ns used by the four layouts are 3, 4,
5, 6, 7, 8 and 0x0A, so usage reaches exactly `tabla+0x14`.

## The pit spends more time shut than open

The pit (0xA870) keeps its width at 0xE133, 1 to 8, and its direction at
0xE132; the class 3 box stretches with it. The cycle is not symmetrical: 0x96
frames with the pit narrow (0xA913) against 0x44 fully open (0xA952) —shut more
than twice as long—.

## What was left over inside the cartridge

Things that are there and go unused. None is a guess: all were checked by
sweeping the cartridge's 16384 words for their address.

- **Six routines nobody calls**: 0xB11E, 0xB199, 0xB1A1, 0xB2A4, 0xB2F4 and
  0xB9AB. 0xB11E is the twin of the 0xB142 decompressor, writing to memory
  instead of the video port; 0xB2A4 is a full keyboard scanner, with debounce
  and key codes, that the game does not need: row 8 is enough.
- **Six orphan `ret`s** (0x9CBD, 0xAA73, 0xACB4, 0xADE7, 0xAE37, 0xB6B0): one
  0xC9 byte stuck after the end of a routine, pointed to by nothing. Four sit
  after a `jp` that takes control away; two, after another `ret`.
- **A well-formed animation script** at 0xAF84 —nine frames, fifty ticks each—
  that nothing loads.
- **A second copy of the starting clock** at 0x8F00, the same five tile numbers
  reading “20:00” as at 0x8A69 with a 0x00 after them instead of the divider.
  Nothing copies it.
- **The data for the second and third logs** (0xAFBA), unused: 0xAD2E takes
  only the first one's and 0xA745 places the other two in code.
- **A collision class that does not exist**: entry 7 of the table at 0x8AA0
  points to 0x874B, and no instruction ever writes a 7 into the class field.
- **Two eight-byte lists** at 0xBAA2, the same one with the nibbles swapped.
  Still without a consumer: it is in [Open questions](OPEN-QUESTIONS.html).
