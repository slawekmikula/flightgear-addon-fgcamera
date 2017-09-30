var main = func( root ) {
    # load scripts
    foreach(var f; ['loader.nas','fgcamera.nas','mouse.nas','flight_controls.nas'] ) {
        io.load_nasal( root ~ "/" ~ f, "fgcamera" );
    }

    # load properties
    io.read_properties(root ~ "/" ~"prop_CR.xml", "/fgcamera/cr");
    io.read_properties(root ~ "/" ~"prop_RND.xml", "/fgcamera/rnd");
    io.read_properties(root ~ "/" ~"prop_camera.xml", "/fgcamera/camera");

    # setting root path to addon
    setprop("/sim/fgcamera/root_path", root);
}
