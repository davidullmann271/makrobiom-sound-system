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
   880.0,
   500.0
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
     "outlettype": [
      "signal",
      "signal",
      ""
     ],
     "patching_rect": [
      30.0,
      60.0,
      55.0,
      22.0
     ],
     "text": "plugin~"
    }
   },
   {
    "box": {
     "id": "obj-gl",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      30.0,
      330.0,
      35.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-gr",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      80.0,
      330.0,
      35.0,
      22.0
     ],
     "text": "*~"
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
      375.0,
      60.0,
      22.0
     ],
     "text": "plugout~"
    }
   },
   {
    "box": {
     "id": "obj-ln",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal",
      "bang"
     ],
     "patching_rect": [
      150.0,
      290.0,
      45.0,
      22.0
     ],
     "text": "line~"
    }
   },
   {
    "box": {
     "id": "obj-pk",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      150.0,
      255.0,
      60.0,
      22.0
     ],
     "text": "pack 0. 10"
    }
   },
   {
    "box": {
     "id": "obj-cf",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      218.0,
      258.0,
      220.0,
      18.0
     ],
     "text": "10 ms fade, so the switch never clicks"
    }
   },
   {
    "box": {
     "id": "obj-tg",
     "maxclass": "live.toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "varname": "on",
     "patching_rect": [
      150.0,
      120.0,
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
       "parameter_longname": "On",
       "parameter_shortname": "On",
       "parameter_mmax": 1,
       "parameter_type": 2
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-ctg",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      175.0,
      120.0,
      250.0,
      18.0
     ],
     "text": "On: track is heard. Off lands on the beat, on lands on the bar."
    }
   },
   {
    "box": {
     "id": "obj-i",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "patching_rect": [
      150.0,
      185.0,
      32.0,
      22.0
     ],
     "text": "int"
    }
   },
   {
    "box": {
     "id": "obj-ch",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      150.0,
      220.0,
      65.0,
      22.0
     ],
     "text": "change -1"
    }
   },
   {
    "box": {
     "id": "obj-ci",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      190.0,
      188.0,
      260.0,
      18.0
     ],
     "text": "stores the push; the trigger below then schedules its release"
    }
   },
   {
    "box": {
     "id": "obj-cclk",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      380.0,
      240.0,
      420.0,
      18.0
     ],
     "text": "off -> next beat (4n).  on -> next bar (1n).  no free-running clock."
    }
   },
   {
    "box": {
     "id": "obj-lp",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "",
      "",
      ""
     ],
     "patching_rect": [
      560.0,
      255.0,
      110.0,
      22.0
     ],
     "text": "live.path live_set"
    }
   },
   {
    "box": {
     "id": "obj-ob",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "",
      ""
     ],
     "patching_rect": [
      560.0,
      290.0,
      175.0,
      22.0
     ],
     "text": "live.observer @property is_playing"
    }
   },
   {
    "box": {
     "id": "obj-sl",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "bang",
      ""
     ],
     "patching_rect": [
      560.0,
      325.0,
      45.0,
      22.0
     ],
     "text": "sel 0"
    }
   },
   {
    "box": {
     "id": "obj-cst",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      560.0,
      348.0,
      290.0,
      18.0
     ],
     "text": "transport stopped: apply at once, no bar is coming"
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
      380.0,
      20.0,
      95.0,
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
     "numoutlets": 4,
     "outlettype": [
      "bang",
      "bang",
      "bang",
      "bang"
     ],
     "patching_rect": [
      380.0,
      55.0,
      70.0,
      22.0
     ],
     "text": "t b b b b"
    }
   },
   {
    "box": {
     "id": "obj-cm",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      415.0,
      480.0,
      20.0
     ],
     "text": "track_gate: one button, switches this track's sound on the bar line"
    }
   },
   {
    "box": {
     "id": "obj-tt",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      150.0,
      150.0,
      50.0,
      22.0
     ],
     "text": "t i i"
    }
   },
   {
    "box": {
     "id": "obj-pl",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "patching_rect": [
      380.0,
      290.0,
      35.0,
      22.0
     ],
     "text": "+ 1"
    }
   },
   {
    "box": {
     "id": "obj-gt",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "",
      ""
     ],
     "patching_rect": [
      380.0,
      325.0,
      60.0,
      22.0
     ],
     "text": "gate 2"
    }
   },
   {
    "box": {
     "id": "obj-dl",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      560.0,
      395.0,
      150.0,
      22.0
     ],
     "text": "delay 0 @quantize 1n"
    }
   },
   {
    "box": {
     "id": "obj-stp",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      650.0,
      360.0,
      40.0,
      22.0
     ],
     "text": "stop"
    }
   },
   {
    "box": {
     "id": "obj-sv",
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
      360.0,
      60.0,
      22.0
     ],
     "text": "sel 0 1"
    }
   },
   {
    "box": {
     "id": "obj-dl2",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      380.0,
      395.0,
      150.0,
      22.0
     ],
     "text": "delay 0 @quantize 4n"
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
      "obj-gl",
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
      "obj-gr",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ln",
      0
     ],
     "destination": [
      "obj-gl",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ln",
      0
     ],
     "destination": [
      "obj-gr",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gl",
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
      "obj-gr",
      0
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
      "obj-pk",
      0
     ],
     "destination": [
      "obj-ln",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ch",
      0
     ],
     "destination": [
      "obj-pk",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-i",
      0
     ],
     "destination": [
      "obj-ch",
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
      "obj-sl",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sl",
      0
     ],
     "destination": [
      "obj-i",
      0
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
      "obj-tr",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-tr",
      3
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
      "obj-tr",
      2
     ],
     "destination": [
      "obj-tg",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-tr",
      1
     ],
     "destination": [
      "obj-i",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-tt",
      0
     ],
     "order": 0,
     "source": [
      "obj-tg",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-i",
      1
     ],
     "order": 0,
     "source": [
      "obj-tt",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-pl",
      0
     ],
     "order": 0,
     "source": [
      "obj-ob",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-gt",
      0
     ],
     "order": 0,
     "source": [
      "obj-pl",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-gt",
      1
     ],
     "order": 0,
     "source": [
      "obj-tt",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-i",
      0
     ],
     "order": 0,
     "source": [
      "obj-gt",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-i",
      0
     ],
     "order": 0,
     "source": [
      "obj-dl",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-stp",
      0
     ],
     "order": 0,
     "source": [
      "obj-sl",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dl",
      0
     ],
     "order": 0,
     "source": [
      "obj-stp",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-sv",
      0
     ],
     "order": 0,
     "source": [
      "obj-gt",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dl2",
      0
     ],
     "order": 0,
     "source": [
      "obj-sv",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dl",
      0
     ],
     "order": 0,
     "source": [
      "obj-sv",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-i",
      0
     ],
     "order": 0,
     "source": [
      "obj-dl2",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-dl2",
      0
     ],
     "order": 0,
     "source": [
      "obj-stp",
      0
     ]
    }
   }
  ]
 }
}