note_gate — MIDI passthrough note gate
======================================

Signal path on the DRMCTRL-style track:

    fixed clip (row 1) -> [midiin] -> [midiparse] -> gate -> [midiformat] -> [midiout]

The note stream is all native objects. js is NOT in it. Max's js object runs
only in the low-priority thread and is documented as unsuitable for timing-
sensitive events; the earlier build ran a byte-level MIDI parser in js, which
put every drum hit on that thread and made the pattern drift under load.

Everything that is not a note passes straight through [midiparse] into the
matching [midiformat] inlet (CC, pitchbend, aftertouch, poly pressure, program
change, channel). Note-ons are looked up in [table pitchallow], a 128-entry
0/1 map: if the pitch's group is muted, the note-on is dropped. The clip keeps
playing, that drum just goes silent — MIDI muted, not audio muted.

Note-offs pass unconditionally. That is what makes hung notes structurally
impossible: mute a group mid-note and the clip's own note-off still gets
through. A note-off for a note that never sounded is a no-op downstream, so no
held-note bookkeeping is needed anywhere.

NOT passed, unlike the old js build: sysex and realtime bytes. [midiparse] does
not carry them. Live does not send either into a MIDI effect's chain, so this
costs nothing here — but do not reuse this patch for hardware passthrough.

note_gate_ctrl.js holds the group/pitch map and the bar-line logic, and does
one thing: write 0/1 into the table. That runs on load and on a toggle push,
never per note, so low priority is fine for it.

A group change always waits for a grid boundary before it takes effect, so
mutes land on the boundary instead of mid-pattern. The Live parameter itself
still flips the instant you push the CC — the toggle shows what is coming, the
audible change follows at the bar. Push it back before the bar arrives and the
change is simply cancelled. The only exception is a stopped transport: with no
bar to wait for, changes are immediate.


BUILD (once)
------------
1. In Live, drop a Max MIDI Effect on the DRMCTRL track, click Edit.
2. In the Max editor: select all (Ctrl+A) and delete the default
   [midiin] -> [midiout] pair.
3. Open note_gate.maxpat in a text editor, select all, copy.
4. Click in the empty Max device patch and paste (Ctrl+V). Max builds the
   objects and connections from the clipboard JSON.
5. Save the device as makrobiome_note_gate.amxd IN THIS FOLDER, so it sits
   next to note_gate_ctrl.js (same arrangement as your other devices).
6. The 4 live.toggles show up as device parameters "subs", "snrs", "hats",
   "perc" — MIDI-map them to ch2 CC 9, 10, 11, 12 per your routing notes.
   Both controllers feed the same four instrument groups, so four is all the
   device needs no matter how many sources are playing into it.

If the paste ever misbehaves, the note path rebuilds by hand like this:

    [midiin] -> [midiparse]
      outlets 1..6 -> [midiformat] inlets 1..6      (everything but notes)
      outlet 0 -> [unpack 0 0]
          velocity (right, fires first) -> [t i i]
              right -> [== 0] -> right inlet of [||]
              left  -> right (cold) inlet of [pack 0 0]
          pitch (left, fires second) -> [t i i]
              right -> [table pitchallow 128] -> left (hot) inlet of [||]
                       [||] -> left inlet of [gate]       (control, set first)
              left  -> left (hot) inlet of [pack 0 0] -> right inlet of [gate]
      [gate] -> [midiformat] -> [midiout]

The [||] is the whole rule: pass if the pitch is allowed OR it is a note-off.

Control side: 4 [live.toggle] each into a message box "group N $1" into
[js note_gate_ctrl.js]; [live.thisdevice] -> [t b b b] with the right outlet
sending "initlive" and the middle outlet banging every live.toggle so saved
states are re-sent on load. Each toggle goes through [t i i]: the right outlet
sends "group N $1" into the js first, then the left outlet goes to [sel 0 1],
which arms one of two shared one-shots -- [delay 0 @quantize 4n] -> "beat" for a
mute, [delay 0 @quantize 1n] -> "bar" for an un-mute. There is no free-running
clock. The js left outlet goes to
[table pitchallow]; its right outlet goes to [midiformat] inlet 2 (panic only).


SETTING WHICH NOTES EACH GROUP OWNS
-----------------------------------
Edit the GROUPS table at the top of note_gate_ctrl.js. A number is one pitch,
a [lo, hi] pair is an inclusive range:

    var GROUPS = [
        [[36, 39]],        // group 1
        [40, 42, 46],      // group 2 — individual pitches
        ...
    ];

Group order is fixed by the table: 1 = subs, 2 = snrs, 3 = hats, 4 = perc,
matching the toggle names and CC 9-12. The shipped map is the drumcomputer
layout from biome_drums_concept_v4_notes.txt:

    subs 36 37
    snrs 38 39 44 45
    hats 40 41 46 47
    perc 42 43 48 49 50 51

A pitch claimed by two groups belongs to the later one.
Save the .js and the device reloads it (autowatch).

You can also set them at runtime by sending these into the js inlet:

    setgroup 2 40 42 46      replace group 2's pitches
    setrange 3 44 47         group 3 = pitches 44..47 inclusive
    cleargroup 5             group 5 owns nothing
    group 4 0                mute group 4   (what the toggles send)
    toggle 4                 flip group 4
    bar                      apply queued UN-mutes now (what the 1n delay sends)
    beat                     apply queued mutes now (what the 4n delay sends)
    passungrouped 0          mute every pitch that is in no group (default: 1, play)
    panic                    all-notes-off downstream (CC 123). No held-note state
                             to clear — note-offs always pass, nothing hangs.
    dump                     print the current map and states to the Max window
    verbose 1                log every group change

Runtime changes are not saved with the set — only the toggle states are.
Anything you want permanent goes in the GROUPS table.


BAR LENGTH AND TRANSPORT
------------------------
The two directions use different grids, each armed by the toggle push itself:

    muting   (group -> 0)   [delay 0 @quantize 4n]   next beat
    unmuting (group -> 1)   [delay 0 @quantize 1n]   next bar line

Dropping a part is responsive; bringing it back lands on the downbeat. 1n is a
whole note = one bar in 4/4 and 4n is a quarter = one beat; change either
attribute for a different grid or to match a meter other than 4/4.

This is deliberately a one-shot and not a metro. A [metro 1n @quantize 1n]
started once at device load free-runs with a phase set by the moment the device
finished loading, so its "bar line" sat on an arbitrary beat -- consistent for a
given load, but landing on beat 2, 3 or 4 as often as beat 1. quantize nudges an
already-scheduled bang; it does not re-derive the phase from Live each cycle.
Arming a fresh one-shot on every push removes the persistent phase entirely, so
there is nothing left to drift.

The wait cannot be switched
off — it is how the device works. The one automatic exception is a stopped
transport: the device watches live_set is_playing, and while stopped, group
changes are immediate. If the transport stops with a change waiting, it is
applied at once rather than stranded.


PUTTING IT ON ALL FIVE DRMCTRL TRACKS
-------------------------------------
Yes — one instance per DRMCTRL track (1, 2, 4, 8, 16). Each keeps its own toggle
states, and they all read the same transport, so every instance releases on the
same bar line. Cost is one delay object and a table lookup per note: nothing measurable.

Note that a CC mapped to a device parameter is consumed by Live's remote map and
never reaches the track's MIDI chain, which is why the bar-sync lives here, on
the parameter, rather than in a separate CC-delaying device upstream.


CHANGED IN THIS BUILD
---------------------
The note stream moved out of js into native objects (see the top of this file).
Two things fell out of that:

* The bar-line quantization documented above was never actually running. The
  old note_gate.js had no bar() and no applyPending(), so the "bar" message
  from the metro hit a nonexistent function — group changes applied instantly
  instead of on the boundary, and every bar line posted an error to the Max
  Console, on the same thread the notes were being parsed on. Both fixed:
  note_gate_ctrl.js implements bar() and applyPending() properly.

* The metro itself is gone (see BAR LENGTH AND TRANSPORT). It was started once
  by [live.thisdevice] and never re-anchored to transport start, so mutes landed
  on a beat determined by device-load time rather than on the bar line.

* Held-note tracking, flushGroup() and the per-channel held[][] arrays are gone.
  They existed only because the old build swallowed note-offs. It does not
  anymore, so they have nothing left to do.

The old note_gate.js has been moved to deprecated/. It is not loaded by the
patch (which instantiates note_gate_ctrl.js) and it calls an applyPending() that
does not exist in that file. The previous patcher is saved as
note_gate_jsversion.maxpat.bak, in case you want to compare or revert.
