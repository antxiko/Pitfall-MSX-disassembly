# Open questions

Every byte of the cartridge is accounted for, the listing gives back the
original byte for byte and its 337 labels have names. That does not mean they
all say what they do: 78 carry their explanation in the label itself and the
rest lean on the 913 line comments and the 50 block headers. This page says
what those figures mean and what remains unknown.

## No victory condition shows up

The only two ways out of a game are running out of lives (0x8975) and running
out of clock (0x9DEA), and both end in the same place: the ending sequence at
0x9E0E.

Whether collecting the 32 treasures does anything is **neither proven nor
ruled out**. What has been searched for and is not there: in the traced code
there is no comparison against 32 that has anything to do with treasures —the
only one compares the vine's swing phase, 0xA5F0— and, apart from the 32 bits
of taken treasures (0xE21D-0xE220), there is no counter of how many you carry.

## The 189-screen route is a calculation, not a game

The number comes from walking the ring of 255 scenes with the cartridge's own
screen-change rules, counting the underground shortcut. It measures **screens
crossed** and nothing else: jumping, waiting for a log and using ladders are
counted as free.

It fits the clock, and that count also comes from the cartridge: walking is
200/256 pixel per frame (0x88ED) and a screen runs from X 0x19 to 0xE7, 206
pixels: 264 frames, 4.4 seconds at 60 Hz. The 189 crossings add up to 49,896
frames —13.9 minutes— against the 72,000 of the 20:00 clock: 70 % of the clock
just walking, with about six minutes to spare. Still model arithmetic.

What remains is running the route in the emulator and checking that the 32
treasures show up and the score reaches 114000.

## Sixteen bytes owned and unused

At 0xBAA2 there are two eight-byte lists, and the second is the first with the
nibbles swapped: 61 against 16, 91 against 19, B1 against 1B. The range is
bounded on both sides, but it has no consumer: no traced instruction reads it,
and none of the cartridge's 16384 words holds its address. They are explained
as data, not as use.

By the same yardstick: the animation script at 0xAF84 and the second clock copy
at 0x8F00 are identified and unused too.

## What backs each figure, and what does not

- **It reassembles byte for byte.** The published listing assembles and the
  sha256 is the cartridge's.
- **Not one byte unexplained.** The 16384 split into 9,467 of code reached by
  the tracer and 6,917 inside declared ranges, each with the instruction that
  reads it noted alongside.
- **No data area is read as code.** A separate check from reassembly, which
  cannot catch that: if drawings are read as instructions, the bytes do not
  change.
- **No entry point falls inside a data area.** Seeding the tracer with a
  wrongly deduced address would inflate coverage with no alarm.

What the 100 % does **not** mean: that the purpose of every byte is known. It
means every byte sits in a named range, and that name comes from reading the
instruction that consumes it. The three cases in the section above are the
exception, which is why they are written down.

The listing's comments are verified by sampling, not line by line.

## Four warnings for whoever carries on

**A period is not a speed, and a frame counter is not a clock.** The code says
frames per tick; how long that lasts depends on the machine, and the two are
easily confused.

**Poking 0xE222 repaints nothing.** The only path that builds a scene is
0x9EE6, reached from the game start (0x809F) and from the screen change (0x9CBE
and 0x9CF9). To walk the world in the emulator, write 0xE7 into 0xE2A3 —the
player's X— and let the game change screen on its own.

**The walk's captures are off by one.** The photograph is taken after the step,
so capture N is not scene N. Cross them by the screen register value, which is
in the file name.

**Brute-force pointer hunting lies.** A run of repeated bytes looks like a
pointer, and reading an operand from the middle of an instruction gives
plausible addresses that do not exist. Every lead from there is confirmed
against the listing; that is why this repository's tools walk instruction
starts only.
