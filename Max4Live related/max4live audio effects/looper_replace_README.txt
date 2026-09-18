looper_replace — hold a toggle to overdub a Looper that REPLACES instead of adds
===============================================================================

    REPLACE on   ->  Looper overdub
                     return fades out (30 ms)
    (play your replacement)
    REPLACE off  ->  return fades back in (30 ms)
                     then Looper play

An audio effect that sits ON THE RETURN TRACK and mutes that track's own
audio. It replaces the first looper_replace (Feedback faded through
live.remote~), which could not work: Looper takes a Feedback change only from
the next round, even by hand (tested 2026-09-17).


THE ROUTING IT BELONGS TO (A side)
----------------------------------
The melody module's SRC / LOOP / SHAPE idea, plus a return track for the
gate and the short Loopers feeding in:

  Track           Audio From                      Monitor  Audio To
  BASS LOOP 1 A   source track                    In       Sends Only
  BASS LOOP 2 A   BASS LOOP 1 A, Post FX          In       Sends Only
  BASS LOOP 8 A   BASS LOOP 2 A, Post FX          In       BASS SHAPE A
  BASS RET A      BASS LOOP 8 A, Insert-Looper    In       Sends Only
  BASS SHAPE A    BASS RET A, Post FX (or Post    In       bass fx
                  Mixer)
  BASS LOOP 8 A   BASS SHAPE A, Post FX           In       Sends Only

  BASS LOOP 8 A: Feedback 0%, Input -> Output Always.
  looper_replace goes on BASS RET A, name field = BASS LOOP 8 A.

The loop survives each overdub pass because it comes back through the
Looper's track input (BASS RET A -> BASS SHAPE A -> BASS LOOP 8 A), exactly
as LOOP gets SHAPE in the melody module. So:

    overdub, return open    = layer   (loop + what you play)
    overdub, return muted   = replace (only what you play)
    play                    = nothing is written

The gain is inside BASS RET A's device chain, so it reaches BASS SHAPE A
whether that track taps BASS RET A Post FX or Post Mixer. BASS RET A's own
mute and fader are not touched; with a Post Mixer tap, keep its fader at
0 dB and pan centred, because they sit inside the loop.

Why not return through Insert-Looper as Audio To (the manual's Feedback
Routing): at Feedback 0 what comes back that way is not kept (tested
2026-09-17).


THE FADE
--------
[line~] -> two [*~] on the device's own L/R audio. Signal rate, no Live
parameter moved, no undo steps.

- 30 ms both ways: FADE_MS in the js. Play comes 20 ms after the fade back
  ends, so the loop is fully back in the Looper's input before writing
  stops.
- "return" on the device shows the gain (1 open, 0 muted), sampled every
  20 ms.
- Pressing REPLACE again during the fade back turns the fade around from
  where it is; the Looper stays in Overdub.
- Releasing REPLACE always ends in Play, also if the Looper was already
  overdubbing (a C1 gesture) before the press.
- At load the return is opened ([loadmess 1], and again by the js) and a
  toggle saved as "on" is turned off without doing anything. A press while
  the device is not bound does nothing, and neither does the release.
- Device switched off = audio passes = return open.


BUILD
-----
1. In Live, drop a Max AUDIO Effect on BASS RET A, click Edit.
2. Select all (Ctrl+A) and delete everything.
3. Open looper_replace.maxpat in a text editor, select all, copy.
4. Click in the empty device patch and paste (Ctrl+V).
5. Check in the inspector:
   - the name field (looper): Parameter Mode Enable ON, Type = Blob,
     Parameter Visibility = Stored Only. SAVE THE SET after typing.
   - the REPLACE toggle: Parameter Mode Enable ON.
   - Patcher Inspector: Open in Presentation ON.
6. Save as looper_replace.amxd IN THIS FOLDER, next to looper_replace.js.
7. MIDI-map the REPLACE toggle (on = press, off = release).

The js does not reload itself (autowatch 0). After replacing the js, reload
the device (save the Live set, or reopen it).


PER INSTANCE
------------
Type the exact Looper track name into "looper" (BASS LOOP 8 A), press Enter.

    BASS LOOP 8 A : bound                     ready
    BASS LOOP 8 A : overdub, return muted     REPLACE went on
    BASS LOOP 8 A : return open               REPLACE went off
    BASS LOOP 8 A : play                      fade back done
    NOT BOUND : ...                           why nothing will happen

Lookup is the same as looper_bridge: exactly one track with exactly
that name, exactly one Looper directly in its device chain.


TESTING WITHOUT MAPPING
-----------------------
Unlocked patch: [toggle 1] / [toggle 0] act like the button, [resolve]
re-binds. Everything is logged to the Max Console with prefix LR; send
"debug 0" into the js to silence it.

Checked outside Live with a mock Live API (2026-09-17): load opens the
return and resets the toggle; press = overdub + fade out; release = fade in,
then play; a press during the fade back turns it around; unbound = nothing.


TO TEST IN LIVE
---------------
- Hold REPLACE over one bar while playing: next round, that bar has only the
  new part; the rest is unchanged.
- No click at the edges of the replaced part. If there is one, raise
  FADE_MS.
- Hold REPLACE without playing: that stretch is silent next round.
