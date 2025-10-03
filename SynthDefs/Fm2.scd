/**
 * A simple FM synthesizer
 */
(
SynthDef("fm2", {
	// all input values (0 .. 1)
	// will be converted to ratio = (0 .. 2), index = (0 .. 25), carrier = (30 .. 300)
	arg carrier=1.0, ratio=0.5, index=0.2, vol=0.5, low_pass=1.0, pan = 0.0, mute=1.0;
	var car, mod, cr;

	var lp_freq = (low_pass+0.1).linexp(0.1,1.1,200,20000);

	cr = 3 + carrier*27;

	// Send values to viz
	SendReply.ar(Impulse.ar(cr), "/fm_viz", [cr, ratio*2, index*25]);

	mod = SinOsc.ar(cr * ratio * 2, 0.0, cr * ratio * 2 * index * 25);

	car = SinOsc.ar(cr + mod, 0.0, vol);

	car = LPF.ar(car, lp_freq);

	car = Splay.ar(car, 1, 1, pan);

	Out.ar(0, car*mute);
}).add;
)