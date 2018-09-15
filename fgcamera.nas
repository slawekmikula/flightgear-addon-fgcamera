var my_addon_id  = "a.marius.FGCamera";
var my_version   = getprop("/addons/by-id/" ~ my_addon_id ~ "/version");
var my_root_path = getprop("/addons/by-id/" ~ my_addon_id ~ "/path");
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
	foreach (var script; v) {
		io.load_nasal ( my_root_path ~ "/Nasal/" ~ script ~ ".nas", "fgcamera" );
	}
}

var init_mouse = func {
	# load new mouse configuration & reinit input subsystem
	props.getNode("/input/mice").removeAllChildren();
	io.read_properties(my_root_path ~ "/fgmouse.xml", "/input/mice");
	fgcommand("reinit", props.Node.new({"subsystem": "input"}));
};

#--------------------------------------------------
var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);

	helicopterF = check_helicopter();
	print("helicopter: " ~ helicopterF);

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
