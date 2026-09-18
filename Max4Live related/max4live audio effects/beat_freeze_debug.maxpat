{
 "patcher": {
  "fileversion": 1,
  "appversion": {
   "major": 9,
   "minor": 0,
   "revision": 9,
   "architecture": "x64",
   "modernui": 1
  },
  "classnamespace": "box",
  "rect": [
   100.0,
   100.0,
   1200.0,
   620.0
  ],
  "openrect": [
   0.0,
   0.0,
   0.0,
   130.0
  ],
  "default_fontsize": 10.0,
  "default_fontname": "Arial Bold",
  "gridsize": [
   5.0,
   5.0
  ],
  "boxes": [
   {
    "box": {
     "id": "obj-in",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "patching_rect": [
      30.0,
      300.0,
      55.0,
      22.0
     ],
     "text": "plugin~",
     "outlettype": [
      "signal",
      "signal",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-ph",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "patching_rect": [
      150.0,
      300.0,
      135.0,
      22.0
     ],
     "text": "phasor~ 1n @lock 1",
     "outlettype": [
      "signal",
      "signal"
     ]
    }
   },
   {
    "box": {
     "id": "obj-gen",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 12,
     "patching_rect": [
      30.0,
      400.0,
      260.0,
      22.0
     ],
     "text": "gen~",
     "outlettype": [
      "signal",
      "signal",
      "signal",
      "signal",
      "signal",
      "signal",
      "signal",
      "signal",
      "signal",
      "signal",
      "signal",
      "signal"
     ],
     "patcher": {
      "fileversion": 1,
      "appversion": {
       "major": 9,
       "minor": 0,
       "revision": 9,
       "architecture": "x64",
       "modernui": 1
      },
      "classnamespace": "dsp.gen",
      "rect": [
       80.0,
       80.0,
       900.0,
       1180.0
      ],
      "boxes": [
       {
        "box": {
         "id": "gin1",
         "maxclass": "newobj",
         "numinlets": 0,
         "numoutlets": 1,
         "patching_rect": [
          30.0,
          30.0,
          40.0,
          22.0
         ],
         "text": "in 1",
         "outlettype": [
          "signal"
         ]
        }
       },
       {
        "box": {
         "id": "gin2",
         "maxclass": "newobj",
         "numinlets": 0,
         "numoutlets": 1,
         "patching_rect": [
          90.0,
          30.0,
          40.0,
          22.0
         ],
         "text": "in 2",
         "outlettype": [
          "signal"
         ]
        }
       },
       {
        "box": {
         "id": "gin3",
         "maxclass": "newobj",
         "numinlets": 0,
         "numoutlets": 1,
         "patching_rect": [
          150.0,
          30.0,
          40.0,
          22.0
         ],
         "text": "in 3",
         "outlettype": [
          "signal"
         ]
        }
       },
       {
        "box": {
         "id": "gcode",
         "maxclass": "codebox",
         "numinlets": 3,
         "numoutlets": 12,
         "outlettype": [
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          ""
         ],
         "patching_rect": [
          30.0,
          75.0,
          760.0,
          1000.0
         ],
         "fontname": "Consolas",
         "fontsize": 11.0,
         "code": "// beat_freeze engine  -  V2, TRANSPORT-INDEXED RING\n//\n// V2 CHANGES ONE THING: the write position is DERIVED from the transport\n// instead of counted.  v1 did  w = w + 1  every sample, so when Live\n// deactivated the device on silent input the counter stopped and w was\n// permanently out of step with real time - the anchor sA = w - D then\n// pointed at the end of the last audio rather than at now, which put a\n// lone pluck at the END of the region with silence in front of it.  that\n// is the whole sparse-material bug.\n//\n// here w tracks  round(ph * bln)  instead.  it counts between samples so\n// there are no one-sample holes from rounding jitter, but whenever it\n// drifts more than 8 samples from the transport it SNAPS back.  a sleep\n// of any length is therefore corrected on the first sample back, exactly,\n// with no gap arithmetic and no aliasing limit.\n//\n// the ring is TWO BARS long, indices 0..2*bln.  the longest division is\n// one bar, so a one-bar freeze still leaves a full bar the write head can\n// keep recording into during the hold - history is current on release.\n// the counter carries which of the two bars it is in; a snap only ever\n// corrects the position WITHIN the bar (wn += dw), never jumps halves.\n//\n// KNOWN COST: a span skipped during a sleep still holds audio from one\n// bar earlier at the same bar position, rather than silence - a ghost.\n// musically aligned, but it can surface a previous note where silence\n// belongs.  fixable with a zeroing head running ahead of the write head;\n// left out on purpose until it is actually audible.\n//\n// the ring is the [data ring 576000 2] object in this gen patcher.\n//\n// POSITION COMES FROM THE TRANSPORT, NOT FROM A COUNTER.\n// in3 carries [phasor~ 1n @lock 1], a transport-locked ramp over one\n// bar.  phu = ph*48 is the position within the bar in 1/48-bar units,\n// re-read every sample, so it cannot creep.  the bar length in samples\n// is MEASURED between wraps rather than derived from the tempo param:\n// if the live.observer chain ever failed to fire, unitms would keep its\n// default and every tempo but 120 would be wrong.\n//\n// THE ANCHOR IS THE CURRENT DIVISION GRID.\n// the press only ARMS.  recording runs untouched until the next boundary\n// of the current division, and the anchor is taken THERE, as S = w - D,\n// from wherever the write head actually is.  the boundary is purely a\n// delay; it never decides the region.  pressing anywhere inside a 1/2\n// slot therefore behaves exactly as if you had hit it on that boundary.\n// this is what makes a note land in the loop: the region is the slot\n// you are playing in, not the first D of a coarser 8th slot.  an 8th\n// anchor was the bug - a 1/16 region started at the 8th line while the\n// note sat a dotted 16th later, so the loop held only silence, and it\n// only showed up with an isolated pluck because continuous material\n// hides where the region begins.\n//\n// every division divides 48, so every anchor and every cycle start sits\n// on a true song boundary and the transient stays aligned.\n//\n// the freeze engages at the first multiple of D after S, which is the\n// next boundary of that division - by then [S, S+D] is fully recorded.\n//\n// CYCLES.  a cycle that has started always finishes.  a new cycle may\n// only begin where that division grid says, i.e. where upos crosses a\n// multiple of D.  anything between is silence, and anything past d0u\n// is silence too.\n//\n// TWO RULES THIS FILE OBEYS, both learned the hard way:\n// 1. every History is read into a local at the top and written back\n//    UNCONDITIONALLY at the bottom.  a History is a one-sample delay:\n//    a branch that does not assign it leaves its input unfed and it\n//    collapses to 0.\n// 2. nothing reads a ring position the write head may overwrite, and\n//    the write head never enters the frozen region.  the guard is a\n//    positional test, not a countdown, so it cannot drift.\n\nParam hold(0);          // 0/1, from CC 1\nParam divunits(12);     // armed division in 1/48-bar units\nParam unitms(41.6667);  // one 1/48 bar in ms; only used with no transport\n// the transport is detected FROM THE PHASOR, not from live.observer\n// is_playing.  that observer was silently never delivering 1, which put\n// every press on the stopped fallback path: engage immediately, anchor\n// taken at the press instead of at the boundary, region = [press-D,\n// press].  the tell was that the device kept working with the session\n// stopped, when it should have fallen back.\n\nHistory wpos(0);        // write index\nHistory held(0);\nHistory pend(0);        // pressed, waiting for the division boundary\nHistory S(0);           // anchor: ring position of the division boundary\nHistory tu(2000);       // samples per 1/48 bar, float, from the measured bar\nHistory blen(96000);    // MEASURED samples per bar, from the phasor itself\nHistory bsc(0);         // samples since the last bar wrap\nHistory barc(0);        // bars elapsed since the press\nHistory gsu(0);         // anchor position within the press bar, in units\nHistory usec(0);        // samples since the anchor, for the stopped case\nHistory upv(0);         // previous upos, for crossing detection\nHistory d0u(0);         // recorded material from the anchor, in units\nHistory csu(0);         // cycle start, in units\nHistory cdu(0);         // cycle length, in units\nHistory act(0);         // 1 = a cycle is playing, 0 = silent gap\nHistory gate(0);        // dry -> frozen ramp\nHistory pph(0);         // previous phasor value, for wrap detection\nHistory stl(999999);    // samples since the phasor last moved\nHistory snc(0);         // how many times the write head has snapped\nHistory jmx(0);         // running max |counted - phasor| this bar\nHistory jhd(0);         // held: that max over the last bar\nHistory swp(0);         // 1 = a division switch is waiting for its cut point\nHistory cut(0);         // the cut point, in units: a grid point of the new division\nHistory pdu(0);         // the division being switched to, in units\nHistory pkv(0);         // running peak of the read span this cycle\nHistory pkh(0);         // peak span of the LAST completed cycle, samples\nHistory ppc(0);         // previous pocu, to catch the cycle edge exactly once\nHistory csr(99);        // running: earliest point in the cycle with signal\nHistory cer(0);         // running: latest point in the cycle with signal\nHistory cst(0);         // held: where the recorded content STARTS, in units\nHistory cen(0);         // held: where the recorded content ENDS, in units\n\n// ---- state in ----\nw   = wpos;\nh   = held;\npn  = pend;\nsA  = S;\ntuv = tu;\nbln = blen;\nbs  = bsc;\nbc  = barc;\ngsv = gsu;\nus  = usec;\nupp = upv;\nd0v = d0u;\ncsv = csu;\ncdv = cdu;\nac  = act;\ngt  = gate;\npp  = pph;\nstv = stl;\nsnv = snc;\njmv = jmx;\njhv = jhd;\nswv = swp;\ncuv = cut;\npdv = pdu;\npkr = pkv;\npkd = pkh;\npcp = ppc;\ncsv2 = csr;\ncev  = cer;\ncstv = cst;\ncenv = cen;\n\nR = 576000;             // the data allocation; the RING is bln long\nF = 64;\nFO = 192;              // fade OUT at cycle ends and the d0 edge; fade in stays short for transients                 // declick length in samples\n\ndryL = in1;\ndryR = in2;\nph   = in3;\n\n// ---- is the transport running? ---------------------------------------\nif (abs(ph - pp) > (0.25 / bln)) {\n\tstv = 0;            // real motion; sub-sample noise does not count\n} else {\n\tstv = stv + 1;\n}\nplv = 1;\nif (stv > 4096) {\n\tplv = 0;            // the phasor has not moved: transport is stopped\n}\n\n// ---- bar clock, measured from the phasor -----------------------------\nwrapd = 0;\nif (ph < pp) {\n\twrapd = 1;\n}\nif (wrapd == 1) {\n\tmeas = bs + 1;\n\t// the phasor is corrected to Live in steps, so single bar measurements\n\t// jitter.  never change bln while armed or held - everything frozen\n\t// depends on it - and smooth it otherwise.  a jump over 2% is a tempo\n\t// change and is taken at once.\n\tif ((h == 0) && (pn == 0)) {\n\t\tif (meas > 2048) {\n\t\t\tif (meas < 480000) {\n\t\t\t\tdm = meas - bln;\n\t\t\t\tif (abs(dm) > (bln * 0.02)) {\n\t\t\t\t\tbln = meas;\n\t\t\t\t} else {\n\t\t\t\t\tbln = round(bln + (dm * 0.2));\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\t}\n\tjhv = jmv;\n\tjmv = 0;\n\tif (bln > (R / 2)) {\n\t\tbln = R / 2;      // two bars must fit in the data\n\t}\n\tbs = 0;\n\tif (h == 1) {\n\t\tbc = bc + 1;\n\t}\n\tif (pn == 1) {\n\t\tbc = bc + 1;\n\t}\n} else {\n\tbs = bs + 1;\n}\nif (plv > 0.5) {\n\tif ((h == 0) && (pn == 0)) {\n\t\ttuv = bln / 48;     // latched from the press until release\n\t}\n}\nphu = ph * 48;          // units into the current bar\n\nRL = bln * 2;           // ring length: two bars, frozen with bln while held\n\n// ---- write head: position comes from the transport -------------------\n// count between samples for smoothness, snap to the transport whenever\n// they disagree by more than a few samples.  that snap is what survives\n// a Live deactivation.\nwn = w + 1;\nif (wn >= RL) {\n\twn = 0;\n}\nif (plv > 0.5) {\n\twt = round(ph * bln);\n\tif (wt >= bln) {\n\t\twt = bln - 1;\n\t}\n\twb = wn - (floor(wn / bln) * bln);   // counted position within its bar\n\tdw = wt - wb;\n\tif (dw < (0 - (bln / 2))) {\n\t\tdw = dw + bln;\n\t}\n\tif (dw > (bln / 2)) {\n\t\tdw = dw - bln;\n\t}\n\tadw = abs(dw);\n\tif (adw > jmv) {\n\t\tjmv = adw;\n\t}\n\t// phasor jitter is normal and must never move the write head - every\n\t// snap splices the recording.  only a real gap (a Live deactivation,\n\t// a transport relocation) is big enough to cross this.\n\tif (adw > 4096) {\n\t\twn = wn + dw;     // correct within the bar; keep which bar we are in\n\t\tif (wn < 0) {\n\t\t\twn = wn + RL;\n\t\t}\n\t\tif (wn >= RL) {\n\t\t\twn = wn - RL;\n\t\t}\n\t\tsnv = snv + 1;\n\t}\n}\nw = wn;\n\nd0s = d0v * tuv;\nlo = sA - 128;\nif (lo < 0) {\n\tlo = lo + RL;\n}\nrel = w - lo;\nif (rel < 0) {\n\trel = rel + RL;\n}\ninreg = 0;\nif (h == 1) {\n\tif (rel < (d0s + 256)) {\n\t\tinreg = 1;\n\t}\n}\nif (inreg == 0) {\n\tpoke(ring, dryL, w, 0);\n\tpoke(ring, dryR, w, 1);\n}\n\n// ---- press: anchor to THIS division grid -----------------------------\nwanthold = hold > 0.5;\ndv = divunits;\nif (dv < 1) {\n\tdv = 1;\n}\nif ((wanthold == 1) && (h == 0) && (pn == 0)) {\n\tif (plv < 0.5) {\n\t\tt0 = unitms * samplerate * 0.001;\n\t\tif (t0 < 1) {\n\t\t\tt0 = 1;\n\t\t}\n\t\ttuv = t0;\n\t\tgsv = 0;\n\t\tbc  = 0;\n\t\tus  = dv * t0;    // no transport: engage at once, no boundary to wait for\n\t} else {\n\t\tkS  = floor(phu / dv);\n\t\tgsv = kS * dv;\n\t\tbc  = 0;\n\t\tus  = (phu - gsv) * tuv;\n\t}\n\tupp = 0;\n\tpn  = 1;\n}\nif ((wanthold == 0) && (pn == 1) && (h == 0)) {\n\tpn = 0;\n}\n\n// ---- position since the anchor, in units ------------------------------\nif (h == 1) {\n\tus = us + 1;\n}\nif (pn == 1) {\n\tus = us + 1;\n}\nupos = us / tuv;       // smooth: counted from the phasor-seeded press point\n\nkn = floor(upos / dv);\nkp = floor(upp / dv);\ncrossed = 0;\nif (kn != kp) {\n\tcrossed = 1;\n}\n\n// ---- engage at the next boundary of this division --------------------\nif ((pn == 1) && (h == 0)) {\n\teng = 0;\n\tif ((crossed == 1) && (kn >= 1)) {\n\t\teng = 1;\n\t}\n\tif (upos > 96) {\n\t\teng = 1;          // safety: never let the wait run past the ring\n\t}\n\tif (eng == 1) {\n\t\t// the anchor is taken HERE, at the boundary, from wherever the\n\t\t// write head actually is - recording ran untouched until now.\n\t\t// the boundary is only a delay; it never decides the region.\n\t\tsA  = w - (dv * tuv);\n\t\tif (sA < 0) {\n\t\t\tsA = sA + RL;\n\t\t}\n\t\td0v = dv;         // exactly one division of real audio\n\t\tcsv = kn * dv;\n\t\tcdv = dv;\n\t\tac  = 1;\n\t\th   = 1;\n\t\tpn  = 0;\n\t\tswv = 0;\n\t}\n}\nif ((wanthold == 0) && (h == 1)) {\n\th  = 0;\n\tac = 0;\n}\n\n// ---- cycles ----------------------------------------------------------\n// a cycle loops its own division, on its own grid.  a DIVISION CHANGE never\n// waits for the cycle to finish and never leaves a silent gap: the playing\n// division keeps looping until the new division's first grid point that is\n// at least one fade-out away, fades out into it, and the new division starts\n// exactly there.  it always lands on its own grid - often sooner than\n// before - and there is no silence between.\npocu = 0;\nsil  = 1;\nrr   = sA;\nfsw  = 1;\nif (h == 1) {\n\t// arm, retarget or cancel a pending switch\n\tif (dv != cdv) {\n\t\tif ((swv == 0) || (pdv != dv)) {\n\t\t\tcu = (floor(upos / dv) + 1) * dv;\n\t\t\tif (((cu - upos) * tuv) < FO) {\n\t\t\t\tcu = cu + dv;     // too close to fade cleanly: take the next one\n\t\t\t}\n\t\t\tcuv = cu;\n\t\t\tpdv = dv;\n\t\t\tswv = 1;\n\t\t}\n\t} else {\n\t\tswv = 0;              // switched back before the cut\n\t}\n\tpocu = upos - csv;\n\t// the cut: the new division starts exactly on its grid point\n\tif (swv == 1) {\n\t\tif (upos >= cuv) {\n\t\t\tcsv  = cuv;\n\t\t\tcdv  = pdv;\n\t\t\tswv  = 0;\n\t\t\tpocu = upos - csv;\n\t\t}\n\t}\n\t// a cycle that reaches its end loops, still on its own grid\n\tif (pocu >= cdv) {\n\t\tcsv  = csv + cdv;\n\t\tpocu = upos - csv;\n\t}\n\t// fade the outgoing division into the cut\n\tif (swv == 1) {\n\t\tfsw = ((cuv - upos) * tuv) / FO;\n\t\tif (fsw > 1) {\n\t\t\tfsw = 1;\n\t\t}\n\t\tif (fsw < 0) {\n\t\t\tfsw = 0;\n\t\t}\n\t}\n\tac  = 1;\n\tsil = pocu >= d0v;\n\trr  = sA + (pocu * tuv);\n\tif (rr >= RL) {\n\t\trr = rr - RL;\n\t}\n}\n\n// ---- declick: every boundary is faded, including the d0 edge ---------\npocs = pocu * tuv;\nfin = pocs / F;\nif (fin > 1) {\n\tfin = 1;\n}\nfout = ((cdv - pocu) * tuv) / FO;\nif (fout > 1) {\n\tfout = 1;\n}\nfrem = ((d0v - pocu) * tuv) / FO;\nif (frem > 1) {\n\tfrem = 1;\n}\nenv = fin;\nif (fout < env) {\n\tenv = fout;\n}\nif (frem < env) {\n\tenv = frem;\n}\nif (fsw < env) {\n\tenv = fsw;\n}\nif (env < 0) {\n\tenv = 0;\n}\nif (ac == 0) {\n\tenv = 0;\n}\n\n// ---- measure the actual read span of each cycle ----------------------\n// peak-held over a whole cycle, so a 10 Hz readout cannot miss the top.\n// compare against cycle length in samples: they must be equal.\ndspan = rr - sA;\nif (dspan < 0) {\n\tdspan = dspan + RL;\n}\nif (pocu < pcp) {\n\tpkd = pkr;        // pocu just wrapped down: one cycle ended\n\tpkr = 0;\n\tcstv = csv2;      // and hold where the audio actually sat in it\n\tcenv = cev;\n\tcsv2 = 99;\n\tcev  = 0;\n}\nif (dspan > pkr) {\n\tpkr = dspan;\n}\n\n// where the RECORDED CONTENT actually lies inside the region, measured\n// from the ring itself rather than inferred.  raw peeks, before the\n// envelope, so this reports the recording and not the playback.\nrawa = abs(peek(ring, rr, 0)) + abs(peek(ring, rr, 1));\nif (rawa > 0.0005) {\n\tif (pocu < csv2) {\n\t\tcsv2 = pocu;\n\t}\n\tif (pocu > cev) {\n\t\tcev = pocu;\n\t}\n}\npcp = pocu;\n\nfrzL = peek(ring, rr, 0) * env;\nfrzR = peek(ring, rr, 1) * env;\n\n// ---- dry / frozen -----------------------------------------------------\ndd = h - gt;\nif (dd > (1 / F)) {\n\tdd = 1 / F;\n}\nif (dd < (0 - (1 / F))) {\n\tdd = 0 - (1 / F);\n}\ngt = gt + dd;\n\n// no keep-alive noise.  it never prevented Live's deactivation anyway -\n// Live decides from this device's incoming audio, not from what it\n// emits - and the transport-derived write head above now corrects a\n// deactivation of any length on the first sample back.\nout1 = dryL + (frzL - dryL) * gt;\nout2 = dryR + (frzR - dryR) * gt;\n\n// ---- debug outlets ----------------------------------------------------\n// generated from one table; the patch labels come from the same table.\nout3  = h;           // held\nout4  = plv;         // TRANSPORT DETECTED (must be 1)\nout5  = sA;          // ANCHOR sA\nout6  = bln;         // MEASURED samples per bar\nout7  = pkd;         // read span (samples)\nout8  = cdv * tuv;   // EXPECTED cycle length (samples)\nout9  = w;           // write head\nout10 = jhv;         // phasor jitter max per bar (samples)\nout11 = tuv;         // tuv (must not move while held)\nout12 = snv;         // SNAP COUNT (should stay 0)\n\n// ---- state out: unconditional, every sample ---------------------------\nwpos = w;\nheld = h;\npend = pn;\nS    = sA;\ntu   = tuv;\nblen = bln;\nbsc  = bs;\nbarc = bc;\ngsu  = gsv;\nusec = us;\nupv  = upos;\nd0u  = d0v;\ncsu  = csv;\ncdu  = cdv;\nact  = ac;\ngate = gt;\npph  = ph;\nstl  = stv;\nsnc  = snv;\njmx  = jmv;\njhd  = jhv;\nswp  = swv;\ncut  = cuv;\npdu  = pdv;\npkv  = pkr;\npkh  = pkd;\nppc  = pcp;\ncsr  = csv2;\ncer  = cev;\ncst  = cstv;\ncen  = cenv;\n"
        }
       },
       {
        "box": {
         "id": "gdata",
         "maxclass": "newobj",
         "numinlets": 2,
         "numoutlets": 1,
         "patching_rect": [
          560.0,
          30.0,
          150.0,
          22.0
         ],
         "text": "data ring 576000 2",
         "outlettype": [
          ""
         ]
        }
       },
       {
        "box": {
         "id": "gout1",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          85.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 1"
        }
       },
       {
        "box": {
         "id": "gout2",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          140.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 2"
        }
       },
       {
        "box": {
         "id": "gout3",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          195.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 3"
        }
       },
       {
        "box": {
         "id": "gout4",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          250.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 4"
        }
       },
       {
        "box": {
         "id": "gout5",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          305.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 5"
        }
       },
       {
        "box": {
         "id": "gout6",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          360.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 6"
        }
       },
       {
        "box": {
         "id": "gout7",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          415.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 7"
        }
       },
       {
        "box": {
         "id": "gout8",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          470.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 8"
        }
       },
       {
        "box": {
         "id": "gout9",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          525.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 9"
        }
       },
       {
        "box": {
         "id": "gout10",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          580.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 10"
        }
       },
       {
        "box": {
         "id": "gout11",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          635.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 11"
        }
       },
       {
        "box": {
         "id": "gout12",
         "maxclass": "newobj",
         "numinlets": 1,
         "numoutlets": 0,
         "patching_rect": [
          690.0,
          1100.0,
          45.0,
          22.0
         ],
         "text": "out 12"
        }
       }
      ],
      "lines": [
       {
        "patchline": {
         "source": [
          "gin1",
          0
         ],
         "destination": [
          "gcode",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gin2",
          0
         ],
         "destination": [
          "gcode",
          1
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gin3",
          0
         ],
         "destination": [
          "gcode",
          2
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          0
         ],
         "destination": [
          "gout1",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          1
         ],
         "destination": [
          "gout2",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          2
         ],
         "destination": [
          "gout3",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          3
         ],
         "destination": [
          "gout4",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          4
         ],
         "destination": [
          "gout5",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          5
         ],
         "destination": [
          "gout6",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          6
         ],
         "destination": [
          "gout7",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          7
         ],
         "destination": [
          "gout8",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          8
         ],
         "destination": [
          "gout9",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          9
         ],
         "destination": [
          "gout10",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          10
         ],
         "destination": [
          "gout11",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "gcode",
          11
         ],
         "destination": [
          "gout12",
          0
         ]
        }
       }
      ]
     }
    }
   },
   {
    "box": {
     "id": "obj-out",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      450.0,
      60.0,
      22.0
     ],
     "text": "plugout~"
    }
   },
   {
    "box": {
     "id": "obj-td",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "patching_rect": [
      30.0,
      60.0,
      100.0,
      22.0
     ],
     "text": "live.thisdevice",
     "outlettype": [
      "bang",
      "bang",
      "int"
     ]
    }
   },
   {
    "box": {
     "id": "obj-t3",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "patching_rect": [
      30.0,
      95.0,
      70.0,
      22.0
     ],
     "text": "t b b b",
     "outlettype": [
      "bang",
      "bang",
      "bang"
     ]
    }
   },
   {
    "box": {
     "id": "obj-lp",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "patching_rect": [
      430.0,
      100.0,
      115.0,
      22.0
     ],
     "text": "live.path live_set",
     "outlettype": [
      "",
      "",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-ob",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "patching_rect": [
      430.0,
      135.0,
      180.0,
      22.0
     ],
     "text": "live.observer @property tempo",
     "outlettype": [
      "",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-um",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      430.0,
      170.0,
      60.0,
      22.0
     ],
     "text": "!/ 5000.",
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-pu",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      430.0,
      205.0,
      95.0,
      22.0
     ],
     "text": "prepend unitms",
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-hd",
     "maxclass": "live.toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "varname": "hold",
     "patching_rect": [
      30.0,
      140.0,
      20.0,
      20.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_longname": "Hold",
       "parameter_shortname": "Hold",
       "parameter_type": 2,
       "parameter_mmax": 1,
       "parameter_initial": [
        0
       ],
       "parameter_initial_enable": 1
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-ph2",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      30.0,
      225.0,
      85.0,
      22.0
     ],
     "text": "prepend hold",
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-dv",
     "maxclass": "live.dial",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "varname": "division",
     "patching_rect": [
      240.0,
      130.0,
      45.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Division",
       "parameter_shortname": "Division",
       "parameter_type": 1,
       "parameter_mmin": 0,
       "parameter_mmax": 127,
       "parameter_unitstyle": 0,
       "parameter_initial": [
        5
       ],
       "parameter_initial_enable": 1
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-cl",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      240.0,
      190.0,
      60.0,
      22.0
     ],
     "text": "clip 0 8",
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-tb",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "patching_rect": [
      240.0,
      225.0,
      50.0,
      22.0
     ],
     "text": "t b i",
     "outlettype": [
      "bang",
      "int"
     ]
    }
   },
   {
    "box": {
     "id": "obj-p1",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      305.0,
      260.0,
      35.0,
      22.0
     ],
     "text": "+ 1",
     "outlettype": [
      "int"
     ]
    }
   },
   {
    "box": {
     "id": "obj-ms",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      150.0,
      260.0,
      140.0,
      22.0
     ],
     "text": "3 4 6 8 9 12 16 24 48"
    }
   },
   {
    "box": {
     "id": "obj-zl",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "patching_rect": [
      150.0,
      340.0,
      55.0,
      22.0
     ],
     "text": "zl nth",
     "outlettype": [
      "",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-pd",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      150.0,
      375.0,
      105.0,
      22.0
     ],
     "text": "prepend divunits",
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-sn0",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      60.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb0",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      60.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn0",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      63.0,
      260.0,
      18.0
     ],
     "text": "held"
    }
   },
   {
    "box": {
     "id": "obj-sn1",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      90.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb1",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      90.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn1",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      93.0,
      260.0,
      18.0
     ],
     "text": "TRANSPORT DETECTED (must be 1)"
    }
   },
   {
    "box": {
     "id": "obj-sn2",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      120.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb2",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      120.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn2",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      123.0,
      260.0,
      18.0
     ],
     "text": "ANCHOR sA"
    }
   },
   {
    "box": {
     "id": "obj-sn3",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      150.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb3",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      150.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn3",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      153.0,
      260.0,
      18.0
     ],
     "text": "MEASURED samples per bar"
    }
   },
   {
    "box": {
     "id": "obj-sn4",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      180.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb4",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      180.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn4",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      183.0,
      260.0,
      18.0
     ],
     "text": "read span (samples)"
    }
   },
   {
    "box": {
     "id": "obj-sn5",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      210.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb5",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      210.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn5",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      213.0,
      260.0,
      18.0
     ],
     "text": "EXPECTED cycle length (samples)"
    }
   },
   {
    "box": {
     "id": "obj-sn6",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      240.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb6",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      240.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn6",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      243.0,
      260.0,
      18.0
     ],
     "text": "write head"
    }
   },
   {
    "box": {
     "id": "obj-sn7",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      270.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb7",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      270.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn7",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      273.0,
      260.0,
      18.0
     ],
     "text": "phasor jitter max per bar (samples)"
    }
   },
   {
    "box": {
     "id": "obj-sn8",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      300.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb8",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      300.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn8",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      303.0,
      260.0,
      18.0
     ],
     "text": "tuv (must not move while held)"
    }
   },
   {
    "box": {
     "id": "obj-sn9",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      700.0,
      330.0,
      95.0,
      22.0
     ],
     "text": "snapshot~ 100",
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-nb9",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      800.0,
      330.0,
      70.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "c-sn9",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      875.0,
      333.0,
      260.0,
      18.0
     ],
     "text": "SNAP COUNT (should stay 0)"
    }
   }
  ],
  "lines": [
   {
    "patchline": {
     "source": [
      "obj-in",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-in",
      1
     ],
     "destination": [
      "obj-gen",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ph",
      0
     ],
     "destination": [
      "obj-gen",
      2
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      0
     ],
     "destination": [
      "obj-out",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      1
     ],
     "destination": [
      "obj-out",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-td",
      0
     ],
     "destination": [
      "obj-t3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t3",
      2
     ],
     "destination": [
      "obj-lp",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t3",
      1
     ],
     "destination": [
      "obj-dv",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-lp",
      0
     ],
     "destination": [
      "obj-ob",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ob",
      0
     ],
     "destination": [
      "obj-um",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-um",
      0
     ],
     "destination": [
      "obj-pu",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pu",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-hd",
      0
     ],
     "destination": [
      "obj-ph2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ph2",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dv",
      0
     ],
     "destination": [
      "obj-cl",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-cl",
      0
     ],
     "destination": [
      "obj-tb",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-tb",
      1
     ],
     "destination": [
      "obj-p1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-p1",
      0
     ],
     "destination": [
      "obj-zl",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-tb",
      0
     ],
     "destination": [
      "obj-ms",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ms",
      0
     ],
     "destination": [
      "obj-zl",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-zl",
      0
     ],
     "destination": [
      "obj-pd",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pd",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      2
     ],
     "destination": [
      "obj-sn0",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn0",
      0
     ],
     "destination": [
      "obj-nb0",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      3
     ],
     "destination": [
      "obj-sn1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn1",
      0
     ],
     "destination": [
      "obj-nb1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      4
     ],
     "destination": [
      "obj-sn2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn2",
      0
     ],
     "destination": [
      "obj-nb2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      5
     ],
     "destination": [
      "obj-sn3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn3",
      0
     ],
     "destination": [
      "obj-nb3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      6
     ],
     "destination": [
      "obj-sn4",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn4",
      0
     ],
     "destination": [
      "obj-nb4",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      7
     ],
     "destination": [
      "obj-sn5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn5",
      0
     ],
     "destination": [
      "obj-nb5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      8
     ],
     "destination": [
      "obj-sn6",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn6",
      0
     ],
     "destination": [
      "obj-nb6",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      9
     ],
     "destination": [
      "obj-sn7",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn7",
      0
     ],
     "destination": [
      "obj-nb7",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      10
     ],
     "destination": [
      "obj-sn8",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn8",
      0
     ],
     "destination": [
      "obj-nb8",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      11
     ],
     "destination": [
      "obj-sn9",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn9",
      0
     ],
     "destination": [
      "obj-nb9",
      0
     ]
    }
   }
  ]
 }
}
