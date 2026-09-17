# Iterative resampling with Looper — findings

Sessions 2026-09-06 / 2026-09-07. Melodic looper concept, not the drum set.

Three topologies were tried. The first is the current one; the two below it are
kept as history.

---

# Current topology — SRC / LOOP / SHAPE

Found by trial and error, 2026-09-07. Simplest and most robust of the three.

| track | Audio From | Monitor | Audio To |
|---|---|---|---|
| `SRC` | input | In | `SHAPE` |
| `LOOP` | `SHAPE` / Post FX | In | Sends Only |
| `SHAPE` | `LOOP` / `Insert - Looper` | Auto | Main |

`LOOP`: Input → Output **Always**, Feedback **0%**.
`SHAPE`: holds the effect chain, and is also where clips are recorded when wanted.

## What it gives

- **Only `SHAPE` is audible.** `LOOP` goes to Sends Only, `SRC` goes to `SHAPE`.
  Everything you hear is the shaper output — playing either the Looper buffer or a
  clip recorded from it.
- **True iterative resampling with free generations.** Nothing caps how many
  passes you take.
- **No gain creep, verified.** Recording to the Looper from `SRC`, or from `SHAPE`
  playback with effects engaged and then reset, returns the exact same sound — no
  added gain, no added anything.
- Simplest and most robust so far.

## Proven in use

**11 generations**, from one basic synth through three basic effects. Gain did not
increase, no drift was recorded, everything stayed punctual. The output at that
depth is nothing you could have predicted from the source — the compounding is the
instrument.

The run used **Overdub → Play → Overdub → Play**, Looper only, with occasional
`SRC` injections along the way. No clips were recorded; they haven't been needed
yet. So the clip path below is proven correct but not yet part of the working
method — overdub chaining is.

That 11 generations survive at all is the real result. Half a dB of creep per pass
or any phase smear and the chain dies around gen 4 or 5.

## Why the clip capture is clean

A track records the signal arriving at its **input**, and the Pre FX / Post FX /
Post Mixer choice taps the *source* track, never the recording one (Live 12
manual, Routing and I/O). So a clip recorded on `SHAPE` stores what comes through
the `Insert - Looper` tap — the unshaped generation — not `SHAPE`'s own chain
output. The chain then shapes that clip on playback exactly as it shapes the
Looper buffer, which is why resetting the effects returns you to the same sound.

This also answers the old open question: Live records **pre** the recording
track's own device chain. `SHAPE` can therefore be its own capture track, and a
separate `CAP` track is unnecessary.

Monitor **Auto** is what makes the swap seamless. The manual: "Monitoring is on
when the track is armed, but monitoring is inhibited as long as the track is
playing clips." So `SHAPE` hears the Looper buffer while idle, and the clip the
moment one is launched — no routing change, no fader juggling.

---

# Verified findings (apply to all topologies)

- **The `Insert - Looper` tap carries the Looper's buffer.** Tested: loop playing,
  source silent, `SHAPE` fader at −inf, Spectrum first in chain → signal present.
  So the loop really is sent out through the FX chain and written back. Ableton's
  Feedback Routing description (manual 28.25.1) holds.
- **`LOOP` + `SHAPE` alone is a complete iterative resampler.** Two tracks. Every
  overdub pass reprocesses the whole buffer, not just live playing.
- **Live accepts `CAP → SHAPE`**, i.e. a cycle that passes through a Looper insert.
  Confirms the insert point is a legal cycle break.
- **Live's audio graph must be acyclic. The only cycle it permits is one that
  passes through a Looper insert.** This is why clip-only ping-pong is impossible
  without runtime routing changes.
- **No VST or M4L device can add an insert point.** Live's track I/O choosers only
  ever offer Pre FX / Post FX / Post Mixer plus device-contributed inserts, and
  Looper is the only device that contributes one. Cycling '74's Audio Routes
  system does not appear in Live's choosers either — its routings live in the
  device's own popups. The Looper insert is therefore not replaceable.
- **Runtime routing switching is disruptive** (freeze / glitch, seen before this
  session). Not a viable route. Rules out every swap-based design.
- **Feedback is a decay control, not a replace control.** At 0% everything is
  wiped at the wrap, including material written during that pass → silence.
  Useful range ~50–70%. Hard replace = capture to clip, clear, reload.
  **Measured in the earlier topology.** In the current one Feedback stays at 0%
  and nothing is wiped, because the buffer returns through `SHAPE` into the
  Looper's input on every pass — external feedback replaces the internal kind.
  Verified by 11 generations; the explanation is inference, not tested.
- **Live records pre the recording track's own device chain.** See above.

## Traps

- **Looper Input→Output governs all monitoring.** Everything routed through the
  Looper becomes audible-or-not depending on Looper state. Source of most of the
  first session's confusion. Keep monitoring paths out of the Looper where possible.
- **A track with Audio From = No Input has no Monitor row**, and the first pass
  won't record. A recording track needs a real input.
- **Track fader controls what a track sends to another track.** Useful for
  killing an injection without touching routing.
- **Loop-boundary click** = the gesture doesn't wrap. A sweep during a pass
  records a one-way ramp into a circular buffer. Fix: hold the setting for the
  whole pass and change it *between* passes, or make motion periodic and
  loop-locked (LFO / clip envelope whose period divides the loop).
- **Bypass ≠ reset.** If the chain stays on, its zero state must be *silent*
  (Utility at −inf on a macro), not neutral pass-through — a neutral chain
  re-injects a copy of the buffer and doubles it.
- **Looper has no declicking and no editable loop points. Clips have both**
  (up to 4 ms fades on clip edges). Looper = workspace, clips = performance.
- **A Session clip auto-plays when recording ends.** Stop it immediately if
  something else is already sounding, or two sources double.
- **Play → Overdub is not quantized.** Looper's Quantization governs the start and
  stop transitions — Record → Play lands on the grid — but Overdub engages
  instantly whatever it is set to. Reported consistently on the Ableton forum;
  the manual's Looper section was not readable to confirm. **This is the one rough
  edge in the working method**, which chains Overdub → Play by hand. Record-based
  iteration would not hit it, since Record → Play is quantized.
  **Solved 2026-09-10** by driving Overdub from a clip instead of by hand — see
  `looper_overdub_bridge` below. Tested: overdub start and stop land on the bar.

## Settings that matter

Looper: Tempo Control **Follow song tempo** (never *Set & Follow*), Song Control
**None**, Record Length **fixed bars**, Quantization **None** (since 2026-09-17,
was **1 Bar**; only the clips are quantized now, record notes sit on the bar).
Audio: **32-bit** — internal recording loss compounds per generation.
`SHAPE`: **Limiter last** — this is a real feedback loop.

## Open / untested

- ~~Whether Looper **Stop → Play** resumes in phase or restarts at loop position 0.~~
  **Answered 2026-09-10:** a Looper that was *recorded* and then stopped always
  starts its beat 1 on transport 1. One whose content came from Clear-in-Overdub
  does not — see the bridge findings below.
- Whether Looper **Undo** restores material lost to low Feedback.
- ~~Latency drift across generations (check by gen 3; fix with Track Delay).~~
  **Answered 2026-09-17:** no latency drift across generations.
- Macro Variations "Launch" button — MIDI-mappable or not.
- ~~Whether Looper's transport state is **automatable** from a clip envelope.~~
  Moot: `looper_overdub_bridge` drives the Looper from a clip through the Live
  API, no envelope needed.

## Devices still to build

- ~~**momentary Overdub**~~ — **built 2026-09-10 as `looper_overdub_bridge`**,
  clip-driven rather than a press-and-count device. See below.
- **grid-aligned `SHAPE` amount** — `track_gate`-style ramp, no hard switching.

---

# Driving the Looper from clips — `looper_overdub_bridge`

**Deprecated 2026-09-17:** moved to `max4live midi effects/deprecated/` and
superseded by `looper_bridge` (same C0/C1 behaviour, plus the short bass
Loopers; see `looper_bridge_README.txt`). Kept below as the tested history.

Built and tested 2026-09-10. Max MIDI Effect on a dedicated MIDI track, one per
loop track. Files (now in `deprecated/`): `looper_overdub_bridge.js`,
`.maxpat`, `_README.txt`.

| input | Looper call |
|---|---|
| C0 (note 24) note-on | `record` — note-off ignored |
| C1 (note 36) note-on / note-off | `overdub` / `play` |
| transport stop | nothing (the `stop` + `clear` was removed 2026-09-17) |

The target Looper is found by the track name typed into each instance.

**2026-09-17:** the Loopers should keep their contents when the song stops, so
the transport clear is gone from this bridge and from `bass_looper_bridge`.
Emptying is now a separate MIDI-mappable button, `looper_clear_all` (stop, then
clear, on every Looper named in its fields). The cycle below is the tested
2026-09-10 version.

## The cycle — tested, everything lands on the bar

1. Song stopped → Looper empty (cleared at the last stop).
2. *(Quantization 1 Bar, as tested then — now None with C0 on the bar.)*
   C0 just before bar 5 (4.4.4). The Record call arrives a few ms after the note
   but still before the bar, so Looper Quantization 1 Bar starts the recording
   exactly on bar 5. Record Length 4 bars ends it; Looper then goes to Play.
3. C1 after that: one note spanning 4 bars = one overdub pass = one generation.
4. Transport stop → full clear, ready for the next C0.

## Looper findings from building it

- **The Live API has a `LooperDevice` class** with callable `record`, `overdub`,
  `play`, `stop`, `clear`, `undo` and more. Nothing sets the playback position.
- **Every Live API call is deferred** to Live's main thread (live.object
  refpage), so a call lands a few ms after the note that sent it. A note placed
  *before* the bar line plus Looper Quantization turns that into an exact start.
- **Song Control only goes one way.** The Looper can start or stop the song;
  no setting makes it follow the transport. With several Loopers: None.
- **A Looper that was recorded and then stopped starts its beat 1 on transport
  1**, every time.
- **Clear in Overdub keeps the length, even with the transport stopped** — the
  manual only promises it while the transport runs. But the Looper then loses
  its transport lock: Play afterwards free-runs out of phase, Stop afterwards
  means it no longer starts with the transport. Not usable as a reset.
- **An unquantized start keeps the timing.** A fixed-length recording replays
  what it heard exactly one loop length later, so on-grid playing stays on
  grid; a start a few ms off the bar only moves the loop seam. Reasoning, not
  measured. This is why the Loopers run unquantized since 2026-09-17.
- **Stop and Clear back to back left an overdubbing Looper stopped but not
  cleared** (bass short Loopers, 2026-09-17). The bridges now clear 100 ms after
  the stop. Cause assumed, not proven.
- **Clear in any other mode resets length and tempo** (manual). Hence Stop
  before Clear — then on transport stop, now in `looper_clear_all`.
- **Overdub into an empty Looper made an unreliable first pass** in the first
  bridge build. Cause not investigated; C0 → Record replaced it.
- **Live's note names:** middle C (60) is C3, so C0 = 24 and C1 = 36.

---

# Superseded: LOOP / SHAPE with CAP archive

The first working version.

| track | Audio From | Audio To |
|---|---|---|
| `SRC` | input | `SHAPE` |
| `LOOP` | `SRC` / Post FX | Main |
| `SHAPE` | `LOOP` / `Insert - Looper` | `LOOP` / `Insert - Looper` |

`CAP` (Audio From `LOOP` / Post FX) was an optional archive track.

Traps specific to it: the source arrived twice — dry via `LOOP`'s tap, shaped via
`SHAPE` — and `SRC`'s fader controlled only the shaped path, because output
routing is post-mixer while the Post FX tap is not.

# Superseded: INPUT group + CAP clips

Sketched at the end of the first session, never fully verified.

```
INPUT (audio group)          Audio To -> SHAPE
  SRC   (audio track)        Audio To -> parent,  monitor ON
  CAP   (audio track)        Audio From: LOOP,  Audio To -> parent,  monitor OFF
LOOP                         Audio From: SHAPE,  Audio To: Main,  monitor In
SHAPE                        Audio From / To: LOOP / Insert - Looper,  monitor In
```

Iteration was by Record into a cleared Looper rather than Overdub, with the group
acting as a summing point for source and clips. Superseded by the current
topology, which reaches the same hard-replace behaviour with three tracks instead
of four plus a group, and without needing `CAP` at all — `SHAPE` records its own
clips because recording taps the input, not the chain.

Its one lasting warning: **a capture track's Monitor must be explicitly Off, never
Auto**, if that track feeds the shaper. Arming a track set to Auto turns
monitoring on, passing its input straight through and closing a live feedback loop
with no buffer in it.

---

# Rejected alternatives

Considered on 2026-09-07 and ruled out, so they don't get re-proposed:

- **Resampling input as the return path.** Sidesteps the acyclic rule, since
  Resampling taps Main rather than a track. Unusable here — it drags the entire
  mix into the capture.
- **Fixed record/play split** (`PLAY → SHAPE → REC`, acyclic). Needs a mouse drag
  per generation to promote a clip back to the source track. The set is played
  without a mouse.
- **Ladder of tracks**, each carrying a copy of the shaper rack and taking input
  from the previous track Post FX. Acyclic and fully mappable, but caps generations
  at the track count, cannot wrap, and spends a rack of CPU per stage.
- **Audio-interface loopback.** The only route to unbounded generations without
  the Looper. Hardware-dependent; unnecessary given the current topology.
