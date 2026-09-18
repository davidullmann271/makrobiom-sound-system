beat_freeze — momentary buffer freeze, anchored to the division grid
====================================================================

A generic Max AUDIO Effect. Two parameters, both meant for MIDI only:

    Hold      ch 4 CC 1    momentary on/off switch
    Division  ch 4 CC 2    send 0..7, default 5

Hold is a real on/off parameter, and Live maps a CC to one by VALUE, not by
toggling: "controller values that are within the mapping's Min and Max range
turn the switch on. Controller values that are above or below this range turn
it off." So set Min to 1 in the MIDI Mappings browser after mapping it, and
127 holds while 0 releases - momentary, held for exactly as long as the pad is
down, no toggle and no latching.

Division is a dial of range 0..127, so Live passes the raw CC value through
untouched and "send the integer 0..7" works as intended. 8..127 clip to 7.

    [plugin~] --------> [gen~] -> [plugout~]
    [phasor~ 1n @lock 1] ^          ring buffer + read head


DIVISIONS  (Division CC value -> length -> 1/48-bar units)
----------------------------------------------------------
    0   1/16    3        4   3/16    9
    1   1/12    4        5   1/4    12
    2   1/8     6        6   1/3    16
    3   1/6     8        7   1/2    24

Ordered ASCENDING BY LENGTH, so raising the CC always makes the loop longer.
Note 3/16 (9 units) sits between 1/6 (8) and 1/4 (12) - it is longer than 1/6,
which is why it is not next to 1/8.

Fractions are of a BAR, always 4/4. 1/16 is a sixteenth note, 1/12 an eighth
triplet, 3/16 a dotted eighth, 1/4 one beat, 1/2 two beats.

48 is the point of the internal grid: it is the lcm of every division in the
list, so every anchor, cycle length and read position lands exactly on it.
Nothing is ever cut mid-unit, triplets included.


HOW IT WORKS
------------
EVERYTHING COMES FROM THE PHASOR. [phasor~ 1n @lock 1] on gen~'s third inlet
is a transport-locked ramp over one bar. From it the engine derives:

  - whether the transport is running     (does the ramp move?)
  - the bar length in samples            (measured between wraps)
  - the position within the bar          (phu = ph * 48, in units)
  - a reference for the write position   (round(ph * bln))

Nothing is taken from live.observer. But the phasor is only used for COARSE
decisions - everything that moves sample by sample counts smoothly (see rule 5).

THE PRESS ONLY ARMS. Recording runs untouched until the next boundary of the
current division. There the anchor is taken as

    S  = w - D          from wherever the write head actually is
    d0 = D              exactly one division of real audio

so pressing anywhere inside a 1/2 slot behaves exactly as if you had hit it on
that slot boundary. The boundary is purely a delay; it never decides the
region. The region is the slot you are playing in, so whatever you just played
is inside it, and because every division divides 48 the anchor always sits on
a true song boundary - a note played on the beat lands on every cycle start,
in every division, through any number of switches.

With the transport STOPPED the phasor does not move, so there is no grid to
anchor to. In that case the freeze engages immediately on the last D.


CYCLES
------
Every cycle plays forward from S for the length of its division.

  - A cycle that has started ALWAYS finishes. A division change never
    interrupts one.
  - A new cycle may only begin where that division's own grid says, i.e. where
    upos crosses a multiple of D, counted from S.
  - Anything between the end of one cycle and the next legal start is SILENCE.
  - Anything past d0 inside a cycle is silence too, since a division longer
    than the one pressed with runs forward into material that does not exist
    yet.

Nothing can jump mid-cycle, so there are no unpredictable discontinuities.
Each cycle is windowed: a 64-sample (~1.3 ms) fade in at the start, kept short
so transients stay sharp, and a 192-sample (~4 ms) fade out at the end and at
the d0 edge.
That third fade matters - it was the one transition that used to slam to zero,
and it caused audible clicks.


WORKED EXAMPLE
--------------
Sixteenths of the region numbered from 30, where 30 begins at the anchor.
Pressed with 3/16, switched to 1/8 during the 7th sixteenth:

    30 31 32 | 30 31 32 | 30 31 32 | sil | 30 31 | 30 31 ...

The cycle that started finishes as 30 31 32. The next 16th is not on the 1/8
grid, so it is silent; the one after is, so the new cycle starts there.
Verified sample-by-sample against the engine.


BUILD (once)
------------
1. In Live, drop a Max Audio Effect on the track. Click Edit.
2. Select all (Ctrl+A) and delete the default [plugin~] -> [plugout~] pair.
3. Open beat_freeze.maxpat in a text editor, select all, copy, and paste into
   the empty Max patch (Ctrl+V).
4. Save as makrobiome_beat_freeze.amxd. No .js file - pure Max and gen~.
5. Ctrl+M and map Hold to ch 4 CC 1, Division to ch 4 CC 2. The mapping goes
   through Live's own remote path, which keeps the channel, so ch 4 is
   honoured. With Hold still selected in the MIDI Mappings browser, set its
   Min to 1. Leaving Min at 0 makes every CC value "in range", and the freeze
   would latch on and never release.

To update it later, paste the whole patch over the old one. The varnames
"hold" and "division" do not change, so the MIDI mappings survive.


FIVE RULES THE GEN~ CODE OBEYS
------------------------------
All five were learned by breaking them. Keep them if you edit the codebox.

1. NEVER ASK LIVE FOR THE TRANSPORT. A live.observer @property is_playing
   silently never delivered 1, so a "playing" param sat at 0 and EVERY code
   path took its stopped-transport fallback: engage immediately on press,
   anchor taken at the finger instead of at the boundary, region = [press-D,
   press]. Recording appeared to stop the moment the button went down, the
   anchor tracked press timing, and short divisions read only the silence in
   front of the note. It cost days.

   The tell was that the device kept working with the session STOPPED, when it
   should have fallen back. Every number measured correct throughout, because
   the fallback path was working exactly as designed.

   Now: if the phasor's value changes, the transport is running; if it holds
   still for 4096 samples, it is stopped. No API, no silent failure, and it is
   the same signal the timing already depends on.

2. THE WRITE HEAD COUNTS, AND REJOINS THE TRANSPORT ONLY ACROSS A REAL GAP.
   It advances one sample per sample and snaps to round(ph * bln) only when
   the two disagree by more than 4096 samples. Live deactivates a device whose input goes silent - "When
   there is no incoming audio, the effects are deactivated until they are
   needed again" - and a counter stops with it, leaving w permanently out of
   step. A derived write head corrects a deactivation of any length on the
   first sample back. Emitting noise from the device does NOT prevent the
   deactivation; Live decides from the device's own incoming audio.

3. EVERY HISTORY IS READ INTO A LOCAL AT THE TOP AND WRITTEN BACK
   UNCONDITIONALLY AT THE BOTTOM. A History is a one-sample delay: a branch
   that does not assign it leaves its input unfed and it collapses to 0. That
   silently zeroed D0 and made the whole device mute.

4. NOTHING READS A RING POSITION THE WRITE HEAD MAY OVERWRITE, and the write
   head never enters the frozen region. The guard is a POSITIONAL test, not a
   countdown, so it cannot drift, and it self-heals: inside the region the
   write head skips the write but keeps advancing. The declick is an envelope,
   not a second read pointer, so nothing is ever read past the end of the
   region into live audio.


5. THE PHASOR JITTERS; NEVER LET IT DRIVE A SAMPLE-LEVEL POSITION.
   phasor~ @lock is corrected to Live's transport in steps, not smoothly, and
   its position wobbles by more than 8 samples at times. With the write head
   snapping at 8 samples, every wobble spliced the recording; the splices
   clustered just before bar lines, which is exactly where regions end, so a
   crunch was baked into the loop and repeated every cycle. The cycle position
   during a hold was also read straight off the phasor, so playback jittered
   too.

   Now: the position while armed or held COUNTS from a phasor-seeded start;
   tuv and the bar length are frozen from press to release; the bar length is
   smoothed while idle (a jump over 2% is treated as a tempo change); and
   "transport running" means real phasor motion, not any change at all. Snaps
   now happen only at transport start and after real gaps - never during a
   freeze. The phasor jitter readout in the debug build shows how big the
   wobble is.


NOTES
-----
- The ring is ONE BAR long, indices 0..bln inside a 576,000-frame stereo data
  object. The largest division is half a bar, so a bar of history is all this
  device needs. A tempo change remaps the indexing and scrambles it for one
  bar.
- Playback speed is exactly 1x by construction: upos advances 48/bln units per
  sample and rr = sA + pocu*tuv with tuv = bln/48, so the two cancel.
- Press timing is accurate to one audio buffer, not one sample; Live hands
  parameter changes to the device at block boundaries. The cycle timeline
  itself is sample-exact once running.
- There is no noise anywhere in the signal path.

DEBUG READOUTS
--------------
gen~ still has outlets 3..12 carrying engine state, but nothing is connected to
them. To bring the readout column back, set DEBUG = True in the build script:
it generates a snapshot~ -> number box -> label column from the SAME table that
generates the outlets, and verifies end to end that each label matches the
expression feeding it.

That verification is not optional. A hand-edited outlet once left the labels
pointing at the wrong values, and two rounds of debugging were spent reasoning
about numbers that were measuring something else entirely. A readout that lies
is worse than no readout.

    out3  held                 out8  expected cycle length (samples)
    out4  transport detected   out9  write head
    out5  anchor sA            out10 content starts at unit
    out6  measured bar length  out11 content ends at unit
    out7  read span (samples)  out12 d0 (units)
