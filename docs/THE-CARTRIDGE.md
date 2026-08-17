# The cartridge

16384 bytes. No loader, no blocks: the MSX maps the cartridge at 0x8000-0xBFFF
—page 2— and that is the whole picture of memory, with no overlays: no address
means two different things at two different times.

## Where it enters

The first sixteen bytes are the header the BIOS reads:

    41 42 13 80 00 00 00 00 00 00 00 00 00 00 00 00
    'A' 'B'  \_ INIT = 0x8013

The two letters mark an executable cartridge; of the four vectors only INIT is
set —STATEMENT, DEVICE and TEXT, the BASIC ones, are zero—.

At 0x8010 there are three bytes that are neither header nor ever executed
here: `C3 F7 80`, a ready-made `jp 0x80F7`. The boot code copies them to the
interrupt hook, and that is where they run.

## What the boot does

INIT (0x8013):

- clears 0xE000-0xEFFF in one go (0x8017), where the state will live, and puts
  the stack at 0xE54B (0x8023);
- silences the sound chip (0x8026) and clears the 16 KB of video memory
  (0x802D);
- copies the three bytes at 0x8010 to the H.KEYI hook, 0xFD9A (0x803C-0x8046);
- runs the intro (0x805C), clears video memory again and loads the sprites;
- sets up the game and sits in a two-byte loop, 0x80F5.

That empty loop is the main program. **The whole game runs inside the
interrupt**, fifty or sixty times a second.

## Where the state lives

Everything the game keeps lives in RAM from 0xE000. The most-read addresses:

| | |
|---|---|
| 0xE012 | lives left |
| 0xE05F | what is being pressed, in joystick format |
| 0xE1D0-0xE1D4 | the clock, already stored as tile numbers |
| 0xE1D6-0xE1DB | the six digits of the score |
| 0xE1E6-0xE1ED | the four sound vectors |
| 0xE20E-0xE21B | the copy of the fourteen sound chip registers |
| 0xE21D-0xE220 | the 32 bits of treasures already taken |
| 0xE221 | whether the demo is running |
| 0xE222 | **the screen register**: the whole world fits here |
| 0xE224 / 0xE225 | the scene's variant and kind, taken from 0xE222 |
| 0xE229-0xE246 | the ten collision boxes |
| 0xE247 | how many live objects, then one pointer per object |
| 0xE26A-0xE2BD | the sprite attribute table, uploaded whole every frame |

Behind that come the object structures, packed with no gap: 0xE2BF, 0xE2D5
(the player), 0xE2ED, 0xE303, 0xE319 and 0xE32F. The player's takes 24 bytes
and the other five 22, closing the chain at 0xE345.

## The screen, and the three registers the game never touches

The cartridge writes five of the video chip's eight registers: 0 and 1 (mode
and screen), 3 and 4 (colour and pattern bases) and 7 (the border, 0x11: black,
at 0x8036).

**Registers 2, 5 and 6 are never written**: they are the ones that say where
the name table, the sprite attributes and the sprite patterns live, and the
game writes to 0x1800, 0x1B00 and 0x3800-0x3FFF trusting the bases the BIOS
left.

| | |
|---|---|
| 0x0000 | the tile patterns (register 4 = 0x00, at 0xB79A) |
| 0x1800 | the name table |
| 0x1B00 | the sprite attributes |
| 0x2000 | the colours (register 3 = 0x80, at 0xB794) |
| 0x3800 | the sprite patterns |

Register 1 holds 0xE2 (0x8047): 16 KB, screen and interrupt on, 16x16 sprites.

**The intro runs in one screen mode and the game in another**: 0xB6B2 sets
register 0 to 0x02 —graphics mode 2— for the entry banner, and 0xB788 puts it
back to 0x00, graphics mode 1. That is why the game's colour table is 32 bytes
and not 6144: in the game's mode colour goes per group of eight tiles.

## How the drawings are stored

There is a 58-byte decompressor at 0xB142 that writes straight to the video
port. The format: two bytes of destination address, then one-byte tokens with
the counter in the low six bits —bit 7 skip N positions, bit 6 copy N literals,
neither repeat the next byte N times, zero ends—.

That covers the tile and sprite patterns (0x909E-0x95FE), the nine sprite
blocks of the scene handlers (0x981E-0x99AF) and the six of the intro
(0xBAB2-0xBC61). Stored raw: the four 16-tile scenery sets (0x95FE-0x97FE) and
seven loose sprite patterns (0x97FE-0x981E and 0x99AF-0x9A6F).

Every compressed block ends **exactly** where the next one starts, and that
pins its size without guessing.

## The typography fits in twelve tiles

There is not one string of text. The only font is twelve tiles: the ten digits
(0xB8-0xC1), the colon (0xC2) and the blank (0xC3), just enough for the score
and the clock. Everything else that looks like text is drawing.

## The full split

Not one byte unaccounted for: 9,467 of code reached by the tracer and 6,917 of
data, each inside a declared range with the instruction that reads it noted
alongside.

| | |
|---|---|
| 0x8000-0x8010 | the header |
| 0x8010-0x8013 | the three bytes copied to the interrupt hook |
| 0x8013-0x8A69 | boot, the player, collisions, the jump, the score and the lives |
| 0x8A69-0x8AFF | RAM initialisers, the class table, the jump curve and the walk scripts |
| 0x8AFF-0x8E1B | screen and sprite loading, and scene drawing |
| 0x8E1B-0x8F06 | the floor strips and the six sinking patterns |
| 0x8F06-0x9090 | the scenery cell scripts |
| 0x9090-0x909E | fourteen raw tile numbers: row 23 |
| 0x909E-0x95FE | the five big blocks of compressed graphics |
| 0x95FE-0x97FE | the four 16-tile scenery sets |
| 0x97FE-0x9A6F | the sprites: nine compressed blocks and seven raw patterns |
| 0x9A6F-0xA086 | the frame, the objects, the screen change, the score and the clock |
| 0xA086-0xA43A | the scenery tables, the four scene layouts and the 14x18 one |
| 0xA43A-0xA61A | the vine |
| 0xA61A-0xA69E | the 33 phases the vine is traced with |
| 0xA69E-0xAE90 | the object handlers and the eight scene routines |
| 0xAE90-0xAED4 | the four dispatch tables |
| 0xAED4-0xB113 | cell scripts, object templates, animation scripts and the colours |
| 0xB113-0xB393 | the video layer, the input and the sound upload |
| 0xB393-0xB6B1 | the sound table and the nine routines it installs |
| 0xB6B1-0xB9E4 | the intro and the demo |
| 0xB9E4-0xBC6D | the intro's tables and graphics |
| 0xBC6D-0xC000 | the padding up to 16 KB: 915 bytes, all zero |
