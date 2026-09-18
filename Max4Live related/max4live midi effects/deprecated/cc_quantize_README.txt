cc_quantize — hold selected CCs until the next bar
==================================================

    controller -> [midiin] -> [js cc_quantize.js] -> [midiout] -> rest of chain

A general MIDI Effect. You give it a list of (channel, cc) addresses. Everything
that is not on that list passes through byte for byte, immediately — notes, other
CCs, pitchbend, aftertouch, program change, sysex, realtime, running status. The
ones on the list are accepted whenever you push them, but only fire out when the
next bar starts. Mutes and switches land on the boundary instead of mid-pattern.


BUILD (once)
------------
1. In Live, drop a Max MIDI Effect where you want the quantizing to happen —
   before whatever the CCs are mapped to. Click Edit.
2. Select all (Ctrl+A) and delete the default [midiin] -> [midiout] pair.
3. Open cc_quantize.maxpat in a text editor, select all, copy, and paste into
   the empty Max patch (Ctrl+V).
4. Save as makrobiome_cc_quantize.amxd IN THIS FOLDER, next to cc_quantize.js.


THE LIST
--------
Edit the message box in the patch:

    watchlist 2 9 2 10 2 11 2 12

Pairs of channel and CC number. That example is ch2 CC 9/10/11/12 — the
subs/snrs/hats/perc enables from your routing notes. Channel is 1..16 as Live
shows it; channel 0 means "any channel". The box is banged on device load, so
whatever you type there is the list.

Runtime messages into the js inlet:

    watchlist 2 9 2 10       replace the whole list
    watch 2 13               add one address
    unwatch 2 13             remove one address
    clearlist                watch nothing (device becomes a plain passthrough)
    enable 0 | 1             bypass / engage (what the Quantize toggle sends)
    mode all | last          see below
    bar                      release now (what the metro sends every bar)
    drop                     throw away what is pending instead of releasing it
    dump                     print state to the Max window
    verbose 1                log every hold and release


MODE
----
    mode all   (default) everything queued comes out at the bar, in arrival
               order, with its original value. A press and its release both
               arrive, in sequence — nothing is lost.
    mode last  only the newest value per address survives. Tighter, but if your
               controller sends 127-on-press and 0-on-release, the release wins
               and the push does nothing. Only use this with absolute controls.


BAR LENGTH
----------
The clock is [metro 1n @quantize 1n]. 1n is a whole note = one bar in 4/4.
Change the object's argument for a different grid:

    metro 2n @quantize 2n    half bar
    metro 4n @quantize 4n    every beat

In a meter other than 4/4, 1n is not a bar — set the note value to match.


TRANSPORT STOPPED
-----------------
The bar clock only runs with Live's transport. The device watches live_set
is_playing: while the transport is stopped nothing is held, CCs pass straight
through, and if the transport stops while messages are waiting they are released
immediately rather than stranded.


LIMITS
------
14-bit CC pairs (MSB/LSB) and NRPN/RPN sequences are treated as ordinary
separate CCs. If you list only one half of a pair, the two halves will be split
across the bar line. List both, or neither.
