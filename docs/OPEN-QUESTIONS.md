# Open questions

Every byte of the cartridge has an owner, the listing gives the original back byte
for byte and its 337 labels have names. What that does **not** mean is that all of
them have what they do written down: 78 carry their explanation on the label
itself and the rest lean on the 305 line comments and the 50 block headers, so
there are named routines of which only the name is stated. This page says what
those figures mean exactly, and what is left to find out.

## The clock, closed: one tick is 60 interrupts, measured

This question used to be open and no longer is. The code says 0x9DB8 spends one
pass per interrupt and ticks every 60 of them (0xE1D5), but an early emulator
measurement had given «about nine seconds per tick», and both couldn't be true.

The code won, and the old measurement was wrong twice over: it watched
0xE25A/0xE25B/0xE25C —which are not this clock— and it pressed SPACE and
RETURN, when the game starts on a **direction** (0x8128 checks bits 0-3 of
0xE05F), so it measured a different variable with no game running.

The good measurement (`tools/omsx_mide_tick.tcl`): one breakpoint on the tick
(0x9DC7) and a control one on the interrupt hook (0x80F7), with a real game
started by pressing right. Out come 55 consecutive ticks with the score clock
counting down from 20:00, all 55 at **exactly 60 interrupts**. So on a 60 Hz
machine «20:00» lasts twenty wall-clock minutes, and on a 50 Hz machine,
twenty-four: the cartridge counts interrupts, not seconds.

And one detail thrown in for free: the routine runs **in the title and the demo
too**, decrementing the clock tiles before anyone initialises them; the «20:00»
is written when a real game starts.

## No winning condition turns up

The only two ways out of a game there are in the code are running out of lives
(0x8975) and running out of clock (0x9DEA). Both end up in the same place: the
closing sequence at 0x9E0E.

That collecting all 32 treasures does anything is **neither proved nor ruled out**.
What can be stated is what was looked for and isn't there: in the traced code there
there is no comparison against 32 that has anything to do with the treasures —the
only one there is compares the phase of the vine's swing, at 0xA5F0— and apart
from the 32 bits of treasures taken (0xE21D-0xE220) no counter of how many you are
carrying turns up. If there is an
ending for having collected them all, it doesn't come from there.

## The 189-screen route is a calculation, not a game

The number is soundly made —it comes from walking the ring of 255 scenes with the
cartridge's own screen-change rules, counting the tunnel shortcut— but it measures
**screens crossed**, and nothing else.

What is not in the count: jumping, waiting for a log to go by, and going down or
up a ladder, which are counted as free. It is not a recorded game.

Does it fit the clock, though? That sum can be done with the cartridge's own
numbers. The player walks at 200/256 of a pixel per frame (0x88ED) and a screen
runs from the entry X (0x19) to the border (0xE7): 206 pixels, **264 frames, 4.4
seconds** at 60 Hz. The 189 crossings add up to 49,896 frames —**13.9 minutes of
game time**— and the 20:00 clock is 72,000: the route spends 70 % of the clock
just walking and leaves about six minutes for everything else. It is still the
model's arithmetic, not a game; but the model fits inside the clock.

It still needs running in the emulator to check two things: that the 32 treasures
turn up and that the score reaches 114000.

## The creatures, named: by looking at them

This question closed the simplest possible way: cropping from the captures the
3x2-cell gap where each routine paints its piece, and looking at it.

| routine | variants | box | what it is |
|---|---|---|---|
| 0xAA74 | 7 | class 6, kills | **the snake**, coiled with its head up |
| 0xAAB7 | 6 | class 6, kills | **the campfire**: white flames over two sticks |
| 0xAD1F | 0-5 | class 1, costs points | **the log** (and the rolling ones come from its template) |
| 0xA69E | object 0xE2ED | class 9, kills | **the scorpion** of the underground, which closes in on your X and stops right under you |

The listing's names now say it: `monta_la_serpiente`, `monta_la_fogata`,
`monta_los_troncos`, `mueve_el_escorpion`.

## Sixteen bytes with an owner and no use

At 0xBAA2 there are two lists of eight bytes, and the second is the first with the
nibbles swapped: 61 against 16, 91 against 19, B1 against 1B. The range is bounded
on both sides —the initialiser that ends right there and the compressed block that
begins right after— so the sixteen bytes are declared and counted.

But they have no consumer: not one traced instruction reads them, and none of the
16384 words of the cartridge is worth their address. They are explained as data, not
as use, and that is the difference the «100 %» doesn't tell apart.

By the same yardstick: the animation script at 0xAF84 and the second copy of the
clock at 0x8F00 are perfectly identified and nobody uses them either.

## What backs each figure, and what doesn't

So that it is clear what is behind the numbers in this repository:

- **It reassembles byte for byte.** The published listing is assembled and the
  sha256 of the result is the cartridge's. If a comment had eaten a byte, that line
  wouldn't come out.
- **Not one byte unexplained.** The 16384 share out into 9467 of code the tracer
  reaches by following the flow for real and 6917 inside a declared range, each one
  with the instruction that reads it written beside it.
- **No area of data is read as code.** That is a separate check, and it is needed: a
  disassembly can reassemble perfectly and still be lying, if some artwork is being
  read as instructions. The bytes don't change, only what we say about them does.
- **No entry point falls inside an area of data.** Seeding the tracer with a badly
  deduced address inflates the coverage without setting off any alarm, so there is a
  rule for exactly that.

And what that 100 % does **not** mean: that what every byte is for is known. It
means that every byte is inside a named range, and that the name comes from having
read the instruction that consumes it. The three cases in the section above are
precisely the exception, and that is why they are written down.

The comments in the listing are verified by sampling —the dispatcher table at
0x8AA0 matches the ROM byte for byte, and the six dead routines were confirmed by a
second route— but not line by line.

## Four warnings for whoever comes after

**A period is not a speed, and a frame counter is not a clock.** Sixty frames per
tick is what the code says; how long that lasts is another question, and confusing
the two is what left the clock section open.

**Writing 0xE222 by hand repaints nothing.** The only way a scene ever gets built is
0x9EE6, and it is reached from the start of a game (0x809F) and from the screen
change (0x9CBE and 0x9CF9), and from nowhere else. To walk
the world in the emulator you have to write 0xE7 into 0xE2A3 —the player's X— and
let the game change screen by itself.

**And then the captures are out by one.** The walk photographs after taking the
step, so capture number N is not scene N. They are crossed by their screen register
value, which is in the file name, and not by the number.

**Hunting for pointers by brute force lies.** A run of repeated bytes looks like a
pointer, and reading an operand from the middle of an instruction gives plausible
addresses that don't exist. Every lead that comes from there is confirmed against
the listing before being believed; it is the reason the tools in this repository
walk only instruction starts.
