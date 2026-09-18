// looper_bridge.js — a MIDI clip drives the Loopers of one module side
//
// Promoted 2026-09-17 from bass_looper_bridge.js (now in deprecated/, together
// with looper_overdub_bridge.js, whose C0/C1 behaviour this includes). One
// device per control track, four name fields; an empty field is unused.
// The 8-bar Looper is the main one (2026-09-17): 1, 2 and 4 bar are the short
// ones that transfer into it.
//
// C0  (note 24)  note-on   -> 8-bar Looper: record
//                note-off  -> ignored: Record Length ends the recording
// C1  (note 36)  note-on   -> 8-bar Looper: overdub
//                note-off  -> short Loopers whose note is still held: stop
//                             (clear follows), then 8-bar Looper: play
// C3  (note 60)  note-on   -> 1-bar Looper: record
//                note-off  -> 1-bar Looper: stop, clear CLEAR_DELAY ms later
// C#3 (note 61)  note-on   -> 2-bar Looper: record
//                note-off  -> 2-bar Looper: stop, clear CLEAR_DELAY ms later
// D3  (note 62)  note-on   -> 4-bar Looper: record
//                note-off  -> 4-bar Looper: stop, clear CLEAR_DELAY ms later
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
// The short Looper has to be silent before the 8-bar Looper leaves Overdub,
// or the next repetition's first milliseconds land in the capture.
//
// The target tracks are the names typed into the four fields (textedits
// "name1edit" / "name2edit" / "name4edit" / "name8edit", each stored by its own
// Parameter Mode, Blob). The lookup is strict: exactly one track with exactly
// that name (case and spaces count), exactly one Looper directly in its device
// chain (not inside a rack). Anything else binds nothing and says why.
//
// Input is raw bytes from [midiin]. The status byte is read here rather than
// through [midiparse], whose refpage does not say how it reports 0x80 note-offs.
// Both spellings of note-off in the MIDI spec (0x80, and 0x90 with velocity 0)
// are note-offs; that is the spec, not a fallback.

// No autowatch: a reload while the device runs resets `ready`, and
// live.thisdevice does not bang again, so every input would be ignored as
// "device not ready" (seen 2026-09-17). The script loads with the device.
autowatch = 0;
inlets    = 1;
outlets   = 4;   // one status line per slot, same order as SLOTS

var NOTE_RECORD_8  = 24;         // C0  -> the main (8-bar) Looper
var NOTE_OVERDUB_8 = 36;         // C1  -> the main (8-bar) Looper

var LOOPER = "LooperDevice";     // LOM class, matched against LiveAPI .type
var DEBUG  = 1;                  // 1 = log every action; "debug 0" to silence
var CLEAR_DELAY = 100;           // ms between stop and clear

// slot index = outlet index = field order on the device. The record note of
// the main Looper is C0, not a per-slot note, so its note entry stays 0.
var S1 = 0, S2 = 1, S4 = 2, S8 = 3;
var SLOTS = [
    { bars: 1, note: 60, noteName: "C3",  textedit: "name1edit", label: "1BAR", name: "", id: 0, held: 0, task: null },
    { bars: 2, note: 61, noteName: "C#3", textedit: "name2edit", label: "2BAR", name: "", id: 0, held: 0, task: null },
    { bars: 4, note: 62, noteName: "D3",  textedit: "name4edit", label: "4BAR", name: "", id: 0, held: 0, task: null },
    { bars: 8, note: 0,  noteName: "C0",  textedit: "name8edit", label: "8BAR", name: "", id: 0, held: 0, task: null }
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
function overdub()  { act(S8, ["overdub"]); }
function play()     { act(S8, ["play"]); }
function resolve()  { for (var s = 0; s < SLOTS.length; s++) bind(s); }
function debug(d)   { DEBUG = (d | 0) ? 1 : 0; post("LBR debug", DEBUG, "\n"); }

function slotarg(n) {
    var b = n | 0;
    for (var s = 0; s < SLOTS.length; s++) if (SLOTS[s].bars === b) return s;
    post("LBR no looper for", n, "bars", "\n");
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
    if (pitch === NOTE_RECORD_8) {
        if (DEBUG) post("LBR C0", on ? "on" : "off", "\n");
        if (on) { cancelclear(S8); act(S8, ["record"]); }
        return;
    }
    if (pitch === NOTE_OVERDUB_8) {
        if (DEBUG) post("LBR C1", on ? "on" : "off", "\n");
        if (on) { act(S8, ["overdub"]); return; }
        for (var s = 0; s < SLOTS.length; s++) {
            if (s === S8 || !SLOTS[s].held) continue;
            SLOTS[s].held = 0;
            stopclear(s);
        }
        act(S8, ["play"]);
        return;
    }
    for (var k = 0; k < SLOTS.length; k++) {
        if (k === S8 || pitch !== SLOTS[k].note) continue;
        if (DEBUG) post("LBR", SLOTS[k].noteName, on ? "on" : "off", "\n");
        if (on) {
            SLOTS[k].held = 1;
            cancelclear(k);
            act(k, ["record"]);
        } else if (SLOTS[k].held) {         // not already stopped by C1 note-off
            SLOTS[k].held = 0;
            stopclear(k);
        }
        return;
    }
    if (DEBUG && on) post("LBR note", pitch, "ignored\n");
}

function anything() {
    if (DEBUG) post("LBR rx unhandled:", messagename, arrayfromargs(arguments).join(" "), "\n");
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
    if (DEBUG) post("LBR", slot.label, "pending clear cancelled\n");
}

// Calls each Looper function in order on one slot.
function act(s, fns) {
    var slot = SLOTS[s];
    var what = fns.join(" ");
    if (!ready) { post("LBR", slot.label, what, "ignored: device not ready\n"); return; }

    // The cached id dies if the Looper or its track is deleted. Re-resolving
    // uses the same exact-name rule, so it cannot bind anything looser.
    if (!slot.id || new LiveAPI(dummy, "id " + slot.id).id == 0) bind(s);
    if (!slot.id) { post("LBR", slot.label, what, "ignored: not bound\n"); return; }

    var looper = new LiveAPI(dummy, "id " + slot.id);
    for (var i = 0; i < fns.length; i++) looper.call(fns[i]);
    report(s, slot.name, what);
}

function bind(s) {
    var slot = SLOTS[s];
    slot.id = 0;
    if (!ready) return;
    if (!slot.name) { report(s, "-", "unused"); return; }

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
    if (DEBUG) post("LBR", slot.label, "bound |", tpath, "| id", slot.id, "\n");
}

function report(s, head, what) {
    var line = SLOTS[s].label + " " + head + " : " + what;
    post("LBR", line, "\n");
    outlet(s, line.split(" "));
}
