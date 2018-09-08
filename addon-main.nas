#
# FGCamera addon
#
# Started by Marius_A
# Started on December 2013
#
# Converted to a FlightGear addon by
# Slawek Mikula, October 2017

var main = func( addon ) {
    var root = addon.basePath;

    # setting root path to addon
    setprop("/sim/fgcamera/root_path", root);

    # load scripts
    foreach(var f; ['fgcamera.nas','mouse.nas'] ) {
        io.load_nasal( root ~ "/" ~ f, "fgcamera" );
    }
}
