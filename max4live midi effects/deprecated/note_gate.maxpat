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
   820.0,
   470.0
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
     "id": "obj-hdr",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      20,
      14,
      520,
      18.0
     ],
     "text": "note_gate -- clip notes in, muted note groups removed, everything else passes through."
    }
   },
   {
    "box": {
     "id": "obj-hdr2",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      20,
      30,
      520,
      18.0
     ],
     "text": "Note path is all native objects: js never touches a note, so timing stays on the scheduler thread."
    }
   },
   {
    "box": {
     "id": "obj-mi",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      ""
     ],
     "patching_rect": [
      20,
      62,
      60,
      22.0
     ],
     "text": "midiin"
    }
   },
   {
    "box": {
     "id": "obj-mp",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 7,
     "outlettype": [
      "list",
      "list",
      "list",
      "int",
      "int",
      "int",
      "int"
     ],
     "patching_rect": [
      20,
      96,
      80,
      22.0
     ],
     "text": "midiparse"
    }
   },
   {
    "box": {
     "id": "obj-up",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      20,
      132,
      80,
      22.0
     ],
     "text": "unpack 0 0"
    }
   },
   {
    "box": {
     "id": "obj-tv",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      116,
      168,
      50,
      22.0
     ],
     "text": "t i i"
    }
   },
   {
    "box": {
     "id": "obj-eq",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "patching_rect": [
      176,
      204,
      45,
      22.0
     ],
     "text": "== 0"
    }
   },
   {
    "box": {
     "id": "obj-tp",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      20,
      168,
      50,
      22.0
     ],
     "text": "t i i"
    }
   },
   {
    "box": {
     "id": "obj-tab",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "bang"
     ],
     "patching_rect": [
      62,
      204,
      130,
      22.0
     ],
     "text": "table pitchallow 128"
    }
   },
   {
    "box": {
     "id": "obj-or",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "patching_rect": [
      62,
      240,
      40,
      22.0
     ],
     "text": "||"
    }
   },
   {
    "box": {
     "id": "obj-pk",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "list"
     ],
     "patching_rect": [
      20,
      276,
      70,
      22.0
     ],
     "text": "pack 0 0"
    }
   },
   {
    "box": {
     "id": "obj-gate",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "list"
     ],
     "patching_rect": [
      20,
      312,
      50,
      22.0
     ],
     "text": "gate"
    }
   },
   {
    "box": {
     "id": "obj-mf",
     "maxclass": "newobj",
     "numinlets": 7,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "patching_rect": [
      20,
      348,
      80,
      22.0
     ],
     "text": "midiformat"
    }
   },
   {
    "box": {
     "id": "obj-mo",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "outlettype": [],
     "patching_rect": [
      20,
      384,
      60,
      22.0
     ],
     "text": "midiout"
    }
   },
   {
    "box": {
     "id": "obj-c1",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      240,
      240,
      300,
      18.0
     ],
     "text": "note-offs pass unconditionally, so a muted group can never hang a note"
    }
   },
   {
    "box": {
     "id": "obj-c2",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      200,
      204,
      300,
      18.0
     ],
     "text": "0/1 per pitch, written by the control js -- never per note"
    }
   },
   {
    "box": {
     "id": "obj-td",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "bang",
      "bang",
      "int"
     ],
     "patching_rect": [
      380,
      62,
      100,
      22.0
     ],
     "text": "live.thisdevice"
    }
   },
   {
    "box": {
     "id": "obj-tr",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "bang",
      "bang",
      "bang"
     ],
     "patching_rect": [
      380,
      96,
      60,
      22.0
     ],
     "text": "t b b b"
    }
   },
   {
    "box": {
     "id": "obj-ini",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      496,
      132,
      60,
      22.0
     ],
     "text": "initlive"
    }
   },
   {
    "box": {
     "id": "obj-bar",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      660,
      322,
      40,
      22
     ],
     "text": "bar"
    }
   },
   {
    "box": {
     "id": "obj-cclk",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      380,
      168,
      420,
      18
     ],
     "text": "mute -> next beat (4n).  un-mute -> next bar (1n)."
    }
   },
   {
    "box": {
     "id": "obj-cbar",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      380,
      190,
      420,
      18
     ],
     "text": "no free-running clock: each push arms its own one-shot"
    }
   },
   {
    "box": {
     "id": "obj-js",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      ""
     ],
     "patching_rect": [
      380,
      412,
      135,
      22.0
     ],
     "text": "js note_gate_ctrl.js"
    }
   },
   {
    "box": {
     "id": "obj-t1",
     "maxclass": "live.toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "varname": "grp1",
     "patching_rect": [
      380.0,
      262.0,
      20.0,
      20.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_initial": [
        1
       ],
       "parameter_initial_enable": 1,
       "parameter_longname": "subs",
       "parameter_shortname": "subs",
       "parameter_mmax": 1,
       "parameter_type": 2
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-l1",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      380.0,
      244,
      40,
      18.0
     ],
     "text": "subs"
    }
   },
   {
    "box": {
     "id": "obj-m1",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      380.0,
      352,
      75,
      22.0
     ],
     "text": "group 1 $1"
    }
   },
   {
    "box": {
     "id": "obj-t2",
     "maxclass": "live.toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "varname": "grp2",
     "patching_rect": [
      440.0,
      262.0,
      20.0,
      20.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_initial": [
        1
       ],
       "parameter_initial_enable": 1,
       "parameter_longname": "snrs",
       "parameter_shortname": "snrs",
       "parameter_mmax": 1,
       "parameter_type": 2
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-l2",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      440.0,
      244,
      40,
      18.0
     ],
     "text": "snrs"
    }
   },
   {
    "box": {
     "id": "obj-m2",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      440.0,
      352,
      75,
      22.0
     ],
     "text": "group 2 $1"
    }
   },
   {
    "box": {
     "id": "obj-t3",
     "maxclass": "live.toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "varname": "grp3",
     "patching_rect": [
      500.0,
      262.0,
      20.0,
      20.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_initial": [
        1
       ],
       "parameter_initial_enable": 1,
       "parameter_longname": "hats",
       "parameter_shortname": "hats",
       "parameter_mmax": 1,
       "parameter_type": 2
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-l3",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      500.0,
      244,
      40,
      18.0
     ],
     "text": "hats"
    }
   },
   {
    "box": {
     "id": "obj-m3",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      500.0,
      352,
      75,
      22.0
     ],
     "text": "group 3 $1"
    }
   },
   {
    "box": {
     "id": "obj-t4",
     "maxclass": "live.toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "varname": "grp4",
     "patching_rect": [
      560.0,
      262.0,
      20.0,
      20.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_initial": [
        1
       ],
       "parameter_initial_enable": 1,
       "parameter_longname": "perc",
       "parameter_shortname": "perc",
       "parameter_mmax": 1,
       "parameter_type": 2
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-l4",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      560.0,
      244,
      40,
      18.0
     ],
     "text": "perc"
    }
   },
   {
    "box": {
     "id": "obj-m4",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      560.0,
      352,
      75,
      22.0
     ],
     "text": "group 4 $1"
    }
   },
   {
    "box": {
     "id": "obj-dly",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      660,
      290,
      150,
      22
     ],
     "text": "delay 0 @quantize 1n"
    }
   },
   {
    "box": {
     "id": "obj-tv1",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      380.0,
      290,
      50,
      22
     ],
     "text": "t i i"
    }
   },
   {
    "box": {
     "id": "obj-tv2",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      440.0,
      290,
      50,
      22
     ],
     "text": "t i i"
    }
   },
   {
    "box": {
     "id": "obj-tv3",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      500.0,
      290,
      50,
      22
     ],
     "text": "t i i"
    }
   },
   {
    "box": {
     "id": "obj-tv4",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      560.0,
      290,
      50,
      22
     ],
     "text": "t i i"
    }
   },
   {
    "box": {
     "id": "obj-dlyb",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      660,
      356,
      150,
      22
     ],
     "text": "delay 0 @quantize 4n"
    }
   },
   {
    "box": {
     "id": "obj-beat",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      660,
      388,
      45,
      22
     ],
     "text": "beat"
    }
   },
   {
    "box": {
     "id": "obj-sl1",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 3,
     "outlettype": [
      "bang",
      "bang",
      ""
     ],
     "patching_rect": [
      380.0,
      318,
      60,
      22
     ],
     "text": "sel 0 1"
    }
   },
   {
    "box": {
     "id": "obj-sl2",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 3,
     "outlettype": [
      "bang",
      "bang",
      ""
     ],
     "patching_rect": [
      440.0,
      318,
      60,
      22
     ],
     "text": "sel 0 1"
    }
   },
   {
    "box": {
     "id": "obj-sl3",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 3,
     "outlettype": [
      "bang",
      "bang",
      ""
     ],
     "patching_rect": [
      500.0,
      318,
      60,
      22
     ],
     "text": "sel 0 1"
    }
   },
   {
    "box": {
     "id": "obj-sl4",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 3,
     "outlettype": [
      "bang",
      "bang",
      ""
     ],
     "patching_rect": [
      560.0,
      318,
      60,
      22
     ],
     "text": "sel 0 1"
    }
   }
  ],
  "lines": [
   {
    "patchline": {
     "destination": [
      "obj-mp",
      0
     ],
     "source": [
      "obj-mi",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-up",
      0
     ],
     "source": [
      "obj-mp",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tv",
      0
     ],
     "source": [
      "obj-up",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-eq",
      0
     ],
     "source": [
      "obj-tv",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-or",
      1
     ],
     "source": [
      "obj-eq",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-pk",
      1
     ],
     "source": [
      "obj-tv",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tp",
      0
     ],
     "source": [
      "obj-up",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tab",
      0
     ],
     "source": [
      "obj-tp",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-or",
      0
     ],
     "source": [
      "obj-tab",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-gate",
      0
     ],
     "source": [
      "obj-or",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-pk",
      0
     ],
     "source": [
      "obj-tp",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-gate",
      1
     ],
     "source": [
      "obj-pk",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      0
     ],
     "source": [
      "obj-gate",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mo",
      0
     ],
     "source": [
      "obj-mf",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      1
     ],
     "source": [
      "obj-mp",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      2
     ],
     "source": [
      "obj-mp",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      3
     ],
     "source": [
      "obj-mp",
      3
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      4
     ],
     "source": [
      "obj-mp",
      4
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      5
     ],
     "source": [
      "obj-mp",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      6
     ],
     "source": [
      "obj-mp",
      6
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tr",
      0
     ],
     "source": [
      "obj-td",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-ini",
      0
     ],
     "source": [
      "obj-tr",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-js",
      0
     ],
     "source": [
      "obj-ini",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-js",
      0
     ],
     "source": [
      "obj-bar",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tab",
      0
     ],
     "source": [
      "obj-js",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-t1",
      0
     ],
     "source": [
      "obj-tr",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-js",
      0
     ],
     "source": [
      "obj-m1",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-t2",
      0
     ],
     "source": [
      "obj-tr",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-js",
      0
     ],
     "source": [
      "obj-m2",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-t3",
      0
     ],
     "source": [
      "obj-tr",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-js",
      0
     ],
     "source": [
      "obj-m3",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-t4",
      0
     ],
     "source": [
      "obj-tr",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-js",
      0
     ],
     "source": [
      "obj-m4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-mf",
      2
     ],
     "source": [
      "obj-js",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-bar",
      0
     ],
     "order": 0,
     "source": [
      "obj-dly",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tv1",
      0
     ],
     "order": 0,
     "source": [
      "obj-t1",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-m1",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv1",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tv2",
      0
     ],
     "order": 0,
     "source": [
      "obj-t2",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-m2",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv2",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tv3",
      0
     ],
     "order": 0,
     "source": [
      "obj-t3",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-m3",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv3",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tv4",
      0
     ],
     "order": 0,
     "source": [
      "obj-t4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-m4",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv4",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-beat",
      0
     ],
     "order": 0,
     "source": [
      "obj-dlyb",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-js",
      0
     ],
     "order": 0,
     "source": [
      "obj-beat",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-sl1",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv1",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dlyb",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl1",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dly",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl1",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-sl2",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv2",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dlyb",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl2",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dly",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl2",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-sl3",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv3",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dlyb",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl3",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dly",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl3",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-sl4",
      0
     ],
     "order": 0,
     "source": [
      "obj-tv4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dlyb",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dly",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl4",
      1
     ]
    }
   }
  ]
 }
}