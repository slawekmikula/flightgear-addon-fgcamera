#==================================================
#	Template for handlers
#==================================================
var t_handler = {
#--------------------------------------------------
	new: func {
		var m = { parents: [t_handler] };

		m.offsets      = [0, 0, 0, 0, 0, 0];
		m._offsets_raw = [0, 0, 0, 0, 0, 0];
		m._lp          = [];
		m._listeners   = [];
		m._free        = 0;
		m._effect      = 0;
		m._updateF     = 0;
		m._list        = ["x", "y", "z", "h", "p", "r"];

		forindex (var i; m.offsets) {
			append (m._lp, lowpass.new(0));
			m._lp[i].filter(0);
		}

		return m;
	},

#--------------------------------------------------
	stop: func {
		if ( size(me._listeners) ) {
			foreach (var l; me._listeners) {
				removelistener(l);
            }
			setsize(me._listeners, 0);
		}
	},

};

#==================================================
#	View adjustment handler
#==================================================
var adjustment_handler = {
	parents      : [ t_handler.new() ],

	_v           : [0, 0, 0, 0, 0, 0],
	_v_t         : [0, 0, 0, 0, 0, 0], # transformed
#--------------------------------------------------
	_reset : func {
		forindex (var i; me.offsets) {
			me.offsets[i] = me._offsets_raw[i] = 0;
			me._lp[i].set(0);
		}
	},
#--------------------------------------------------
	_trigger : func {
		forindex (var i; me._list) {
			var v     = nil;
			var v_cfg = cameras[current[1]].adjustment.v;

			if (i < 3) {
				v = v_cfg[0];
			} else {
				v = v_cfg[1];
            }

			me._v[i] = getprop(my_node_path ~ "/controls/adjust-" ~ me._list[i]) or 0;
			if ( (me._v[i] *= v) != 0 ) {
				me._updateF = 1;
            }
		}
	},
#--------------------------------------------------
	start: func {
		foreach (var a; me._list) {
			var listener = setlistener( my_node_path ~ "/controls/adjust-" ~ a, func { me._trigger() }, 0, 0 );
			append (me._listeners, listener);
		}
	},
#--------------------------------------------------
	update: func (dt) {
		if (me._updateF) {
			me._updateF = 0;

			var filter  = cameras[current[1]].adjustment.filter;

			me._rotate();
# FIXME SM TODELETE ?
#			forindex (var dof; me.offsets) {
#				me._offsets_raw[dof] += me._v_t[dof] * dt;
#				me.offsets[dof]       = me._lp[dof].filter(me._offsets_raw[dof], filter);

#				if ( (me.offsets[dof] != me._offsets_raw[dof]) or (me._v[dof] != 0) )
#					me._updateF = 1;
#			}

			forindex (var dof; me.offsets) {
				var v = me._lp[dof].filter(me._v_t[dof], filter);
				me.offsets[dof] += v * dt;
# FIXME SM TODELETE ?
#				me.offsets[dof]       = me._lp[dof].filter(me._offsets_raw[dof], filter);

				if ( v != 0 )
					me._updateF = 1;
			}
		}
	},
	_rotate: func {
		var t = subvec(me._v, 0, 3);
		var r = subvec(offsets, 3);

		forindex (var i; var c = rotate3d(t, r)) {
			var _i      = [3, 4, 5][i];
			me._v_t[i]  = c[i];
			me._v_t[_i] = me._v[_i];
		}
	},
};

