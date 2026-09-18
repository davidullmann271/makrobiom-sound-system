monitor_exclusive — five buttons, one track's Monitor In, the others Off
=======================================================================

Five rows: button, track name field, status line. Button N sets the track in
field N to Monitor In and the tracks in the other four fields to Monitor Off.
An empty field is unused (its track, if any, is left alone).

    button N -> [select N] -> [js monitor_exclusive.js] -> Live API
    [midiin] -> [midiout]     (MIDI passes through untouched)

The buttons are live.button parameters (select1 .. select5), so each one is
MIDI-mappable: MIDI Map Mode, click the button, press the pad.

The Live API property is Track.current_monitoring_state: 0 = In, 1 = Auto,
2 = Off; return and master tracks have none (LOM reference). Group tracks have
none either; a track counts as monitorable when its can_be_armed is true.

If button N's own track cannot be found, NOTHING is switched: the other tracks
are not turned Off either, so a typo never silences everything.

Presses that arrive before the device has finished loading are ignored, so a
button's parameter restore on load cannot switch any track.


BUILD
-----
1. In Live, drop a Max MIDI Effect on a MIDI track, click Edit.
2. Select all (Ctrl+A) and delete everything.
3. Open monitor_exclusive.maxpat in a text editor, select all, copy.
4. Click in the empty device patch and paste (Ctrl+V).
5. Check in the inspector:
   - the five name fields: Parameter Mode Enable ON, Type = Blob,
     Parameter Visibility = Stored Only. This is what stores the typed names
     with the set (same mechanism as looper_bridge). SAVE THE SET after
     typing.
   - the five buttons: Parameter Visibility = Automated and Stored (needed
     for MIDI mapping).
   - Patcher Inspector: Open in Presentation ON.
6. Save as monitor_exclusive.amxd IN THIS FOLDER, next to monitor_exclusive.js.

The js does not reload itself (autowatch 0). After replacing the js, reload
the device (save the Live set, or reopen it).


PER INSTANCE
------------
Type the exact track name into each field you use, press Enter. The status
lines show what happened:

    1 BASS LOOP 1 A : found       the name resolves to exactly one track
    1 BASS LOOP 1 A : In          last press set it to In
    2 BASS LOOP 2 A : Off         last press set it to Off
    3 - : unused                  field left empty
    4 NOT BOUND : ...             why this track is not switched

The lookup is strict: exactly one track with exactly that name (case and
spaces count), and it must have a Monitor section. Names are looked up again
on every press, so renaming or moving a track needs no re-bind.


TESTING
-------
Everything is logged to the Max Console with prefix MEX; send "debug 0" into
the js to silence it. Unlocked patch: the [select 1] .. [select 5] message
boxes do what the buttons do.

Checked outside Live with a mock Live API (2026-09-18): press before load is
ignored; button N gives In on its track and Off on every other named track;
an empty field is skipped; a group track, a missing name and a duplicated
name each report NOT BOUND, and a press on such a field switches nothing.
Not yet tested in Live.
