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
   700.0,
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
     "id": "obj-mi",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "patching_rect": [
      30.0,
      60.0,
      45.0,
      22.0
     ],
     "text": "midiin"
    }
   },
   {
    "box": {
     "id": "obj-js",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      30.0,
      290.0,
      140.0,
      22.0
     ],
     "text": "js cc_quantize.js"
    }
   },
   {
    "box": {
     "id": "obj-mo",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      340.0,
      52.0,
      22.0
     ],
     "text": "midiout"
    }
   },
   {
    "box": {
     "id": "obj-mt",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      220.0,
      180.0,
      145.0,
      22.0
     ],
     "text": "metro 1n @quantize 1n"
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
      220.0,
      215.0,
      32.0,
      22.0
     ],
     "text": "bar"
    }
   },
   {
    "box": {
     "id": "obj-on",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      220.0,
      145.0,
      25.0,
      22.0
     ],
     "text": "1"
    }
   },
   {
    "box": {
     "id": "obj-cclk",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      375.0,
      183.0,
      290.0,
      18.0
     ],
     "text": "1n = one bar in 4/4. 2n = half bar, 4n = beat."
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
      220.0,
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
      220.0,
      55.0,
      70.0,
      22.0
     ],
     "text": "t b b b b"
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
      560.0,
      110.0,
      30.0,
      22.0
     ],
     "text": "init"
    }
   },
   {
    "box": {
     "id": "obj-wl",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      300.0,
      110.0,
      245.0,
      22.0
     ],
     "text": "watchlist 2 9 2 10 2 11 2 12"
    }
   },
   {
    "box": {
     "id": "obj-cwl",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      300.0,
      88.0,
      330.0,
      18.0
     ],
     "text": "pairs of channel cc  --  edit me. channel 0 = any channel"
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
     "varname": "quantize",
     "patching_rect": [
      30.0,
      180.0,
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
       "parameter_longname": "Quantize",
       "parameter_shortname": "Quantize",
       "parameter_mmax": 1,
       "parameter_type": 2
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-en",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      30.0,
      215.0,
      62.0,
      22.0
     ],
     "text": "enable $1"
    }
   },
   {
    "box": {
     "id": "obj-ctg",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      55.0,
      180.0,
      150.0,
      18.0
     ],
     "text": "off = pass everything now"
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
      380.0,
      470.0,
      20.0
     ],
     "text": "cc_quantize: listed CCs are held and fired on the next bar line, everything else passes through"
    }
   }
  ],
  "lines": [
   {
    "patchline": {
     "source": [
      "obj-mi",
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
      "obj-mo",
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
      "obj-ini",
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
      "obj-wl",
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
      "obj-tg",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-tr",
      0
     ],
     "destination": [
      "obj-on",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-ini",
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
      "obj-wl",
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
      "obj-on",
      0
     ],
     "destination": [
      "obj-mt",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-mt",
      0
     ],
     "destination": [
      "obj-bar",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-bar",
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
      "obj-en",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-en",
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