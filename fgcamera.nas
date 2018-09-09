var my_version   = "v1.2.1";
var my_node_path = "/sim/fgcamera";
var my_views     = ["FGCamera1", "FGCamera2", "FGCamera3", "FGCamera4", "FGCamera5"];
var my_settings  = {};

var cameras      = [];
var offsets      = [0, 0, 0, 0, 0, 0];
var offsets2     = [0, 0, 0, 0, 0, 0];
var current      = [0, 0]; # [view, camera]

var popupTipF    = 0;
var panelF       = 0;
var dialogF      = 0;
var timeF        = 0;
var helicopterF  = nil;

var mouse_enabled = 0;

#==================================================
#	"Shortcuts"
#==================================================
var sin       = math.sin;
var cos       = math.cos;
var hasmember = view.hasmember;

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
var show_panel = func(path = "Aircraft/Panels/generic-vfr-panel.xml") {
	if ( !cameras[current[1]]["panel-show"] ) {
		return;
	}

	setprop("/sim/panel/path", path);
	setprop("/sim/panel/visibility", 1);
}
#--------------------------------------------------
var hide_panel = func { setprop("/sim/panel/visibility", 0) }
var check_helicopter = func props.globals.getNode("/rotors", 0, 0) != nil ? 1 : 0;

#==================================================
#	Start
#==================================================
var FGcycleMouseMode = nil;

var configure_FG = func (mode = "start") {
	var path = "/sim/mouse/right-button-mode-cycle-enabled";
	if ( FGcycleMouseMode == nil ) FGcycleMouseMode = getprop(path);
	if ( mode == "start" ) {
		setprop(path, 1);
	} else {
		setprop(path, FGcycleMouseMode);
	}
}

var fgcamera_view_handler = {
	init   : func { manager.init() },
	start  : func { manager.start(); configure_FG("start") },
	update : func { return manager.update() },
	stop   : func { manager.stop(); configure_FG("stop") }
};

var load_nasal = func (v) {
	var path = getprop("/sim/fgcamera/root_path");
	foreach (var script; v) {
		io.load_nasal ( path ~ "/Nasal/" ~ script ~ ".nas", "fgcamera" );
	}
}

var init_mouse = func {
	# load new mouse configuration & reinit input subsystem
	props.getNode("/input/mice").removeAllChildren();
	var path = getprop("/sim/fgcamera/root_path");
	io.read_properties(path ~ "/fgmouse.xml", "/input/mice");
	fgcommand("reinit", props.Node.new({"subsystem": "input"}));
};

#--------------------------------------------------
var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);

	load_nasal ([
		"math",
		"version",
		"gui",
		"commands",
		"io",
		"mouse",
		"offset_template",
		"offset_movement",
		"offset_DHM",
		"offset_RND",
		"offset_trackir",
		"offset_linuxtrack",
		"offset_adjustment",
		"offset_mouselook",
		"offsets_manager",
	]);

  init_mouse();
	add_commands();
	load_cameras();
	load_gui();
	helicopterF = check_helicopter();

	foreach (var a; my_views) {
		view.manager.register(a, fgcamera_view_handler);
	}

	if ( getprop("/sim/fgcamera/enable") ) {
		setprop (my_node_path ~ "/current-camera/camera-id", 0);
	}
});

var reinit_listener = setlistener("/sim/signals/reinit", func {

	init_mouse();

	fgcommand("gui-redraw");
	fgcommand("fgcamera-reset-view");

	helicopterF = check_helicopter();
});
#eof
