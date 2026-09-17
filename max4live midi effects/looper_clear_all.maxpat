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
   1700.0,
   600.0
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
      90,
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
     "text": "js looper_clear_all.js",
     "patching_rect": [
      140,
      420,
      1500,
      22
     ],
     "numinlets": 1,
     "numoutlets": 8,
     "outlettype": [
      "",
      "",
      "",
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
      30,
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
     "id": "obj-5",
     "maxclass": "newobj",
     "text": "deferlow",
     "patching_rect": [
      30,
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
     "id": "obj-7",
     "maxclass": "newobj",
     "text": "t b",
     "patching_rect": [
      140,
      300,
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
      345,
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
     "id": "obj-btn",
     "maxclass": "live.text",
     "mode": 0,
     "text": "CLEAR ALL",
     "texton": "CLEAR ALL",
     "varname": "clearall",
     "parameter_enable": 1,
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      ""
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "val1",
        "val2"
       ],
       "parameter_longname": "clear all",
       "parameter_mmax": 1,
       "parameter_shortname": "clear all",
       "parameter_type": 2
      }
     },
     "patching_rect": [
      30,
      300,
      80,
      20
     ],
     "presentation": 1,
     "presentation_rect": [
      10,
      8,
      90,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-btb",
     "maxclass": "newobj",
     "text": "t b",
     "patching_rect": [
      30,
      345,
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
     "id": "obj-cla",
     "maxclass": "message",
     "text": "clearall",
     "patching_rect": [
      30,
      380,
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
     "id": "obj-te1",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "parameter_enable": 1,
     "varname": "name1edit",
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
      28,
      36,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop1name",
       "parameter_shortname": "loop1name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb1",
     "maxclass": "comment",
     "text": "1",
     "patching_rect": [
      140,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      37,
      18,
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
      470,
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
     "text": "not loaded",
     "patching_rect": [
      140,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      172,
      37,
      150,
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
     "parameter_enable": 1,
     "varname": "name2edit",
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      330,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      348,
      36,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop2name",
       "parameter_shortname": "loop2name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb2",
     "maxclass": "comment",
     "text": "2",
     "patching_rect": [
      330,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      330,
      37,
      18,
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
      330,
      470,
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
     "text": "not loaded",
     "patching_rect": [
      330,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      492,
      37,
      150,
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
     "parameter_enable": 1,
     "varname": "name3edit",
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      520,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      28,
      60,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop3name",
       "parameter_shortname": "loop3name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb3",
     "maxclass": "comment",
     "text": "3",
     "patching_rect": [
      520,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      61,
      18,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp3",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      520,
      470,
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
     "text": "not loaded",
     "patching_rect": [
      520,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      172,
      61,
      150,
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
     "parameter_enable": 1,
     "varname": "name4edit",
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      710,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      348,
      60,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop4name",
       "parameter_shortname": "loop4name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb4",
     "maxclass": "comment",
     "text": "4",
     "patching_rect": [
      710,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      330,
      61,
      18,
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
      710,
      470,
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
     "text": "not loaded",
     "patching_rect": [
      710,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      492,
      61,
      150,
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
     "parameter_enable": 1,
     "varname": "name5edit",
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      900,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      28,
      84,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop5name",
       "parameter_shortname": "loop5name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb5",
     "maxclass": "comment",
     "text": "5",
     "patching_rect": [
      900,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      85,
      18,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp5",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      900,
      470,
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
     "text": "not loaded",
     "patching_rect": [
      900,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      172,
      85,
      150,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-te6",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "parameter_enable": 1,
     "varname": "name6edit",
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      1090,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      348,
      84,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop6name",
       "parameter_shortname": "loop6name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb6",
     "maxclass": "comment",
     "text": "6",
     "patching_rect": [
      1090,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      330,
      85,
      18,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp6",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      1090,
      470,
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
     "id": "obj-st6",
     "maxclass": "comment",
     "text": "not loaded",
     "patching_rect": [
      1090,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      492,
      85,
      150,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-te7",
     "maxclass": "textedit",
     "keymode": 1,
     "outputmode": 1,
     "parameter_enable": 1,
     "varname": "name7edit",
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      1280,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      28,
      108,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop7name",
       "parameter_shortname": "loop7name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb7",
     "maxclass": "comment",
     "text": "7",
     "patching_rect": [
      1280,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      10,
      109,
      18,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-pp7",
     "maxclass": "newobj",
     "text": "prepend set",
     "patching_rect": [
      1280,
      470,
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
     "id": "obj-st7",
     "maxclass": "comment",
     "text": "not loaded",
     "patching_rect": [
      1280,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      172,
      109,
      150,
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
     "parameter_enable": 1,
     "varname": "name8edit",
     "numinlets": 1,
     "numoutlets": 4,
     "outlettype": [
      "",
      "int",
      "",
      ""
     ],
     "patching_rect": [
      1470,
      45,
      150,
      22
     ],
     "presentation": 1,
     "presentation_rect": [
      348,
      108,
      140,
      22
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_invisible": 1,
       "parameter_longname": "loop8name",
       "parameter_shortname": "loop8name",
       "parameter_type": 3
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-lb8",
     "maxclass": "comment",
     "text": "8",
     "patching_rect": [
      1470,
      20,
      20,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      330,
      109,
      18,
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
      1470,
      470,
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
     "text": "not loaded",
     "patching_rect": [
      1470,
      510,
      150,
      20
     ],
     "numinlets": 1,
     "numoutlets": 0,
     "presentation": 1,
     "presentation_rect": [
      492,
      109,
      150,
      20
     ]
    }
   },
   {
    "box": {
     "id": "obj-t0",
     "maxclass": "message",
     "text": "clearall",
     "patching_rect": [
      140,
      250,
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
     "text": "resolve",
     "patching_rect": [
      205,
      250,
      50,
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
      "obj-btn",
      0
     ],
     "destination": [
      "obj-btb",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-btb",
      0
     ],
     "destination": [
      "obj-cla",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-cla",
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
      "obj-te6",
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
      5
     ],
     "destination": [
      "obj-pp6",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp6",
      0
     ],
     "destination": [
      "obj-st6",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-te7",
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
      6
     ],
     "destination": [
      "obj-pp7",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-pp7",
      0
     ],
     "destination": [
      "obj-st7",
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
      7
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
   }
  ]
 }
}