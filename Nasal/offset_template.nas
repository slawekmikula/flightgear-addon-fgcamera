
#==================================================
#	Template for handlers
#==================================================
var t_handler = {
	new: func {
		var m = { parents: [t_handler] };

		m.offsets      = zeros(6);

		m._offsets_raw = zeros(6);
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
			foreach (var l; me._listeners)
				removelistener(l);

			setsize(me._listeners, 0);
		}
	},

};
