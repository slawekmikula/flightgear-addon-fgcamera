# About

Flightgear virtual camera. Written in NASAL. Adds features similar to Ezdok Camera Addon for FSX.

# Running

- extract zip (if downloaded as a zip) to a given location. For example let's say we have /myfolder/addons/fgcamera with contents of the fgcamera addon.
- run flightgear with --addon directive. WARNING this is not "additional settings" window in the launcher ! you
  have to modify windows shortcut or linux startup script for example to looks like this (in linux):

Code:
```
    ./fgbin/bin/fgfs --fg-root=./fgdata --launcher --prop:/sim/fg-home=/myfolder/flightgear/fghome --addon="/myfolder/addons/fgcamera"
```

# Configuration

- all can be configured through GUI available in the main menu under View->FGCamera
- settings regarding each plane are stored in FGHOME/aircraft-data/FGCamera/<plane name>

# History

- 1.0-1.2 - versions published on the flightgear forum
- 1.3
  - new GUI for configuration
  - fgcamera converted to FlightGear addon
  - ability to select mini dialogs to toggle cameras (simple and with slot numbers)

# Authors

- Marius_A - concept, coding

# Links
- FlightGear wiki: [Wiki](http://wiki.flightgear.org/FGCamera)
- FlightGear forum: [Forum](https://forum.flightgear.org/viewtopic.php?f=6&t=21685)

# License

GNU General Public License version 2 or, at your option, any later version
(https://forum.flightgear.org/viewtopic.php?f=6&t=21685&p=314678#p314678)
