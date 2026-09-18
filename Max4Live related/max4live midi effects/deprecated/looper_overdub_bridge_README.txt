looper_overdub_bridge — a MIDI clip drives a Looper on another track
====================================================================

Signal path on the bridge MIDI track:

    MIDI clip -> [midiin] -> [js looper_overdub_bridge.js] -> Live API -> Looper
                         \-> [midiout]                      (MIDI passes through)

    C0 (note 24)  note-on    ->  Looper record
                  note-off   ->  ignored (Record Length ends the recording)
    C1 (note 36)  note-on    ->  Looper overdub
                  note-off   ->  Looper play
    other notes              ->  ignored

    transport stop           ->  nothing: the Looper keeps its contents
                                 (emptying it: looper_clear_all)

Note names are Live's: middle C (60) is C3, so C0 = 24 and C1 = 36.


THE CYCLE
---------
1. Song stopped: the Looper keeps whatever it held. Empty it with
   looper_clear_all when needed; a C0 recording overwrites it anyway.
2. C0 on a bar line (e.g. 5.1.1). The Looper is unquantized (since
   2026-09-17), so the recording starts when the Record call arrives, a few
   ms after the note. Record Length (fixed, 4 bars) ends it; Looper then
   goes to Play or Overdub as set on the Looper. The C0 note-off does
   nothing.
   A C0 placed before the bar now starts the recording that much early.
   Timing still holds (a fixed-length loop replays everything exactly one
   loop later), but the loop seam leaves the bar line.
3. C1 gestures after the recording has finished: one note from bar N to bar
   N+4 overdubs exactly one pass. The stop is the note-off, so stopping the
   clip early or the transport also ends the overdub.
4. Transport stop: nothing is sent. Removed 2026-09-17 on purpose.

  !! Do not let a C1 note start while the C0 recording is still running.
     Overdub would arrive mid-record and most likely cut it short.

  !! C1 must be ONE note per pass. Two short notes do not work: the first
     note-off switches to Play at once.


BUILD
-----
1. In Live, drop a Max MIDI Effect on the bridge MIDI track, click Edit.
2. Select all (Ctrl+A) and delete everything.
3. Open looper_overdub_bridge.maxpat in a text editor, select all, copy.
4. Click in the empty device patch and paste (Ctrl+V).
5. Check in the inspector:
   - the name field (track): Parameter Mode Enable ON,
     Type = Blob, Parameter Visibility = Stored Only. The field itself
     stores the typed name with the set. SAVE THE SET after typing.
   - Patcher Inspector: Open in Presentation ON.
6. Save as looper_overdub_bridge.amxd IN THIS FOLDER, next to
   looper_overdub_bridge.js.

Replacing an older build: the varnames (nameedit, trackname) are unchanged,
but if the track field comes up empty after the paste, retype the name.


PER INSTANCE
------------
Type the exact name of the Looper track into the "track" field, press Enter.
The status line shows what happened:

    LOOP : bound                 ready
    LOOP : record / overdub /    the last command sent
           play / stop clear
    NOT BOUND : ...              why nothing will be switched

One device per clip track, one name per device.

The lookup is strict:
- exactly one track must have exactly that name (case and spaces count)
- exactly one Looper must sit directly in that track's device chain
  (a Looper inside a rack is not found)


LOOPER SETTINGS THIS RELIES ON
------------------------------
Record Length   fixed, 4 Bars
Quantization    None          (since 2026-09-17; only the clips are
                              quantized. Was 1 Bar with C0 just before
                              the bar, see VERIFIED IN LIVE)
Song Control    None          (otherwise a Looper can start the song)
Tempo Control   Follow song tempo


TESTING WITHOUT A CLIP
----------------------
Unlocked patch: [record] [overdub] [play] [clear] call the Looper directly
([clear] sends stop then clear). [resolve] re-binds.
Everything is logged to the Max Console with prefix LB; send "debug 0" into
the js to silence it.


VERIFIED IN LIVE (2026-09-10)
-----------------------------
- (then) Transport stop cleared the Looper completely; the next C0 recorded
  a fresh 4 bars. The transport clear was removed on 2026-09-17.
- (then, Quantization 1 Bar) C0 just before bar 5 starts the recording
  exactly on bar 5.
- C1 overdub start and the Play at its note-off both land on the bar.

Every Live API call still arrives a few ms after its note (deferred to Live's
main thread). C0 absorbs that by sitting before the bar; in practice C1's
start and stop were on the bar as well.

Background and the Looper behaviour found while building this:
docs/looper-resampling-notes.md, section "Driving the Looper from clips".
