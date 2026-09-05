autowatch = 1;
inlets = 1;   // raw MIDI bytes from [midiin], plus control messages
outlets = 1;  // raw MIDI bytes to [midiout]

// -----------------------------------------------------------------------------
// note_gate.js — MIDI passthrough gate for a DRMCTRL-style track.
//
//   clip notes -> [midiin] -> [js note_gate.js] -> [midiout] -> receiving track
//
// Every byte passes through untouched except note-on / note-off. Those are
// looked up per pitch: the pitch belongs to a group, and if that group's
// toggle is off the note is swallowed, so the clip keeps running but that
// drum stays silent. Toggling a group off also releases the notes it is
// currently holding, so nothing hangs.
//
// Groups are edited here (GROUPS) or at runtime (setgroup / setrange).
//
// A toggle push is remembered but only takes effect at the next bar line, so a
// mute always lands on the boundary instead of mid-pattern. The Live parameter
// still flips the instant you push it, so the controller and the UI stay
// responsive and show what is coming; only the audible change waits. The one
// exception is a stopped transport, where there is no bar to wait for.
// -----------------------------------------------------------------------------

// Group i owns these pitches. A number is one pitch, a [lo, hi] pair is an
// inclusive range. Defaults = 8 blocks of 4 pads starting at C1 (36) — EDIT ME.
var GROUPS = [
    [[36, 39]],   // 1  subs
    [[40, 43]],   // 2  snrs
    [[44, 47]],   // 3  hats
    [[48, 51]]    // 4  perc
];

// What happens to a pitch that is in no group at all: 1 = play, 0 = mute.
var PASS_UNGROUPED = 1;

var enabled = [];        // per group, 1 = notes play — what the gate is doing now
var pending = [];        // per group, queued state waiting for the bar, or -1
var playing = 1;         // Live transport running? if not, changes are immediate
var songObs = null;
var pitchGroup = [];     // 128 entries, group index or -1
var held = [];           // held[channel][pitch] = notes we let through
var VERBOSE = 0;

init();

function init() {
    enabled = [];
    pending = [];
    for (var g = 0; g < GROUPS.length; g++) { enabled[g] = 1; pending[g] = -1; }
    held = [];
    for (var c = 0; c < 16; c++) {
        held[c] = [];
        for (var p = 0; p < 128; p++) held[c][p] = 0;
    }
    rebuildMap();
}

// Later groups win if two groups claim the same pitch.
function rebuildMap() {
    pitchGroup = [];
    for (var p = 0; p < 128; p++) pitchGroup[p] = -1;
    for (var g = 0; g < GROUPS.length; g++) {
        var spec = GROUPS[g];
        for (var s = 0; s < spec.length; s++) {
            var e = spec[s];
            if (e instanceof Array) {
                for (var n = e[0]; n <= e[1]; n++) if (n >= 0 && n < 128) pitchGroup[n] = g;
            } else if (e >= 0 && e < 128) {
                pitchGroup[e] = g;
            }
        }
    }
}

// ------------------------------------------------------------------- transport

// Called from [live.thisdevice] so the LiveAPI exists by the time we observe.
function initlive() {
    if (songObs === null) {
        songObs = new LiveAPI(onPlayingChanged, "live_set");
        songObs.property = "is_playing";
    }
}

function onPlayingChanged(args) {
    var v = (args instanceof Array) ? args[args.length - 1] : args;
    var now = (v ? 1 : 0);
    if (now === playing) return;
    playing = now;
    // Transport stopped: the bar clock has nothing to deliver, so anything
    // waiting takes effect right away rather than being stranded.
    if (!playing) applyPending();
}

// ----------------------------------------------------------------- MIDI parser

var status = 0;      // running status byte
var data = [];       // data bytes collected for the current status
var need = 0;        // data bytes this status wants
var inSysex = false;

function msg_int(b) {
    if (b >= 0xF8) { outlet(0, b); return; }          // realtime, may interleave
    if (inSysex) {
        outlet(0, b);
        if (b === 0xF7) inSysex = false;
        return;
    }
    if (b === 0xF0) { inSysex = true; status = 0; outlet(0, b); return; }

    if (b >= 0x80) {                                   // status byte
        status = b;
        data = [];
        need = dataBytesFor(b);
        if (need === 0) { outlet(0, b); status = 0; }
        return;
    }

    if (status === 0) { outlet(0, b); return; }        // stray data byte
    data.push(b);
    if (data.length === need) {
        emit(status, data);
        data = [];                                     // keep status: running status
    }
}

function dataBytesFor(s) {
    if (s < 0xF0) {
        var kind = s & 0xF0;
        if (kind === 0xC0 || kind === 0xD0) return 1;
        return 2;
    }
    if (s === 0xF1 || s === 0xF3) return 1;
    if (s === 0xF2) return 2;
    return 0;
}

function emit(s, d) {
    var kind = s & 0xF0;
    if (kind === 0x90 || kind === 0x80) {
        gateNote(s, kind, d[0], d[1]);
        return;
    }
    passRaw(s, d);
}

function passRaw(s, d) {
    outlet(0, s);
    for (var i = 0; i < d.length; i++) outlet(0, d[i]);
}

function gateNote(s, kind, pitch, vel) {
    var ch = s & 0x0F;
    var isOn = (kind === 0x90 && vel > 0);

    if (isOn) {
        if (!allowed(pitch)) return;                   // swallow the note
        held[ch][pitch]++;
        passRaw(s, [pitch, vel]);
        return;
    }
    // note-off: only pass it if we passed the matching note-on
    if (held[ch][pitch] > 0) {
        held[ch][pitch]--;
        passRaw(s, [pitch, vel]);
    }
}

function allowed(pitch) {
    var g = pitchGroup[pitch];
    if (g < 0) return PASS_UNGROUPED === 1;
    return enabled[g] === 1;
}

// Release everything this group is currently sounding.
function flushGroup(g) {
    for (var p = 0; p < 128; p++) {
        if (pitchGroup[p] !== g) continue;
        for (var c = 0; c < 16; c++) {
            while (held[c][p] > 0) {
                held[c][p]--;
                passRaw(0x80 | c, [p, 0]);
            }
        }
    }
}

// --------------------------------------------------------------- control input

// group <1..N> <0|1>   — the message the live.toggles send
function group(index, state) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    var on = (state ? 1 : 0);
    if (enabled[g] === on) return;
    enabled[g] = on;
    if (!on) flushGroup(g);
    if (VERBOSE) post("note_gate: group " + index + (on ? " on\n" : " off\n"));
}

// toggle <1..N>
function toggle(index) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    group(index, enabled[g] ? 0 : 1);
}

// setgroup <1..N> <pitch> <pitch> ...   — replaces that group's pitches
function setgroup() {
    if (arguments.length < 1) return;
    var g = arguments[0] - 1;
    if (g < 0 || g >= GROUPS.length) return;
    var spec = [];
    for (var i = 1; i < arguments.length; i++) spec.push(arguments[i]);
    GROUPS[g] = spec;
    rebuildMap();
}

// setrange <1..N> <lo> <hi>
function setrange(index, lo, hi) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    GROUPS[g] = [[lo, hi]];
    rebuildMap();
}

// cleargroup <1..N>
function cleargroup(index) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    GROUPS[g] = [];
    rebuildMap();
}

// passungrouped <0|1>
function passungrouped(v) {
    PASS_UNGROUPED = (v ? 1 : 0);
}

function verbose(v) {
    VERBOSE = (v ? 1 : 0);
}

// all notes off, forget held state, keep the toggles as they are
function panic() {
    for (var c = 0; c < 16; c++) {
        for (var p = 0; p < 128; p++) {
            while (held[c][p] > 0) { held[c][p]--; passRaw(0x80 | c, [p, 0]); }
        }
        passRaw(0xB0 | c, [123, 0]);
    }
    status = 0; data = []; inSysex = false;
}

function dump() {
    for (var g = 0; g < GROUPS.length; g++) {
        var pitches = [];
        for (var p = 0; p < 128; p++) if (pitchGroup[p] === g) pitches.push(p);
        post("note_gate: group " + (g + 1) + " " + (enabled[g] ? "on " : "off") +
             " pitches [" + pitches.join(" ") + "]\n");
    }
    post("note_gate: ungrouped pitches " + (PASS_UNGROUPED ? "play\n" : "muted\n"));
}
