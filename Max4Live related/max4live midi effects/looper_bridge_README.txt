looper_bridge — a MIDI clip drives the four Loopers of one module side
======================================================================

Promoted 2026-09-17 from bass_looper_bridge; it replaces that and
looper_overdub_bridge (both in deprecated/). The 8-bar Looper became the main
one the same day; 1, 2 and 4 bar are the short ones that transfer into it.

Four name fields: "1 bar", "2 bar", "4 bar", "8 bar". An empty field is
unused. One device per control track; duplicate the control track for the
other side and type its names. The same device serves the melody module,
which uses the same layout.

    MIDI clip -> [midiin] -> [js looper_bridge.js] -> Live API -> the Loopers
                         \-> [midiout]              (MIDI passes through)

    C0  (note 24)  note-on   ->  8-bar record
                   note-off  ->  ignored (Record Length ends the recording)
    C1  (note 36)  note-on   ->  8-bar overdub
                   note-off  ->  held short Loopers: stop (clear follows)
                                 then 8-bar play
    C3  (note 60)  note-on   ->  1-bar record
                   note-off  ->  1-bar stop, clear 100 ms later
    C#3 (note 61)  note-on   ->  2-bar record
                   note-off  ->  2-bar stop, clear 100 ms later
    D3  (note 62)  note-on   ->  4-bar record
                   note-off  ->  4-bar stop, clear 100 ms later
    other notes              ->  ignored

    transport stop           ->  nothing: the Loopers keep their contents
                                 (emptying them: looper_clear_all)

Note names are Live's: middle C (60) is C3, so C0 = 24 and C1 = 36.


THE ROUTING (bass, A side)
--------------------------
The melody module's SRC / LOOP / SHAPE idea, with the short Loopers in front
and a return track for looper_replace:

  Track           Audio From                      Monitor  Audio To
  BASS LOOP 1 A   source track                    In       Sends Only
  BASS LOOP 2 A   BASS LOOP 1 A, Post FX          In       Sends Only
  BASS LOOP 4 A   BASS LOOP 2 A, Post FX          In       BASS SHAPE A
  BASS RET A      BASS LOOP 8 A, Insert-Looper    In       Sends Only
  BASS SHAPE A    BASS RET A, Post FX             In       bass fx
  BASS LOOP 8 A   BASS SHAPE A, Post FX           In       Sends Only

    BASS CTRL A (MIDI track)
      [looper_bridge]   1 bar = BASS LOOP 1 A    4 bar = BASS LOOP 4 A
                        2 bar = BASS LOOP 2 A    8 bar = BASS LOOP 8 A
    BASS RET A
      [looper_replace]  looper = BASS LOOP 8 A

- BASS SHAPE A is what you hear: the chain (live input + short loops) plus
  the returning 8-bar loop, with any effects on it. Limiter last — this is a
  real feedback loop.
- BASS LOOP 8 A records BASS SHAPE A. Its Feedback is 0%: the loop survives
  an overdub pass because it comes back through the track input, as LOOP
  does in the melody module. Effects on BASS SHAPE A are therefore baked in
  on every overdub pass, and heard before that.
- Every Looper: Input -> Output Always. Post FX taps after a track's devices
  and before its mixer (Live manual, Routing and I/O), so Sends Only does not
  silence a tap.
- Returning through Insert-Looper as Audio To does NOT work here: at
  Feedback 0 what comes back that way is not kept (tested 2026-09-17).


THE CYCLE (a transfer clip)
---------------------------
BASS LOOP 8 A always holds at least 8 bars: C0 records 8 bars first (of
silence if nothing plays).

A transfer clip (launched on the bar) holds two notes:

    C3 / C#3 / D3   from 1 to 9
    C1              from 1 to 9 (or a little after, see below)

1. The short note's note-on: that Looper gets Record. All Loopers are
   unquantized, so the recording starts when the call arrives: a few ms
   after bar 1 (Live API calls are deferred to Live's main thread).
2. Its Record Length (1, 2 or 4 bars) ends the recording; it switches to
   OVERDUB and repeats until bar 9. A phrase that rings past the loop end
   is laid over the loop start, so from the next round on it plays back
   complete. Anything played in the middle rounds is layered into the short
   loop too and repeats after that.
3. C1 note-on: BASS LOOP 8 A overdubs from bar 1: its own loop (returning
   through BASS RET A) plus the recording pass and every repeat. Whatever
   you play meanwhile is captured too, so "overdub the last round" = play in
   bar 8 (1-bar), bars 7-8 (2-bar) or bars 5-8 (4-bar).
4. Bar 9: both note-offs. Whichever arrives first, the short Looper is
   stopped (and cleared 100 ms later) BEFORE BASS LOOP 8 A is put back to
   Play, so the next repetition's first milliseconds do not land in the
   capture. (C1 note-off stops any short Looper whose note is still held;
   the later short note-off then does nothing.)

  !! The short note must END exactly on 9. Earlier cuts the last repetition
     out of the capture.

  C1 may end a little AFTER 9. The short Looper is already stopped at 9, so
  only the live tail of the last round is added to the start of
  BASS LOOP 8 A (along with anything else played in that moment). Ending
  exactly on 9 loses that tail at the loop start.

  !! Do not let C1 start while a C0 recording is still running. Overdub
     would arrive mid-record and most likely cut it short.

  !! C1 must be ONE note per pass. Two short notes do not work: the first
     note-off switches to Play at once.

WHY THE CLEAR COMES 100 MS AFTER THE STOP
With the short Loopers in Overdub, stop and clear sent back to back left them
stopped but NOT cleared (seen in Live 2026-09-17). Assumed cause: the clear
still found the Looper in Overdub, where Clear keeps the length (manual).
So the stop goes out at once (it is what silences the Looper before the
8-bar Looper leaves Overdub) and the clear follows 100 ms later
(CLEAR_DELAY in the js). A new record note for that Looper within those
100 ms cancels the pending clear; its Record overwrites the buffer anyway
(manual).

WHY THE LATE START IS FINE
All Loopers are unquantized and only the clips are quantized, so every
record note (C0 included) sits ON the bar.

A fixed-length recording replays what it heard exactly one loop length
later, so your on-grid playing stays on grid in every repeat. Only the loop
seam moves: the first few ms of the downbeat are missing from the buffer,
and in the repeats they are replaced by the first few ms after the
recording pass. In a transfer, bar 1 itself reaches BASS LOOP 8 A live.

A record note placed BEFORE the bar starts the recording that early: timing
still holds, but the seam leaves the bar line.

Why not Looper Quantization 1 Bar: a quantized Record has to arrive BEFORE
the bar line, and a note at the clip's 1 arrives after it, so the recording
would start one bar late.


LOOPER SETTINGS THIS RELIES ON
------------------------------
                  1 bar        2 bar        4 bar        8 bar (main)
Record Length     1 Bar        2 Bars       4 Bars       8 Bars
after recording   Overdub      Overdub      Overdub      Play
Quantization      None         None         None         None
Song Control      None         None         None         None
Tempo Control     Follow song tempo (all)
Input -> Output   Always       Always       Always       Always
Feedback          100%         100%         100%         0%

The short Loopers have no return, so in Overdub a lower Feedback fades or
wipes their loop; keep them out of any 0/100 Feedback switch. The main
Looper is the other way round: its loop comes back through BASS RET A, so
its own Feedback stays at 0.


BUILD
-----
1. In Live, drop a Max MIDI Effect on the control track, click Edit.
2. Select all (Ctrl+A) and delete everything.
3. Open looper_bridge.maxpat in a text editor, select all, copy.
4. Click in the empty device patch and paste (Ctrl+V).
5. Check in the inspector:
   - the name fields (1 bar, 2 bar, 4 bar, 8 bar): Parameter Mode Enable ON,
     Type = Blob, Parameter Visibility = Stored Only. The field itself
     stores the typed name with the set. SAVE THE SET after typing.
   - Patcher Inspector: Open in Presentation ON.
6. Save as looper_bridge.amxd IN THIS FOLDER, next to looper_bridge.js.

The js does not reload itself (autowatch 0). After replacing the js, reload
the device (save the Live set, or reopen it).


PER INSTANCE
------------
Type the exact track name into each field you use, press Enter. Four status
lines show what happened:

    8BAR BASS LOOP 8 A : bound          ready
    8BAR BASS LOOP 8 A : overdub        the last command sent
    1BAR - : unused                     field left empty
    1BAR NOT BOUND : ...                why nothing will be switched

The lookup is strict: exactly one track with exactly that name (case and
spaces count), exactly one Looper directly in its device chain (not in a
rack).


TESTING WITHOUT A CLIP
----------------------
Unlocked patch: [rec 1] [rec 2] [rec 4] [rec 8], [clear 1] [clear 2]
[clear 4] [clear 8] (clear = stop, then clear 100 ms later), [overdub]
[play] (8-bar Looper), [resolve] re-binds all four. Everything is logged to
the Max Console with prefix LBR; send "debug 0" into the js to silence it.

Checked outside Live with a mock Live API (2026-09-17): C0/C1 reach the
8-bar Looper; a D3 (or C3 / C#3) transfer gives record / overdub / short
stop / 8-bar play, then the short clear 100 ms later, with either note-off
first; a note-on right after a note-off cancels the pending clear; a short
note-off with no note-on does nothing.

Verified in Live with looper_overdub_bridge (2026-09-10): C1 overdub start
and the Play at its note-off both land on the bar.


VERIFIED IN LIVE (2026-09-17)
-----------------------------
- The transfers work: C3 / C#3 / D3 into the 8-bar Looper, which keeps its
  old content and gains the transferred phrase. The short Looper is cleared
  after its note-off.
- Overdub layering and looper_replace both work in this routing.
