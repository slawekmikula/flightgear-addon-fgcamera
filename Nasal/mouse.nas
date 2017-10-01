var mouse = {
	_path: "/devices/status/mice/mouse/",

	mode: func(mode = nil) {
		if (mode != nil) {
			return setprop("/devices/status/mice/mouse/mode", mode);
        }
		getprop("/devices/status/mice/mouse/mode");
	},

	button: func(n) (getprop(me._path ~ "button[" ~ n ~ "]") or 0),
};

#-------------------------------------------------
var mouse_mode = 0; #  0 - mouse; 1 - yoke; 2 - rudder/throttle
#-------------------------------------------------
var toggleYoke = func {
	if (mouse_mode == 0) {
		mouse_mode = 1;
	} else {
		mouse_mode = 0;
	}
	setprop("/devices/status/mice/mouse/mode", mouse_mode);
	setprop("/sim/fgcamera/mouse/mouse-yoke", mouse_mode);
}
#-------------------------------------------------
var prev_mode = 0;
#-------------------------------------------------
var switch_to_mouse = func {
	if ( !getprop("/sim/fgcamera/mouse/spring-loaded") or !getprop("/sim/fgcamera/fgcamera-enabled") ) return;
	var b2 = mouse.button(2);
	if (b2) {
		prev_mode = mouse.mode();
		mouse.mode(2);
	} else {
        mouse.mode(prev_mode);
    }
}
#-------------------------------------------------

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

#==================================================
#	"Mouse look" handler
#==================================================

var mouse_look_handler = {
	parents      : [ t_handler.new() ],

#	_mouse       : [[,,], [,,]],
	_delta       : zeros(6),
	_delta_t     : zeros(6),
	_path        : "/devices/status/mice/mouse/",
	_sensitivity : 1,
	_filter      : 0,
	_track_xy    : 0,
	_prev_mode   : 0,
	_mlook       : 0,
#--------------------------------------------------
	_reset : func {
		me.offsets      = zeros(6);
		me._offsets_raw = zeros(6);

		forindex (var i; me._lp)
			me._lp[i].set(me._offsets_raw[i]);
	},
#--------------------------------------------------
	_trigger : func {
		var m = mouse.get_mode();
		if ( (m == 2) or (m == 3) ) {
			me._mlook = 1;

			mouse.reset();

			var m = cameras[current[1]].mouse_look;
			me._sensitivity = m.sensitivity;
			me._filter      = m.filter;

			me._updateF = 1;
		} else
			me._mlook   = 0;
	},
#--------------------------------------------------
	start : func {
		var path     = me._path ~ "mode";
		var listener = setlistener ( path, func {me._trigger()} );

		append (me._listeners, listener);
	},
#--------------------------------------------------
	update : func {
		if (!me._updateF) return;

		me._updateF = me._mlook;

		me._delta = mouse.get_delta();
		me._rotate();

		var i = 0;
		forindex (var i; me._delta_t) {
			me._offsets_raw[i] += me._delta_t[i] * me._sensitivity;
			me.offsets[i]       = me._lp[i].filter(me._offsets_raw[i], me._filter);

			if ( me.offsets[i] != me._offsets_raw[i] )
				me._updateF = 1;

			i += 1;
		}
	},
	_rotate: func {
		var t = subvec(me._delta, 0, 3);
		var r = subvec(offsets, 3);

		forindex (var i; var c = rotate3d(t, r)) {
			var _i      = [3, 4, 5][i];
			me._delta_t[i]  = c[i];
			me._delta_t[_i] = me._delta[_i];
		}
	},
};