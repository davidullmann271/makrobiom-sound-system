autowatch = 1;
inlets = 1;
outlets = 0;

var GROUPS = ["subs", "snrs", "hats", "perc", "fx"];
var BARS_TO_RECORD = 4;
var STOP_MARGIN_MS = 150;

var stopTask = null;
var pendingDestIndices = null;
var pendingMuteIndices = null;
var pendingSceneIndex = null;
var pendingIsResample = false;

var QUANT_BEATS = {
    0: 0, 1: 32, 2: 16, 3: 8, 4: 4, 5: 2, 6: 2,
    7: 1, 8: 1, 9: 0.5, 10: 0.5, 11: 0.25, 12: 0.25, 13: 0.125
};

function runStaggered(workers, delayMs, onDone) {
    var i = 0;
    function step() {
        if (i >= workers.length) {
            if (onDone) onDone();
            return;
        }
        workers[i]();
        i++;
        var t = new Task(step, this);
        t.schedule(delayMs);
    }
    step();
}

// ---------- shared helpers ----------

function mod(a, b) { return ((a % b) + b) % b; }

function getNameToIndex(song) {
    var count = song.getcount("tracks");
    var map = {};
    for (var i = 0; i < count; i++) {
        var t = new LiveAPI("live_set tracks " + i);
        map[t.get("name")[0]] = i;
    }
    return map;
}

function resolveGroupTracks(nameToIndex) {
    var g = {};
    for (var i = 0; i < GROUPS.length; i++) {
        var base = GROUPS[i];
        var roles = {
            base: nameToIndex[base],
            raw: nameToIndex[base + " raw"],
            saveA: nameToIndex[base + " save"],
            saveB: nameToIndex[base + " save 2"]
        };
        for (var key in roles) {
            if (roles[key] === undefined) {
                post("routing: missing track for '" + base + "' (" + key + ")\n");
                return null;
            }
        }
        g[base] = roles;
    }
    return g;
}

function highestFilledRow(trackIndex, sceneCount) {
    var highest = -1;
    for (var s = 0; s < sceneCount; s++) {
        var slot = new LiveAPI("live_set tracks " + trackIndex + " clip_slots " + s);
        if (slot.get("has_clip")[0] === 1) {
            highest = s;
        } else if (highest !== -1) {
            break; // contiguous fill assumed -- stop once past the last used row
        }
    }
    return highest;
}

function determineSourceDest(roles, sceneCount) {
    var hiA = highestFilledRow(roles.saveA, sceneCount);
    var hiB = highestFilledRow(roles.saveB, sceneCount);
    if (hiA === -1 && hiB === -1) {
        return { source: null, dest: roles.saveA };
    }
    if (hiA >= hiB) {
        return { source: roles.saveA, dest: roles.saveB };
    } else {
        return { source: roles.saveB, dest: roles.saveA };
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

// ---------- routing (confirmed working against your set) ----------

function setAudioFromTrack(trackIndex, sourceTrackName, channelKeyword) {
    var track = new LiveAPI("live_set tracks " + trackIndex);

    var typeRaw = JSON.parse(track.get("available_input_routing_types")[0]);
    var typeList = typeRaw.available_input_routing_types;
    var chosenType = null;
    for (var i = 0; i < typeList.length; i++) {
        if (typeList[i].display_name === sourceTrackName) {
            chosenType = typeList[i].identifier;
            break;
        }
    }
    if (chosenType === null) {
        post("routing: could not find input source '" + sourceTrackName + "' on track " + trackIndex + "\n");
        return false;
    }
    track.set("input_routing_type", JSON.stringify({ identifier: chosenType }));

    if (channelKeyword) {
        var chanRaw = JSON.parse(track.get("available_input_routing_channels")[0]);
        var chanList = chanRaw.available_input_routing_channels;
        for (var j = 0; j < chanList.length; j++) {
            if (chanList[j].display_name && chanList[j].display_name.indexOf(channelKeyword) !== -1) {
                track.set("input_routing_channel", JSON.stringify({ identifier: chanList[j].identifier }));
                break;
            }
        }
    }
    return true;
}

// ---------- shared record choreography ----------

function startTake(destIndices, isResample) {
    var song = new LiveAPI("live_set");
    var sceneCount = song.getcount("scenes");

    var trackIndicesArr = [];
    for (var g in destIndices) trackIndicesArr.push(destIndices[g]);

    var sceneIndex = findFirstFreeRow(trackIndicesArr, sceneCount);
    if (sceneIndex === -1) {
        post("record: no free row found\n");
        return;
    }

    var destSet = {};
    for (var di = 0; di < trackIndicesArr.length; di++) destSet[trackIndicesArr[di]] = true;

    var trackCount = song.getcount("tracks");
    for (var ti = 0; ti < trackCount; ti++) {
        var trk = new LiveAPI("live_set tracks " + ti);
        if (trk.get("is_foldable")[0] === 1) continue; // group tracks have no arm state
        trk.set("arm", destSet[ti] ? 1 : 0);
    }

    for (var gi = 0; gi < trackIndicesArr.length; gi++) {
        var t = new LiveAPI("live_set tracks " + trackIndicesArr[gi]);
        t.set("current_monitoring_state", 2);
    }

    pendingDestIndices = destIndices;
    pendingSceneIndex = sceneIndex;
    pendingIsResample = isResample;

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

    if (stopTask) stopTask.cancel();
    stopTask = new Task(stopTake, this);
    stopTask.schedule(fireAt);

    for (var f = 0; f < trackIndicesArr.length; f++) {
        var s = new LiveAPI("live_set tracks " + trackIndicesArr[f] + " clip_slots " + sceneIndex);
        s.call("fire");
    }
}

function stopTake() {
    for (var g in pendingDestIndices) {
        var s = new LiveAPI("live_set tracks " + pendingDestIndices[g] + " clip_slots " + pendingSceneIndex);
        s.call("fire");

        var t = new LiveAPI("live_set tracks " + pendingDestIndices[g]);
        t.set("arm", 0);
        t.set("mute", 0);

        if (pendingMuteIndices && pendingMuteIndices[g] !== null && pendingMuteIndices[g] !== undefined) {
            var other = new LiveAPI("live_set tracks " + pendingMuteIndices[g]);
            other.set("mute", 1);
        }
    }

    var song = new LiveAPI("live_set");
    var nameToIndex = getNameToIndex(song);
    var groupTracks = resolveGroupTracks(nameToIndex);

    if (pendingIsResample) {
        if (groupTracks) {
            for (var gi = 0; gi < GROUPS.length; gi++) {
                setAudioFromTrack(groupTracks[GROUPS[gi]].base, GROUPS[gi] + " raw", null);
            }
        }
    } else {
        clearDrumTriggerClips();
    }
}

function clearDrumTriggerClips() {
    var DRUM_TRACKS = ["DRMCTRL 1", "DRMCTRL 2", "DRMCTRL 4", "DRMCTRL 8", "DRMCTRL 16"];
    var song = new LiveAPI("live_set");
    var nameToIndex = getNameToIndex(song);
    for (var d = 0; d < DRUM_TRACKS.length; d++) {
        var dIdx = nameToIndex[DRUM_TRACKS[d]];
        if (dIdx === undefined) {
            post("clear: track not found: " + DRUM_TRACKS[d] + "\n");
            continue;
        }
        var slot = new LiveAPI("live_set tracks " + dIdx + " clip_slots 0");
        if (slot.get("has_clip")[0] === 1) {
            var clip = new LiveAPI("live_set tracks " + dIdx + " clip_slots 0 clip");
            clip.call("remove_notes_extended", 0, 127, 0, 1000000);
        }
    }
}

// ---------- button 1: main drum recording ----------

function recordmain() {
    var song = new LiveAPI("live_set");
    var nameToIndex = getNameToIndex(song);
    var groupTracks = resolveGroupTracks(nameToIndex);
    if (!groupTracks) return;
    var sceneCount = song.getcount("scenes");

    var destIndices = {};
    var otherIndices = {};

    for (var i = 0; i < GROUPS.length; i++) {
        var g = GROUPS[i];
        var roles = groupTracks[g];

        setAudioFromTrack(roles.base, g + " raw", null);

        var sd = determineSourceDest(roles, sceneCount);
        destIndices[g] = sd.dest;
        otherIndices[g] = sd.source;
    }

    pendingMuteIndices = otherIndices;
    startTake(destIndices, false);
}

// ---------- button 2: resample recording ----------

function resample() {
    var song = new LiveAPI("live_set");
    var nameToIndex = getNameToIndex(song);
    var groupTracks = resolveGroupTracks(nameToIndex);
    if (!groupTracks) return;
    var sceneCount = song.getcount("scenes");

    var destIndices = {};
    var otherIndices = {};

    for (var i = 0; i < GROUPS.length; i++) {
        var g = GROUPS[i];
        var roles = groupTracks[g];
        var sd = determineSourceDest(roles, sceneCount);
        if (sd.source === null) {
            post("resample: '" + g + "' has no recorded take yet -- run Main Rec first\n");
            return;
        }
        var sourceName = (sd.source === roles.saveA) ? (g + " save") : (g + " save2");
        setAudioFromTrack(roles.base, sourceName, "Post FX");

        var sourceTrack = new LiveAPI("live_set tracks " + sd.source);
        sourceTrack.set("mute", 1);

        destIndices[g] = sd.dest;
        otherIndices[g] = sd.source;
    }

    pendingMuteIndices = otherIndices;
    startTake(destIndices, true);
}

// ---------- utility buttons ----------

function forcesave() {
    var song = new LiveAPI("live_set");
    var nameToIndex = getNameToIndex(song);
    var groupTracks = resolveGroupTracks(nameToIndex);
    if (!groupTracks) return;
    var sceneCount = song.getcount("scenes");

    var workers = [];
    GROUPS.forEach(function(g) {
        workers.push(function() {
            var roles = groupTracks[g];
            var sd = determineSourceDest(roles, sceneCount);
            if (sd.source === null) {
                post("forcesave: '" + g + "' has no recorded take yet\n");
                return;
            }
            var sourceName = (sd.source === roles.saveA) ? (g + " save") : (g + " save2");
            setAudioFromTrack(roles.base, sourceName, "Post FX");
            var sourceTrack = new LiveAPI("live_set tracks " + sd.source);
            sourceTrack.set("mute", 1);
        });
    });
    runStaggered(workers, 30);
}

function forceraw() {
    var song = new LiveAPI("live_set");
    var nameToIndex = getNameToIndex(song);
    var groupTracks = resolveGroupTracks(nameToIndex);
    if (!groupTracks) return;
    var sceneCount = song.getcount("scenes");

    var workers = [];
    GROUPS.forEach(function(g) {
        workers.push(function() {
            var roles = groupTracks[g];
            setAudioFromTrack(roles.base, g + " raw", null);
            var sd = determineSourceDest(roles, sceneCount);
            if (sd.source !== null) {
                var sourceTrack = new LiveAPI("live_set tracks " + sd.source);
                sourceTrack.set("mute", 0);
            }
        });
    });
    runStaggered(workers, 30);
}