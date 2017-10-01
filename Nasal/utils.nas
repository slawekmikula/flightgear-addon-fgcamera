#==================================================
#	Utils
#==================================================

#--------------------------------------------------
var play_sound = func {
	var hash = {
		path   : getprop("/sim/fgcamera/root_path") ~ "/Sounds/",
		file   : "start.wav",
		volume : 1.0
	};
	fgcommand ("play-audio-sample", props.Node.new(hash));
}
#--------------------------------------------------
var show_panel = func(path = "Panels/generic-vfr-panel1.xml") {
	if ( !cameras[current[1]]["panel-show"] ) {
		return;
    }

    var root_path = getprop("/sim/fgcamera/root_path");
	setprop("/sim/panel/path", root_path ~ "/" ~ path);
	setprop("/sim/panel/visibility", 1);
}
#--------------------------------------------------
var hide_panel = func {
    setprop("/sim/panel/visibility", 0)
}

#--------------------------------------------------
var check_helicopter = func {
    props.globals.getNode("/rotors", 0, 0) != nil ? 1 : 0;
}

