# The cartridge

It is 16384 bytes, and that's it. There is no loader, no blocks, nothing to wait
for: the MSX maps the cartridge at 0x8000-0xBFFF —page 2— and what is there is
what is there for good. One single photograph of memory, with no overlaps: no
address means two different things at two different moments.

## Where it comes in

The first sixteen bytes are the header the BIOS reads:

    41 42 13 80 00 00 00 00 00 00 00 00 00 00 00 00
    'A' 'B'  \_ INIT = 0x8013

The two letters are the signature that tells the machine there is an executable
cartridge there, and behind them go four two-byte vectors. Only the first is
filled in: the other three —STATEMENT, DEVICE and TEXT, the ones that would serve
to add statements to BASIC or to declare a device— are zero. This cartridge is a
game and nothing else.

Behind the header, at 0x8010, there are three bytes that are not header and are
never executed there either: `C3 F7 80`, that is, a `jp 0x80F7` ready made. The
startup copies them just as they are into the interrupt hook, and that is where
they run.

## What the startup does

INIT (0x8013) is short and very carefully measured:

- it clears the 4 KB from 0xE000 to 0xEFFF in one go (0x8017), which is where all
  the game's state is going to live, and puts the stack at 0xE54B (0x8023);
- it silences the sound chip (0x8026) and zeroes the 16 KB of video memory
  (0x802D);
- it copies the three bytes at 0x8010 into the H.KEYI hook, at 0xFD9A
  (0x803C-0x8046);
- it goes through the title screen (0x805C), comes back, zeroes the video memory
  again and loads the sprites;
- it sets a game up and drops into a two-byte loop, at 0x80F5.

That empty loop is the main program. **From there on the whole game runs inside
the interrupt**, fifty or sixty times a second, and the thread the machine
started never does anything again.

## Where the state lives

There isn't a single variable in the cartridge, because it is ROM. Everything the
game keeps note of lives in the MSX's RAM from 0xE000 on, and that is why the
listing is full of addresses beginning with 0xE0: they are not cartridge data,
they are variables.

The ones read most:

| | |
|---|---|
| 0xE012 | the lives left |
| 0xE05F | what is being pressed, in joystick format |
| 0xE1D0-0xE1D4 | the clock, stored already as cell numbers |
| 0xE1D6-0xE1DB | the six digits of the score |
| 0xE1E6-0xE1ED | the four sound vectors |
| 0xE20E-0xE21B | the copy of the sound chip's fourteen registers |
| 0xE21D-0xE220 | the 32 bits of the treasures you have already taken |
| 0xE221 | whether what is running is the demo |
| 0xE222 | **the screen register**: the whole world fits in here |
| 0xE224 / 0xE225 | the variant and the kind of the scene, taken from 0xE222 |
| 0xE229-0xE246 | the ten collision boxes |
| 0xE247 | how many objects are alive, and behind it one pointer per object |
| 0xE26A-0xE2BD | the sprite attribute table, dumped whole every frame |

And behind that table go the object structures, one right up against the next
without a gap: 0xE2BF, 0xE2D5 (the player), 0xE2ED, 0xE303, 0xE319 and 0xE32F.
The player's takes 24 bytes and the other five 22, which is exactly what is needed
for the chain to close at 0xE345.

## The screen, and the three registers the game doesn't touch

The cartridge writes the video chip's registers in five places you can count, and
it only writes five of the eight: 0 and 1 (mode and screen), 3 and 4 (the colour
and pattern bases) and 7 (the background, at 0x8036, value 0x11: black).

**Registers 2, 5 and 6 are written by nobody.** They are the ones that say where
the name table, the sprite attributes and the sprite patterns are, and yet the
game writes to 0x1800, to 0x1B00 and to 0x3800-0x3FFF all through the listing. So
it takes as good the bases the BIOS left set and doesn't bother repeating them.

The layout that comes out is this:

| | |
|---|---|
| 0x0000 | the cell patterns (register 4 = 0x00, at 0xB79A) |
| 0x1800 | the name table |
| 0x1B00 | the sprite attributes |
| 0x2000 | the colours (register 3 = 0x80, at 0xB794) |
| 0x3800 | the sprite patterns |

Register 1 is 0xE2 (0x8047): 16 KB, screen and interrupt on, and 16x16 sprites.

There is one detail that is paid for in bytes: **the title screen is in one mode
and the game in another**. At 0xB6B2 register 0 is set to 0x02 —graphics mode 2,
the one with three independent banks— for the opening banner, and on the way out,
at 0xB788, it goes back to 0x00, graphics mode 1. That is why the game's colour
table is 32 bytes and not 6144: in the game's mode the colour goes per group of
eight cells, not per cell.

## How the artwork is stored

There is a 58-byte decompressor at 0xB142 that dumps straight into the video
port. The whole format can be read off it: two bytes of destination address and
then one-byte tokens with the count in the low six bits —bit 7 skip N positions,
bit 6 copy N literal bytes, neither of the two repeat the next byte N times, and a
zero closes—.

Compressed that way go the cell and sprite patterns (0x909E-0x95FE), the nine
sprite blocks of the scene handlers (0x981E-0x99AF) and the six of the title
screen (0xBAB2-0xBC61). What is not compressed is the four sets of 16 scenery
cells (0x95FE-0x97FE) and seven loose sprite patterns: the filler one at
0x97FE-0x981E and the six at 0x99AF-0x9A6F, 32 bytes each, with nothing to save.

Each compressed block ends **exactly** where the next one begins, and that is
what fixes its size without having to assume it.

## The typeface fits in twelve cells

There isn't a single string of text in this cartridge. The only thing resembling
a font is twelve cells: the ten digits (0xB8-0xC1), the colon (0xC2) and the blank
(0xC3). The score and the clock are written with those, and they don't stretch to
a single letter. Everything else on screen that looks like text is drawing.

## The full share-out

Not one byte ownerless: 9467 of code the tracer reaches by following the flow for
real and 6917 of data, each one inside a declared range with the instruction that
reads it written beside it.

| | |
|---|---|
| 0x8000-0x8010 | the header |
| 0x8010-0x8013 | the three bytes copied into the interrupt hook |
| 0x8013-0x8A69 | startup, the player, the collisions, the jump, the score and the lives |
| 0x8A69-0x8AFF | RAM initialisers, the class table, the jump curve and the walking scripts |
| 0x8AFF-0x8E1B | screen and sprite loading, and painting the scene |
| 0x8E1B-0x8F06 | the stretches of ground and the six sinking patterns |
| 0x8F06-0x9090 | the cell scripts of the scenery |
| 0x9090-0x909E | fourteen raw cell numbers: row 23 of the screen |
| 0x909E-0x95FE | the five big blocks of compressed graphics |
| 0x95FE-0x97FE | the four sets of 16 scenery cells |
| 0x97FE-0x9A6F | the sprites: nine compressed blocks and seven raw patterns |
| 0x9A6F-0xA086 | the frame, the objects, the screen change, the score and the clock |
| 0xA086-0xA43A | the scenery tables, the four scene layouts and the 14x18 one |
| 0xA43A-0xA61A | the vine |
| 0xA61A-0xA69E | the 33 slopes the vine is traced with |
| 0xA69E-0xAE90 | the object handlers and the eight scene routines |
| 0xAE90-0xAED4 | the four dispatch tables |
| 0xAED4-0xB113 | cell scripts, object templates, animation scripts and the colours |
| 0xB113-0xB393 | the video layer, the input and the sound dump |
| 0xB393-0xB6B1 | the sound table and the nine routines it installs |
| 0xB6B1-0xB9E4 | the title screen and the demo |
| 0xB9E4-0xBC6D | the tables and the graphics of the title screen |
| 0xBC6D-0xC000 | the padding up to 16 KB: 915 bytes, all zero |
