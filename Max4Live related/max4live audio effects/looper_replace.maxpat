{
 "patcher": {
  "fileversion": 1,
  "appversion": {
   "major": 8,
   "minor": 5,
   "revision": 5,
   "architecture": "x64",
   "modernui": 1
  },
  "classnamespace": "box",
  "rect": [
   59.0,
   104.0,
   880.0,
   500.0
  ],
  "bglocked": 0,
  "openinpresentation": 1,
  "default_fontsize": 12.0,
  "default_fontface": 0,
  "default_fontname": "Arial",
  "gridonopen": 1,
  "gridsize": [
   15.0,
   15.0
  ],
  "gridsnaponopen": 1,
  "objectsnaponopen": 1,
  "statusbarvisible": 2,
  "toolbarvisible": 1,
  "lefttoolbarpinned": 0,
  "toptoolbarpinned": 0,
  "righttoolbarpinned": 0,
  "bottomtoolbarpinned": 0,
  "toolbars_unpinned_last_save": 0,
  "tallnewobj": 0,
  "boxanimatetime": 200,
  "enablehscroll": 1,
  "enablevscroll": 1,
  "devicewidth": 0.0,
  "description": "",
  "digest": "",
  "tags": "",
  "style": "",
  "subpatcher_template": "",
  "assistshowspatchername": 0,
  "boxes": [
   {
    "box": {
     "id": "obj-in",
     "maxclass": "newobj",
     "text": "plugin~",
     "patching_rect": [
      30,
      40,
      55,
      22
     ],
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "signal",
      "signal",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-gl",
     "maxclass": "newobj",
     "text": "*~ 1.",
     "patching_rect": [
      30,
      120,
      40,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ]
    }
   },
   {
    "box": {
     "id": "obj-gr",
     "maxclass": "newobj",
     "text": "*~ 1.",
     "patching_rect": [
      100,
      120,
      40,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ]
    }
   },
   {
    "box": {
     "id": "obj-out",
     "maxclass": "newobj",
     "text": "plugout~",
     "patching_rect": [
      30,
      180,
      60,
      22
     ],
     "numinlets": 2,
     "numoutlets": 0
    }
   },
   {
    "box": {
     "id": "obj-lm",
     "maxclass": "newobj",
     "text": "loadmess 1",
     "patching_rect": [
      160,
      40,
      70,
      22
     ],
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-ln",
     "maxclass": "newobj",
     "text": "line~",
     "patching_rect": [
      160,
      80,
      40,
      22
     ],
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "bang"
     ]
    }
   },
   {
    "box": {
     "id": "obj-js",
     "maxclass": "newobj",
     "text": "js looper_replace.js",
     "patching_rect": [
      300,
      330,
      160,
      22
     ],
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-td",
     "maxclass": "newobj",
     "text": "live.thisdevice",
     "patching_rect": [
      300,
      200,
      103,
      22
     ],
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "bang",
      "",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-dl",
     "maxclass": "newobj",
     "text": "deferlow",
     "patching_rect": [
      300,
      240,
      62,
      22
     ],
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-te",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "varname": "nameedit",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loopname",
       "parameter_shortname": "loopname",
       "parameter_type": 3
      }
     },
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      300,
      40,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      55,
      10,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-lb",
     "maxclass": "comment",
     "text": "looper",
     "patching_rect": [
      455,
      43,
      45,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      11,
      45,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-tb",
     "maxclass": "newobj",
     "text": "t b",
     "patching_rect": [
      300,
      120,
      29.5,
      22
     ],
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ]
    }
   },
   {
    "box": {
     "id": "obj-rn",
     "maxclass": "message",
     "text": "readname",
     "patching_rect": [
      300,
      160,
      65,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-tg",
     "maxclass": "live.toggle",
     "varname": "replace",
     "parameter_enable": 1,
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_initial": [
        0
       ],
       "parameter_initial_enable": 1,
       "parameter_longname": "Replace",
       "parameter_shortname": "Replace",
       "parameter_mmax": 1,
       "parameter_type": 2
      }
     },
     "patching_rect": [
      520,
      40,
      20,
      20
     ],
     "presentation": 1,
     "presentation_rect": [
      10,
      38,
      20,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-tl",
     "maxclass": "comment",
     "text": "REPLACE",
     "patching_rect": [
      545,
      40,
      60,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      34,
      38,
      70,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pt",
     "maxclass": "newobj",
     "text": "prepend toggle",
     "patching_rect": [
      520,
      160,
      90,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-ps",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      300,
      380,
      75,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-st",
     "maxclass": "comment",
     "text": "NOT BOUND : not loaded",
     "patching_rect": [
      300,
      420,
      260,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      64,
      260,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pr",
     "maxclass": "newobj",
     "text": "print LR",
     "patching_rect": [
      400,
      380,
      55,
      22
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "outlettype": []
    }
   },
   {
    "box": {
     "id": "obj-sn",
     "maxclass": "newobj",
     "text": "snapshot~ 20",
     "patching_rect": [
      160,
      240,
      80,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ]
    }
   },
   {
    "box": {
     "id": "obj-rv",
     "maxclass": "flonum",
     "format": 6,
     "parameter_enable": 0,
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      160,
      280,
      60,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      185,
      38,
      60,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-rl",
     "maxclass": "comment",
     "text": "return",
     "patching_rect": [
      225,
      280,
      45,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      140,
      39,
      45,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-t0",
     "maxclass": "message",
     "text": "toggle 1",
     "patching_rect": [
      620,
      160,
      60,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-t1",
     "maxclass": "message",
     "text": "toggle 0",
     "patching_rect": [
      690,
      160,
      60,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-t2",
     "maxclass": "message",
     "text": "resolve",
     "patching_rect": [
      760,
      160,
      60,
      22
     ],
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ]
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
      "obj-lm",
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
      "obj-js",
      1
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
      "obj-td",
      0
     ],
     "destination": [
      "obj-dl",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dl",
      0
     ],
     "destination": [
      "obj-js",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-te",
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
      0
     ],
     "destination": [
      "obj-rn",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-rn",
      0
     ],
     "destination": [
      "obj-js",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-tg",
      0
     ],
     "destination": [
      "obj-pt",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pt",
      0
     ],
     "destination": [
      "obj-js",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-js",
      0
     ],
     "destination": [
      "obj-ps",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ps",
      0
     ],
     "destination": [
      "obj-st",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-js",
      0
     ],
     "destination": [
      "obj-pr",
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
      "obj-sn",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sn",
      0
     ],
     "destination": [
      "obj-rv",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t0",
      0
     ],
     "destination": [
      "obj-js",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t1",
      0
     ],
     "destination": [
      "obj-js",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t2",
      0
     ],
     "destination": [
      "obj-js",
      0
     ]
    }
   }
  ]
 }
}