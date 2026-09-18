autowatch = 1;
inlets = 1;
outlets = 0;

var RECORD_TRACKS = ["subs save", "snrs save", "hats save", "perc save", "fx save"];
var DRUM_TRACKS = ["DRMCTRL 1", "DRMCTRL 2", "DRMCTRL 4", "DRMCTRL 8", "DRMCTRL 16"];
var BARS_TO_RECORD = 4;
var STOP_MARGIN_MS = 150;

var stopTask = null;
var pendingTrackIndices = null;
var pendingSceneIndex = null;

// Global Quantization enum -> beats. Values 0-4 and 7/9/11 are exact;
// the "T" (triplet) settings 6/8/10/12 are approximated to their
// non-triplet neighbor. If you use a triplet Global Quantization,
// tell me and I'll correct these — for now, plain 1 Bar is safest.
var QUANT_BEATS = {
    0: 0,    // None
    1: 32,   // 8 bars
    2: 16,   // 4 bars
    3: 8,    // 2 bars
    4: 4,    // 1 bar
    5: 2,    // 1/2
    6: 2,    // 1/2T (approx)
    7: 1,    // 1/4
    8: 1,    // 1/4T (approx)
    9: 0.5,  // 1/8
    10: 0.5, // 1/8T (approx)
    11: 0.25,// 1/16
    12: 0.25 // 1/16T (approx)
};

function bang() {
    var song = new LiveAPI("live_set");
    var trackCount = song.getcount("tracks");

    var nameToIndex = {};
    for (var i = 0; i < trackCount; i++) {
        var t = new LiveAPI("live_set tracks " + i);
        nameToIndex[t.get("name")[0]] = i;
    }

// --- 1 & 6: exclusive arm + monitor off ---
    for (var name in nameToIndex) {
        var idx = nameToIndex[name];
        var track = new LiveAPI("live_set tracks " + idx);
        if (track.get("is_foldable")[0] === 1) continue; // group tracks have no arm state — skip
        var isTarget = RECORD_TRACKS.indexOf(name) !== -1;
        track.set("arm", isTarget ? 1 : 0);
        if (isTarget) track.set("current_monitoring_state", 2);
    }

    var targetIndices = [];
    for (var r = 0; r < RECORD_TRACKS.length; r++) {
        if (nameToIndex[RECORD_TRACKS[r]] === undefined) {
            post("record_take: track not found: " + RECORD_TRACKS[r] + "\n");
            return;
        }
        targetIndices.push(nameToIndex[RECORD_TRACKS[r]]);
    }

    // --- 2: first free row across the 5 record tracks ---
    var sceneIndex = findFirstFreeRow(targetIndices, song.getcount("scenes"));
    if (sceneIndex === -1) {
        post("record_take: no free row found\n");
        return;
    }
    pendingTrackIndices = targetIndices;
    pendingSceneIndex = sceneIndex;

    // --- compute real quantized start time, no observer needed ---
    var tempo = song.get("tempo")[0];
    var quarterMs = 60000 / tempo;
    var numerator = song.get("signature_numerator")[0];
    var denominator = song.get("signature_denominator")[0];
    var beatMs = quarterMs * (4 / denominator);
    var barMs = beatMs * numerator;

    var quantSetting = song.get("clip_trigger_quantization")[0];
    var quantBeats = QUANT_BEATS[quantSetting] !== undefined ? QUANT_BEATS[quantSetting] : numerator;
    var currentBeat = song.get("current_song_time")[0];
    var beatsUntilStart = quantBeats > 0 ? mod(quantBeats - mod(currentBeat, quantBeats), quantBeats) : 0;
    var msUntilStart = beatsUntilStart * beatMs;

    var totalMs = msUntilStart + (barMs * BARS_TO_RECORD);
    var fireAt = Math.max(totalMs - STOP_MARGIN_MS, 0);

    post("record_take: quant=" + quantSetting + " beatsUntilStart=" + beatsUntilStart +
         " fireAt=" + Math.round(fireAt) + "ms\n");

    if (stopTask) stopTask.cancel();
    stopTask = new Task(stopRecording, this);
    stopTask.schedule(fireAt);

    // --- 3: fire all 5 (quantized record start) ---
    for (var t = 0; t < targetIndices.length; t++) {
        var s = new LiveAPI("live_set tracks " + targetIndices[t] + " clip_slots " + sceneIndex);
        s.call("fire");
    }
}

function stopRecording() {
    // --- 4 & 5: stop recording / immediately start clip playback ---
    for (var t = 0; t < pendingTrackIndices.length; t++) {
        var s = new LiveAPI("live_set tracks " + pendingTrackIndices[t] + " clip_slots " + pendingSceneIndex);
        s.call("fire");
    }
	
	// --- disarm the 5 record tracks now that the take is done ---
    for (var a = 0; a < pendingTrackIndices.length; a++) {
        var track = new LiveAPI("live_set tracks " + pendingTrackIndices[a]);
        track.set("arm", 0);
    }


    // --- 7 & 8: NOW reset the DRMCTRL trigger clips ---
    var song = new LiveAPI("live_set");
    var trackCount = song.getcount("tracks");
    var nameToIndex = {};
    for (var i = 0; i < trackCount; i++) {
        var t = new LiveAPI("live_set tracks " + i);
        nameToIndex[t.get("name")[0]] = i;
    }

    for (var d = 0; d < DRUM_TRACKS.length; d++) {
        var dIdx = nameToIndex[DRUM_TRACKS[d]];
        if (dIdx === undefined) {
            post("record_take: track not found: " + DRUM_TRACKS[d] + "\n");
            continue;
        }
        var slot = new LiveAPI("live_set tracks " + dIdx + " clip_slots 0");
        if (slot.get("has_clip")[0] === 1) {
            var clip = new LiveAPI("live_set tracks " + dIdx + " clip_slots 0 clip");
            clip.call("remove_notes_extended", 0, 127, 0, 1000000);
        }
    }
}

function findFirstFreeRow(trackIndices, sceneCount) {
    for (var s = 0; s < sceneCount; s++) {
        var allEmpty = true;
        for (var t = 0; t < trackIndices.length; t++) {
            var slot = new LiveAPI("live_set tracks " + trackIndices[t] + " clip_slots " + s);
            if (slot.get("has_clip")[0] === 1) { allEmpty = false; break; }
        }
        if (allEmpty) return s;
    }
    return -1;
}

function mod(a, b) {
    return ((a % b) + b) % b;
}