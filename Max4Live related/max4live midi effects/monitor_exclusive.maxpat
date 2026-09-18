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
   1480.0,
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
     "text": "js monitor_exclusive.js",
     "patching_rect": [
      140,
      340,
      190,
      22
     ],
     "numinlets": 1,
     "numoutlets": 5,
     "outlettype": [
      "",
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
      1300,
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
      1300,
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
      30,
      195,
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
      30,
      240,
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
     "text": "print MEX",
     "patching_rect": [
      1300,
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
     "id": "obj-bt1",
     "maxclass": "live.button",
     "varname": "select1",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "select1",
       "parameter_shortname": "select1",
       "parameter_type": 2,
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_mmax": 1
      }
     },
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      140,
      45,
      20,
      20
     ],
     "presentation": 1,
     "presentation_rect": [
      10,
      11,
      20,
      20
     ]
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
      100,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      36,
      10,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-sm1",
     "maxclass": "message",
     "text": "select 1",
     "patching_rect": [
      140,
      150,
      62,
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
     "text": "1 NOT BOUND : not loaded",
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
      182,
      11,
      230,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-bt2",
     "maxclass": "live.button",
     "varname": "select2",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "select2",
       "parameter_shortname": "select2",
       "parameter_type": 2,
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_mmax": 1
      }
     },
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      370,
      45,
      20,
      20
     ],
     "presentation": 1,
     "presentation_rect": [
      10,
      37,
      20,
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
      100,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      36,
      36,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-sm2",
     "maxclass": "message",
     "text": "select 2",
     "patching_rect": [
      370,
      150,
      62,
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
     "text": "2 NOT BOUND : not loaded",
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
      182,
      37,
      230,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-bt3",
     "maxclass": "live.button",
     "varname": "select3",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "select3",
       "parameter_shortname": "select3",
       "parameter_type": 2,
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_mmax": 1
      }
     },
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      600,
      45,
      20,
      20
     ],
     "presentation": 1,
     "presentation_rect": [
      10,
      63,
      20,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-te3",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "varname": "name3edit",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "track3name",
       "parameter_shortname": "track3name",
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
      100,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      36,
      62,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-sm3",
     "maxclass": "message",
     "text": "select 3",
     "patching_rect": [
      600,
      150,
      62,
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
     "id": "obj-pp3",
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
     "id": "obj-st3",
     "maxclass": "comment",
     "text": "3 NOT BOUND : not loaded",
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
      182,
      63,
      230,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-bt4",
     "maxclass": "live.button",
     "varname": "select4",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "select4",
       "parameter_shortname": "select4",
       "parameter_type": 2,
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_mmax": 1
      }
     },
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      830,
      45,
      20,
      20
     ],
     "presentation": 1,
     "presentation_rect": [
      10,
      89,
      20,
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
      830,
      100,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      36,
      88,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-sm4",
     "maxclass": "message",
     "text": "select 4",
     "patching_rect": [
      830,
      150,
      62,
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
     "id": "obj-pp4",
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
     "id": "obj-st4",
     "maxclass": "comment",
     "text": "4 NOT BOUND : not loaded",
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
      182,
      89,
      230,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-bt5",
     "maxclass": "live.button",
     "varname": "select5",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "select5",
       "parameter_shortname": "select5",
       "parameter_type": 2,
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_mmax": 1
      }
     },
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      1060,
      45,
      20,
      20
     ],
     "presentation": 1,
     "presentation_rect": [
      10,
      115,
      20,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-te5",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "varname": "name5edit",
     "parameter_enable": 1,
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "track5name",
       "parameter_shortname": "track5name",
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
      1060,
      100,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      36,
      114,
      140,
      22
     ]
    }
   },
   {
    "box": {
     "id": "obj-sm5",
     "maxclass": "message",
     "text": "select 5",
     "patching_rect": [
      1060,
      150,
      62,
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
     "id": "obj-pp5",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      1060,
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
     "id": "obj-st5",
     "maxclass": "comment",
     "text": "5 NOT BOUND : not loaded",
     "patching_rect": [
      1060,
      430,
      220,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      182,
      115,
      230,
      20
     ]
    }
   }
  ],
  "lines": [
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
   },
   {
    "patchline": {
     "source": [
      "obj-bt1",
      0
     ],
     "destination": [
      "obj-sm1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sm1",
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
      "obj-bt2",
      0
     ],
     "destination": [
      "obj-sm2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sm2",
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
      "obj-bt3",
      0
     ],
     "destination": [
      "obj-sm3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sm3",
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
      "obj-te3",
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
      "obj-pp3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp3",
      0
     ],
     "destination": [
      "obj-st3",
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
      "obj-bt4",
      0
     ],
     "destination": [
      "obj-sm4",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sm4",
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
      3
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
      "obj-bt5",
      0
     ],
     "destination": [
      "obj-sm5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-sm5",
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
      "obj-te5",
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
      4
     ],
     "destination": [
      "obj-pp5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp5",
      0
     ],
     "destination": [
      "obj-st5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-3",
      4
     ],
     "destination": [
      "obj-12",
      0
     ]
    }
   }
  ]
 }
}