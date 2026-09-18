autowatch = 1;
inlets = 1;   // raw MIDI bytes from [midiin], plus control messages
outlets = 1;  // raw MIDI bytes to [midiout]

// -----------------------------------------------------------------------------
// cc_quantize.js — hold selected CCs until the next bar line.
//
//   controller -> [midiin] -> [js cc_quantize.js] -> [midiout] -> rest of chain
//
// Every byte passes straight through except control-change messages whose
// (channel, cc) is on the watch list. Those are queued and released as a burst
// the moment the next bar starts, so a mute pressed halfway through a pattern
// lands on the boundary instead of mid-phrase.
//
// The bar clock comes from [metro 1n @quantize 1n] in the patch, which sends
// this script a "bar" message on every bar line of Live's transport.
//
// Queued messages keep their arrival order and their exact values — a press and
// its release both come out at the bar, in sequence. Set "mode last" if you
// want only the newest value per address instead.
// -----------------------------------------------------------------------------

// Watch list entries are [channel, cc]. Channel is 1..16 as Live shows it;
// channel 0 means "any channel". Normally set from the patch with a
// "watchlist ..." message, so you can edit it without touching this file.
var WATCH = [];

var MODE = "all";        // "all" = release everything queued, "last" = newest per address
var ENABLED = 1;         // 0 = bypass, everything passes immediately
var MAX_QUEUE = 512;     // runaway guard
var VERBOSE = 0;

var queue = [];          // pending [status, cc, value]
var playing = 1;         // Live transport running? if not, nothing is held
var songObs = null;

// ------------------------------------------------------------------ transport

// Called from [live.thisdevice] so the LiveAPI exists by the time we observe.
function init() {
    if (songObs === null) {
        songObs = new LiveAPI(onPlayingChanged, "live_set");
        songObs.property = "is_playing";
    }
}

function onPlayingChanged(args) {
    // args arrives as ["is_playing", value]
    var v = (args instanceof Array) ? args[args.length - 1] : args;
    var now = (v ? 1 : 0);
    if (now === playing) return;
    playing = now;
    // Transport just stopped: never sit on messages the bar clock can no longer
    // deliver — let go of them right away.
    if (!playing) flush();
}

// ---------------------------------------------------------------- watch list

function inWatchList(ch, cc) {
    for (var i = 0; i < WATCH.length; i++) {
        var w = WATCH[i];
        if (w[1] !== cc) continue;
        if (w[0] === 0 || w[0] === ch) return true;
    }
    return false;
}

// watchlist <ch> <cc> <ch> <cc> ...   — replaces the whole list
function watchlist() {
    WATCH = [];
    for (var i = 0; i + 1 < arguments.length; i += 2) {
        WATCH.push([arguments[i], arguments[i + 1]]);
    }
    if (VERBOSE) post("cc_quantize: watching " + WATCH.length + " address(es)\n");
}

// watch <ch> <cc>
function watch(ch, cc) {
    if (inWatchList(ch, cc)) return;
    WATCH.push([ch, cc]);
}

// unwatch <ch> <cc>
function unwatch(ch, cc) {
    for (var i = WATCH.length - 1; i >= 0; i--) {
        if (WATCH[i][0] === ch && WATCH[i][1] === cc) WATCH.splice(i, 1);
    }
}

function clearlist() {
    WATCH = [];
}

// ------------------------------------------------------------- MIDI parser

var status = 0;
var data = [];
var need = 0;
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
    if ((s & 0xF0) === 0xB0 && ENABLED && playing &&
        inWatchList((s & 0x0F) + 1, d[0])) {
        if (queue.length < MAX_QUEUE) queue.push([s, d[0], d[1]]);
        if (VERBOSE) post("cc_quantize: held ch" + ((s & 0x0F) + 1) +
                          " cc" + d[0] + " = " + d[1] + "\n");
        return;
    }
    passRaw(s, d);
}

function passRaw(s, d) {
    outlet(0, s);
    for (var i = 0; i < d.length; i++) outlet(0, d[i]);
}

// ----------------------------------------------------------------- releasing

// "bar" arrives from [metro 1n @quantize 1n] on every bar line.
function bar() {
    flush();
}

function flush() {
    if (queue.length === 0) return;
    var out = (MODE === "last") ? lastPerAddress(queue) : queue;
    for (var i = 0; i < out.length; i++) {
        passRaw(out[i][0], [out[i][1], out[i][2]]);
    }
    if (VERBOSE) post("cc_quantize: released " + out.length + " message(s)\n");
    queue = [];
}

// Keep only the newest value for each (status, cc), in order of last arrival.
function lastPerAddress(q) {
    var out = [];
    for (var i = 0; i < q.length; i++) {
        var keep = true;
        for (var j = i + 1; j < q.length; j++) {
            if (q[j][0] === q[i][0] && q[j][1] === q[i][1]) { keep = false; break; }
        }
        if (keep) out.push(q[i]);
    }
    return out;
}

// throw away what is waiting instead of releasing it
function drop() {
    queue = [];
}

// --------------------------------------------------------------- settings

// enable 0|1 — 0 bypasses the whole thing and releases anything pending
function enable(v) {
    ENABLED = (v ? 1 : 0);
    if (!ENABLED) flush();
}

// mode all | last
function mode(m) {
    if (m === "all" || m === "last") MODE = m;
}

function verbose(v) {
    VERBOSE = (v ? 1 : 0);
}

function dump() {
    post("cc_quantize: " + (ENABLED ? "on" : "bypassed") + ", mode " + MODE +
         ", transport " + (playing ? "running" : "stopped") +
         ", " + queue.length + " pending\n");
    for (var i = 0; i < WATCH.length; i++) {
        post("cc_quantize:   watching ch" +
             (WATCH[i][0] === 0 ? " any" : WATCH[i][0]) + " cc" + WATCH[i][1] + "\n");
    }
}
