#==================================================
#	"Shortcuts"
#==================================================
var sin       = math.sin;
var cos       = math.cos;
var hasmember = view.hasmember;

#==================================================
#	Generic functions:
#
#		lowpass()              -
#		zeros(n)               -
#		Bezier2(p1, x)         -
#		rotate3d(coord, angle) -
#==================================================
var lowpass = {
	new: func(coeff = 0) {
		var m = { parents: [lowpass] };

		m.coeff     = coeff >= 0 ? coeff : 0;
		m.tolerance = 0.0001;
		m.value     = nil;

		return m;
	},
#--------------------------------------------------
	filter: func(v, coeff = 0) {
		me.filter = me._filter_;
		me.value  = v;
	},
#--------------------------------------------------
	get: func {
		me.value;
	},
#--------------------------------------------------
	set: func(v) {
		me.value = v;
	},
#--------------------------------------------------
	_filter_: func(v, coeff = 0) {
		me.coeff = coeff;
		var dt   = getprop("/sim/time/delta-realtime-sec") * getprop("/sim/speed-up");
		var c    = dt / (me.coeff + dt);
		me.value = v * c + me.value * (1 - c);

		if (math.abs(me.value - v) <= me.tolerance)
			me.value = v;

		return me.value;
	},
};

var hi_pass = {
#--------------------------------------------------
	new: func(coeff = 0) {
		var m = { parents: [hi_pass] };
		m.coeff = coeff >= 0 ? coeff : die("lowpass(): coefficient must be >= 0");
		m.value = 0;
		m.v1 = 0;
		return m;
	},
#--------------------------------------------------
	filter: func(v, coeff = 0) {
		me.coeff = coeff;
		var dt = getprop("/sim/time/delta-sec") * getprop("/sim/speed-up");
		var c = me.coeff / (me.coeff + dt);
		me.value = me.value * c + (v - me.v1) * c;
		me.v1 = v;
		return me.value;
	},
#--------------------------------------------------
	get: func {
		me.value;
	},
#--------------------------------------------------
	set: func(v) {
		me.value = v;
	},
};

#--------------------------------------------------
var zeros = func (n) {
	forindex (var i; setsize (var v = [], n))
		v[i] = 0;

	return v;
}
#--------------------------------------------------
var linterp = func (x0, y0, x1, y1, x) {
	return y0 + (y1 - y0) * (x - x0) / (x1 - x0); #linear interpolation
}
#--------------------------------------------------
var Bezier2 = func (p1, x) {
	var p0 = [0.0, 0.0];
	var p2 = [1.0, 1.0];

	var t = (-p1[0] + math.sqrt(p1[0] * p1[0] + (1 - 2 * p1[0]) * x)) / (1 - 2 * p1[0]);
    # FIXME SM TODELETE ?
	#var y = (1 - t) * (1 - t) * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1];
	var y = 2 * (1 - t) * t * p1[1] + t * t;

	return y;
}
#--------------------------------------------------
var Bezier3 = {
	_x  : zeros(31),
	_y  : zeros(31),
	_p0 : [0, 0],
	_p3 : [1, 1],

	generate: func (p1, p2) {
		var t = 0;
		for (var i = 0; i <= 30; i += 1) {
			t = i / 20;

			me._x[i] = math.pow( (1 - t), 3) * me._p0[0] + 3 * math.pow( (1 - t), 2) * t * p1[0] + 3 * (1 - t) * t * t * p2[0] + t * t * t * me._p3[0];
			me._y[i] = math.pow( (1 - t), 3) * me._p0[1] + 3 * math.pow( (1 - t), 2) * t * p1[1] + 3 * (1 - t) * t * t * p2[1] + t * t * t * me._p3[1];
		}
	},

	blend: func (x) {
		me._find_y(x);
	},

	_find_y: func (x) {
		if ( x < 0 ) return 0;
		if ( x > 1 ) return 1;

		for (var i = 0; i <= 30; i += 1)
			if ( x <= me._x[i] ) break;

		linterp(me._x[i-1], me._y[i-1], me._x[i], me._y[i], x);
	},
};
Bezier3.generate( [0.47, 0.01], [0.39, 0.98] ); #[0.52, 0.05], [0.27, 0.97]

#--------------------------------------------------
var sin_blend = func (x) {
	return 0.5 * (sin((x - 0.5) * math.pi) + 1);
}
#--------------------------------------------------
var s_blend = func (x) {
	x = 1 - x;
	return 1 + 2 * x * x * x - 3 * x * x;
}
#--------------------------------------------------
var rotate3d = func (coord, angle) {
	var s = [,,,];
	var c = [,,,];

	forindex (var i; angle) {
		var a = angle[i] * math.pi / 180;
		s[i]  = sin(a);
		c[i]  = cos(a);
	}

	var x =  coord[0] * c[0] + coord[2] * s[0];
	var y =  coord[1] * c[1] - coord[2] * s[1];
	var z = -coord[0] * s[0] + coord[2] * c[0];

	return coord = [x, y, z];
}

