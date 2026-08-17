# Findings

What turned up when the cartridge was taken apart, with the evidence beside it.
Everything on this page can be checked by reading the binary; what isn't settled
yet is in [Open questions](OPEN-QUESTIONS.html).

## The world isn't stored: it's computed

The 255 screens of this game don't take up one byte of map. There is no list, no
index, no table of scenes: the screen you are on **is** the contents of a byte of
RAM, 0xE222, and changing screen is turning it one step.

The turn is at 0xB68F, and it is sixteen bytes of `rla` and `xor (hl)`. Read and
checked over all 256 possible values, what they do is a feedback shift register:

    new bit = b7 xor b5 xor b4 xor b3      (mask 0xB8)

With that feedback the ring is **maximal**: it runs through all 255 non-zero
values and comes back to the start. 0x00 is left outside, because nobody gets out
of zero in a register like that, and that is why the game uses it for the title
screen: the state that doesn't belong to the world.

And there is a second routine, 0xB69F, which is **the exact inverse function**: it
shifts the other way and undoes what the other one did. Leaving a screen by the
left brings you back to exactly the one before. The two together take 33 bytes,
and that is all the map this game has.

Seeded with 0xC4, which is what the startup does at 0x8075, out comes the precise
order in which the world is walked going always to the right. That order was
reproduced by two independent paths: simulating the two routines over the data,
and capturing all 255 scenes in the emulator. **They agree on 255 out of 255.**

## Not one of the screen register's eight bits is wasted

That byte isn't just a position counter. When the scene is built (0x9EE6) it is
split into three pieces, and each piece picks something different:

| bits | what they pick | where they are read |
|---|---|---|
| 6-7 | which of the four sceneries is painted | 0x9F91 |
| 3-5 | the kind of scene, 0 to 7 | 0x9EFB |
| 0-2 | the variant within that kind | 0x9EEF |

Eight bits, three jobs, nothing wasted. A whole screen of this game is described
by one byte, and that is why the world can be written out without playing.

Bit 7 does **a second job** as well, and it is the detail that takes the most
finding: apart from going inside the scenery index, it is read again on its own at
0xA9AA, in the pit scenes, and it decides where the **rebound box** goes —the
class 10 one, centred at 0xD8 with the bit set and at 0x31 with it clear— and
which of the two pit drawings is painted. The ladder itself doesn't move: both
branches paint the same script, 0x8F06.

The share-out the ring produces is practically even, and can also be counted
without playing: 31 scenes of kind 0 and 32 of each of the other seven; 63 of
scenery 0 and 64 of each of the other three. The odd one out in each case is the
missing 0x00.

## The ceiling of the game is 114000 points, and it is counted without playing

The treasures are **exactly** the 32 scenes of kind 5. There is no need to walk
them: kind 5 is the only one dispatched through the table at 0xAEA4, that table
holds four routines repeated two by two, and the eight variants share out four
scenes each. One treasure of each class comes up eight times: 8+8+8+8 = 32, and
not one more.

Each routine writes what its own is worth into 0xE188 —2, 3, 4 or 5, that is,
thousands of points— and 0x878C adds it in when you pick it up. So the whole world
holds

    8 x (2000 + 3000 + 4000 + 5000) = 112000 points

and with the 2000 the score starts at (0x8A28), **114000**. That is the ceiling of
the game, and it comes out of reading a sixteen-byte table.

What you have already taken away is remembered in exactly 32 bits: 0xE21D-0xE220,
one byte per class of treasure and one bit per treasure, with the index within the
class at 0xE223.

And the «this one's already been taken» check is solved in a way you don't see
first time round. 0xAAFF rotates the bit out into the carry; if it was clear it
returns normally and whoever called paints the treasure, but if it was set it does
`pop hl` and `ret` (0xAB19): **it eats its own return address**, jumps over the
code that would paint the treasure and hands control back two levels up.

## The tunnel crosses the world three times as fast

At 0x9CD2, on changing screen, bit 0 of 0xE2EB —the one that says whether you are
on the surface— is looked at and the register is turned **one step or three**. Down
below, three scenes at once.

That makes the tunnel a real shortcut, and it can be measured: the shortest route
that collects all 32 treasures is **189 screens** crossed, against 238 never going
down. 21 % fewer. And the route doesn't all go one way: it goes right to the
first treasure, turns round, and sweeps the other 31 leftwards —13 crossings to
the right and 176 to the left—, which is how it never crosses the ring's most
expensive gap. Always going right would cost 190.

Going down needs a ladder, and the ladders were counted over the 255 captures of
the walk. The result is clean in an unusual way: it is **bimodal, without a single
in-between case**. Either a scene has 3 vertical stripes —which is scenery— or it
has 8, which is a ladder. The ones with 8 are 63, and they are exactly the 63
scenes of kinds 0 and 1, which is what reading the code already said. Two methods
with nothing in common giving the same number.

The whole ring is [the map of the world](imagenes/mapa-del-mundo.png), the 255
scenes in a labelled grid, and the route is [the walkthrough of the perfect
game](imagenes/guion-de-la-partida-perfecta.png), one cell per screen crossed.

## There isn't one letter in this cartridge

Not a string, not an alphabet, not a message hidden by the programmers.

The font the game loads is **twelve cells**: the ten digits (0xB8-0xC1), the colon
(0xC2) and the blank (0xC3). The score and the clock are written with those, and
they don't stretch to a single letter.

Everything else on screen that looks like text is **drawing** cut into consecutive
cells, one per position. That is why searching the ROM for strings returns nothing
readable: the little that turns up is chance runs of graphics and code bytes.

The authors' only signature is the line at the foot of the title screen, and that
is a drawing too: two dates, 1982 and 1984.

## The vine isn't drawn: it's traced

There is no vine graphic in the cartridge, and there isn't one because it isn't
needed. On every step, 0xA471 draws a 16-point straight line onto a 0x40-byte
bitmap that lives in RAM (0xE18A) and sends it up to video memory as a sprite
pattern (0xA594). The slope comes out of the table at 0xA61A, indexed by the phase
of the swing (0xE1CB), which runs up and down between 1 and 0x20.

So the vine is a sprite the game draws for itself frame by frame. Storing the
frames would cost rather more than the instructions that work them out.

## The sprites facing left aren't in the ROM

Only half of them are drawn. The ones facing left are made at startup by mirroring
the others (0x8B5E), and there are two routines for it: 0xB1D1, which reverses each
byte bit by bit —which gives the horizontal mirror—, and 0xB20B, which also changes
the order of the eight bytes.

A real mirror is needed and not just reversing bits, because a 16x16 sprite on an
MSX is **two halves of 16 bytes**, so turning it round means crossing the two
halves over as well (0x8BC1).

The animation scripts square it beyond doubt: walking right uses patterns 0x20 to
0x30 and walking left 0x44 to 0x54. The difference is 0x24, which is exactly nine
sprites of four patterns, which is what the mirroring loop processes in one go.

## The tar and the water are the same drawing, and three bytes apart

Scene kinds 2 and 3 paint the same thing. The only difference is that 0xAC7C
writes `1B 1B 1B` at position 0x200B of the colour table —black, tar— and 0xAC6B
writes `7B 7B 7B` over it —cyan, water—.

The patch spends three bytes of its own, at 0xB110. Putting it back spends none:
the `7B 7B 7B` that returns the pool to water is the same one already inside the
initial colour table, at 0xB0FB, and 0xAC6B copies it from there.

And the same trick is in the treasures. The two bars —the 3000 one and the 4000
one— share a colour: the colour byte is 0x4B at 0xAE90 and at 0xAE92 alike. What
tells them apart is the pattern, not the colour.

## The game keeps the interrupt and doesn't give it back to the BIOS

The interrupt hook doesn't end with an ordinary `ret`. It ends with **eleven
`pop`s in a row** (0x810F-0x8122), which unstack one by one the registers the BIOS
had saved on the way in —the alternate ones included, after the `ex af,af'` and the
`exx` at 0x8118—, with an `in a,(099h)` slipped in among them (0x811A) that reads
the video chip's status, which is what marks the interrupt as served.

The first `pop hl` takes away the return address into the BIOS, and the `ei` /
`ret` at 0x8123 hands control straight back to the interrupted program. The rest
of the BIOS interrupt routine never gets to run.

## There is an `rst 0` that tries to overwrite the game's own code

At the end of every frame, at 0x9AE0, there are these two instructions:

```asm
fin_del_cuadro:
    ld hl,fin_del_cuadro      ; 9ae0
    ld (hl),0c7h              ; 9ae3
```

0xC7 is `rst 0`, and the address being written is that very line's. So the frame
ends, every time, trying to write over itself a jump to the machine's reset.

In a cartridge that does nothing, because 0x9AE0 is ROM and the write is lost
along the way. What it does is verified by reading the bytes; **what it is for
cannot be proved from the binary**. The reading that fits is a guard against
running the game from RAM: the write only lands somewhere if that thing there
isn't ROM, and then the game kills itself on the first frame. But that's a
reading, not a measurement.

## The sound doesn't touch the chip: it touches fourteen bytes of RAM

In the whole cartridge there is **a single place** that writes the sound
registers: the `outd` loop at 0xB380. What is at 0xE20E-0xE21B is a copy in RAM of
registers 0 to 13, and 0xB37B dumps the lot once per frame, counting from 13 down
to 0. Port 0xA1 is written in two other places, 0xB24F and 0xB261, but that isn't
sound: it is register 15, the one the controller reader uses to pick which
joystick port it looks at.

On top of that go four vectors at 0xE1E6-0xE1ED, and the table at 0xB393 says which
routine is installed in which of them for each of the eleven sounds.

Out of that comes a detail you can't see by playing: **sounds 0 and 1 are mute, and
doubly so**. Their entry in the table points at 0xB392, which is a lone `ret`, and
on top of that they are installed in slot 3, the only one of the four that the
chain at 0xB35B doesn't even walk.

## The opening banner isn't painted: it's revealed

The title screen (0xB7F1) doesn't dump a picture. Every frame it shifts by **one
pixel** the ten patterns it has loaded at 0xE132 and sends them up to the pattern
table; every eight frames it reloads the drawing and moves on a column, until it
reaches column 0x18.

Ones come in from the left, which is the background (the `scf` at 0xB86E), and from
column 12 on a sprite appears and starts walking. The result is the banner
appearing in bands, and it doesn't cost a single stored frame.

You don't leave the title screen with a key either: it ends when the demo's
recorded script has spent seven of its entries (0xB751).

## The title screen is in one screen mode and the game in another

At 0xB6B2, register 0 of the video chip is set to 0x02: graphics mode 2, the one
with three independent banks, which is the one needed for the opening banner. On
the way out, at 0xB788, it goes back to 0x00, which is graphics mode 1.

That change explains a figure that would otherwise throw you: **the game's colour
table is 32 bytes**, not 6144. In the game's mode the colour goes per group of eight
cells, so the 32 bytes at 0xB0F0 are the whole palette.

There is a second consequence, more useful still for reading the cartridge:
registers 2, 5 and 6 —the ones that say where the name table, the sprite attributes
and the sprite patterns are— **are written by nobody in the whole binary**. The game
keeps what the BIOS left and writes to 0x1800, 0x1B00 and 0x3800 without declaring
it.

## The blocks close against each other, and that is what fixes their size

Knowing where a table ends is usually the worst of a disassembly, because the size
isn't written anywhere and getting it wrong gives no error at all.

Here almost everything delimits itself, because the data go one against the next
without a byte of gap. The five big blocks of compressed graphics (0x909E-0x95FE),
the nine sprite ones of the scene handlers (0x981E-0x99AF), the six of the title
screen (0xBAB2-0xBC61), the five cell scripts (0x8F06-0x9090) and the four scene
layouts (0xA096-0xA33E) each close **exactly** where the next one begins, and the
last one closes against the first instruction of the code that follows.

You try it with N entries and only one N closes. With that, the size stops being an
assumption.

## One byte that is three things at once

The tightest piece of programming in the cartridge is in how the stretches of
ground of rows 12 and 13 are painted. The scene layout carries five bytes for that,
and each of those bytes is, at the same time, **an offset into the table, the length
of the copy and the step through video memory** (0x8DA7): each stretch copies from
`table+N` to `table+2N`.

It is read at 0x8DA0-0x8DB6, and it has a side effect that helps delimit the data:
the Ns the four layouts use are 3, 4, 5, 6, 7, 8 and 0x0A, so the use reaches just
as far as `table+0x14` and not one byte more.

## The pit is open longer than it is shut

The pit that opens and shuts (0xA870) has its width at 0xE133, from 1 to 8, and its
direction at 0xE132. The class 3 collision box stretches with it, so the danger
isn't a drawing: it is a box that grows and shrinks.

And the object's period alternates between 0x96 and 0x44. So the cycle **isn't
symmetrical**, and it goes the opposite way to what you would expect: 0x96 frames
with the pit narrow (0xA913) against 0x44 with it fully open (0xA952). It is shut
more than twice as long as it is open.

## What was left over inside the cartridge

On closing the 16384 bytes a few things turned up that are there and are good for
nothing. None of them is a suspicion: all of them were checked by sweeping all
16384 words of the cartridge, and not just the traced code, to see whether their
address ever appears.

- **Six routines nobody calls**: 0xB11E, 0xB199, 0xB1A1, 0xB2A4, 0xB2F4 and
  0xB9AB. The first is especially telling: it is the twin of the decompressor at
  0xB142, **but writing to memory instead of to the video port**. And 0xB2A4 is a
  complete keyboard scanner, with debounce and key code, which the game doesn't
  use because row 8 is enough for it.
- **Six orphan `ret`s** (0x9CBD, 0xAA73, 0xACB4, 0xADE7, 0xAE37, 0xB6B0): a single
  0xC9 byte stuck behind the end of a routine, with nobody pointing at it. Four of
  the six come right after a `jp` that takes control away; the other two (0x9CBD
  and 0xB6B0) come after another `ret`. Either way they are the closing the
  assembler wrote and that never runs.
- **A whole, well-formed animation script** at 0xAF84 —nine frames, patterns 0x20
  to 0x40 four at a time, fifty frames each— that nobody loads. Fifty frames per
  frame is slow: that is not a creature.
- **A second copy of the starting clock** at 0x8F00, with the same five cell
  numbers that read «20:00» as the ones at 0x8A69, but with a 0x00 behind them
  instead of the divisor. Nobody copies it.
- **The data for the second and third logs** (0xAFBA), written and unused: 0xAD2E
  takes only the first one's and 0xA745 places the other two from code.
- **A collision class that doesn't exist**: the table at 0x8AA0 has eleven entries
  and number 7 points at 0x874B, but there isn't one instruction in the whole
  cartridge that writes a 7 into the class field.
- And **two lists of eight bytes** at 0xBAA2 that are the same one with the nibbles
  swapped (61 against 16, 91 against 19, B1 against 1B). That one still has no
  consumer; it is in [Open questions](OPEN-QUESTIONS.html).
