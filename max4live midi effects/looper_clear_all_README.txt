looper_clear_all — one button empties every named Looper
========================================================

    [CLEAR ALL] press  ->  every Looper named in the 8 fields:
                           stop at once, clear 100 ms later

The button is a live.text in Button mode with Parameter Mode on ("clear
all"), so it can be MIDI-mapped. Button mode sends a bang on a press
(live.text refpage).

Stop comes first: Clear in Overdub keeps the length and tempo, Clear in any
other mode resets them (Live manual, Looper). The clear waits 100 ms
(CLEAR_DELAY in the js) because stop and clear back to back left an
overdubbing Looper stopped but not cleared (bass short Loopers, 2026-09-17).
The status shows "stopped", then "cleared".

Stopping the song clears nothing. looper_bridge does not clear on transport
stop (its predecessors did until 2026-09-17); this button is the only full
reset.

MIDI passes straight through ([midiin] -> [midiout]), so the device can sit on
any MIDI track, e.g. a control track, without changing what it plays.


FIELDS
------
Eight name fields, numbered 1-8. Type the exact track name of a Looper track,
press Enter. An empty field is unused. The status beside each field:

    bound                     ready
    cleared                   the last press reached it
    NOT BOUND no such track   no track has exactly that name
    NOT BOUND 2 tracks        more than one track has that name
    NOT BOUND no Looper       the track has no Looper in its chain
    NOT BOUND 2 Loopers       the track has more than one
    -                         field empty, unused

Lookup is the same as looper_bridge: exactly one track with exactly
that name, exactly one Looper directly in its device chain (not in a rack).
A field that is not bound is skipped on a press; the other Loopers are still
cleared.

The current set has two melody LOOP tracks and six bass Loopers (1/2/4 bar,
sides A and B), which is why there are eight fields.


BUILD
-----
1. In Live, drop a Max MIDI Effect on a MIDI track, click Edit.
2. Select all (Ctrl+A) and delete everything.
3. Open looper_clear_all.maxpat in a text editor, select all, copy.
4. Click in the empty device patch and paste (Ctrl+V).
5. Check in the inspector:
   - the name field (1-8): Parameter Mode Enable ON,
     Type = Blob, Parameter Visibility = Stored Only. The field itself
     stores the typed name with the set. SAVE THE SET after typing.
   - The CLEAR ALL button: Parameter Mode Enable ON, Mode = Button.
   - Patcher Inspector: Open in Presentation ON.
6. Save as looper_clear_all.amxd IN THIS FOLDER, next to
   looper_clear_all.js.
7. MIDI-map the CLEAR ALL button (MIDI Map Mode, click it, send the control).


TESTING
-------
Unlocked patch: [clearall] does what the button does, [resolve] re-binds all
eight fields. Everything is logged to the Max Console with prefix LCA; send
"debug 0" into the js to silence it.

Checked outside Live with a mock Live API (2026-09-17): three named Loopers
got stop, then clear 100 ms later, a name with no matching track was skipped and reported,
empty fields were ignored.


TO TEST IN LIVE
---------------
- A MIDI-mapped press clears once. If the mapping also fires on release,
  the Loopers get cleared twice, which does no harm.
- A Looper in Overdub is empty after the press (length reset too).
