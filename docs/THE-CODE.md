# The code

## Everything happens inside the interrupt

This game's main program is two bytes: a jump to itself, at 0x80F5. What really
happens goes on in the H.KEYI hook, which the BIOS calls on every screen
retrace, and which always does the same thing in the same order (0x80F7-0x8100):

    B249   the two joysticks, through the sound chip
    B26E   row 8 of the keyboard, put back into joystick format
    B35B   the chain of sound vectors
    9A6F   the frame: the screen and the objects

and behind that, at 0x8103, the 0x54 bytes from 0xE26A into video memory at
0x1B00: the whole sprite attribute table in one go, once per frame.

There is no lock and no re-entry check, because none is needed: everything the
game does fits in one frame.

## And it doesn't go back to the BIOS from there

The end of the hook is not an ordinary `ret`. It is eleven `pop`s in a row
(0x810F-0x8122) which unstack what the BIOS had saved on entering the interrupt
—the main register set, the index registers and, after the `ex af,af'` and the
`exx` at 0x8118, the alternate set too— and in the middle of them, at 0x811A, an
`in a,(099h)` that reads the video chip's status, which is what marks the
interrupt as served.

So the first `pop hl` eats the return address into the BIOS and the `ei` / `ret`
at 0x8123 hands control straight back to the interrupted program. The rest of the
BIOS interrupt routine never gets to run.

## The frame

0x9A6F, in order:

1. the game clock (0x9DB8), which spends one frame per pass;
2. the edge of the screen (0x9CBE): if the player has reached it, the scene
   changes, and if it changes, the frame ends there;
3. if 0xE221 isn't zero, what's running is the demo, and the player's input is
   replaced by the one recorded at 0xE259 (0x9A7E);
4. the walk through the live objects (0x9A88);
5. the two sprites on top of the player (0x9D03);
6. and the close (0x9AE0): the system keys and the idle clock.

## The character is three sprites, one per colour

An MSX1 sprite is a single colour, so a player in three colours is three sprites
0x9D03 builds the other two out of the main one: same X, **16 pixels higher up**,
and patterns (P-0x20)+0x68 and (P-0x20)+0xB0. The colours are written by the
routine that sets the scene up: 0x0C into 0xE2A5, 0x06 into 0xE2A9 and 0x0F into
0xE2AD. That isn't the only routine that touches them: `reaparece` zeroes them to
hide the character (0x8247) and switches them back on out of step on the way back
(0x82D4-0x82E1), which is where the flickering comes from.

So Harry is 16x32, and they are not three layers on top of one another: the two
upper sprites overlap each other —two colours in the top half— and the main one
goes below, one colour for the legs. Pulled out of the dumped video memory and put
back together that way (`tools/render_jugador.py`), what comes out is the strip of
the twelve frames that the cartridge's own animation scripts name:

![The twelve frames of the main character](imagenes/jugador-tira.png)

The timings are the cartridge's too: walking is five frames of three video frames
each (0x8AE1), and climbing two of one frame each (0x8AF9). Walking left uses
patterns 0x44 to 0x54 (0x8AED), which **are the exact mirror** of 0x20 to 0x30:
checked pixel by pixel over the strip, all five of them. The twelve are the
scripts' and nothing else: the two standing-still patterns, 0x34 and 0x58, aren't
in there because they don't come from a script — `se_para` sets them by hand
(0x8970 and 0x896B).

And the order of the layers is not the one you would assume: on the TMS9918 **the
lower-numbered sprite goes in front**, so the one at 0xE2A6 covers the one at
0xE2AA. That matters in the two climbing frames, the only ones where the two upper
layers overlap: five pixels each, which with the order reversed would come out
white instead of red.

And the walking speed isn't an impression either: `anda` (0x88ED) writes 0x00C8
into the speed field, which is in 1/256ths of a pixel per frame —200/256, that is
0.78 pixels a frame— and 0xFF38 for the other way, the same number negated.

The emulator agrees with the arithmetic: dumping the RAM with the game running
gives three sprite entries at 0xE2A2 with the same X, Y 109 for the main one and
93 for the other two —sixteen lines apart— and patterns 0x34, 0x7C and 0xC4,
which is exactly 0x34, (0x34-0x20)+0x68 and (0x34-0x20)+0xB0. The 0x34 in that
dump is the standing-still one, which is why it isn't in the strip.

## The objects: six bytes per axis, and one counter each

0xE247 says how many objects are alive and behind it goes one pointer per object.
Each object's counter (+0x11) is decremented and **only when it reaches zero** is
it reloaded with its period (+0x10) and the object attended to (0x9A99). That way
each object runs at its own pace without there being a timer per object: the pit
opens slowly and the crocodile's jaws move quickly out of the same loop.

The structure, read off the walk at 0x9A88 and the routines that consume it:

| | |
|---|---|
| +0x00 to +0x05 | flags, 16-bit speed, the two limits and the fractional part — of one axis |
| +0x06 to +0x0B | the same thing, byte for byte, of the other axis |
| +0x0C / +0x0D | the animation script |
| +0x0E / +0x0F | the animation counter and the current frame |
| +0x10 / +0x11 | the object's period and its count |
| +0x12 / +0x13 | its handler |
| +0x14 / +0x15 | where its sprite attributes are |

That the two movement blocks are identical can be seen without interpreting
anything: at 0x9AB3 the move routine is called, at 0x9AB9 **six** is added to IX,
at 0x9ABB the sprite pointer is incremented, and at 0x9ABD the same routine is
called again.

And the position isn't in the structure: the whole part lives directly in the
sprite attribute (0x9B24) and the structure only holds the fraction, in +0x05.
Moving an object is adding its speed to a 16-bit number whose high byte is what
the video chip sees.

The flags of each axis, read at 0x9B1F:

| | |
|---|---|
| bit 0 | it moves |
| bit 1 | on reaching the limit it bounces instead of stopping (0x9B5A, with two's complement) |
| bit 2 | it has limits, in +0x03 and +0x04 |
| bit 5 | it is animated (0x9AEC) |
| bit 6 | it has a handler of its own (0x9AC2) |

## Four dispatchers, and all with the same trick

This cartridge jumps to computed addresses all over the place, and always the
same way: **the return is pushed by hand**. At 0x9AD2 it does `ld de,<return>` /
`push de` / `jp (hl)`, which is an indirect call written out by hand, and at
0x9F89 exactly the same. The tracer doesn't get there on its own: the return
addresses are declared as entry points.

The four of them are:

| What it picks | Where | Index | Table |
|---|---|---|---|
| an object's handler | 0x9AD6 | the object itself, in +0x12/+0x13 | none |
| the kind of scene | 0x9F81 | 0xE225, 0 to 7 | 0xAEB4 |
| the variant of the scene | 0xA99F | 0xE224, 0 to 7 | 0xAE94, 0xAEA4 or 0xAEC4, depending on the caller |
| what happens to you when you collide | 0x873B | the box's class, 0 to 10 | 0x8AA0 |

The variant one is the interesting one: it gets the table in HL, so **the same
routine serves three different tables**, and which one is used is up to whoever
calls it. The one at 0xAEA4 is loaded only by 0xAE2E, and only when the kind of
scene is 5.

## The collision boxes

0xE229-0xE246 are ten three-byte records: the class, the X on the left and the X
on the right. The scene routines write them when they build the screen, and
0x84EF, 0x8529 and 0x8589 walk them with the player's X plus eight, that is, with
his centre.

The first seven are the surface's and the ones from 0xE241 on are the tunnel's
(0x853A). The class that comes out of the walk goes straight to the dispatcher at
0x873B:

| | | |
|---|---|---|
| 0 | off | doesn't jump anywhere |
| 1 | log | 0x8640: knocks you over and takes points off you |
| 2 | ground | 0x8751: that's how you fall into the tunnel |
| 3 | pool | 0x8361: you sink |
| 4 | crocodile | 0x8361: the same place |
| 5 | vine | 0x8162: you grab on |
| 6 | kills | 0x8221 |
| 7 | — | points at 0x874B, and nobody writes it |
| 8 | treasure | 0x878C: you take it |
| 9 | kills | 0x8221 |
| 10 | rebound | 0x85EF: your direction is reversed and you retreat three steps. **Not the ladder** |

Classes 2, 3 and 4 also push the player **sideways** to get him out of the box
(0x8555-0x8578). What is adjusted is his X, which is field +0x01 of the sprite
attribute; nothing there touches his Y.

## The world isn't stored: it's computed

The scene you are in **is** the contents of 0xE222, an 8-bit feedback shift
register. 0xB68F steps it forward and 0xB69F steps it back with the exact inverse
function, so leaving a screen by the left undoes what the right did. All eight
bits are used up: 6-7 the scenery (0x9F91), 3-5 the kind of scene (0x9EFB) and 0-2
the variant (0x9EEF).

The full detail, with the reason why it is exactly 255 screens, is in
[Findings](FINDINGS.html).

## Drawing a scene

0x9EE6 is the only way a screen ever gets built, and changing 0xE222 by force
repaints nothing. What it does is read the scenery, the kind and the variant out
of the register, and from there:

- **the layout**, which is a block of the table at 0xA08E consumed by 0x8D70:
  0x71 raw bytes for rows 4 to 7, one row of 0x20 bytes painted six times, five
  bytes for the variable-width stretches of rows 12 and 13, and a cell script at
  the end. Each of the four layouts closes exactly where the next one begins;
- **the set of 16 cells** of the scenery, from the table at 0xA086;
- and **the cell scripts**, which is a three-line interpreter (0x9FE6): the first
  byte says how many cells, the second is skipped without being read —0x9FE7 and
  0x9FE8 are two `inc hl` in a row— and behind them go four-byte records with the
  position within the name table and the cell number. That is what paints the ladder's
  column, the strips of ground and the 3x2 objects over on the right.

The stretches of ground carry a trick that saves two bytes per stretch: the byte
in the layout is **at once** an offset into the table, a length and a step through
video memory (0x8DA7). Each stretch copies from `table+N` to `table+2N`.

## The input: two controllers and a keyboard that end up in the same byte

0xB249 reads the two joystick ports through the sound chip and leaves them at
0xE05F and 0xE061 —inverted with a `cpl` at 0xB257, because the chip hands them
over the other way round—. And 0xB26E takes row 8 of the keyboard, the one with
the space bar and the cursor keys, and shuffles it bit by bit until it is in the
same format: three rotations and an `and 0x1F` at 0xB28F leave bit 0 up, bit 1
down, bit 2 left, bit 3 right and bit 4 fire.

Since both sources end up in the same place and in the same shape, the rest of the
game has no idea which one you are using. And the demo takes advantage of exactly
that: it writes the recorded input into 0xE05F and that's it (0x9A7E).

## The sound doesn't touch the chip: it touches fourteen bytes of RAM

0xE20E-0xE21B is a copy of registers 0 to 13 of the sound chip, and 0xB37B dumps
the lot with an `outd` loop counting from 13 down to 0, once per frame and as soon
as the vectors have finished playing with it. Outside that routine port 0xA1 is
only written at 0xB24F and 0xB261, and not to make a sound: that is register 15,
the one the controller reader uses to pick a joystick port.

On top of that go four vectors at 0xE1E6-0xE1ED. Asking for a sound is calling
0xB32E with a number from 0 to 10; the table at 0xB393 —eleven three-byte records
of [slot][pointer]— says which slot it is installed in and with which routine, and
the slot fixes the channel. Every frame, 0xB35B calls whatever is installed in the
first three (0xB360-0xB37A).

There are two sound engines and three effects written out by hand. The one at
0xB3F0 reads eight-byte scripts and sweeps pitch and volume at the same time, with
a fractional part at 0xE1FC of which only the high byte comes out (0xB471); the
one at 0xB5EA reads four-byte scripts and leaves each note still until the next
one. The three that carry no script —0xB49F, 0xB4E6 and 0xB52E— have the sweep
inside the code itself: 19 frames raising the period by 0x14 at a time, three
frames dropping it by 0x7F at a time —or by 0x80, because the `sbc hl,bc` at
0xB528 takes the carry in and nobody clears it first— and a single frame of noise.

## The vine is traced, not drawn

There is no drawing of a vine in the cartridge. On every step, 0xA471 traces a
16-point line onto a 0x40-byte bitmap in RAM (0xE18A) and uploads it to video
memory as a sprite pattern (0xA594). The tilt comes from the table at 0xA61A —33
records of four bytes— indexed by the swing phase, 0xE1CB, which goes back and
forth between 1 and 0x20 (0xA5EF).

The four bytes of each phase are four different things, and not one of them is
decoration:

| byte | what it is | from vertical to the far end |
|---|---|---|
| 1 | the slope, in 1/256 of a pixel per row | 0x00 → 0xC9 |
| 2 | the object's **period** (0xA48F) | 1 → 9 frames |
| 3 | where the rope ends and you grab it (0xA529) | 0x10 → 0x06 |
| 4 | how many steps of the jump curve you fall with when you let go (0xA546) | 0x00 → 0x10 |

The second one is the good one: because the period grows towards the ends, **the
swing runs through the middle and slows down at the extremes**, just like a real
pendulum. There is no physics anywhere; there is a column of a table. Half a
swing is those 32 periods added up: 75 frames.

And the rope **is not the 48 rows of its three sprites**. The third one carries a
different pattern, 0x60, which 0xA551 builds by copying from the first one only
as many rows as the third byte says, so the rope **ends exactly where you grab
it** and gets shorter as it tilts: 48 rows upright and 38 at the far end.

Reproducing that tracer with the same data (`tools/render_liana.py`) gives the 33
phases, which is the whole vine:

![The 33 phases of the vine on top of each other](imagenes/liana.png)

Upright rope on the left, fully tilted on the right, with all 33 phases on top of
each other: the bottom edge is each one's grab point, which is why the outer ones
end higher up.

Put next to an emulator capture, the rope lands **0.28 pixels away on average**
from where the model puts it (the matching phase is 0x1C). Even the steps repeat:
the machine restarts the accumulator on each sprite and loses the fraction, which
is why the line jogs every 16 rows.

While you hang, the vine writes your X and Y (0xA5F9), and you get your own
drawing: pattern 0x40, or 0x64 if you face left (0x819A). Letting go is not
holding the «down» bit (0x81A7).
## The jump is a table, not a speed

The jump starts at 0x87E9, and the step is kept in +0x17 of the player's
structure. In the air (0x8820), that number counts from 0x1F down to 0 and is
used as an index into the curve at 0x8AB6, which **is read from the end
backwards**: a 0xFF goes up one pixel, a 0x01 goes down one and a 0x00 leaves the
height where it is (0x8835). There is no vertical speed anywhere; there is a
table, at 0x8AB6.

From 0x1F to 0x11 the curve goes up ten pixels and from 0x10 down to 1 it brings
them back down, closer and closer together: the whole jump is 31 frames, 15 going
up and 16 coming down. **Letting go of the vine uses that same curve, but does
not start at 0x1F**: it starts at the fourth byte of the swing phase (0x821A),
which never goes past 0x10 —exactly the half that descends— so letting go only
ever falls. Upright it is 0 and you land at once (0x882E); at the far end it is
0x10, which is the whole descent.

Turning round in the air is only possible in the first three steps (0x8896), and
doing it recovers the ground lost in changing direction (0x88C3).
