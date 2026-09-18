autowatch = 1;
inlets = 1;
outlets = 0;

// Button 1..5 clears all MIDI notes from the first-row clip of the matching
// DRMCTRL track AND its SMPLCTRL counterpart — the two engines are cleared
// together as one action.
var PREFIXES = ["DRMCTRL", "SMPLCTRL"];
var SUFFIXES = ["1", "2", "4", "8", "16"];
var CLEAR_ROW = 0; // first row

function msg_int(buttonIndex) {
    if (buttonIndex < 1 || buttonIndex > SUFFIXES.length) return;
    var suffix = SUFFIXES[buttonIndex - 1];
    for (var p = 0; p < PREFIXES.length; p++) {
        clearTrack(PREFIXES[p] + " " + suffix);
    }
}

// optional: clears all lengths on both engines at once
function clear_all() {
    for (var s = 0; s < SUFFIXES.length; s++) {
        for (var p = 0; p < PREFIXES.length; p++) {
            clearTrack(PREFIXES[p] + " " + SUFFIXES[s]);
        }
    }
}

function clearTrack(targetName) {
    var song = new LiveAPI("live_set");
    var trackCount = song.getcount("tracks");

    for (var i = 0; i < trackCount; i++) {
        var track = new LiveAPI("live_set tracks " + i);
        if (track.get("name")[0] !== targetName) continue;

        var base = "live_set tracks " + i + " clip_slots " + CLEAR_ROW;
        var slot = new LiveAPI(base);
        if (slot.get("has_clip")[0] !== 1) {
            post("drmctrl_clear: no clip on row " + CLEAR_ROW + " of " + targetName + "\n");
            return;
        }
        var clip = new LiveAPI(base + " clip");
        clip.call("remove_notes_extended", 0, 127, 0, 1000000);
        return;
    }
    post("drmctrl_clear: track not found: " + targetName + "\n");
}
