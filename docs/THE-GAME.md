# The game

An explorer crosses the jungle from left to right collecting treasures, with a
clock running out on him. Everything here comes from reading the code that does
it.

## The world is 255 screens, and not one byte of it is a map

The scene you are in is the contents of one byte of RAM, 0xE222. When the
player's X reaches the right-hand edge —0xE7— he is put at 0x19, that is, on the
other side, and that byte is turned one step (0x9CBE). On the left, at 0x16, the
same happens in reverse with the inverse function (0x9CF9).

That turning runs through 255 different values before coming back to the start,
so the world is a ring of 255 screens and **the order is fixed**: a game always
begins on the same scene, and the next one is always the same. There is nothing
random about it, and there is no list of screens in the cartridge.

Three separate things are read out of that byte when the scene is built (0x9EE6):

| bits | what they pick |
|---|---|
| 6-7 | the scenery: which of the four landscapes is painted (0x9F91) |
| 3-5 | the kind of scene, 0 to 7 (0x9EFB) |
| 0-2 | the variant within that kind (0x9EEF) |

## The eight kinds of screen

Bits 3-5 pick one of eight routines through the table at 0xAEB4, and each one
builds a kind of screen:

| Kind | Routine | What it is | How many |
|---|---|---|---|
| 0 | 0xA9AA | pits in the ground, with a ladder to the tunnel | 31 |
| 1 | 0xA9AA | the same ones: both table entries point to the same place | 32 |
| 2 | 0xAC7C | a tar pit | 32 |
| 3 | 0xAC6B | a water pool | 32 |
| 4 | 0xAD75 | a lagoon with three crocodiles | 32 |
| 5 | 0xADF6 | **the treasure scene**, the only one that scores | 32 |
| 6 | 0xAE04 | tar with a vine | 32 |
| 7 | 0xADE8 | water with a vine | 32 |

The share-out is practically even because the ring runs through all 255 non-zero
values: only kind 0 ends up one scene short.

Kinds 0 and 1 share a routine, so those 63 scenes are the same class of screen.
What splits them in two is **another bit**: 0xA9AA reads bit 7 of the register on
its own and uses it to decide where the **rebound box** goes —the class 10 one,
centred at 0xD8 with the bit set and at 0x31 with it clear— and which of the two
pit drawings is painted, the one with a single pit or the one with three. The
ladder doesn't move: both branches paint the same cell script, 0x8F06 (0x8D4A and
0x8D5D).

And kinds 2 and 3 are **the same drawing in a different colour**: 0xAC7C writes
`1B 1B 1B` into the colour table, which leaves the pool black —tar—, and 0xAC6B
writes `7B 7B 7B`, which leaves it cyan —water—.

The lagoon's three crocodiles sit at X 0x50, 0x6F and 0x88 (0xA828), and open
their jaws every frame (script at 0xAFD8). With the jaws open, their collision
box grows (0xA812).

## The 32 treasures, counted without playing a game

The treasures are exactly the 32 scenes of kind 5, because kind 5 is the only one
dispatched through the table at 0xAEA4, and that table holds four routines
repeated two by two. Since the eight variants share out four scenes each, one
treasure of each class comes up eight times:

| Routine | Worth | How many |
|---|---|---|
| 0xAC11 | 2000 | 8 |
| 0xAB51 | 3000 | 8 |
| 0xAB1B | 4000 | 8 |
| 0xABB7 | 5000 | 8 |

They are four drawings: the money bag, two bars and the ring with the stone,
which is the dearest one. The two bars share even their colour —the colour byte is
0x4B at 0xAE90 and at 0xAE92 alike— and the only thing that tells them apart is
the pattern.

Eight of each, and not one more: 8 × (2000+3000+4000+5000) = **112000 points**
spread around the world. The score starts at 2000 (0x8A28), so the ceiling of the
game is **114000 points**.

What you have already taken away is remembered in 32 bits: 0xE21D-0xE220, one
byte per class and one bit per treasure, with the index within the class at
0xE223. On entering a treasure scene, 0xAAFF looks at that bit, and if it is set
nothing is painted: the treasure never appears again.

## The tunnel, which is a real shortcut

The pits take you down to the tunnel, and so does the ladder that the scenes of
kinds 0 and 1 carry —63 of the 255—. The ladder has no collision box: it is
checked by hand that the scene is one of those and that the player's X falls
between 0x70 and 0x88 (0x83D4). That window is **wider than the drawing**: the
mast the cell script at 0x8F06 paints is column 16, that is 0x80 to 0x87, so you
can also go down from a little before standing on it.

And down there the world runs at three times the rate. Bit 0 of 0xE2EB says
whether you are on the surface —0xACE4 sets it when the game starts, 0x8751
clears it when you fall down a pit and 0x849A sets it again on the way out— and
when it is clear, crossing a screen turns the register **three steps instead of
one** (0x9CD2). Three scenes at once.

On top of those two rules you can work out the shortest route that collects all
32 treasures: **189 screens** crossed, against 238 if you never go down: the
shortcut saves 21 %. And they don't all go one way: right to the first
treasure, then round and the other 31 swept leftwards.

It is a calculation, not a game played: the cost is measured in screens crossed,
the ladder is counted as free, and the clock is not in the count.

## What costs you points, and what costs you a life

Of the ten classes of box only four cost a life: 3 and 4 through 0x83B9, and 6 and
9 through 0x8226, which are the only two places in the cartridge that call for a
life to be taken. This is what the rest of them do:

- **the log** (collision class 1, handler 0x8640) knocks you over and takes
  **one point per frame** off you while it rolls over you (0x8674). You walk out
  of it, and as soon as the box stops giving class 1 the normal handler is back;
- **being hit by a log while you're climbing** costs two points and sends you
  down the ladder (0x8506);
- **falling down a pit** costs a hundred points, and you end up in the tunnel
  (0x8781);
- **the pool and the crocodile** sink you (0x8361): the player's drawing is
  eaten away from the bottom a byte at a time as he goes down to Y 0x7A, and
  there a life is lost;
- **classes 6 and 9** kill you outright (0x8221).

You start with two spare lives (0x8A52), and they are shown two ways at once:
three cells in rows 2 and 3 of the screen, and the colour of sprites 12 and 13,
which is set to zero —transparent— when that life is gone (0x89A8).

When you lose one, the scene is not repainted: everything else is hidden, keeping
how many objects there were in 0xE189, the player is drawn again in pieces and
falls to the ground, and at the end the objects are given back (0x8221-0x82E7).
You come back at the left-hand edge, at X 0x20 (0x826A).

## The clock and the score

The clock starts at **20:00** and counts down. It is not stored as a number: the
five bytes at 0xE1D0 are already the cell numbers `BA B8 C2 B8 B8`, that is, the
drawings of «2», «0», «:», «0» and «0», and the countdown is done on those
(0x9DB8). When the borrow reaches the tens of minutes and a blank turns up there
(0xC3), time is up (0x9DEA): the clock stays stuck at 00:00 and the closing
sequence starts.

Each tick spends 60 frames (0xE1D5), and while paused the clock doesn't run
(0x9DB8).

The score is six loose digits at 0xE1D6-0xE1DB, in binary, turned into cells when
they are painted and written into row 1, column 6 (0x9D72). The leading zeros are
painted blank until a non-zero digit turns up (0x9D5C). Adding a treasure is
adding into the thousands digit (0x9D9F); taking points off is the routine at
0x9D7C, which is told which digit to touch.

## The controls

Four directions and one fire, and it makes no difference whether they come from
the joystick or the keyboard: the space bar and the cursor keys are put back into
the same bits (0xB26E). Up, down, left and right are bits 0 to 3 of 0xE05F, and
the two fire buttons bits 4 and 5 (0x87E0).

Holding the button down doesn't jump again (0x87E9), and you only let go of the
vine by pressing down (0x81A7).

Three keys do something else, and they are read from row 7 of the keyboard
(0x9BF3):

| | |
|---|---|
| ESC | pause, with a press-and-release state machine in 0xE267 |
| RETURN | back to the title, but only if 0xE269 allows it |
| STOP | starts from scratch, jumping to INIT |

The pause is solved rather nicely: 0x9C94 saves how many objects there were and
puts zero. With the object list empty nothing moves, and there isn't a single
`if` scattered through the rest of the code. With only one object alive you
cannot pause, because that means what is running is the closing sequence.

## If nobody touches anything, the screen goes off

0x9B6D keeps three counters in cascade, 0xE25A, 0xE25B and 0xE25C, each of 60.
As long as input keeps coming the two outer ones are reloaded, 0xE25B and 0xE25C
(0x9B74); the first keeps counting and reloads itself on reaching zero (0x9B82).
When all three run out,
register 1 of the video chip is set to 0x82 and the screen goes off (0x9B8D).
From then on the game sits in a waiting loop with interrupts disabled —the `di`
comes before switching off, at 0x9B8C—, so there are no frames to count in there.
Any of the four directions or the two buttons wakes it (0x9B99) and, through row 7
of the keyboard, so do RETURN, STOP and ESC (0x9BA9). On the way back, register 1
goes to 0xE2 again (0x9BAF).

## The demo plays itself, and it is a recording byte for byte

You don't leave the title screen (0xB6B1) with a key: it ends when the demo's
script has spent seven of its entries (0xB751). From then on 0xE221 is 1 and the player's
input is no longer read: every frame it is fed whatever the table at 0xB9E4
dictates, which is pairs of [how many frames][what is pressed] in the same format
the keyboard produces (0xB9C8).

Six pairs finish the demo's game, and behind them come three waits of 0xFF
frames: there is no intelligence playing, there are eighteen bytes —twelve of play
and six of waiting—.

## The ending

You get to it through two doors, and they are the only two: running out of lives
(0x8975, which on going past zero eats its own return address and fits the player
with handler 0x9E0E) or running out of clock (0x9DEA, which goes through 0x9BCF).

Both do the same thing: leave a single object alive and give it the farewell
handler. What you see then is four sprites coming out and rising —their Y is 0xBC
minus the frame (0x9E8F)— over fourteen strips of drawing which are run through
in ten frames and start again (0x9E67).

Pressing RETURN there jumps to 0x8065, which is where every game starts, the
second one included (0x9C91).
