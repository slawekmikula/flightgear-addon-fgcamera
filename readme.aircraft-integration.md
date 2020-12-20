Aircraft integration 
=====================
This file documents some integration API for your aircraft nasal code.

### Walker compatibility callbacks

|Callback / Variable|Description|
|-----------------------|---------------|
|`fgcamera.walkerGetoutTime`|wait time in seconds after the GetOut callback executed|
|`fgcamera.walkerGetinTime`|wait time in seconds after the GetIn callback executed|
|`fgcamera.walkerGetout_callback()`|callback  when getting out|
|`fgcamera.walkerGetin_callback()`|callback when getting in|

The `fgcamera.nas` code contains an example at the end for the C182S which opens the door if not open yet.