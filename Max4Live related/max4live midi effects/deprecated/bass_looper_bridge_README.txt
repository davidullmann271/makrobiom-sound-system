bass_looper_bridge — a MIDI clip drives the three bass Loopers of one side
=========================================================================

One device, three name fields: "1 bar", "2 bar", "4 bar". Type the track
names of that side's Loopers; duplicate the control track for the other side
and type its names.

    MIDI clip -> [midiin] -> [js bass_looper_bridge.js] -> Live API -> 3 Loopers
                         \-> [midiout]                   (MIDI passes through)

    C0  (note 24)  note-on   ->  4-bar record
                   note-off  ->  ignored (Record Length ends the recording)
    C1  (note 36)  note-on   ->  4-bar overdub
                   note-off  ->  held short Loopers: stop (clear follows)
                                 then 4-bar play
    C3  (note 60)  note-on   ->  1-bar record
                   note-off  ->  1-bar stop, clear 100 ms later
    C#3 (note 61)  note-on   ->  2-bar record
                   note-off  ->  2-bar stop, clear 100 ms later
    other notes              ->  ignored

    transport stop           ->  nothing: the Loopers keep their contents
                                 (emptying them: looper_clear_all)

Note names are Live's: middle C (60) is C3, so C0 = 24 and C1 = 36.
C0 and C1 behave exactly as in looper_overdub_bridge; this device replaces
it on the bass control track.


THE CHAIN (A side)
------------------
    source -> BASS LOOP 1 A -> BASS LOOP 2 A -> BASS LOOP 4 A -> bass fx

  Track           Audio From                  Monitor   Audio To
  BASS LOOP 1 A   source track                In        Sends Only, sends down
  BASS LOOP 2 A   BASS LOOP 1 A, Post FX      In        Sends Only, sends down
  BASS LOOP 4 A   BASS LOOP 2 A, Post FX      In        bass fx

All three Loopers: Input -> Output Always. Every Looper passes on what it hears
plus its own playback, so BASS LOOP 4 A hears everything and is the only one
audible. Post FX taps after the track's devices and before its mixer (Live
manual, Routing and I/O), so Sends Only does not silence the tap.

    BASS CTRL A (MIDI track)
      [bass_looper_bridge]   1 bar = BASS LOOP 1 A
                             2 bar = BASS LOOP 2 A
                             4 bar = BASS LOOP 4 A


THE CYCLE (a transfer clip)
---------------------------
BASS LOOP 4 A always holds at least 4 bars: C0 records 4 bars first (of
silence if nothing plays), as in the melody module.

A transfer clip (length 4, launched on the bar) holds two notes:

    C3 or C#3   from 1 to 5
    C1          from 1 to 5

1. C3/C#3 note-on: the short Looper gets Record. All Loopers are
   unquantized, so the recording starts when the call arrives: a few ms
   after bar 1 (Live API calls are deferred to Live's main thread).
2. Its Record Length (1 or 2 bars) ends the recording; it switches to
   OVERDUB and repeats until bar N+4. A phrase that rings past the loop end
   is laid over the loop start, so from the next round on it plays back
   complete. Anything played in the middle rounds is layered into the short
   loop too and repeats after that.
3. C1 note-on: BASS LOOP 4 A overdubs from bar N and captures the recording
   pass and every repeat. Whatever you play meanwhile passes through the
   chain and is captured too, so "overdub the 4th repetition" = play in
   bar N+3 (1-bar) or bars N+2..N+3 (2-bar).
4. Bar N+4: both note-offs. Whichever arrives first, the short Looper is
   stopped and cleared BEFORE BASS LOOP 4 A is put back to Play, so the
   next repetition's first milliseconds do not land in the capture.
   (C1 note-off clears any short Looper whose note is still held; the
   later C3/C#3 note-off then does nothing.)

In the steps above, bar N = the clip's 1 and bar N+4 = its 5.

  !! C3/C#3 must END exactly on 5. Earlier cuts the last repetition out of
     the capture.

  C1 may end a little AFTER 5. The short Looper is already cleared at 5, so
  only the live tail of round 4 is added to the start of BASS LOOP 4 A
  (along with anything else played in that moment). Ending exactly on 5
  loses that tail at the 4-bar loop start.

WHY THE CLEAR COMES 100 MS AFTER THE STOP
With the short Loopers in Overdub, stop and clear sent back to back left them
stopped but NOT cleared (seen in Live 2026-09-17). Assumed cause: the clear
still found the Looper in Overdub, where Clear keeps the length (manual).
So the stop goes out at once (it is what silences the Looper before the
4-bar Looper leaves Overdub) and the clear follows 100 ms later
(CLEAR_DELAY in the js). A new C3/C#3 note-on within those 100 ms cancels
the pending clear; its Record overwrites the buffer anyway (manual).

WHY THE LATE START IS FINE
Applies to every Looper here, C0 included: all three are unquantized and
only the clips are quantized, so every record note sits ON the bar.

A fixed-length recording replays what it heard exactly one loop length
later, so your on-grid playing stays on grid in every repeat. Only the loop
seam moves: the first few ms of the downbeat are missing from the buffer,
and in the repeats they are replaced by the first few ms after the
recording pass. In a transfer, bar 1 itself reaches BASS LOOP 4 A live.

A record note placed BEFORE the bar now starts the recording that early:
timing still holds, but the seam leaves the bar line.

Why not Looper Quantization 1 Bar: a quantized Record has to arrive BEFORE
the bar line, and a note at the clip's 1 arrives after it, so the recording
would start one bar late.

  !! Do not let C1 start while a C0 recording is still running (same rule as
     looper_overdub_bridge).


LOOPER SETTINGS THIS RELIES ON
------------------------------
                  BASS LOOP 1 A     BASS LOOP 2 A     BASS LOOP 4 A
Record Length     1 Bar             2 Bars            4 Bars
after recording   Overdub           Overdub           as melody Looper
Quantization      None              None              None
Song Control      None              None              None
Tempo Control     Follow song tempo (all)
Input -> Output   Always            Always            Always
Feedback          100%              100%              100%
                  (in Overdub, lower Feedback fades or wipes the loop at
                  every wrap; keep the short Loopers out of any 0/100
                  Feedback switch)


BUILD
-----
1. In Live, drop a Max MIDI Effect on BASS CTRL A, click Edit.
2. Select all (Ctrl+A) and delete everything.
3. Open bass_looper_bridge.maxpat in a text editor, select all, copy.
4. Click in the empty device patch and paste (Ctrl+V).
5. Check in the inspector:
   - the name fields (1 bar, 2 bar, 4 bar): Parameter Mode Enable ON,
     Type = Blob, Parameter Visibility = Stored Only. The field itself
     stores the typed name with the set. SAVE THE SET after typing.
   - Patcher Inspector: Open in Presentation ON.
6. Save as bass_looper_bridge.amxd IN THIS FOLDER, next to
   bass_looper_bridge.js.


PER INSTANCE
------------
Type the exact track name into each field, press Enter. Three status lines
show what happened:

    4BAR BASS LOOP 4 A : bound          ready
    4BAR BASS LOOP 4 A : overdub        the last command sent
    1BAR NOT BOUND : ...                why nothing will be switched

Lookup is the same as looper_overdub_bridge: exactly one track with exactly
that name, exactly one Looper directly in its device chain (not in a rack).


TESTING WITHOUT A CLIP
----------------------
Unlocked patch: [rec 1] [rec 2] [rec 4], [clear 1] [clear 2] [clear 4]
(clear = stop then clear), [overdub] [play] (4-bar Looper), [resolve]
re-binds all three. Everything is logged to the Max Console with prefix BLB;
send "debug 0" into the js to silence it.

Checked outside Live with a mock Live API (2026-09-17): the call order for a
transfer is record / overdub / short stop / 4-bar play, then the short clear
100 ms later, with either note-off first. A note-on right after a note-off
cancels the pending clear.


TO TEST IN LIVE
---------------
- A transfer: listen to the loop start of BASS LOOP 4 A for a doubled
  attack.
- The downbeat in repeats 2-4 sounds clean, also when bar 2 of the
  recording pass was silent.
- The short Looper plays straight after its recorded bar(s) and does not
  jump to the next bar line (the manual does not say whether a running
  Looper re-aligns an off-grid loop).
- The short Looper is empty after its note-off (the 100 ms delayed clear).
  If it still is not, raise CLEAR_DELAY in the js and report back.
- A phrase ringing past the bar: its tail is on the short loop's start
  from round 2 on.
- Stop and restart the song: the Loopers keep their contents. Check which
  state each one comes back in.
