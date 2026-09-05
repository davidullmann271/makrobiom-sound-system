autowatch = 1;
inlets = 1;   // bang / "bind" -- resolve the target and hand the id to live.remote~
outlets = 1;  // "id <n>" into [live.remote~] right inlet

// -----------------------------------------------------------------------------
// autoswitchoff_target.js -- binds live.remote~ to one named parameter.
//
// The device used to carry a hardcoded index path:
//
//     goto live_set tracks 10 devices 2 parameters 17
//
// Track indices move whenever a track is added, deleted or reordered anywhere
// above the target, and they count group tracks too, so that path silently
// started pointing at a different track (or at nothing). The three names below
// do not move. They are still hardcoded -- this is a lookup, not a search: the
// names are fixed, and if any one of them does not match, the device binds
// nothing and says so in the Max Console rather than grabbing a wrong parameter.
//
// Chain on DRMAUD is: [effect rack] -> [Limiter] -> [Beat Repeat].
// -----------------------------------------------------------------------------

var TRACK_NAME  = "DRMAUD";        // group audio track
var DEVICE_CLASS = "BeatRepeat";   // class_name, so renaming the device is fine
var PARAM_NAME  = "Repeat";        // the toggle button, range 0..1

function bang() { bind(); }

function bind() {
    var song = new LiveAPI("live_set");
    var ntr = song.getcount("tracks");

    for (var i = 0; i < ntr; i++) {
        var tpath = "live_set tracks " + i;
        var tr = new LiveAPI(tpath);
        if (String(tr.get("name")) !== TRACK_NAME) continue;

        var ndev = tr.getcount("devices");
        for (var d = 0; d < ndev; d++) {
            var dpath = tpath + " devices " + d;
            var dev = new LiveAPI(dpath);
            if (String(dev.get("class_name")) !== DEVICE_CLASS) continue;

            var npar = dev.getcount("parameters");
            for (var p = 0; p < npar; p++) {
                var par = new LiveAPI(dpath + " parameters " + p);
                if (String(par.get("name")) !== PARAM_NAME) continue;

                outlet(0, "id", par.id);
                post("autoswitchoff: bound to " + TRACK_NAME + " / " + DEVICE_CLASS +
                     " / " + PARAM_NAME + "  (" + dpath + " parameters " + p +
                     ", range " + par.get("min") + ".." + par.get("max") + ")\n");
                return;
            }
            fail("device found but it has no parameter named \"" + PARAM_NAME + "\"");
            return;
        }
        fail("track \"" + TRACK_NAME + "\" has no " + DEVICE_CLASS + " device");
        return;
    }
    fail("no track named \"" + TRACK_NAME + "\"");
}

function fail(why) {
    post("autoswitchoff: NOT BOUND -- " + why + ". Nothing will be switched.\n");
}

// Print the whole chain, for when a name has drifted and you need to see why.
function dump() {
    var song = new LiveAPI("live_set");
    var ntr = song.getcount("tracks");
    for (var i = 0; i < ntr; i++) {
        var tr = new LiveAPI("live_set tracks " + i);
        var nm = String(tr.get("name"));
        if (nm !== TRACK_NAME) continue;
        post("autoswitchoff: tracks " + i + " \"" + nm + "\"\n");
        var ndev = tr.getcount("devices");
        for (var d = 0; d < ndev; d++) {
            var dev = new LiveAPI("live_set tracks " + i + " devices " + d);
            post("   devices " + d + "  " + String(dev.get("class_name")) +
                 "  \"" + String(dev.get("name")) + "\"\n");
            if (String(dev.get("class_name")) !== DEVICE_CLASS) continue;
            var npar = dev.getcount("parameters");
            for (var p = 0; p < npar; p++) {
                var par = new LiveAPI("live_set tracks " + i + " devices " + d +
                                      " parameters " + p);
                post("      parameters " + p + "  \"" + String(par.get("name")) + "\"\n");
            }
        }
        return;
    }
    post("autoswitchoff: no track named \"" + TRACK_NAME + "\"\n");
}
