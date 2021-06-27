#==================================================
#	GUI loader and handler
#==================================================

#--------------------------------------------------
var load_gui = func {
	var dialogs   = ["fgcamera-main", "create-new-camera", "current-camera",
									 "fgcamera-options", "DHM-settings", "RND-mixer",
									 "RND-generator", "RND-curves", "RND-import", "fgcamera-help", "fgcamera-welcome"];
	var filenames = ["main", "create_camera", "camera_settings", "fgcamera_options",
									 "DHM_settings", "RND_mixer", "RND_generator", "RND_curves",
									 "RND_import", "fgcamera-help", "fgcamera-welcome"];
	var menu_item_name = "fgcamera";

	forindex (var i; dialogs) {
		gui.Dialog.new("/sim/gui/dialogs/" ~ dialogs[i] ~ "/dialog", my_root_path ~ "/GUI/" ~ filenames[i] ~ ".xml");
	}

	var data = {
		label   : "FGCamera",
		name    : menu_item_name,
		binding : { command : "dialog-show", "dialog-name" : "fgcamera-main" }
	};

	if (!is_menu_item_exists(menu_item_name)) {
		props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);
	}

	fgcommand("gui-redraw");
}

#--------------------------------------------------
var show_dialog = func (show = 0) {
	if (cameras[current[1]]["dialog-show"] or show)
		gui.showDialog(cameras[current[1]]["dialog-name"]);
}

#--------------------------------------------------
var close_dialog = func (close = 0) {
	if (cameras[current[1]]["dialog-show"] or close)
		fgcommand ( "dialog-close", props.Node.new({ "dialog-name" : cameras[current[1]]["dialog-name"] }) );
}

#--------------------------------------------------
# Prevent to add menu item more than once, e.g. after reload the sim by <Shift-Esc>
var is_menu_item_exists = func (menu_item_name) {
	foreach (var item; props.globals.getNode("/sim/menubar/default/menu[1]").getChildren("item")) {
		var name = item.getChild("name");
		if (name != nil and name.getValue() == menu_item_name) {
			print("Menu item FGCamera alredy exists");
			return 1;
		}
	}

	return 0;
}

print("GUI loaded");
