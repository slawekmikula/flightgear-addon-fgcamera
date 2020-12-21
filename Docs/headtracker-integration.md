Head Tracker integration
========================

Head Tracking is implemented in Nasal/offset_<trackername>.nas files. Currently available integration with:

* Linux Track - offset_linuxtrack.nas
* Track IR - offset_trackir.nas

# Adding new integration

* Create file with content similar to core head tracking software
* Add offset handler to handlers variable in offsets_manager.nas file