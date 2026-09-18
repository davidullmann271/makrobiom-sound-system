// looper_clear_all.js — one button empties every named Looper
//
// [live.text CLEAR ALL] (Button mode, MIDI-mappable) -> "clearall" ->
// for every name field that is not empty: LooperDevice.stop, then .clear
// CLEAR_DELAY ms later
//
// Stop comes first because Clear in Overdub keeps the length and tempo; Clear in
// any other mode resets them (Live manual, Looper). So the Looper ends up empty.
//
// Eight fields (textedits "name1edit" .. "name8edit", each stored with the set
// by its own Parameter Mode, Blob). An empty field is unused. Lookup as in
// looper_bridge: exactly one track with exactly that name, exactly one
// Looper directly in its device chain. Anything else clears nothing and says why.
//
// Nothing here watches the transport: stopping the song clears nothing.

// No autowatch: a reload while the device runs resets `ready`, and
// live.thisdevice does not bang again, so every input would be ignored as
// "device not ready" (seen 2026-09-17). The script loads with the device.
autowatch = 0;
inlets    = 1;
outlets   = 8;   // one status line per field, same order as SLOTS

var LOOPER = "LooperDevice";     // LOM class, matched against LiveAPI .type
var DEBUG  = 1;                  // 1 = log every action; "debug 0" to silence
var COUNT  = 8;
var CLEAR_DELAY = 100;           // ms between stop and clear

var pending = null;              // the scheduled clear, if any

var SLOTS = [];
for (var k = 0; k < COUNT; k++)
    SLOTS.push({ textedit: "name" + (k + 1) + "edit", name: "", id: 0 });

var ready = 0;                   // Live API usable only after live.thisdevice

function dummy() {}

// live.thisdevice -> deferlow. Bangs on load, on set save and on preset load.
// Only re-binds; never calls a Looper.
function bang() {
    ready = 1;
    readnames();
    resolve();
}

// Any textedit's Enter and every parameter restore arrive here. The names are read
// back from the textedits themselves.
function readnames() {
    for (var s = 0; s < SLOTS.length; s++) {
        var slot = SLOTS[s];
        var obj = this.patcher.getnamed(slot.textedit);
        if (!obj) { report(s, "NOT BOUND no textedit " + slot.textedit); continue; }

        var v  = obj.getvalueof();
        var nm = (v instanceof Array) ? v.join(" ") : String(v);
        nm = nm.replace(/^\s+|\s+$/g, "");

        if (nm === slot.name) continue;
        slot.name = nm;
        if (ready) bind(s);
    }
}

// the button
// Stop everything now, clear everything CLEAR_DELAY ms later. Stop and Clear
// back to back left an overdubbing Looper stopped but not cleared
// (bass short Loopers, 2026-09-17); the delay lets the Stop land first.
function clearall() {
    if (!ready) { post("LCA clear all ignored: device not ready\n"); return; }
    if (DEBUG) post("LCA clear all\n");
    if (pending) pending.cancel();

    var ids = [];
    for (var s = 0; s < SLOTS.length; s++) {
        var slot = SLOTS[s];
        if (!slot.name) continue;

        // The cached id dies if the Looper or its track is deleted. Re-resolving
        // uses the same exact-name rule, so it cannot bind anything looser.
        if (!slot.id || new LiveAPI(dummy, "id " + slot.id).id == 0) bind(s);
        if (!slot.id) { post("LCA", slot.name, "not cleared: not bound\n"); continue; }

        new LiveAPI(dummy, "id " + slot.id).call("stop");
        report(s, "stopped");
        ids.push([s, slot.id]);
    }

    // Task runs in the low-priority thread (Task reference), where Live API
    // calls belong.
    pending = new Task(function () {
        pending = null;
        for (var i = 0; i < ids.length; i++) {
            new LiveAPI(dummy, "id " + ids[i][1]).call("clear");
            report(ids[i][0], "cleared");
        }
    }, this);
    pending.schedule(CLEAR_DELAY);
}

function resolve()  { for (var s = 0; s < SLOTS.length; s++) bind(s); }
function debug(d)   { DEBUG = (d | 0) ? 1 : 0; post("LCA debug", DEBUG, "\n"); }

function anything() {
    if (DEBUG) post("LCA rx unhandled:", messagename, arrayfromargs(arguments).join(" "), "\n");
}

function bind(s) {
    var slot = SLOTS[s];
    slot.id = 0;
    if (!ready) return;
    if (!slot.name) { report(s, "-"); return; }

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
    if (hits.length === 0) { report(s, "NOT BOUND no such track"); return; }
    if (hits.length > 1)   { report(s, "NOT BOUND " + hits.length + " tracks"); return; }

    var tpath = "live_set tracks " + hits[0];
    t.path = tpath;
    var nDev = t.getcount("devices");
    var d = new LiveAPI(dummy);

    var found = [];
    for (var j = 0; j < nDev; j++) {
        d.path = tpath + " devices " + j;
        if (d.type === LOOPER) found.push(d.id);
    }
    if (found.length === 0) { report(s, "NOT BOUND no Looper"); return; }
    if (found.length > 1)   { report(s, "NOT BOUND " + found.length + " Loopers"); return; }

    slot.id = found[0];
    report(s, "bound");
    if (DEBUG) post("LCA", s + 1, "bound |", slot.name, "|", tpath, "| id", slot.id, "\n");
}

// Status beside the field: short, the field already shows the name.
function report(s, what) {
    post("LCA", s + 1, SLOTS[s].name || "(empty)", ":", what, "\n");
    outlet(s, what.split(" "));
}
