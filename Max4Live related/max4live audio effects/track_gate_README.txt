track_gate — one button, switches the track's sound on the bar
==============================================================

A generic Max AUDIO Effect. Drop it on any audio track; it has a single
parameter, "On". Push it and the change takes effect at the next bar line, not
under your finger — same timing behaviour as note_gate on the MIDI side.

    [plugin~] -> [*~] -> [plugout~]      with the gain switched at the bar

Meant for the recorded/save audio tracks, but it is track-generic: nothing in it
refers to a track name, an index, or a device on the track. Put it on as many
tracks as you like, each keeps its own On state.


BUILD (once)
------------
1. In Live, drop a Max Audio Effect on the track, at the END of the chain (it
   gates whatever reaches it, so anything after it is not affected). Click Edit.
2. Select all (Ctrl+A) and delete the default [plugin~] -> [plugout~] pair.
3. Open track_gate.maxpat in a text editor, select all, copy, and paste into
   the empty Max patch (Ctrl+V).
4. Save as makrobiome_track_gate.amxd. No .js file to keep beside it — this one
   is pure Max.
5. Ctrl+M and map the "On" parameter to whatever button you want.


HOW IT WORKS
------------
The live.toggle goes through [t i i]. The right outlet fires first and drops the
value into the COLD (right) inlet of [int], so the push is only stored. The left
outlet carries the same value on to [gate 2] and then [sel 0 1], which arms one
of two one-shots: [delay 0 @quantize 4n] when you switched the track OFF, or
[delay 0 @quantize 1n] when you switched it ON. Either one bangs the hot inlet
and releases the stored value through [change] (so an unchanged state
does not retrigger) into [pack 0. 10] -> [line~]. The 10 ms ramp is what keeps
the switch from clicking. Raise it in the pack object if you want a softer
transition.

Push it twice before the bar arrives and only the final state is used — the
stored value is simply overwritten, and the delay is just re-armed to the same
bar line. Nothing queues up.


BAR LENGTH
----------
    switching OFF   [delay 0 @quantize 4n]   next beat
    switching ON    [delay 0 @quantize 1n]   next bar line

Killing the track is responsive; bringing it back lands on the downbeat. 1n is a
whole note = one bar in 4/4, 4n is a quarter = one beat. Change either attribute
for a different grid or to match another meter.

It is a one-shot armed by the push, not a metro. A [metro 1n @quantize 1n]
started at device load free-runs with a phase fixed by the moment the device
loaded, so its "bar line" sat on an arbitrary beat — stable within one load, but
landing on beat 2, 3 or 4 as often as beat 1. Arming a fresh one-shot per push
leaves no persistent phase to drift.


TRANSPORT STOPPED
-----------------
[live.path live_set] -> [live.observer @property is_playing] feeds [+ 1] into
the control inlet of [gate 2]. Stopped routes the push out outlet 0, straight to
the hot inlet of [int], so the button acts immediately — there is no bar coming
to wait for. Playing routes it out outlet 1 into [sel 0 1] and on to the matching delay. [sel 0] additionally
bangs the [int] when the transport stops, so a change left waiting is applied
rather than stranded, and sends "stop" to both delays so a bang cannot arrive late
from a bar that never came.

On device load, [live.thisdevice] restores the saved toggle state and pushes it
straight to the gain before the clock starts, so a track saved in the "On" state
is audible immediately rather than silent until the first bar.
