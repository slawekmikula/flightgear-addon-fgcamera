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
var show_panel = func() {
	show_panel_path(cameras[current[1]]["panel-show-type"]);
}

var show_panel_path = func(path) {
	if ( !cameras[current[1]]["panel-show"] ) {
		return;
	}

	if (path == nil or path == "") {
		path = "generic-vfr-panel";
	}

	path = "Aircraft/Panels/" ~ path ~ ".xml";

	setprop("/sim/panel/path", path);
	setprop("/sim/panel/visibility", 1);
}
#--------------------------------------------------
var hide_panel = func { setprop("/sim/panel/visibility", 0) }
var check_helicopter = func props.globals.getNode("/rotors/main/torque", 0, 0) != nil ? 1 : 0;

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

# Support walk view toggle, when he gets out
# The following variables define the behaviour and may be overriden by aircraft (for example to open the door before going out)
# (See examples below)
var walkerGetoutTime = 0.0;           # wait time after the GetOut callback executed
var walkerGetinTime  = 0.0;           # wait time after the GetIn callback executed
var walkerGetout_callback = func{0};  # callback when getting out
var walkerGetin_callback  = func{0};  # callback when getting in
var lastWalkerFGCam = nil;  # here we store what view we were in when the walker exits
setlistener("sim/walker/key-triggers/outside-toggle", func {
    # we let pass some time so the walker code can execute first
    var timer = nil;
    if (getprop("sim/walker/key-triggers/outside-toggle")) {
        walkerGetout_callback();
        timer = maketimer(walkerGetoutTime + 0.5, func(){
            # went outside
            lastWalkerFGCam = getprop("/sim/current-view/view-number-raw");
            view.setViewByIndex(110);  #110 is defined as walk view by fgdata/walker-include.xml
        });
    } else {
        walkerGetin_callback();
        timer = maketimer(walkerGetinTime + 0.5, func(){
            # went inside
            view.setViewByIndex(lastWalkerFGCam);  #110 is defined as walk view by fgdata/walker-include.xml
            lastWalkerFGCam = nil;
        });
    }
    timer.singleShot = 1; # timer will only be run once
    timer.start();
});


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


#eof
