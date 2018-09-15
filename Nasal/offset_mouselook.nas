#==================================================
#	"Mouse look" handler
#==================================================

var mouse_look_handler = {
	parents      : [ t_handler.new() ],

# FIXME - remove ?
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

		forindex (var i; me._lp) {
			me._lp[i].set(me._offsets_raw[i]);
		}
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
		} else {
			me._mlook   = 0;
		}
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

			if ( me.offsets[i] != me._offsets_raw[i] ) {
				me._updateF = 1;
			}

			i += 1;
		}
	},
#--------------------------------------------------	
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
