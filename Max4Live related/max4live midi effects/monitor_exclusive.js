// monitor_exclusive.js — one button sets one track's Monitor to In, the rest to Off
//
// Five buttons, five name fields (textedits "name1edit" .. "name5edit", each
// stored by its own Parameter Mode, Blob — the looper_bridge mechanism).
// Button N: the track in field N -> Monitor In, the tracks in the other
// fields -> Monitor Off. An empty field is unused.
//
// Track.current_monitoring_state: 0 = In, 1 = Auto, 2 = Off, not in
// return/master tracks (LOM reference, Max 7). Group tracks have no Monitor
// either; the lookup checks can_be_armed, which is false for exactly those
// tracks that show no Arm / Monitor section.
//
// The lookup is strict: exactly one track in live_set tracks with exactly that
// name (case and spaces count). Anything else binds nothing and says why.
// If button N's own track is not bound, nothing is switched: the other tracks
// are not turned Off either.
//
// Selects before live.thisdevice has banged are ignored, so a parameter
// restore on load cannot switch anything.

// No autowatch: a reload while the device runs resets `ready`, and
// live.thisdevice does not bang again (seen 2026-09-17 on looper_replace).
autowatch = 0;
inlets    = 1;
outlets   = 5;   // one status line per slot

var MON_IN  = 0;
var MON_OFF = 2;
var DEBUG   = 1;                 // 1 = log every action; "debug 0" to silence

var SLOTS = [
    { textedit: "name1edit", label: "1", name: "" },
    { textedit: "name2edit", label: "2", name: "" },
    { textedit: "name3edit", label: "3", name: "" },
    { textedit: "name4edit", label: "4", name: "" },
    { textedit: "name5edit", label: "5", name: "" }
];

var ready = 0;                   // Live API usable only after live.thisdevice

function dummy() {}

// ---- inputs -------------------------------------------------------------

// live.thisdevice -> deferlow. Bangs on load, on set save and on preset load.
// Only reads the names and checks them; never switches a track.
function bang() {
    ready = 1;
    readnames();
    for (var s = 0; s < SLOTS.length; s++) check(s);
}

// Any textedit's Enter arrives here. The names are read back from the
// textedits themselves.
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
        if (ready) check(s);
    }
}

// "select N" from button N (1..5)
function select(n) {
    var k = (n | 0) - 1;
    if (k < 0 || k >= SLOTS.length) { post("MEX no button", n, "\n"); return; }
    if (!ready) { post("MEX select", n, "ignored: device not ready\n"); return; }

    var target = find(k);
    if (!target) return;                    // find() has reported why

    var ids = [];
    for (var s = 0; s < SLOTS.length; s++) {
        if (s === k) { ids.push(target); continue; }
        ids.push(SLOTS[s].name ? find(s) : null);
    }

    // Target first, so the selected track is never Off at the same time as
    // everything else.
    setmon(k, ids[k], MON_IN);
    for (var j = 0; j < SLOTS.length; j++) {
        if (j === k || !ids[j]) continue;
        setmon(j, ids[j], MON_OFF);
    }
    if (DEBUG) post("MEX select", n, "done\n");
}

function debug(d) { DEBUG = (d | 0) ? 1 : 0; post("MEX debug", DEBUG, "\n"); }

function anything() {
    if (DEBUG) post("MEX rx unhandled:", messagename, arrayfromargs(arguments).join(" "), "\n");
}

// ---- the work -----------------------------------------------------------

function check(s) {
    var slot = SLOTS[s];
    if (!slot.name) { report(s, "-", "unused"); return; }
    if (find(s)) report(s, slot.name, "found");
}

// Returns the track id, or 0 after reporting why there is none. Looked up on
// every press, so renamed or moved tracks are always current.
function find(s) {
    var slot = SLOTS[s];
    if (!slot.name) { report(s, "-", "unused"); return 0; }

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
    if (hits.length === 0) { report(s, "NOT BOUND", "no track named " + slot.name); return 0; }
    if (hits.length > 1)   { report(s, "NOT BOUND", hits.length + " tracks named " + slot.name); return 0; }

    t.path = "live_set tracks " + hits[0];
    if (!(t.get("can_be_armed") | 0)) { report(s, "NOT BOUND", slot.name + " has no Monitor"); return 0; }
    return t.id;
}

function setmon(s, id, state) {
    var t = new LiveAPI(dummy, "id " + id);
    t.set("current_monitoring_state", state);
    report(s, SLOTS[s].name, state === MON_IN ? "In" : "Off");
}

function report(s, head, what) {
    var line = SLOTS[s].label + " " + head + " : " + what;
    if (DEBUG) post("MEX", line, "\n");
    outlet(s, line.split(" "));
}
