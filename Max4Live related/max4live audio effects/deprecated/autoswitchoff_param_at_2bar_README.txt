autoswitchoff_param_at_2bar — momentary Beat Repeat, released on the phrase line
================================================================================

One button. Push it and Beat Repeat's "Repeat" comes on at the next 16th note,
then switches itself off at the next 2-bar boundary of the song.

    live.button -> [delay 0 @quantize 16n] -> [t b b] -right-> [1(   -> live.remote~
                                                     \-left--> [delay @delaytime 1 ticks
                                                                      @quantize 3840 ticks]
                                                                -> [0( -> live.remote~

Files: autoswitchoff_param_at_2bar.amxd  (the device, edit it in Live)
       autoswitchoff_param_at_2bar.maxpat (same patch as source, to paste/compare)
       autoswitchoff_target.js            (must sit beside the .amxd)


WHAT IT CONTROLS
----------------
DRMAUD (group audio track) -> Beat Repeat -> "Repeat".

The chain on DRMAUD is [effect rack] -> [Limiter] -> [Beat Repeat]; this device
does not have to be in that chain to drive it.

"Repeat" is a toggle: its range is 0..1, so the device sends 1 and 0, not 127.


WHY A .js FOR THE BINDING
-------------------------
The device used to bind with a hardcoded index path:

    goto live_set tracks 10 devices 2 parameters 17

Track indices shift whenever a track is added, deleted or reordered anywhere
above the target, and LiveAPI counts group tracks in that numbering as well.
DRMAUD had moved from index 10 to 21, so the path pointed at an unrelated track.
The message box was not even connected to the loadbang, so nothing bound at all
unless it was clicked by hand.

autoswitchoff_target.js resolves the target by name instead, on device load:

    TRACK_NAME   = "DRMAUD"
    DEVICE_CLASS = "BeatRepeat"     (class_name, so renaming the device is fine)
    PARAM_NAME   = "Repeat"

and sends "id <n>" into the right inlet of [live.remote~]. Those three names are
hardcoded at the top of the file — it is a lookup, not a search. If any of them
does not match, the device binds nothing and says so in the Max Console rather
than silently grabbing a wrong parameter.

Messages to the js:
    bang / bind    resolve again (also happens on live.thisdevice)
    dump           print DRMAUD's whole chain and Beat Repeat's parameter names,
                   for when a name has drifted and you need to see why


TIMING
------
ON:  [delay 0 @quantize 16n] — the next 16th note after the push.

OFF: [delay @delaytime 1 ticks @quantize 3840 ticks]. Max is fixed at 480 ppq, so
     3840 ticks is 2 bars in 4/4, and quantize snaps to that grid measured from
     song position 0 — i.e. the OFF always lands on bar 1, 3, 5, 7... Hold length
     therefore varies from near zero to 2 bars, but the release is always on the
     phrase line.

     The delaytime is 1 tick rather than 0 so that an ON landing exactly on a
     2-bar boundary schedules its OFF at the NEXT boundary, instead of resolving
     to the same instant and producing a zero-length blip. One tick is 1/480 of a
     quarter note.

If your phrases start on even bars, every OFF will be one bar out of phase with
what you hear — the grid is anchored to Live's bar 1.

Transport stopped: [live.observer @property is_playing] -> [sel 0] sends "stop"
to both delays, so a bang cannot arrive late from a bar that never came.


WHAT THIS REPLACED
------------------
[metro 8n] (started by loadbang, no quantize) -> [counter 1 8] -> [sel 1].

The metro free-ran with a phase set by whenever the device finished loading, and
the counter was never reset by the button — so the OFF fired at the next multiple
of 8 eighth-notes since the metro started, not 2 bars after the ON. Hold time
varied from almost nothing to 2 bars depending purely on when you pressed.
