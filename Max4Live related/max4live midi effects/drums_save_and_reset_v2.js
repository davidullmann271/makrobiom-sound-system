autowatch = 1;
inlets = 1;
outlets = 0;

var RECORD_TRACKS = ["subs save", "snrs save", "hats save", "perc save"];
var BASE_TRACKS   = ["subs",      "snrs",      "hats",      "perc"];
// The " aud" group slots are no longer fired. They used to end the recording AND
// launch the base dummy clip in one action; Live now owns the recording length,
// so re-firing that group would only retrigger a clip Live is already closing.
// Only the base dummy clips are launched, and only at the closing bar line.
var AUD_TRACKS    = ["subs aud",  "snrs aud",  "hats aud",  "perc aud"];
// both engines are cleared after a take: the drum engine and the sampler engine
var CTRL_PREFIXES = ["DRMCTRL", "SMPLCTRL"];
var CTRL_SUFFIXES = ["1", "2", "4", "8", "16"];
var DRUM_TRACKS = buildCtrlTracks();
var BARS_TO_RECORD = 4;
var STOP_MARGIN_MS = 150;   // how far before the closing bar line the base dummy
                            // clips are fired, so Live's quantization lands them ON it
var CLEANUP_MARGIN_MS = 60; // how long after the closing bar line the cleanup runs
var LIVE_ROW = 0;           // the live-only row: base clips here carry the 0 dB envelope
var FIRST_ALLOWED_ROW = 1;  // row 0 is the live-only row and is never recorded to

// -----------------------------------------------------------------------------
// Live owns the take length.
//
// ClipSlot.fire() takes an optional record_length in beats: "If record_length is
// provided, the slot will record for the given length in beats." So the take
// starts on Live's quantization grid and stops after exactly N beats, locked to
// the transport -- immune to a tempo change mid-take and to anything happening
// on Max's low-priority thread.
//
// The previous build instead PREDICTED the start from a current_song_time
// snapshot and counted milliseconds to the stop. Pressing a few ms before a
// quantization boundary made it predict "starts now" while Live, receiving the
// fire slightly after the boundary, deferred the launch a full bar. The stop
// still ran on the original estimate, so the take came out one bar short.
//
// Two things still need timing, and both are now anchored to the OBSERVED start
// rather than a predicted one:
//   * the base dummy clips, fired just before the closing bar line so Live's
//     quantization lands them on it (this is what silences the live input)
//   * the cleanup, run just after it
// Both have wide tolerance. Neither decides when the recording ends.
// -----------------------------------------------------------------------------

var startObs = null;
var launchTask = null;
var cleanupTask = null;
var watchdogTask = null;
var pendingArmState = null;
var pendingTrackIndices = null;
var pendingBaseIndices = null;
var pendingSceneIndex = null;
var takeMs = 0;
var takeInProgress = false;
var takeStarted = false;

function bang() {
    if (takeInProgress) {
        post("record_take: a take is already running -- send 'abort' to cancel it\n");
        return;
    }

    var song = new LiveAPI("live_set");
    var nameToIndex = buildTrackMap(song);

    // --- snapshot the arm state of every armable track, so afterRecording()
    // can put the set back exactly as it was before the take ---
    pendingArmState = [];

    // --- 1 & 6: exclusive arm + monitor off ---
    for (var name in nameToIndex) {
        var idx = nameToIndex[name];
        var track = new LiveAPI("live_set tracks " + idx);
        if (track.get("is_foldable")[0] === 1) continue; // group tracks have no arm state -- skip
        // store by id, not index: a track added or moved mid-take would shift indices
        pendingArmState.push({ id: track.id, arm: track.get("arm")[0] });
        var isTarget = RECORD_TRACKS.indexOf(name) !== -1;
        track.set("arm", isTarget ? 1 : 0);
        if (isTarget) track.set("current_monitoring_state", 2);
    }

    var targetIndices = resolveTracks(RECORD_TRACKS, nameToIndex);
    if (targetIndices === null) { restoreArm(); return; }

    // --- the base tracks whose dummy clip mutes the live input at the end ---
    var baseIndices = resolveTracks(BASE_TRACKS, nameToIndex);
    if (baseIndices === null) { restoreArm(); return; }

    // --- 2: first free row across the save tracks, never row 0 ---
    var sceneIndex = findFirstFreeRow(targetIndices, song.getcount("scenes"));
    if (sceneIndex === -1) {
        post("record_take: no free row found\n");
        restoreArm();
        return;
    }
    pendingTrackIndices = targetIndices;
    pendingBaseIndices = baseIndices;
    pendingSceneIndex = sceneIndex;

    var tempo = song.get("tempo")[0];
    var numerator = song.get("signature_numerator")[0];
    var denominator = song.get("signature_denominator")[0];
    var beatMs = (60000 / tempo) * (4 / denominator);
    var recordBeats = numerator * BARS_TO_RECORD;
    takeMs = recordBeats * beatMs;

    post("record_take: row=" + sceneIndex + " length=" + recordBeats + " beats (" +
         BARS_TO_RECORD + " bars, " + Math.round(takeMs) + "ms)\n");

    // --- 3: fire all save slots with a fixed length. Live quantizes the start
    // and closes the take itself after recordBeats. ---
    for (var t = 0; t < targetIndices.length; t++) {
        var s = new LiveAPI("live_set tracks " + targetIndices[t] + " clip_slots " + sceneIndex);
        s.call("fire", recordBeats);
    }

    takeInProgress = true;
    takeStarted = false;
    watchForStart(targetIndices[0], sceneIndex);

    // If the take never begins -- transport stopped, quantization None with
    // nothing running -- nothing would ever restore the arm state. Give it a
    // generous window, then put the set back.
    if (watchdogTask) watchdogTask.cancel();
    watchdogTask = new Task(watchdogExpired, this);
    watchdogTask.schedule(takeMs * 2 + 10000);
}

// --------------------------------------------------------------- take tracking

// Anchor on the slot itself rather than on a predicted start time. has_clip is
// documented as "1 = a clip exists in this clip slot", and the recording clip
// comes into existence when the take actually begins.
function watchForStart(trackIndex, sceneIndex) {
    releaseObserver();
    startObs = new LiveAPI(onSlotHasClip, "live_set tracks " + trackIndex +
                           " clip_slots " + sceneIndex);
    startObs.property = "has_clip";
}

function onSlotHasClip(args) {
    var v = (args instanceof Array) ? args[args.length - 1] : args;
    if (v != 1) return;              // still empty: the take has not begun
    if (takeStarted) return;
    takeStarted = true;
    releaseObserver();
    onTakeStarted();
}

function releaseObserver() {
    if (startObs !== null) {
        startObs.property = "";
        startObs = null;
    }
}

function onTakeStarted() {
    if (watchdogTask) { watchdogTask.cancel(); watchdogTask = null; }

    // Fired a little BEFORE the closing bar line so Live's quantization lands it
    // ON the line. Only clip launches are quantized, which is why the cleanup
    // below is scheduled separately, past the line.
    if (launchTask) launchTask.cancel();
    launchTask = new Task(launchPlayback, this);
    launchTask.schedule(Math.max(takeMs - STOP_MARGIN_MS, 0));

    if (cleanupTask) cleanupTask.cancel();
    cleanupTask = new Task(afterRecording, this);
    cleanupTask.schedule(takeMs + CLEANUP_MARGIN_MS);
}

function watchdogExpired() {
    watchdogTask = null;
    if (takeStarted) return;
    post("record_take: take never started (transport stopped?) -- restoring arm state\n");
    releaseObserver();
    restoreArm();
    takeInProgress = false;
}

// ---------------------------------------------------------------- take closing

// subs / snrs / hats / perc are GROUP tracks holding "<g> eng" and "<g> smpl".
// Firing the group's row launches the dummy clips on both, whose Track Volume
// envelope (-inf on the save rows) is what silences the live engine -- handing
// the row over to the take that was just recorded. The group deliberately does
// NOT contain "<g> save", so this never touches the clip Live is still closing.
function launchPlayback() {
    for (var b = 0; b < pendingBaseIndices.length; b++) {
        fireRow(pendingBaseIndices[b], pendingSceneIndex, BASE_TRACKS[b]);
    }
}

// Runs after the take has actually ended. Everything here takes effect the moment
// it is called -- no quantization -- so it must not run early.
function afterRecording() {
    restoreArm();

    // --- 7 & 8: NOW reset the DRMCTRL/SMPLCTRL trigger clips ---
    var song = new LiveAPI("live_set");
    var nameToIndex = buildTrackMap(song);

    for (var k = 0; k < DRUM_TRACKS.length; k++) {
        var dIdx = nameToIndex[DRUM_TRACKS[k]];
        if (dIdx === undefined) {
            post("record_take: track not found: " + DRUM_TRACKS[k] + "\n");
            continue;
        }
        var slot = new LiveAPI("live_set tracks " + dIdx + " clip_slots 0");
        if (slot.get("has_clip")[0] === 1) {
            var clip = new LiveAPI("live_set tracks " + dIdx + " clip_slots 0 clip");
            clip.call("remove_notes_extended", 0, 127, 0, 1000000);
        }
    }

    takeInProgress = false;
}

// subs / snrs / hats / perc are GROUP tracks. A group track slot never holds a
// clip of its own -- has_clip is always 0 on it -- it is a proxy that launches
// the clips in that row on the tracks inside the group ("subs eng", "subs smpl").
// controls_other_clips is the property that actually means "there is something
// here to fire": "1 for a Group Track slot that has non-deactivated clips in the
// tracks within its group."
function fireRow(trackIndex, sceneIndex, label) {
    var slot = new LiveAPI("live_set tracks " + trackIndex + " clip_slots " + sceneIndex);
    if (slot.get("has_clip")[0] !== 1 && slot.get("controls_other_clips")[0] !== 1) {
        post("record_take: nothing to fire on row " + sceneIndex + " of " + label + "\n");
        return false;
    }
    slot.call("fire");
    return true;
}

function restoreArm() {
    if (!pendingArmState) return;
    for (var r = 0; r < pendingArmState.length; r++) {
        var prev = new LiveAPI("id " + pendingArmState[r].id);
        prev.set("arm", pendingArmState[r].arm);
    }
    pendingArmState = null;
}

// Give up on a take in flight and put the arm state back. The clip Live is
// recording is left alone -- stop it by hand if you do not want it.
function abort() {
    if (launchTask) { launchTask.cancel(); launchTask = null; }
    if (cleanupTask) { cleanupTask.cancel(); cleanupTask = null; }
    if (watchdogTask) { watchdogTask.cancel(); watchdogTask = null; }
    releaseObserver();
    restoreArm();
    takeInProgress = false;
    takeStarted = false;
    post("record_take: aborted\n");
}

// ------------------------------------------------------------------- utilities

function buildCtrlTracks() {
    var all = [];
    for (var p = 0; p < CTRL_PREFIXES.length; p++) {
        for (var s = 0; s < CTRL_SUFFIXES.length; s++) {
            all.push(CTRL_PREFIXES[p] + " " + CTRL_SUFFIXES[s]);
        }
    }
    return all;
}

function buildTrackMap(song) {
    var trackCount = song.getcount("tracks");
    var nameToIndex = {};
    for (var i = 0; i < trackCount; i++) {
        var t = new LiveAPI("live_set tracks " + i);
        nameToIndex[t.get("name")[0]] = i;
    }
    return nameToIndex;
}

function resolveTracks(names, nameToIndex) {
    var out = [];
    for (var i = 0; i < names.length; i++) {
        if (nameToIndex[names[i]] === undefined) {
            post("record_take: track not found: " + names[i] + "\n");
            return null;
        }
        out.push(nameToIndex[names[i]]);
    }
    return out;
}

function findFirstFreeRow(trackIndices, sceneCount) {
    for (var s = FIRST_ALLOWED_ROW; s < sceneCount; s++) {
        var allEmpty = true;
        for (var t = 0; t < trackIndices.length; t++) {
            var slot = new LiveAPI("live_set tracks " + trackIndices[t] + " clip_slots " + s);
            if (slot.get("has_clip")[0] === 1) { allEmpty = false; break; }
        }
        if (allEmpty) return s;
    }
    return -1;
}

// --- separate utility button: bring the live input back on the base tracks ---
// Firing the group's LIVE_ROW swaps in the 0 dB envelope on "<g> eng" and
// "<g> smpl", so the live engine returns and can be layered over the stored
// take. This is a launch, not a stop: stopping the clips would leave the
// modulated volume in an undefined state.
function bases_live() {
    var song = new LiveAPI("live_set");
    var nameToIndex = buildTrackMap(song);

    for (var i = 0; i < BASE_TRACKS.length; i++) {
        var idx = nameToIndex[BASE_TRACKS[i]];
        if (idx === undefined) {
            post("bases_live: track not found: " + BASE_TRACKS[i] + "\n");
            continue;
        }
        fireRow(idx, LIVE_ROW, BASE_TRACKS[i]);
    }
}

// kept so an existing [stop_bases] message box still works
function stop_bases() {
    bases_live();
}
