autowatch = 1;
inlets = 1;   // control messages only -- NEVER the note stream
outlets = 2;  // 0: "<pitch> <0|1>" into [table pitchallow]
              // 1: "<cc> <value>" into [midiformat]'s control inlet (panic only)

// -----------------------------------------------------------------------------
// note_gate_ctrl.js -- control half of note_gate.
//
// The note stream does NOT pass through here. It runs entirely in native
// objects ([midiparse] -> [table pitchallow] lookup -> [gate] -> [midiformat]),
// which stay on Max's scheduler thread. js is documented as low-priority only
// and unsuitable for timing-sensitive events, so the old byte-level parser in
// note_gate.js was jittering every drum hit.
//
// All this script does is decide which pitches are allowed and write 0/1 into
// the 128-entry table the patcher reads. That happens on load and on a toggle,
// never per note, so low priority is fine here.
//
// A toggle push is remembered and takes effect on a grid boundary, so a change
// always lands on a musical division instead of mid-pattern. The two directions
// use different grids:
//
//     muting   (group -> 0)   next BEAT, so dropping a part is responsive
//     unmuting (group -> 1)   next BAR,  so a part comes back on the downbeat
//
// The Live parameter still flips the instant you push it, so the controller and
// the UI stay responsive and show what is coming; only the audible change waits.
// The one exception is a stopped transport, where there is no grid to wait for.
//
// Note-offs are passed unconditionally by the patcher, so a note cannot hang
// when its group is muted mid-note -- the clip's own note-off still gets
// through. That is why there is no held-note bookkeeping or flush here.
// -----------------------------------------------------------------------------

// Group i owns these pitches. A number is one pitch, a [lo, hi] pair is an
// inclusive range. Mapping is from biome_drums_concept_v4_notes.txt.
var GROUPS = [
    [36, 37],                     // 1  subs
    [38, 39, 44, 45],             // 2  snrs
    [40, 41, 46, 47],             // 3  hats
    [42, 43, 48, 49, 50, 51]      // 4  perc
];

// What happens to a pitch that is in no group at all: 1 = play, 0 = mute.
var PASS_UNGROUPED = 1;

var enabled = [];        // per group, 1 = notes play -- what the gate is doing now
var pending = [];        // per group, queued state waiting for the bar, or -1
var playing = 1;         // Live transport running? if not, changes are immediate
var songObs = null;
var pitchGroup = [];     // 128 entries, group index or -1
var VERBOSE = 0;

init();

function init() {
    enabled = [];
    pending = [];
    for (var g = 0; g < GROUPS.length; g++) { enabled[g] = 1; pending[g] = -1; }
    rebuildMap();
    writeAll();
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

// ------------------------------------------------------------------ table sync

function allowed(pitch) {
    var g = pitchGroup[pitch];
    if (g < 0) return PASS_UNGROUPED === 1 ? 1 : 0;
    return enabled[g] === 1 ? 1 : 0;
}

function writeAll() {
    for (var p = 0; p < 128; p++) outlet(0, p, allowed(p));
}

// Only the pitches this group owns -- a toggle does not need all 128 writes.
function writeGroup(g) {
    for (var p = 0; p < 128; p++) {
        if (pitchGroup[p] === g) outlet(0, p, allowed(p));
    }
}

// ------------------------------------------------------------------- transport

// Called from [live.thisdevice] so the LiveAPI exists by the time we observe.
function initlive() {
    if (songObs === null) {
        songObs = new LiveAPI(onPlayingChanged, "live_set");
        songObs.property = "is_playing";
    }
    writeAll();
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

// Sent by [delay 0 @quantize 1n]: un-mutes land on the bar line.
function bar() { applyPending(1); }

// Sent by [delay 0 @quantize 4n]: mutes land on the next beat.
function beat() { applyPending(0); }

// which = 1 apply only queued un-mutes, 0 only queued mutes,
//         undefined apply everything (transport stopped: no grid is coming).
function applyPending(which) {
    for (var g = 0; g < GROUPS.length; g++) {
        if (pending[g] === -1) continue;
        if (which !== undefined && pending[g] !== which) continue;
        var on = pending[g];
        pending[g] = -1;
        if (enabled[g] === on) continue;
        enabled[g] = on;
        writeGroup(g);
        if (VERBOSE) post("note_gate: group " + (g + 1) + (on ? " on\n" : " off\n"));
    }
}

// --------------------------------------------------------------- control input

// group <1..N> <0|1>   -- the message the live.toggles send
function group(index, state) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    var on = (state ? 1 : 0);
    if (enabled[g] === on) { pending[g] = -1; return; } // pushed back before the grid: cancel
    if (!playing) {                                     // no grid to wait for
        enabled[g] = on;
        writeGroup(g);
        return;
    }
    pending[g] = on;
}

// toggle <1..N>
function toggle(index) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    var current = (pending[g] !== -1) ? pending[g] : enabled[g];
    group(index, current ? 0 : 1);
}

// setgroup <1..N> <pitch> <pitch> ...   -- replaces that group's pitches
function setgroup() {
    if (arguments.length < 1) return;
    var g = arguments[0] - 1;
    if (g < 0 || g >= GROUPS.length) return;
    var spec = [];
    for (var i = 1; i < arguments.length; i++) spec.push(arguments[i]);
    GROUPS[g] = spec;
    rebuildMap();
    writeAll();
}

// setrange <1..N> <lo> <hi>
function setrange(index, lo, hi) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    GROUPS[g] = [[lo, hi]];
    rebuildMap();
    writeAll();
}

// cleargroup <1..N>
function cleargroup(index) {
    var g = index - 1;
    if (g < 0 || g >= GROUPS.length) return;
    GROUPS[g] = [];
    rebuildMap();
    writeAll();
}

// passungrouped <0|1>
function passungrouped(v) {
    PASS_UNGROUPED = (v ? 1 : 0);
    writeAll();
}

function verbose(v) { VERBOSE = (v ? 1 : 0); }

// All-notes-off on every channel. There is no held-note state to clear here:
// the patcher passes note-offs unconditionally, so notes cannot hang. This is
// only for a stuck voice in the instrument downstream.
function panic() {
    outlet(1, 123, 0);
    writeAll();
}

function dump() {
    for (var g = 0; g < GROUPS.length; g++) {
        var pitches = [];
        for (var p = 0; p < 128; p++) if (pitchGroup[p] === g) pitches.push(p);
        post("note_gate: group " + (g + 1) + " " + (enabled[g] ? "on " : "off") +
             (pending[g] !== -1 ? " (pending " + pending[g] + ")" : "") +
             " pitches [" + pitches.join(" ") + "]\n");
    }
    post("note_gate: ungrouped pitches " + (PASS_UNGROUPED ? "play\n" : "muted\n"));
}

function bang() { writeAll(); }
