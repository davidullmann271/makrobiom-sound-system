// LoopCeiling.js — global loop-length ceiling for DRMCTRL / SMPLCTRL tracks
//
// Track name encodes the clip's natural length in beats:
//   "DRMCTRL 1"  -> 1 beat      "DRMCTRL 8"   -> 2 bars
//   "SMPLCTRL 4" -> 1 bar       "SMPLCTRL 16" -> 4 bars
//
// Ceiling L is applied as:  loop_end = loop_start + min(natural, L)
// Setting L back to 16 restores every clip to its natural length.
// Stateless: nothing is cached, so nothing can go stale.
//
// Control input is hardcoded to CC 43, values 0..4 (channel is not filtered:
// Live normalises track input to channel 1, so the radio.s channel 2 is lost).
// Requires TWO cables from midiparse:
//   outlet 3 (control) -> deferlow -> js
//   outlet 7 (channel) -> prepend chan -> js
// midiparse fires right-to-left, so the channel always arrives before the
// control pair it belongs to.

autowatch = 1;
inlets    = 1;
outlets   = 2;   // 0 = status, 1 = selected index (UI sync)

var NAME_RE = /^(?:DRMCTRL|SMPLCTRL)\s+(\d+)\s*$/i;
var STEPS   = [1, 2, 4, 8, 16];   // beats: 1beat, 2beat, 1bar, 2bar, 4bar

var CHANNEL = 1;                  // informational only - Live rewrites input to ch 1
var CC      = 43;                 // CC number of the TouchOSC radio
var DEBUG   = 1;                  // 1 = log to Max window; "debug 0" to silence

var lastChan = -1;                // channel of the message currently arriving
var current  = STEPS.length - 1;  // ceiling index, starts unrestricted

function dummy() {}

// ---- inputs -------------------------------------------------------------

// live.thisdevice bangs on device load, on set save, and on preset load.
// It must NOT re-apply: script globals reset on recompile, so "current" would
// be back at 4 and would silently blow the ceiling open to 16 beats.
// Clip loop_end is saved with the set, so doing nothing on load is correct.
function bang() {
    post("LC ready | channel", CHANNEL, "| cc", CC, "| load does not re-apply\n");
}

function refresh()  { post("LC refresh\n"); applyIndex(current); }
function msg_int(i) { applyIndex(i); }          // message boxes 0..4
function step(i)    { applyIndex(i); }
function debug(d)   { DEBUG = (d | 0) ? 1 : 0; post("LC debug", DEBUG, "\n"); }

// from: midiparse outlet 7 -> prepend chan
function chan(c) { lastChan = c | 0; }

// from: midiparse outlet 3 (control) -> deferlow.
// Order is (controller number, controller value) per the midiparse refpage.
function list() {
    var a = arrayfromargs(arguments);
    if (a.length < 2) return;

    var controller = a[0] | 0;
    var value      = a[1] | 0;

    if (DEBUG) {
        post("LC rx | channel", lastChan, "| cc", controller, "| value", value, "\n");
    }

    // NOTE: no channel filter. Live normalises incoming MIDI to channel 1 when
    // a track input is set to All Channels, so the radio's channel 2 never
    // survives to the device chain. lastChan is logged for information only.
    if (controller !== CC) {
        if (DEBUG) post("LC  -> ignored: cc", controller, "is not", CC, "\n");
        return;
    }
    if (value < 0 || value >= STEPS.length) {
        if (DEBUG) post("LC  -> ignored: value", value, "outside 0..4\n");
        return;
    }

    applyIndex(value);
}

// catches any message type not handled above
function anything() {
    if (DEBUG) post("LC rx unhandled:", messagename, arrayfromargs(arguments).join(" "), "\n");
}

function applyIndex(i) {
    i = Math.max(0, Math.min(STEPS.length - 1, Math.round(i)));
    current = i;
    outlet(1, i);
    apply(STEPS[i]);
}

// ---- the work -----------------------------------------------------------

function apply(L) {
    var song = new LiveAPI(dummy, "live_set");
    var nTracks = song.getcount("tracks");

    var t  = new LiveAPI(dummy);
    var cs = new LiveAPI(dummy);
    var cl = new LiveAPI(dummy);

    var matched = 0, touched = 0;

    for (var i = 0; i < nTracks; i++) {
        t.path = "live_set tracks " + i;

        // LiveAPI can return a multi-atom name; join puts it back together
        var raw = t.get("name");
        var nm  = (raw instanceof Array) ? raw.join(" ") : String(raw);

        var m = NAME_RE.exec(nm);
        if (!m) continue;                     // untagged track: leave alone
        matched++;

        var natural = parseInt(m[1], 10);
        var target  = Math.min(natural, L);
        var nSlots  = t.getcount("clip_slots");

        for (var j = 0; j < nSlots; j++) {
            cs.path = "live_set tracks " + i + " clip_slots " + j;
            if (!parseInt(cs.get("has_clip"), 10)) continue;

            cl.path = "live_set tracks " + i + " clip_slots " + j + " clip";
            if (!cl.id || cl.id == 0) continue;

            // loop_start/loop_end only mean anything while looping is on
            cl.set("looping", 1);

            var ls = parseFloat(cl.get("loop_start"));
            var sm = parseFloat(cl.get("start_marker"));
            var newEnd = ls + target;

            // a start marker past the new loop end would fight the shrink
            if (sm > newEnd) cl.set("start_marker", ls);

            cl.set("loop_end", newEnd);
            touched++;
        }
    }

    if (DEBUG) post("LC applied | ceiling", L, "beats | tracks", matched, "| clips", touched, "\n");
    outlet(0, ["ceiling", L, "tracks", matched, "clips", touched]);
}
