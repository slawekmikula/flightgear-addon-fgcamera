var ht_filter = 0.05;

#==================================================
#	Linuxtrack inputs handler
#==================================================
var LinuxTracker = {
	parents  : [ t_handler.new() ],

	free     : 1,
	_updateF : 1,
	_effect  : 1,
#--------------------------------------------------
	init: func {
		var i = 0;
		foreach (var a; ["x", "y", "z", "h", "p", "r"] ) {
			me._list[i] = "/sim/linuxtrack/data/" ~ a;
			i += 1;
		}
	},
#--------------------------------------------------
	update: func (dt) {
		for (var i = 0; i <= 5; i += 1) {
			me._offsets_raw[i] = getprop(me._list[i]) or 0;
    }

		for (var i = 0; i <= 5; i += 1) {
			me.offsets[i] = me._lp[i].filter(me._offsets_raw[i], ht_filter);
    }
	},

};
