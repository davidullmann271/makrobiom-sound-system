// looper_replace.js — hold a toggle to overdub a Looper with its return muted
//
// Sits as an audio effect on the RETURN track (e.g. BASS RET A: Audio From
// BASS LOOP 8 A / Insert-Looper). The device mutes that track's own audio, so
// the loop stops coming back into the Looper's input while you play.
//
// toggle on   -> LooperDevice.overdub
//                return gain 1 -> 0 over FADE_MS
// toggle off  -> return gain 0 -> 1 over FADE_MS
//                then LooperDevice.play
//
// With Feedback 0% and the loop returning through the track input (the
// SRC / LOOP / SHAPE topology), overdub with the return open layers, overdub
// with the return muted replaces. The gain is a [line~] into two [*~] in the
// device's own audio path, so the fade is signal-rate and touches no Live
// parameter: no undo steps, and the track's fader and mute stay the user's.
//
// The Looper is the name typed into the device (textedit "nameedit", stored
// with the set by its own Parameter Mode, Blob). Lookup as in
// looper_bridge: exactly one track with exactly that name, exactly one
// Looper directly in its device chain.

// No autowatch: a reload while the device runs resets `ready`, and
// live.thisdevice does not bang again, so every input would be ignored as
// "device not ready" (seen 2026-09-17). The script loads with the device.
autowatch = 0;
inlets    = 1;
outlets   = 2;   // 0 = status line, 1 = [line~] (return gain)

var FADE_MS  = 30;               // fade length, both directions
var LOOPER   = "LooperDevice";   // LOM class, matched against LiveAPI .type
var TOGGLE   = "replace";        // varname of the live.toggle
var TEXTEDIT = "nameedit";       // varname of the name field
var DEBUG    = 1;                // 1 = log every action; "debug 0" to silence

var ready     = 0;               // Live API usable only after live.thisdevice
var trackName = "";
var looperId  = 0;
var on        = 0;               // last toggle state acted on
var active    = 0;               // 1 from a real start until the fade back ends
var pending   = null;            // Task: play after the fade back

function dummy() {}

// ---- inputs -------------------------------------------------------------

// live.thisdevice -> deferlow. Bangs on load, on set save and on preset load.
// Never calls the Looper. On the first bang: a toggle restored as "on" is set
// back to off without output, and the return is opened, so loading a set
// never starts an overdub or leaves the loop muted.
function bang() {
    var first = !ready;
    ready = 1;
    if (first) {
        var tg = this.patcher.getnamed(TOGGLE);
        if (tg) tg.message("set", 0);
        outlet(1, 1);
    }
    readname();
    bind();
}

// textedit Enter and its parameter restore both arrive here.
function readname() {
    var obj = this.patcher.getnamed(TEXTEDIT);
    if (!obj) { report("NOT BOUND", "no textedit named " + TEXTEDIT); return; }

    var v  = obj.getvalueof();
    var nm = (v instanceof Array) ? v.join(" ") : String(v);
    nm = nm.replace(/^\s+|\s+$/g, "");

    if (nm === trackName) return;
    trackName = nm;
    if (ready) bind();
}

// live.toggle -> prepend toggle
function toggle(v) {
    var want = (v | 0) ? 1 : 0;
    if (!ready) { post("LR toggle", want, "ignored: device not ready\n"); return; }
    if (want === on) return;
    on = want;
    if (on) start(); else finish();
}

function resolve() { bind(); }
function debug(d)  { DEBUG = (d | 0) ? 1 : 0; post("LR debug", DEBUG, "\n"); }

function anything() {
    if (DEBUG) post("LR rx unhandled:", messagename, arrayfromargs(arguments).join(" "), "\n");
}

// ---- the work -----------------------------------------------------------

function start() {
    // Pressed again during the fade back: the Looper is still overdubbing,
    // so the fade just turns around from wherever it is.
    var midFade = (pending !== null);
    if (midFade) { pending.cancel(); pending = null; }
    if (!check()) return;

    active = 1;
    if (!midFade) new LiveAPI(dummy, "id " + looperId).call("overdub");
    outlet(1, 0, FADE_MS);               // return fades out
    report(trackName, "overdub, return muted");
}

function finish() {
    if (!active) return;                 // the press did nothing, so neither does this

    outlet(1, 1, FADE_MS);               // return fades back in
    report(trackName, "return open");

    // Task runs in the low-priority thread (Task reference), where Live API
    // calls belong. Play comes after the fade, so the loop is fully back in
    // the Looper's input before writing stops.
    pending = new Task(function () {
        pending = null;
        active = 0;
        if (!check()) return;
        new LiveAPI(dummy, "id " + looperId).call("play");
        report(trackName, "play");
    }, this);
    pending.schedule(FADE_MS + 20);
}

// Bound and still alive. The cached id dies if the Looper or its track is
// deleted; re-resolving uses the same exact-name rule.
function check() {
    if (!looperId || new LiveAPI(dummy, "id " + looperId).id == 0) bind();
    if (!looperId) { post("LR ignored: not bound\n"); return 0; }
    return 1;
}

function bind() {
    looperId = 0;
    if (!ready) return;
    if (!trackName) { report("NOT BOUND", "type a track name"); return; }

    var song = new LiveAPI(dummy, "live_set");
    var nTracks = song.getcount("tracks");
    var t = new LiveAPI(dummy);

    var hits = [];
    for (var i = 0; i < nTracks; i++) {
        t.path = "live_set tracks " + i;
        var raw = t.get("name");            // multi-atom for names with spaces
        var nm  = (raw instanceof Array) ? raw.join(" ") : String(raw);
        if (nm === trackName) hits.push(i);
    }
    if (hits.length === 0) { report("NOT BOUND", "no track named " + trackName); return; }
    if (hits.length > 1)   { report("NOT BOUND", hits.length + " tracks named " + trackName); return; }

    var tpath = "live_set tracks " + hits[0];
    t.path = tpath;
    var nDev = t.getcount("devices");
    var d = new LiveAPI(dummy);

    var found = [];
    for (var j = 0; j < nDev; j++) {
        d.path = tpath + " devices " + j;
        if (d.type === LOOPER) found.push(d.id);
    }
    if (found.length === 0) { report("NOT BOUND", trackName + " has no Looper"); return; }
    if (found.length > 1)   { report("NOT BOUND", trackName + " has " + found.length + " Loopers"); return; }

    looperId = found[0];
    report(trackName, "bound");
    if (DEBUG) post("LR bound |", tpath, "| id", looperId, "\n");
}

function report(head, what) {
    var line = head + " : " + what;
    post("LR", line, "\n");
    outlet(0, line.split(" "));
}
