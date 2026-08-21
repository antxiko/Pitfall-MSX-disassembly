# The game

An explorer crosses the jungle picking up treasures, against a clock that runs
out. Everything on this page comes from reading the code that does it.

## The world is 255 screens, and they take up no map at all

The scene you are in is the content of one byte of RAM, 0xE222. When the
player's X reaches the right edge —0xE7— it is put at 0x19, the other side, and
that byte is stepped once (0x9CBE). On the left, at 0x16, the same happens in
reverse with the inverse function (0x9CF9).

The step runs through 255 values before repeating, so the world is a ring of
255 screens in a fixed order: the game always starts on the same scene and the
next one is always the same. Nothing is random, and there is no list of screens
in the cartridge.

When a scene is built (0x9EE6), three things are read from the byte:

| bits | what they choose |
|---|---|
| 6-7 | the scenery: which of the four landscapes is drawn (0x9F91) |
| 3-5 | the kind of scene, 0 to 7 (0x9EFB) |
| 0-2 | the variant within that kind (0x9EEF) |

## The eight kinds of screen

Bits 3-5 pick one of eight routines through the table at 0xAEB4:

| Kind | Routine | What it is | How many |
|---|---|---|---|
| 0 | 0xA9AA | pits in the ground, with a ladder to the underground | 31 |
| 1 | 0xA9AA | the same: both entries point to the same place | 32 |
| 2 | 0xAC7C | a tar pit, with a vine | 32 |
| 3 | 0xAC6B | a water pool, with a vine | 32 |
| 4 | 0xAD75 | a lagoon with three crocodiles, **with a vine in 16 of them** | 32 |
| 5 | 0xADF6 | **the treasure scene**, the only one that scores | 32 |
| 6 | 0xAE04 | tar with a vine | 32 |
| 7 | 0xADE8 | water, **no vine** | 32 |

The share-out is almost uniform because the ring visits the 255 non-zero
values: only kind 0 gets one scene fewer.

Kinds 0 and 1 share their routine; what splits those 63 scenes in two is bit 7
of the register, which 0xA9AA reads on its own to decide where the **bounce
box** goes —class 10, centred at 0xD8 with the bit set and at 0x31 with it
clear— and whether one pit or three are drawn. The ladder does not move: both
branches draw the same cell script, 0x8F06 (0x8D4A and 0x8D5D).

Kinds 2 and 3 are **the same drawing in a different colour**: 0xAC7C writes
`1B 1B 1B` into the colour table —a black pool, tar— and 0xAC6B writes
`7B 7B 7B` —cyan, water—.

The three crocodiles sit at X 0x50, 0x6F and 0x88 (0xA828) and open their
mouths every frame (script at 0xAFD8); with the mouth open their collision box
grows (0xA812).

## The vine is not handed out by the scene kind

The vine is set up by `monta_la_liana` (0xAE38), and **four** places call it.
Three are the plain calls in kinds 2 (0xAC88), 3 (0xAC77) and 6 (0xAE04). The
fourth one works differently: the tail of the lagoon, 0xADDE, dispatches through
the table at 0xAE94 keyed by **the variant** instead of the kind, and that table
holds `monta_la_liana` at its entries 2, 3, 6 and 7 —the other four are a bare
`ret`—. `ld hl,0AE94h` appears exactly once in the whole cartridge and the kind
4 routine has no other entry point, so that is the only way in.

Since the ring visits the 255 non-zero values, 16 of the 32 lagoons have a vine
and 16 do not, and the scenes with a vine are **112 of the 255**, not 96. Of the
pool family, the one left without any is kind 7.

You can check it without playing and without reading more code, because they are
the same scene with the variant changed: with 0xE222 = 0x26 the rope hangs from
the tree, and with 0xE222 = 0x24 it is not there. `make capturas` takes both
screenshots.

## The 32 treasures, counted without playing

The treasures are exactly the 32 scenes of kind 5: kind 5 is the only one
dispatched through the table at 0xAEA4, which holds four routines repeated two
by two, and the eight variants share out four scenes each. One treasure of each
class eight times:

| Routine | Worth | How many |
|---|---|---|
| 0xAC11 | 2000 | 8 |
| 0xAB51 | 3000 | 8 |
| 0xAB1B | 4000 | 8 |
| 0xABB7 | 5000 | 8 |

Four drawings: the money bag, two bars and the ring. The two bars share their
colour (0x4B at 0xAE90 and 0xAE92): the pattern tells them apart.

8 × (2000+3000+4000+5000) = **112000 points** spread over the world. The score
starts at 2000 (0x8A28), so the ceiling of the game is **114000**.

What you have taken is remembered in 32 bits: 0xE21D-0xE220, one byte per class
and one bit per treasure, with the index within the class at 0xE223. Entering a
treasure scene, 0xAAFF checks that bit and, if it is set, the treasure never
appears again.

## The underground

You go down through the pits, and also by the ladder in scenes of kinds 0 and
1. The ladder has no collision box: the code checks by hand that the scene is
one of those and that the player's X falls between 0x70 and 0x88 (0x83D4). That
window is wider than the drawing: the mast drawn by 0x8F06 runs from 0x80 to
0x87, so you also go down from a little before stepping on it.

Down there the world runs at triple speed: bit 0 of 0xE2EB says whether you are
on the surface —0xACE4 sets it at the start, 0x8751 clears it when you fall
down a pit, 0x849A sets it on the way out— and with it clear, crossing a screen
steps the register **three places instead of one** (0x9CD2).

With those two rules the shortest route that collects the 32 treasures can be
computed: **189 screens** crossed, against 238 never going down —21 % fewer—.
It does not all go the same way: right until the first treasure, an about-turn,
and the other 31 swept leftwards. It is a count of screens crossed, not a
recorded game: ladders are counted as free and the clock is not in it.

## What costs points, and what costs a life

Of the ten collision classes only four cost a life: 3 and 4 through 0x83B9, 6
and 9 through 0x8226 —the only two callers of the lose-a-life routine—. The
rest:

- **the log** (class 1, 0x8640) knocks you down and drains **one point per
  frame** while it rolls over you (0x8674); you walk out of it;
- **a log while you climb** costs two points and sends you back down the ladder
  (0x8506);
- **falling down a pit** costs a hundred points, and you end up underground
  (0x8781);
- **the pool and the crocodile** sink you (0x8361): the player's drawing is
  eaten from below down to Y 0x7A, and there the life is lost;
- **classes 6 and 9** kill outright (0x8221).

The creatures the scenes set up, identified in the captures:

| routine | what it is | box |
|---|---|---|
| 0xAA74 | the snake | class 6, kills |
| 0xAAB7 | the campfire | class 6, kills |
| 0xAD1F | the standing log (the rolling ones come from its template) | class 1 |
| 0xA69E | the underground scorpion: it walks towards your X | class 9, kills |

You start with two spare lives (0x8A52), visible in two ways: three tiles on
rows 2 and 3, and the colour of sprites 12 and 13, set to zero —transparent—
when that life is spent (0x89A8).

Losing one does not repaint the scene: everything else is hidden, saving how
many objects there were at 0xE189, the player is redrawn piece by piece, falls
to the ground, and the objects are given back (0x8221-0x82E7). You reappear at
the left edge, X 0x20 (0x826A).

## The clock and the score

The clock starts at **20:00** and counts down. It is not stored as a number:
the five bytes at 0xE1D0 are already tile numbers —`BA B8 C2 B8 B8`, the
drawings of “2”, “0”, “:”, “0”, “0”— and the countdown works on them (0x9DB8).
When the borrow reaches the tens of minutes, time is up (0x9DEA): the clock
stays at 00:00 and the ending sequence starts.

A tick takes 60 frames (0xE1D5), and the interrupt hook calls the clock once
per interrupt with no condition on the way: **one tick is 60 interrupts**.
Measured in a real game (`tools/omsx_mide_tick.tcl`): 55 ticks in a row, all 55
at exactly 60 interrupts. At 60 Hz the 20:00 last twenty wall-clock minutes; at
50 Hz, twenty-four: the cartridge counts interrupts, not seconds. The routine
also runs on the title and the demo, over uninitialised tiles; the 20:00 are
written when a real game starts. It does not run while paused.

The score is six binary digits at 0xE1D6-0xE1DB, turned into tiles when drawn
at row 1, column 6 (0x9D72). Leading zeros are drawn blank until the first
non-zero digit (0x9D5C). A treasure adds to the thousands digit (0x9D9F);
subtracting points is 0x9D7C, told which digit to touch.

## The controls

Four directions and one fire, from joystick or keyboard: the space bar and the
cursors are remapped onto the same bits (0xB26E). Directions in bits 0-3 of
0xE05F, both fire buttons in bits 4 and 5 (0x87E0).

Holding the button does not jump again (0x87E9), and the only way off the vine
is pressing down (0x81A7).

Three more keys, read from keyboard row 7 (0x9BF3):

| | |
|---|---|
| ESC | pause, with a press-release state machine at 0xE267 |
| RETURN | back to the title, only if 0xE269 allows it |
| STOP | starts from scratch, jumping to INIT |

The pause: 0x9C94 saves how many objects there were and writes zero. With the
object list empty nothing moves, without a single `if` spread through the code.
With one live object you cannot pause: that is the ending sequence.

## If nobody touches anything, the screen switches off

0x9B6D keeps three cascaded counters (0xE25A/B/C, 60 each). Input reloads the
outer two (0x9B74); with all three spent, register 1 of the video chip is set
to 0x82 and the screen goes dark (0x9B8D). The game sits in a wait loop with
interrupts disabled (`di` at 0x9B8C). Any direction or button wakes it (0x9B99)
and, through keyboard row 7, RETURN, STOP or ESC (0x9BA9).

## The demo is recorded byte by byte

You do not leave the intro (0xB6B1) with a key: you leave when the demo script
has spent seven of its entries (0xB751). With 0xE221 set to 1, the player's
input is not read: every frame it is fed from the table at 0xB9E4, pairs of
[how many frames][what is pressed] in the same format the keyboard produces
(0xB9C8). The demo's game is six pairs plus three waits of 0xFF frames:
eighteen bytes.

## The ending

Two doors, and only two: running out of lives (0x8975, which on passing zero
eats its own return address and gives the player handler 0x9E0E) or running out
of clock (0x9DEA, through 0x9BCF). Both leave a single live object with the
farewell handler: four sprites that come out and rise —Y is 0xBC minus the
frame (0x9E8F)— over fourteen strips of drawing cycled in ten frames (0x9E67).

RETURN there jumps to 0x8065, where every game starts (0x9C91).
