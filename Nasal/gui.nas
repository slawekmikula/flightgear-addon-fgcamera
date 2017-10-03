#==================================================
#	GUI
#==================================================

var root_path = getprop("/sim/fgcamera/root_path");

var load_gui = func {
	var dialogs   = [
        "fgcamera-main",
        "fgcamera-options",
        "create-new-camera",
        "current-camera",
        "DHM-settings",
        "RND-mixer",
        "RND-generator",
        "RND-curves",
        "RND-import",
        "vibration-curves",
        "power-plant-vibration",
        "timestamps-import"];

	forindex (var i; dialogs) {
		gui.Dialog.new("/sim/gui/dialogs/" ~ dialogs[i] ~ "/dialog", root_path ~ "/GUI/" ~ dialogs[i] ~ ".xml");
    }

	foreach(var item; props.getNode("/sim/menubar/default/menu[1]").getChildren("item")) {
		if (item.getValue("name") == "fgcamera") {
			return;
        }
    }

	var data = {
		label   : "FGCamera",
		name    : "fgcamera",
		binding : { command : "dialog-show", "dialog-name" : "fgcamera-main" },
		enabled : { property : "/sim/fgcamera/fgcamera-enabled" },#??? FIX
	};
	props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);

	fgcommand("gui-redraw");
}

var mini_dialog_visible = 0;
var mini_dialog = nil;

var register_gui_mini_dialogs = func {

    if (getprop("/sim/fgcamera/mini-dialog-enable") == 0) {
        return;
    }

    var x_size = getprop("/sim/startup/xsize");
    var y_size = getprop("/sim/startup/ysize");

    var calc_screen_xsize = func x_size = getprop("/sim/startup/xsize");
    var calc_screen_ysize = func y_size = getprop("/sim/startup/ysize");

    setlistener("/sim/startup/xsize", func calc_screen_xsize());
    setlistener("/sim/startup/ysize", func calc_screen_ysize());

    var dialog_type = getprop("/sim/fgcamera/mini-dialog-type");
    if (dialog_type == nil) {
        dialog_type = "simple";
    }

    if (dialog_type == "simple") {
        mini_dialog = gui.Dialog.new("/sim/gui/dialogs/fgcamera-mini-dialog/dialog", root_path ~ "/GUI/mini-dialog-simple.xml");
    } elsif (dialog_type == "slots") {
        mini_dialog = gui.Dialog.new("/sim/gui/dialogs/fgcamera-mini-dialog-slots/dialog", root_path ~ "/GUI/mini-dialog-slots.xml");
    }

    if (getprop("/sim/fgcamera/mini-dialog-autohide") == 1) {
        var __mouse = {
            x: func getprop("/devices/status/mice/mouse/x") or 0,
            y: func getprop("/devices/status/mice/mouse/y") or 0,
        };

        setlistener("/devices/status/mice/mouse/y", func {
            if ( (__mouse.y() > (y_size-120)) and (__mouse.x() < 200) ) {
                if (!mini_dialog_visible) {
                    mini_dialog.open();
                    mini_dialog_visible = 1;
                }
            } elsif (mini_dialog_visible) {
                mini_dialog.close();
                mini_dialog_visible = 0;
            }
        }, 1, 0);
    } else {
        mini_dialog.open();
        mini_dialog_visible = 1;
    }
}

load_gui();
register_gui_mini_dialogs();


var show_dialog = func (show = 0) {
    gui.showDialog( getprop("/sim/fgcamera/current-camera/config/dialog-name") );
    setprop("/sim/fgcamera/current-camera/dialog-opened", 1);
}

var close_dialog = func (close = 0) {
	var h = {"dialog-name" : getprop("/sim/fgcamera/current-camera/config/dialog-name") or return};
    fgcommand ( "dialog-close", {"dialog-name" : getprop("/sim/fgcamera/current-camera/config/dialog-name")} );
	setprop("/sim/fgcamera/current-camera/dialog-opened", 0);
}

print("FGCamera: GUI script loaded");