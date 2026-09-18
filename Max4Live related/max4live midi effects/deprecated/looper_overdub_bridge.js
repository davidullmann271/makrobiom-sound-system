// looper_overdub_bridge.js — a MIDI clip drives a Looper on another track
//
// C0 (note 24)  note-on   -> LooperDevice.record
//               note-off  -> ignored: Record Length ends the recording itself
// C1 (note 36)  note-on   -> LooperDevice.overdub
//               note-off  -> LooperDevice.play
// every other note          ignored (still passed through by [midiout])
//
// Transport stop does nothing: the Looper keeps its contents. Clearing is
// looper_clear_all's job.
//
// Note names are Live's: middle C (60) is C3, so C0 = 24 and C1 = 36.
//
// The target track is the name typed into the device (textedit "nameedit",
// stored with the set by its own Parameter Mode, Blob). It is a lookup, not a search:
// exactly one track must carry that exact name, and exactly one Looper must sit
// directly in its device chain. Anything else binds nothing and says why.
//
// Input is raw bytes from [midiin]. The status byte is read here rather than
// through [midiparse], whose refpage does not say how it reports 0x80 note-offs.
// Both spellings of note-off in the MIDI spec (0x80, and 0x90 with velocity 0)
// are note-offs; that is the spec, not a fallback.
//
// Timing: the Live API is always deferred to Live's main thread (live.object
// refpage), so running this in js adds nothing over a native [live.object].

// No autowatch: a reload while the device runs resets `ready`, and
// live.thisdevice does not bang again, so every input would be ignored as
// "device not ready" (seen 2026-09-17). The script loads with the device.
autowatch = 0;
inlets    = 1;
outlets   = 1;   // 0 = status line for the device face and the Max window

var NOTE_RECORD  = 24;           // C0
var NOTE_OVERDUB = 36;           // C1

var TEXTEDIT = "nameedit";       // varname of the textedit on the device face
var LOOPER   = "LooperDevice";   // LOM class, matched against LiveAPI .type
var DEBUG    = 1;                // 1 = log every action; "debug 0" to silence

var ready     = 0;               // Live API usable only after live.thisdevice
var trackName = "";
var looperId  = 0;

var status = 0;                  // current MIDI status byte, 0 = none
var data   = [];                 // data bytes collected for that status

function dummy() {}

// ---- inputs -------------------------------------------------------------

// live.thisdevice -> deferlow. Bangs on load, on set save and on preset load.
// Only re-binds; never calls the Looper.
function bang() {
    ready = 1;
    readname();
    resolve();
}

// textedit Enter and its parameter restore both arrive here. The name is read back
// from the textedit itself, so its output format does not matter.
function readname() {
    var obj = this.patcher.getnamed(TEXTEDIT);
    if (!obj) { report("NOT BOUND", "no textedit named " + TEXTEDIT); return; }

    var v  = obj.getvalueof();
    var nm = (v instanceof Array) ? v.join(" ") : String(v);
    nm = nm.replace(/^\s+|\s+$/g, "");

    if (nm === trackName) return;
    trackName = nm;
    if (ready) resolve();
}

function record()  { act(["record"]); }        // manual test boxes
function overdub() { act(["overdub"]); }
function play()    { act(["play"]); }
function clear()   { act(["stop", "clear"]); }
function debug(d)  { DEBUG = (d | 0) ? 1 : 0; post("LB debug", DEBUG, "\n"); }

// raw MIDI, one byte at a time
function msg_int(b) {
    if (b >= 0xF8) return;                  // realtime: leaves running status alone
    if (b >= 0xF0) { status = 0; data = []; return; }   // sysex / system common
    if (b >= 0x80) { status = b; data = []; return; }
    if (!status) return;                    // data byte with no status to own it

    data.push(b);
    var hi   = status & 0xF0;
    var need = (hi === 0xC0 || hi === 0xD0) ? 1 : 2;
    if (data.length < need) return;

    var d = data;
    data = [];                              // running status: status is kept

    if (hi !== 0x80 && hi !== 0x90) return;
    var on = (hi === 0x90 && d[1] > 0);
    note(d[0], on);
}

function note(pitch, on) {
    if (pitch === NOTE_RECORD) {
        if (DEBUG) post("LB C0", on ? "on" : "off", "\n");
        if (on) act(["record"]);
    } else if (pitch === NOTE_OVERDUB) {
        if (DEBUG) post("LB C1", on ? "on" : "off", "\n");
        act([on ? "overdub" : "play"]);
    } else if (DEBUG && on) {
        post("LB note", pitch, "ignored\n");
    }
}

function anything() {
    if (DEBUG) post("LB rx unhandled:", messagename, arrayfromargs(arguments).join(" "), "\n");
}

// ---- the work -----------------------------------------------------------

// Calls each Looper function in order.
function act(fns) {
    var what = fns.join(" ");
    if (!ready) { post("LB", what, "ignored: device not ready\n"); return; }

    // The cached id dies if the Looper or its track is deleted. Re-resolving
    // uses the same exact-name rule, so it cannot bind anything looser.
    if (!looperId || new LiveAPI(dummy, "id " + looperId).id == 0) resolve();
    if (!looperId) { post("LB", what, "ignored: not bound\n"); return; }

    var looper = new LiveAPI(dummy, "id " + looperId);
    for (var i = 0; i < fns.length; i++) looper.call(fns[i]);
    report(trackName, what);
}

function resolve() {
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
    if (DEBUG) post("LB bound |", tpath, "| id", looperId, "\n");
}

function report(head, what) {
    var line = head + " : " + what;
    post("LB", line, "\n");
    outlet(0, line.split(" "));
}
