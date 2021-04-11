FGCamera FlightGear Addon
=========================

# About

Flightgear virtual camera. Written in NASAL. Adds features similar to Ezdok Camera Addon for FSX.

# Running

- extract zip (if downloaded as a zip) to a given location. For example let's
  say we have /myfolder/addons/thisaddon with contents of this addon.
- run flightgear with --addon directive **OR** add it in the Launcher application
  in 'Add-On' section.

Code:
```
    ./fgbin/bin/fgfs --fg-root=./fgdata --launcher --prop:/sim/fg-home=/myfolder/flightgear/fghome --addon="/myfolder/addons/fgcamera"
```

# Documentation

More documents can be found in the Docs folder.

# Configuration

- all can be configured through GUI available in the main menu under View->FGCamera
- settings regarding each plane are stored in FGHOME/aircraft-data/FGCamera/<plane name>

# History

- 1.0-1.2 - versions published on the flightgear forum
- 1.2.1 - addon compatiblity + small fixes
- 1.2.2 - #5 (reverse mouse controls - the same as in FG), #3 disable <space> keyboard mapping, #10 adds additional API for walker aircraft integration
- 1.2.3 - fix create new camera, fix count cameras from 1, welcome message, help message

# Planned (branch next)

- 2.x
  - new GUI for configuration
  - logic moved to property-rules
  - ability to select mini dialogs to toggle cameras (simple and with slot numbers)

# Authors

- Marius_A - concept, coding
- Slawek Mikula - addon compatiblity
- PlayeRom - fixes and improvements

# Links

- FlightGear wiki: [Wiki](http://wiki.flightgear.org/FGCamera)
- FlightGear forum: [Forum](https://forum.flightgear.org/viewtopic.php?f=6&t=21685)

# License

GNU General Public License version 2 or, at your option, any later version
(https://forum.flightgear.org/viewtopic.php?f=6&t=21685&p=314678#p314678)
