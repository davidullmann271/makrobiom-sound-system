// bass_looper_bridge.js — a MIDI clip drives the three bass Loopers of one side
//
// C0  (note 24)  note-on   -> 4-bar Looper: record
//                note-off  -> ignored: Record Length ends the recording
// C1  (note 36)  note-on   -> 4-bar Looper: overdub
//                note-off  -> short Loopers whose note is still held: stop
//                             (clear follows), then 4-bar Looper: play
// C3  (note 60)  note-on   -> 1-bar Looper: record
//                note-off  -> 1-bar Looper: stop, clear CLEAR_DELAY ms later
// C#3 (note 61)  note-on   -> 2-bar Looper: record
//                note-off  -> 2-bar Looper: stop, clear CLEAR_DELAY ms later
// every other note            ignored (still passed through by [midiout])
//
// Transport stop does nothing here: the Loopers keep their contents. Clearing
// them all is looper_clear_all's job.
//
// Note names are Live's: middle C (60) is C3, so C0 = 24 and C1 = 36.
//
// Why the clear is delayed: the short Loopers sit in Overdub when their note
// ends. Stop and Clear sent back to back left them stopped but not cleared
// (seen in Live 2026-09-17). Assumed cause: the Clear still found the Looper in
// Overdub, where Clear keeps the length (manual). The Task gives the Stop time
// to land first. A new record note for that Looper cancels a pending clear;
// Record overwrites the buffer anyway (manual).
//
// Why C1 note-off clears held short Loopers first: at the end of a transfer
// both note-offs fall on the same tick, in an order the clip does not promise.
// The short Looper has to be silent before the 4-bar Looper leaves Overdub,
// or the next repetition's first milliseconds land in the capture.
//
// The target tracks are the names typed into the three fields (textedits
// "name1edit" / "name2edit" / "name4edit", each stored with the set by its own
// Parameter Mode, Blob). Lookup as in
// looper_overdub_bridge: exactly one track with exactly that name, exactly one
// Looper directly in its device chain.
//
// Input is raw bytes from [midiin], parsed as in looper_overdub_bridge.js.

// No autowatch: a reload while the device runs resets `ready`, and
// live.thisdevice does not bang again, so every input would be ignored as
// "device not ready" (seen 2026-09-17). The script loads with the device.
autowatch = 0;
inlets    = 1;
outlets   = 3;   // one status line per slot, same order as SLOTS

var NOTE_RECORD_4  = 24;         // C0
var NOTE_OVERDUB_4 = 36;         // C1
var NOTE_RECORD_1  = 60;         // C3
var NOTE_RECORD_2  = 61;         // C#3

var LOOPER = "LooperDevice";     // LOM class, matched against LiveAPI .type
var DEBUG  = 1;                  // 1 = log every action; "debug 0" to silence
var CLEAR_DELAY = 100;           // ms between stop and clear

var S1 = 0, S2 = 1, S4 = 2;      // slot index = outlet index
var SLOTS = [
    { textedit: "name1edit", label: "1BAR", name: "", id: 0, held: 0, task: null },
    { textedit: "name2edit", label: "2BAR", name: "", id: 0, held: 0, task: null },
    { textedit: "name4edit", label: "4BAR", name: "", id: 0, held: 0, task: null }
];

var ready = 0;                   // Live API usable only after live.thisdevice

var status = 0;                  // current MIDI status byte, 0 = none
var data   = [];                 // data bytes collected for that status

function dummy() {}

// ---- inputs -------------------------------------------------------------

// live.thisdevice -> deferlow. Bangs on load, on set save and on preset load.
// Only re-binds; never calls a Looper.
function bang() {
    ready = 1;
    readnames();
    resolve();
}

// Any textedit's Enter and every parameter restore arrive here. The names are
// read back from the textedits themselves.
function readnames() {
    for (var s = 0; s < SLOTS.length; s++) {
        var slot = SLOTS[s];
        var obj = this.patcher.getnamed(slot.textedit);
        if (!obj) { report(s, "NOT BOUND", "no textedit named " + slot.textedit); continue; }

        var v  = obj.getvalueof();
        var nm = (v instanceof Array) ? v.join(" ") : String(v);
        nm = nm.replace(/^\s+|\s+$/g, "");

        if (nm === slot.name) continue;
        slot.name = nm;
        if (ready) bind(s);
    }
}

// manual test boxes: "rec 1", "clear 4", ... (bar lengths as on the device)
function rec(n)     { var s = slotarg(n); if (s >= 0) { cancelclear(s); act(s, ["record"]); } }
function clear(n)   { var s = slotarg(n); if (s >= 0) stopclear(s); }
function overdub()  { act(S4, ["overdub"]); }
function play()     { act(S4, ["play"]); }
function resolve()  { for (var s = 0; s < SLOTS.length; s++) bind(s); }
function debug(d)   { DEBUG = (d | 0) ? 1 : 0; post("BLB debug", DEBUG, "\n"); }

function slotarg(n) {
    var b = n | 0;
    if (b === 1) return S1;
    if (b === 2) return S2;
    if (b === 4) return S4;
    post("BLB no looper for", n, "\n");
    return -1;
}

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
    if (pitch === NOTE_RECORD_4) {
        if (DEBUG) post("BLB C0", on ? "on" : "off", "\n");
        if (on) { cancelclear(S4); act(S4, ["record"]); }
    } else if (pitch === NOTE_OVERDUB_4) {
        if (DEBUG) post("BLB C1", on ? "on" : "off", "\n");
        if (on) { act(S4, ["overdub"]); return; }
        for (var s = 0; s < SLOTS.length; s++) {
            if (s === S4 || !SLOTS[s].held) continue;
            SLOTS[s].held = 0;
            stopclear(s);
        }
        act(S4, ["play"]);
    } else if (pitch === NOTE_RECORD_1 || pitch === NOTE_RECORD_2) {
        var sl = (pitch === NOTE_RECORD_1) ? S1 : S2;
        if (DEBUG) post("BLB", pitch === NOTE_RECORD_1 ? "C3" : "C#3", on ? "on" : "off", "\n");
        if (on) {
            SLOTS[sl].held = 1;
            cancelclear(sl);
            act(sl, ["record"]);
        } else if (SLOTS[sl].held) {        // not already cleared by C1 note-off
            SLOTS[sl].held = 0;
            stopclear(sl);
        }
    } else if (DEBUG && on) {
        post("BLB note", pitch, "ignored\n");
    }
}

function anything() {
    if (DEBUG) post("BLB rx unhandled:", messagename, arrayfromargs(arguments).join(" "), "\n");
}

// ---- the work -----------------------------------------------------------

// Stop now, clear CLEAR_DELAY ms later. Task runs in the low-priority thread
// (Task reference), where Live API calls belong.
function stopclear(s) {
    cancelclear(s);
    act(s, ["stop"]);
    var slot = SLOTS[s];
    slot.task = new Task(function () {
        slot.task = null;
        act(s, ["clear"]);
    }, this);
    slot.task.schedule(CLEAR_DELAY);
}

function cancelclear(s) {
    var slot = SLOTS[s];
    if (!slot.task) return;
    slot.task.cancel();
    slot.task = null;
    if (DEBUG) post("BLB", slot.label, "pending clear cancelled\n");
}

// Calls each Looper function in order on one slot.
function act(s, fns) {
    var slot = SLOTS[s];
    var what = fns.join(" ");
    if (!ready) { post("BLB", slot.label, what, "ignored: device not ready\n"); return; }

    // The cached id dies if the Looper or its track is deleted. Re-resolving
    // uses the same exact-name rule, so it cannot bind anything looser.
    if (!slot.id || new LiveAPI(dummy, "id " + slot.id).id == 0) bind(s);
    if (!slot.id) { post("BLB", slot.label, what, "ignored: not bound\n"); return; }

    var looper = new LiveAPI(dummy, "id " + slot.id);
    for (var i = 0; i < fns.length; i++) looper.call(fns[i]);
    report(s, slot.name, what);
}

function bind(s) {
    var slot = SLOTS[s];
    slot.id = 0;
    if (!ready) return;
    if (!slot.name) { report(s, "NOT BOUND", "type a track name"); return; }

    var song = new LiveAPI(dummy, "live_set");
    var nTracks = song.getcount("tracks");
    var t = new LiveAPI(dummy);

    var hits = [];
    for (var i = 0; i < nTracks; i++) {
        t.path = "live_set tracks " + i;
        var raw = t.get("name");            // multi-atom for names with spaces
        var nm  = (raw instanceof Array) ? raw.join(" ") : String(raw);
        if (nm === slot.name) hits.push(i);
    }
    if (hits.length === 0) { report(s, "NOT BOUND", "no track named " + slot.name); return; }
    if (hits.length > 1)   { report(s, "NOT BOUND", hits.length + " tracks named " + slot.name); return; }

    var tpath = "live_set tracks " + hits[0];
    t.path = tpath;
    var nDev = t.getcount("devices");
    var d = new LiveAPI(dummy);

    var found = [];
    for (var j = 0; j < nDev; j++) {
        d.path = tpath + " devices " + j;
        if (d.type === LOOPER) found.push(d.id);
    }
    if (found.length === 0) { report(s, "NOT BOUND", slot.name + " has no Looper"); return; }
    if (found.length > 1)   { report(s, "NOT BOUND", slot.name + " has " + found.length + " Loopers"); return; }

    slot.id = found[0];
    report(s, slot.name, "bound");
    if (DEBUG) post("BLB", slot.label, "bound |", tpath, "| id", slot.id, "\n");
}

function report(s, head, what) {
    var line = SLOTS[s].label + " " + head + " : " + what;
    post("BLB", line, "\n");
    outlet(s, line.split(" "));
}
