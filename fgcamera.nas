var my_version   = "v1.3";
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
var cycle_mouse_mode = nil;

#==================================================
#	Start
#==================================================

#--------------------------------------------------
var configure = func (mode = "start") {
	var path = "/sim/mouse/right-button-mode-cycle-enabled";
	if ( cycle_mouse_mode == nil ) {
        cycle_mouse_mode = getprop(path);
    }
	if ( mode == "start" ) {
		setprop(path, 1);
	} else {
		setprop(path, cycle_mouse_mode);
    }
}

#--------------------------------------------------
var fgcamera_view_handler = {
	init   : func { manager.init() },
	start  : func { manager.start(); configure("start") },
	update : func { return manager.update() },
	stop   : func { manager.stop(); configure("stop") }
};

#--------------------------------------------------
var load_nasal = func {
	var path = getprop("/sim/fgcamera/root_path");
	foreach (var script; arg) {
		io.load_nasal ( path ~ "/Nasal/" ~ script ~ ".nas", "fgcamera" );
    }
}

#--------------------------------------------------
var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);

	load_nasal ([
        "utils",
        "handlers",
		"version",
		"gui",
		"commands",
		"persistence",
		"view_movement",
		"DHM",
		"RND",
		"headtracker",
		"offsets_manager",
        "mouse",
	]);

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

#--------------------------------------------------
var reinit_listener = setlistener("/sim/signals/reinit", func {
	fgcommand("gui-redraw");
	fgcommand("fgcamera-reset-view");
	helicopterF = check_helicopter();
});
#eof