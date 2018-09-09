#==================================================
#	fgcamera.mouse
#
#		get_xy()      - ... returns [x, y],
#		get_dxdy()    - ... returns [dx, dy],
#		get_button(n) - ... returns 0 / 1.
#==================================================
var mouse = {
	_current   : zeros(6),
	_previous  : zeros(6),
	_delta     : zeros(6),
	_path      : "/devices/status/mice/mouse/",
	_path1     : "/sim/fgcamera/mouse/",
#--------------------------------------------------
	get_xy: func {
		foreach (var a; [[0, "x"], [1, "y"]] ) {
			var i   = a[0];
			var dof = a[1];

			me._previous[i] = me._current[i];
			me._current[i]  = getprop(me._path ~ dof);
			me._delta[i]    = me._current[i] - me._previous[i];
		}
		return me._current;
	},
#--------------------------------------------------
	get_delta: func {
		var i = 0;
		foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
			me._previous[i] = me._current[i];
			me._current[i]  = getprop(me._path1 ~ a) or 0;

			me._delta[i]    = me._current[i] - me._previous[i];

			i += 1;
		}
		return me._delta;
	},
#--------------------------------------------------
	set_mode: func(mode) {
		setprop("/devices/status/mice/mouse/mode", mode);
	},
#--------------------------------------------------
	get_mode: func {
		getprop("/devices/status/mice/mouse/mode");
	},
#--------------------------------------------------
	get_button: func(n) {
		getprop(me._path ~ "button[" ~ n ~ "]") or 0;
	},
#--------------------------------------------------
	reset: func {
		var i = 0;
		foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
			me._previous[i] = 0;
			me._current[i]  = 0;
			me._delta[i]    = 0;

			setprop(me._path1 ~ a, 0);
			i += 1;
		}
	},
};
