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
   1280.0,
   580.0
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
     "id": "obj-1",
     "maxclass": "newobj",
     "text": "midiin",
     "patching_rect": [
      30,
      45,
      47,
      22
     ],
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ]
    }
   },
   {
    "box": {
     "id": "obj-2",
     "maxclass": "newobj",
     "text": "midiout",
     "patching_rect": [
      30,
      520,
      54,
      22
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "outlettype": []
    }
   },
   {
    "box": {
     "id": "obj-3",
     "maxclass": "newobj",
     "text": "js looper_bridge.js",
     "patching_rect": [
      140,
      340,
      190,
      22
     ],
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "",
      "",
      ""
     ]
    }
   },
   {
    "box": {
     "id": "obj-4",
     "maxclass": "newobj",
     "text": "live.thisdevice",
     "patching_rect": [
      1100,
      45,
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
     "id": "obj-5",
     "maxclass": "newobj",
     "text": "deferlow",
     "patching_rect": [
      1100,
      90,
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
     "id": "obj-7",
     "maxclass": "newobj",
     "text": "t b",
     "patching_rect": [
      140,
      150,
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
     "id": "obj-8",
     "maxclass": "message",
     "text": "readnames",
     "patching_rect": [
      140,
      195,
      70,
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
     "id": "obj-12",
     "maxclass": "newobj",
     "text": "print LBR",
     "patching_rect": [
      1080,
      390,
      60,
      22
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "outlettype": []
    }
   },
   {
    "box": {
     "id": "obj-te1",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "varname": "name1edit",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "track1name",
       "parameter_shortname": "track1name",
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
      140,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      50,
      10,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-lb1",
     "maxclass": "comment",
     "text": "1 bar",
     "patching_rect": [
      295,
      48,
      40,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      11,
      40,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp1",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      140,
      390,
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
     "id": "obj-st1",
     "maxclass": "comment",
     "text": "1BAR NOT BOUND : not loaded",
     "patching_rect": [
      140,
      430,
      220,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      116,
      260,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-te2",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "varname": "name2edit",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "track2name",
       "parameter_shortname": "track2name",
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
      370,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      50,
      36,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-lb2",
     "maxclass": "comment",
     "text": "2 bar",
     "patching_rect": [
      525,
      48,
      40,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      37,
      40,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp2",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      370,
      390,
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
     "id": "obj-st2",
     "maxclass": "comment",
     "text": "2BAR NOT BOUND : not loaded",
     "patching_rect": [
      370,
      430,
      220,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      136,
      260,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-te4",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "varname": "name4edit",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "track4name",
       "parameter_shortname": "track4name",
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
      600,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      50,
      62,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-lb4",
     "maxclass": "comment",
     "text": "4 bar",
     "patching_rect": [
      755,
      48,
      40,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      63,
      40,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp4",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      600,
      390,
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
     "id": "obj-st4",
     "maxclass": "comment",
     "text": "4BAR NOT BOUND : not loaded",
     "patching_rect": [
      600,
      430,
      220,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      156,
      260,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-te8",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "varname": "name8edit",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "track8name",
       "parameter_shortname": "track8name",
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
      830,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      50,
      88,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-lb8",
     "maxclass": "comment",
     "text": "8 bar",
     "patching_rect": [
      985,
      48,
      40,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      89,
      40,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp8",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      830,
      390,
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
     "id": "obj-st8",
     "maxclass": "comment",
     "text": "8BAR NOT BOUND : not loaded",
     "patching_rect": [
      830,
      430,
      220,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      176,
      260,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-t0",
     "maxclass": "message",
     "text": "rec 1",
     "patching_rect": [
      370,
      150,
      55,
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
     "text": "clear 1",
     "patching_rect": [
      440,
      150,
      55,
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
     "text": "rec 2",
     "patching_rect": [
      370,
      180,
      55,
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
     "id": "obj-t3",
     "maxclass": "message",
     "text": "clear 2",
     "patching_rect": [
      440,
      180,
      55,
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
     "id": "obj-t4",
     "maxclass": "message",
     "text": "rec 4",
     "patching_rect": [
      370,
      210,
      55,
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
     "id": "obj-t5",
     "maxclass": "message",
     "text": "clear 4",
     "patching_rect": [
      440,
      210,
      55,
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
     "id": "obj-t6",
     "maxclass": "message",
     "text": "rec 8",
     "patching_rect": [
      370,
      240,
      55,
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
     "id": "obj-t7",
     "maxclass": "message",
     "text": "clear 8",
     "patching_rect": [
      440,
      240,
      55,
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
     "id": "obj-t8",
     "maxclass": "message",
     "text": "overdub",
     "patching_rect": [
      370,
      270,
      55,
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
     "id": "obj-t9",
     "maxclass": "message",
     "text": "play",
     "patching_rect": [
      440,
      270,
      55,
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
     "id": "obj-t10",
     "maxclass": "message",
     "text": "resolve",
     "patching_rect": [
      370,
      300,
      55,
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
      "obj-te1",
      0
     ],
     "destination": [
      "obj-7",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      0
     ],
     "destination": [
      "obj-pp1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp1",
      0
     ],
     "destination": [
      "obj-st1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      0
     ],
     "destination": [
      "obj-12",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-te2",
      0
     ],
     "destination": [
      "obj-7",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      1
     ],
     "destination": [
      "obj-pp2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp2",
      0
     ],
     "destination": [
      "obj-st2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      1
     ],
     "destination": [
      "obj-12",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-te4",
      0
     ],
     "destination": [
      "obj-7",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      2
     ],
     "destination": [
      "obj-pp4",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp4",
      0
     ],
     "destination": [
      "obj-st4",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      2
     ],
     "destination": [
      "obj-12",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-te8",
      0
     ],
     "destination": [
      "obj-7",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      3
     ],
     "destination": [
      "obj-pp8",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp8",
      0
     ],
     "destination": [
      "obj-st8",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      3
     ],
     "destination": [
      "obj-12",
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
      "obj-3",
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
      "obj-3",
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
      "obj-3",
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
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t4",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t5",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t6",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t7",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t8",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t9",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-t10",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-1",
      0
     ],
     "destination": [
      "obj-2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-1",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-4",
      0
     ],
     "destination": [
      "obj-5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-5",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-7",
      0
     ],
     "destination": [
      "obj-8",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-8",
      0
     ],
     "destination": [
      "obj-3",
      0
     ]
    }
   }
  ]
 }
}