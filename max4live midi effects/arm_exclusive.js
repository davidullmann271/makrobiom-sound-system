autowatch = 1;
inlets = 1;
outlets = 0;

// Button 1..5 selects a length. Each length exists as a DRMCTRL track and a
// SMPLCTRL track; both are armed together, and every other managed track is
// disarmed, so the two engines always follow the same selection.
var PREFIXES = ["DRMCTRL", "SMPLCTRL"];
var SUFFIXES = ["1", "2", "4", "8", "16"];

var MANAGED = buildManaged();

function buildManaged() {
    var all = [];
    for (var p = 0; p < PREFIXES.length; p++) {
        for (var s = 0; s < SUFFIXES.length; s++) {
            all.push(PREFIXES[p] + " " + SUFFIXES[s]);
        }
    }
    return all;
}

function msg_int(buttonIndex) {
    if (buttonIndex < 1 || buttonIndex > SUFFIXES.length) return;
    var suffix = SUFFIXES[buttonIndex - 1];

    var targets = [];
    for (var p = 0; p < PREFIXES.length; p++) {
        targets.push(PREFIXES[p] + " " + suffix);
    }

    var song = new LiveAPI("live_set");
    var trackIds = song.get("tracks"); // ["id", n0, "id", n1, ...]

    for (var i = 1; i < trackIds.length; i += 2) {
        var track = new LiveAPI("id " + trackIds[i]);
        var name = track.get("name")[0];
        if (MANAGED.indexOf(name) === -1) continue; // skip unrelated tracks
        track.set("arm", targets.indexOf(name) !== -1 ? 1 : 0);
    }
}
