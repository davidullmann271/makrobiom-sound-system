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
   134.0,
   134.0,
   1852.0,
   921.0
  ],
  "openrect": [
   0.0,
   0.0,
   0.0,
   169.0
  ],
  "default_fontsize": 10.0,
  "default_fontname": "Arial Bold",
  "gridsize": [
   8.0,
   8.0
  ],
  "boxanimatetime": 500,
  "boxes": [
   {
    "box": {
     "id": "obj-15",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      441.1662348508835,
      69.41176760196686,
      101.0,
      20.0
     ],
     "text": "property is_playing"
    }
   },
   {
    "box": {
     "id": "obj-13",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "bang",
      ""
     ],
     "patching_rect": [
      521.0526266098022,
      39.41176635026932,
      55.121952533721924,
      20.0
     ],
     "text": "t b l"
    }
   },
   {
    "box": {
     "id": "obj-12",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "",
      ""
     ],
     "patching_rect": [
      521.0526266098022,
      108.23529863357544,
      70.0,
      20.0
     ],
     "saved_object_attributes": {
      "_persistence": 1
     },
     "text": "live.observer"
    }
   },
   {
    "box": {
     "id": "obj-4",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "",
      "",
      ""
     ],
     "patching_rect": [
      453.1662348508835,
      11.842105150222778,
      89.0,
      20.0
     ],
     "text": "live.path live_set"
    }
   },
   {
    "box": {
     "id": "obj-38",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      20.97561025619507,
      6.842105150222778,
      62.4390230178833,
      30.0
     ],
     "text": "PRESS\n"
    }
   },
   {
    "box": {
     "id": "obj-36",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      20.0,
      159.0,
      30.0,
      20.0
     ],
     "text": "0"
    }
   },
   {
    "box": {
     "id": "obj-26",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      20.0,
      195.0,
      67.0,
      20.0
     ],
     "saved_object_attributes": {
      "_persistence": 1,
      "normalized": 0,
      "smoothing": 1.0
     },
     "text": "live.remote~"
    }
   },
   {
    "box": {
     "id": "obj-25",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      300.0,
      131.0,
      35.0,
      20.0
     ],
     "text": "1"
    }
   },
   {
    "box": {
     "id": "obj-22",
     "maxclass": "live.button",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "parameter_enable": 1,
     "patching_rect": [
      20.147058099508286,
      39.41176635026932,
      34.70588380098343,
      33.52941316366196
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_enum": [
        "off",
        "on"
       ],
       "parameter_longname": "live.button",
       "parameter_mmax": 1,
       "parameter_modmode": 0,
       "parameter_shortname": "live.button",
       "parameter_type": 2
      }
     },
     "varname": "live.button"
    }
   },
   {
    "box": {
     "id": "obj-11",
     "maxclass": "live.comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      28.0,
      294.0,
      19.0,
      18.0
     ],
     "text": "L",
     "textjustification": 0
    }
   },
   {
    "box": {
     "id": "obj-10",
     "maxclass": "live.comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      28.0,
      213.0,
      19.0,
      18.0
     ],
     "text": "L",
     "textjustification": 0
    }
   },
   {
    "box": {
     "id": "obj-8",
     "maxclass": "live.comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      101.0,
      214.0,
      19.0,
      18.0
     ],
     "text": "R",
     "textjustification": 0
    }
   },
   {
    "box": {
     "id": "obj-7",
     "maxclass": "live.comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      100.0,
      294.0,
      19.0,
      18.0
     ],
     "text": "R",
     "textjustification": 0
    }
   },
   {
    "box": {
     "fontname": "Ableton Sans Medium Regular",
     "fontsize": 11.0,
     "hidden": 1,
     "id": "obj-9",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      0.0,
      170.0,
      134.0,
      20.0
     ],
     "text": "Device vertical limit"
    }
   },
   {
    "box": {
     "fontname": "Arial Bold",
     "fontsize": 10.0,
     "id": "obj-2",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "signal"
     ],
     "patching_rect": [
      44.0,
      293.0,
      53.0,
      20.0
     ],
     "text": "plugout~"
    }
   },
   {
    "box": {
     "fontname": "Arial Bold",
     "fontsize": 10.0,
     "id": "obj-1",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "signal"
     ],
     "patching_rect": [
      44.0,
      213.0,
      53.0,
      20.0
     ],
     "text": "plugin~"
    }
   },
   {
    "box": {
     "id": "obj-d1",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      20.0,
      75.0,
      150.0,
      20.0
     ],
     "text": "delay 0 @quantize 16n"
    }
   },
   {
    "box": {
     "id": "obj-t1",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "bang",
      "bang"
     ],
     "patching_rect": [
      20.0,
      103.0,
      45.0,
      20.0
     ],
     "text": "t b b"
    }
   },
   {
    "box": {
     "id": "obj-d2",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      20.0,
      131.0,
      255.0,
      20.0
     ],
     "text": "delay @delaytime 1 ticks @quantize 3840 ticks"
    }
   },
   {
    "box": {
     "id": "obj-s0",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "bang",
      ""
     ],
     "patching_rect": [
      521.0,
      140.0,
      45.0,
      20.0
     ],
     "text": "sel 0"
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
      521.0,
      168.0,
      40.0,
      20.0
     ],
     "text": "stop"
    }
   },
   {
    "box": {
     "id": "obj-c1",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      180.0,
      75.0,
      240.0,
      18.0
     ],
     "text": "press -> ON at the next 16th note"
    }
   },
   {
    "box": {
     "id": "obj-c2",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      60.0,
      159.0,
      330.0,
      18.0
     ],
     "text": "OFF on the song 2-bar grid: 3840 ticks = 2 bars in 4/4 (480 ppq)"
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
      400.0,
      20.0,
      100.0,
      20.0
     ],
     "text": "live.thisdevice"
    }
   },
   {
    "box": {
     "id": "obj-t0",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "bang",
      "bang"
     ],
     "patching_rect": [
      400.0,
      48.0,
      45.0,
      20.0
     ],
     "text": "t b b"
    }
   },
   {
    "box": {
     "id": "obj-jsb",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      400.0,
      76.0,
      190.0,
      20.0
     ],
     "text": "js autoswitchoff_target.js"
    }
   },
   {
    "box": {
     "id": "obj-c3",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      400.0,
      104.0,
      380.0,
      18.0
     ],
     "text": "DRMAUD / Beat Repeat / \"Repeat\" -- bound by name, not by index"
    }
   }
  ],
  "lines": [
   {
    "patchline": {
     "destination": [
      "obj-2",
      1
     ],
     "source": [
      "obj-1",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-2",
      0
     ],
     "source": [
      "obj-1",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-12",
      1
     ],
     "source": [
      "obj-13",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-15",
      0
     ],
     "source": [
      "obj-13",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-12",
      0
     ],
     "source": [
      "obj-15",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-26",
      0
     ],
     "source": [
      "obj-25",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-26",
      0
     ],
     "source": [
      "obj-36",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-13",
      0
     ],
     "source": [
      "obj-4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-d1",
      0
     ],
     "order": 0,
     "source": [
      "obj-22",
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
     "order": 0,
     "source": [
      "obj-d1",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-25",
      0
     ],
     "order": 0,
     "source": [
      "obj-t1",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-d2",
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
      "obj-36",
      0
     ],
     "order": 0,
     "source": [
      "obj-d2",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-s0",
      0
     ],
     "order": 0,
     "source": [
      "obj-12",
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
      "obj-s0",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-d1",
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
      "obj-d2",
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
      "obj-t0",
      0
     ],
     "order": 0,
     "source": [
      "obj-td",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-4",
      0
     ],
     "order": 0,
     "source": [
      "obj-t0",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-jsb",
      0
     ],
     "order": 0,
     "source": [
      "obj-t0",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-26",
      1
     ],
     "order": 0,
     "source": [
      "obj-jsb",
      0
     ]
    }
   }
  ],
  "parameters": {
   "obj-22": [
    "live.button",
    "live.button",
    0
   ],
   "parameterbanks": {
    "0": {
     "index": 0,
     "name": "",
     "parameters": [
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-"
     ],
     "buttons": [
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-"
     ]
    }
   },
   "inherited_shortname": 1
  },
  "dependency_cache": [],
  "latency": 0,
  "is_mpe": 0,
  "external_mpe_tuning_enabled": 0,
  "minimum_live_version": "",
  "minimum_max_version": "",
  "platform_compatibility": 0,
  "project": {
   "version": 1,
   "creationdate": 3590052493,
   "modificationdate": 3590052493,
   "viewrect": [
    0.0,
    0.0,
    300.0,
    500.0
   ],
   "autoorganize": 1,
   "hideprojectwindow": 1,
   "showdependencies": 1,
   "autolocalize": 0,
   "contents": {
    "patchers": {}
   },
   "layout": {},
   "searchpath": {},
   "detailsvisible": 0,
   "amxdtype": 1633771873,
   "readonly": 0,
   "devpathtype": 0,
   "devpath": ".",
   "sortmode": 0,
   "viewmode": 0,
   "includepackages": 0
  },
  "autosave": 0,
  "saved_attribute_attributes": {
   "default_plcolor": {
    "expression": ""
   }
  },
  "oscreceiveudpport": 0
 }
}