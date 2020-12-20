Aircraft integration API
========================

This file documents some integration API for your aircraft nasal code.

## Walker compatibility callbacks

|Callback / Variable|Description|
|-----------------------|---------------|
|`fgcamera.walkerGetoutTime`|wait time in seconds after the GetOut callback executed|
|`fgcamera.walkerGetinTime`|wait time in seconds after the GetIn callback executed|
|`fgcamera.walkerGetout_callback()`|callback  when getting out|
|`fgcamera.walkerGetin_callback()`|callback when getting in|


The example code for the Cessna C182S which opens the door if not open yet.

    #
    # Example to open the door on the C182S/T when getting out or in:
    # (this code should go to the aircraft nasal script)
    #
    if (getprop("/sim/aircraft") == "c182s") {
        var planeNamespace = globals[getprop("/sim/aircraft")];
        fgcamera.walkerGetout_callback = func{
            fgcamera.walkerGetoutTime = getprop("/sim/model/door-positions/DoorL/opened")==0? 2 : 0;
            c182s.DoorL.open();
        };
        fgcamera.walkerGetin_callback = func{
            view.setViewByIndex(110); # so we stay outside (under the hood we are already switched one frame into the pilot seat, which we must roll back)
            fgcamera.walkerGetinTime = getprop("/sim/model/door-positions/DoorL/opened")==0? 2 : 0;
            c182s.DoorL.open();
        };
    }
