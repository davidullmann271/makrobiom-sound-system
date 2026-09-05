# makrobiom sound system

Live-performance drum system: a touchOSC surface drives an Ableton Live set, a
Sugar Bytes DrumComputer engine, and a set of custom Max for Live devices that
handle recording, muting and clearing on musical boundaries.

---

## Components

- **touchOSC** — control surface, `makrobiom_v4.tosc` + 5 Lua scripts
- **Ableton Live** — `makrobiom_drums_v4.als` (42 tracks)
- **Max for Live** — 8 MIDI effects, 2 audio effects
- **Sugar Bytes DrumComputer** — drum engine, `makrobiom_midicc.sbm` CC map + 20 preset banks
- **oeksound EQ** — mixing

---

## Current capabilities

- Play drums from MIDI into DrumComputer, no generated drums in Live
- Record a take into one of 5 length slots (1/4, 1/2, 1, 2, 4 bars)
- Only one length armed at a time, drum + sampler engines armed together
- Clear a length's pattern, per length or all at once
- Global loop-length ceiling across all lengths
- Mute/unmute drum groups (subs / snrs / hats / perc) on musical boundaries
- Mute/unmute recorded audio tracks on musical boundaries
- Momentary Beat Repeat, auto-released on the phrase grid
- Per-group delay / reverb / Valhalla sends, master filter XY
- Undo / redo / tap tempo from the surface
- Swing via Live's Groove Pool (global Groove Amount, switched not swept)

---

## Ableton project

### Track tree

```
UTILITY CH2                     4x M4L midi
UTILITY CH9                     1x M4L midi
DRMCTRL (group)
  in DRMCTRL
  DRMCTRL 1 / 2 / 4 / 8 / 16    1x M4L midi each
  out DRMCTRL                   1x M4L midi
DRMCOMP                         Sugar Bytes DrumComputer (VST)
SMPLCTRL (group)
  in SMPLCTRL
  SMPLCTRL 1 / 2 / 4 / 8 / 16
  out SMPLCTRL                  1x M4L midi
temp (audio) / temp (midi)
DRMAUD (group)                  FX rack -> Limiter -> Beat Repeat -> M4L audio
  subs aud                      FX rack
    subs                          subs eng (Limiter), subs smpl (Limiter)
    subs save                   M4L audio
  snrs aud                      FX rack
    snrs                          snrs eng, snrs smpl
    snrs save                   M4L audio
  hats aud                      FX rack, Compressor
    hats                          hats eng, hats smpl
    hats save                   M4L audio
  perc aud                      FX rack, Compressor
    perc                          perc eng, perc smpl
    perc save                   M4L audio
```

### Pattern

- `DRMCTRL n` / `SMPLCTRL n` — one track per loop length, armed exclusively
- `* eng` — live engine output; `* smpl` — sampler; `* save` — recorded take
- `* aud` groups carry the per-group FX rack; `DRMAUD` is the master bus

---

## Max for Live devices

### MIDI effects

| device | purpose | how |
|---|---|---|
| **note_gate_eng** | mute drum groups without stopping the clip | `[table pitchallow]` lookup per pitch gates note-ons; note-offs always pass. Mutes land on the next beat, un-mutes on the next bar — two `[delay @quantize]` one-shots armed by the push |
| **arm_exclusive** | one length armed at a time | button 1–5 arms the matching DRMCTRL + SMPLCTRL pair, disarms all others |
| **drmctrl_clear** | wipe a length's pattern | clears all MIDI notes from the first-row clip of a DRMCTRL track and its SMPLCTRL counterpart |
| **drums_save_and_reset** | record a take, then reset | records the clips, launches the base dummy clips at the closing bar line, clears both engines after the take |
| **LoopCeiling** | cap all loop lengths at once | track name encodes natural length; sets `loop_end = loop_start + min(natural, L)`. Stateless. Hardcoded to CC 43 |
| **midi_undo_redo** | undo / redo from the surface | sends Ctrl+Z / Ctrl+Shift+Z |

### Audio effects

| device | purpose | how |
|---|---|---|
| **track_gate** | switch a track's sound on the grid | `live.toggle` stores into `[int]` cold inlet; a `[delay @quantize]` one-shot releases it — off on the next beat, on at the next bar. 10 ms `[line~]` ramp, no click |
| **autoswitchoff_param_at_2bar** | momentary Beat Repeat | press → `Repeat` on at the next 16th → off at the next 2-bar boundary of the song. Binds by name (DRMAUD / BeatRepeat / Repeat) via `autoswitchoff_target.js`, not by index |

> All timing uses one-shot `[delay @quantize]` armed by the push, never a
> free-running `[metro]` — a metro started at device load free-runs with a phase
> set by load time and lands on an arbitrary beat.

---

## touchOSC

- `makrobiom_v4.tosc` — 24 buttons, 20 radials, 3 radios, 2 XY pads, 18 boxes, 25 groups
- 49 MIDI bindings, two pages: `drum_controls_ch2`, `utils_ch9`
- Lua: `root_v4_base`, `root_container_for_radial`, `toggle_switches`, `subs_mod_controls`, `play_stop_transport`

---

## MIDI mapping

### Channel 2 — drum controls

| CC | control | goes to |
|---|---|---|
| 0–4 | length select 1/4, 1/2, 1, 2, 4 | Live |
| 5 | session record | M4L |
| 6 | snapshot store | Live |
| 7, 8 | short / long enable | Live (no surface control) |
| 9–12 | subs / snrs / hats / perc enable | Live → note_gate |
| 13 | subs reso | DrumComputer |
| 14–16 | perc vol 1–3 | DrumComputer |
| 17–19 | snrs vol 1–3 | DrumComputer |
| 25, 26 | snrs delay, reverb | Live |
| 27, 28 | hats delay, reverb | Live |
| 29, 30 | perc delay, reverb | Live |
| 31–36 | clear 1/4, 1/2, 1, 2, 4, all | Live |
| 37 | live playing again | Live |
| 39, 40 | hats, perc valhalla | Live |
| 41, 42 | midi echo, beat repeat | Live |
| 43 | global set length | M4L (LoopCeiling) |
| 44, 45 | master filter X / Y | Live |
| 46, 47 | master NA X / Y | unassigned |
| 48 | swing | Live (Groove Amount) |
| 86, 90, 94, 98 | subs, snrs, hats, perc decay | DrumComputer |

### Channel 9 — utils

| CC | control |
|---|---|
| 10 | undo |
| 11 | redo |
| 12 | tap tempo |

**Counts:** touchOSC sends 45 CCs on ch2; the Live set holds 32 CC mappings.
The 15 that are not Live mappings go to DrumComputer or are read inside a M4L
device. CC 7 and 8 are mapped in Live but have no surface control yet.

> The channel field inside the `.tosc` is 0-based: `channel 1` = MIDI channel 2,
> `channel 8` = MIDI channel 9.

### Note map (DrumComputer, notes 36–51)

| group | pitches |
|---|---|
| subs | 36, 37 |
| snrs | 38, 39, 44, 45 |
| hats | 40, 41, 46, 47 |
| perc | 42, 43, 48, 49, 50, 51 |

---

## Notes

- Recorded audio (`Samples/`) is not versioned — see `.gitignore`
- `deprecated/` holds superseded versions, kept deliberately
- `.amxd` files are the built devices; `.maxpat` + `.js` beside them are the source
