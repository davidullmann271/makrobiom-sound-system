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
     "id": "c-title",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      20.0,
      520.0,
      20.0
     ],
     "text": "beat_freeze: momentary buffer freeze, engaged on the 8th grid"
    }
   },
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
     "text": "phasor~ 8n @lock 1",
     "outlettype": [
      "signal",
      "signal"
     ]
    }
   },
   {
    "box": {
     "id": "c-ph",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      295.0,
      303.0,
      380.0,
      18.0
     ],
     "text": "transport-locked 8th ramp; a drop in it is an 8th boundary"
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
         "code": "// beat_freeze engine\n//\n// the ring is the [data ring 576000 2] object in this gen patcher.\n//\n// POSITION COMES FROM THE TRANSPORT, NOT FROM A COUNTER.\n// in3 carries [phasor~ 8n @lock 1]; a drop in it is an 8th boundary.\n// se counts samples since that boundary and e8 counts boundaries since\n// the anchor, so the position in 1/48-bar units is\n//\n//     upos = 6*e8 + se/tu            tu = exact samples per unit\n//\n// which is re-derived from the transport every sample and therefore\n// cannot creep.  an earlier version counted samples and multiplied by\n// round(tu); at 90 bpm that is 2667 instead of 2666.67, one sample late\n// per 16th, always in the same direction - a slow drag that grew with\n// the length of the hold.  tu is kept as a float here and never rounded.\n//\n// THE ANCHOR IS THE GRID, NOT THE PRESS.\n// on press, S = the 8th boundary at or before your finger, and upos = 0\n// there.  the region runs FORWARD from S, so a note played on the beat\n// sits exactly at S and its transient lands on every cycle start, in\n// every division, through any number of switches.\n//\n// the freeze engages at the first multiple of D that has actually been\n// recorded.  d0u is however much material lies between S and that\n// point, so pressing later in the 8th yields more usable audio.\n//\n// CYCLES.  a cycle that has started always finishes.  a new cycle may\n// only begin where that division grid says, i.e. where upos crosses a\n// multiple of D.  anything between is silence, and anything past d0u\n// is silence too.\n//\n// TWO RULES THIS FILE OBEYS, both learned the hard way:\n// 1. every History is read into a local at the top and written back\n//    UNCONDITIONALLY at the bottom.  a History is a one-sample delay:\n//    a branch that does not assign it leaves its input unfed and it\n//    collapses to 0.\n// 2. nothing reads a ring position the write head may overwrite, and\n//    the write head never enters the frozen region.  the guard is a\n//    positional test, not a countdown, so it cannot drift.\n\nParam hold(0);          // 0/1, from CC 1\nParam divunits(12);     // armed division in 1/48-bar units\nParam unitms(41.6667);  // one 1/48 bar in ms, from Live tempo\nParam playing(0);       // 1 while the Live transport runs\n\nHistory wpos(0);        // write index\nHistory held(0);\nHistory pend(0);        // pressed, waiting for a legal cycle start\nHistory S(0);           // anchor: ring position of the 8th boundary\nHistory tu(2000);       // samples per 1/48 bar, float, latched at press\nHistory e8(0);          // 8th boundaries since the anchor\nHistory upv(0);         // previous upos, for crossing detection\nHistory d0u(0);         // recorded material from the anchor, in units\nHistory csu(0);         // cycle start, in units\nHistory cdu(0);         // cycle length, in units\nHistory act(0);         // 1 = a cycle is playing, 0 = silent gap\nHistory gate(0);        // dry -> frozen ramp\nHistory se(0);          // samples since the last 8th boundary\nHistory pph(0);         // previous phasor value, for edge detection\n\n// ---- state in ----\nw   = wpos;\nh   = held;\npn  = pend;\nsA  = S;\ntuv = tu;\ne8v = e8;\nupp = upv;\nd0v = d0u;\ncsv = csu;\ncdv = cdu;\nac  = act;\ngt  = gate;\nsec = se;\npp  = pph;\n\nR = 576000;             // must match the data object above\nF = 64;                 // declick length in samples\n\ndryL = in1;\ndryR = in2;\nph   = in3;\n\n// ---- 8th-note clock -------------------------------------------------\nedge = 0;\nif (ph < pp) {\n\tedge = 1;\n}\nif (edge == 1) {\n\tsec = 0;\n\tif (h == 1) {\n\t\te8v = e8v + 1;\n\t}\n\tif (pn == 1) {\n\t\te8v = e8v + 1;\n\t}\n} else {\n\tsec = sec + 1;\n}\n\n// ---- write head -----------------------------------------------------\nd0s = d0v * tuv;        // recorded material, in samples\nlo = sA - 128;\nif (lo < 0) {\n\tlo = lo + R;\n}\nrel = w - lo;\nif (rel < 0) {\n\trel = rel + R;\n}\ninreg = 0;\nif (h == 1) {\n\tif (rel < (d0s + 256)) {\n\t\tinreg = 1;\n\t}\n}\nif (inreg == 0) {\n\tpoke(ring, dryL, w, 0);\n\tpoke(ring, dryR, w, 1);\n}\nw = w + 1;\nif (w >= R) {\n\tw = 0;\n}\n\n// ---- press: latch the anchor to the grid ----------------------------\nwanthold = hold > 0.5;\ndv = divunits;\nif (dv < 1) {\n\tdv = 1;\n}\nif ((wanthold == 1) && (h == 0) && (pn == 0)) {\n\tt0 = unitms * samplerate * 0.001;\n\tif (t0 < 1) {\n\t\tt0 = 1;\n\t}\n\ttuv = t0;\n\tif (playing < 0.5) {\n\t\tsec = dv * t0;    // stopped: no grid, so behave as before\n\t}\n\tsA = w - sec;\n\tif (sA < 0) {\n\t\tsA = sA + R;\n\t}\n\te8v = 0;\n\tupp = 0;\n\tpn  = 1;\n}\nif ((wanthold == 0) && (pn == 1) && (h == 0)) {\n\tpn = 0;\n}\n\n// ---- position, straight from the transport --------------------------\nupos = (6 * e8v) + (sec / tuv);\n\n// crossing a multiple of the current division\nkn = floor(upos / dv);\nkp = floor(upp / dv);\ncrossed = 0;\nif (kn != kp) {\n\tcrossed = 1;\n}\n\n// ---- engage at the first recorded cycle boundary --------------------\nif ((pn == 1) && (h == 0)) {\n\tif ((crossed == 1) && (kn >= 1)) {\n\t\td0v = kn * dv;    // everything from S to here is real audio\n\t\tcsv = kn * dv;\n\t\tcdv = dv;\n\t\tac  = 1;\n\t\th   = 1;\n\t\tpn  = 0;\n\t}\n\tif (upos > 96) {\n\t\td0v = upos;       // safety: never let the wait run past the ring\n\t\tcsv = upos;\n\t\tcdv = dv;\n\t\tac  = 1;\n\t\th   = 1;\n\t\tpn  = 0;\n\t}\n}\nif ((wanthold == 0) && (h == 1)) {\n\th  = 0;\n\tac = 0;\n}\n\n// ---- cycles ---------------------------------------------------------\npocu = 0;\nsil  = 1;\nrr   = sA;\nif (h == 1) {\n\tpocu = upos - csv;\n\tif (ac == 1) {\n\t\tif (pocu >= cdv) {\n\t\t\tac = 0;       // the cycle that started has finished\n\t\t}\n\t}\n\tif (ac == 0) {\n\t\tif (crossed == 1) {\n\t\t\tac   = 1;     // only ever start on this division grid\n\t\t\tcsv  = kn * dv;\n\t\t\tcdv  = dv;\n\t\t\tpocu = upos - csv;\n\t\t}\n\t}\n\tif (ac == 1) {\n\t\tsil = pocu >= d0v;\n\t\trr  = sA + (pocu * tuv);\n\t\tif (rr >= R) {\n\t\t\trr = rr - R;\n\t\t}\n\t}\n}\n\n// ---- declick: every boundary is faded, including the d0 edge --------\npocs = pocu * tuv;\nfin = pocs / F;\nif (fin > 1) {\n\tfin = 1;\n}\nfout = ((cdv - pocu) * tuv) / F;\nif (fout > 1) {\n\tfout = 1;\n}\nfrem = ((d0v - pocu) * tuv) / F;\nif (frem > 1) {\n\tfrem = 1;\n}\nenv = fin;\nif (fout < env) {\n\tenv = fout;\n}\nif (frem < env) {\n\tenv = frem;\n}\nif (env < 0) {\n\tenv = 0;\n}\nif (ac == 0) {\n\tenv = 0;\n}\n\nfrzL = peek(ring, rr, 0) * env;\nfrzR = peek(ring, rr, 1) * env;\n\n// ---- dry / frozen ---------------------------------------------------\ndd = h - gt;\nif (dd > (1 / F)) {\n\tdd = 1 / F;\n}\nif (dd < (0 - (1 / F))) {\n\tdd = 0 - (1 / F);\n}\ngt = gt + dd;\n\nout1 = dryL + (frzL - dryL) * gt;\nout2 = dryR + (frzR - dryR) * gt;\n\n// ---- debug outlets --------------------------------------------------\nout3  = h;              // 1 while frozen\nout4  = pn;             // 1 = armed, waiting for a legal cycle start\nout5  = sil;            // 1 = outputting silence\nout6  = sec;            // samples since the last 8th boundary\nout7  = upos;           // position since the anchor, in 1/48-bar units\nout8  = cdv;            // current cycle length, in units\nout9  = rr;             // current read position in the ring\nout10 = inreg;          // 1 = write head in the region, writing paused\nout11 = ac;             // 1 = a cycle is playing, 0 = silent gap\nout12 = d0v;            // recorded material from the anchor, in units\n\n// ---- state out: unconditional, every sample -------------------------\nwpos = w;\nheld = h;\npend = pn;\nS    = sA;\ntu   = tuv;\ne8   = e8v;\nupv  = upos;\nd0u  = d0v;\ncsu  = csv;\ncdu  = cdv;\nact  = ac;\ngate = gt;\nse   = sec;\npph  = ph;\n"
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
     "id": "c-unit",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      530.0,
      173.0,
      250.0,
      18.0
     ],
     "text": "one 1/48 bar in ms = 5000 / bpm"
    }
   },
   {
    "box": {
     "id": "obj-o2",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "patching_rect": [
      430.0,
      240.0,
      200.0,
      22.0
     ],
     "text": "live.observer @property is_playing",
     "outlettype": [
      "",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      430.0,
      275.0,
      100.0,
      22.0
     ],
     "text": "prepend playing",
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "c-play",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      540.0,
      278.0,
      380.0,
      32.0
     ],
     "text": "stopped transport: the phasor never moves, so the freeze engages at once"
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
     "id": "c-hd",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      60.0,
      133.0,
      340.0,
      32.0
     ],
     "text": "Hold - map to ch 4 CC 1, then set Min to 1 in the MIDI Mappings browser, so 127 holds and 0 releases."
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
     "id": "c-dv",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      295.0,
      133.0,
      250.0,
      18.0
     ],
     "text": "Division - map to ch 4 CC 2.  send 0..7."
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
     "text": "clip 0 7",
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
      125.0,
      22.0
     ],
     "text": "3 4 6 8 9 12 16 24"
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
     "id": "c-list",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      285.0,
      263.0,
      520.0,
      32.0
     ],
     "text": "ascending by length:  0=1/16  1=1/12  2=1/8  3=1/6  4=3/16  5=1/4  6=1/3  7=1/2      values are 1/48-bar units"
    }
   },
   {
    "box": {
     "id": "c-dbg",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      700.0,
      30.0,
      400.0,
      18.0
     ],
     "text": "live readout, 10x a second.  not audio outlets."
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
     "text": "armed, waiting for a cycle start"
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
     "text": "silence"
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
     "text": "samples since the 8th"
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
     "text": "upos (units since anchor)"
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
     "text": "cycle length (units)"
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
     "text": "read position"
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
     "text": "writing paused (1 = in region)"
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
     "text": "cycle playing (0 = silent gap)"
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
     "text": "recorded material d0 (units)"
    }
   },
   {
    "box": {
     "id": "c-foot",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      500.0,
      640.0,
      46.0
     ],
     "text": "hold: engages on the next 8th and loops the last <division> of audio. a cycle that starts always finishes; a new division only starts on its own grid, and the gap between is silence.  past the freeze point is silence too."
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
      "obj-t3",
      0
     ],
     "destination": [
      "obj-hd",
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
      "obj-lp",
      0
     ],
     "destination": [
      "obj-o2",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-o2",
      0
     ],
     "destination": [
      "obj-pp",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp",
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
