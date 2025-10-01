/**
 * A simple FM synthesizer
 */
(
SynthDef("fm2", {
	// all input values (0 .. 1)
	// will be converted to ratio = (0 .. 2), index = (0 .. 25)
	// it is easier for now to name the controls like the other synth, therefore
	// size = ratio, position = index, pitch = carrier
	arg pitch=1.0, size=0.5, position=0.2, vol=0.5, pan = 0.0, mute=1.0;
	var car, mod, ratio, index, carrier;
	carrier = pitch * 300;
	ratio = size;
	index = position;

	// Send values to viz
	SendReply.ar(Impulse.ar(carrier), "/fm_viz", [carrier, ratio*2, index*25]);

	mod = SinOsc.ar(carrier * ratio * 2, 0.0, carrier * ratio * 2 * index * 25);

	car = SinOsc.ar(carrier + mod, 0.0, vol);

	car = Splay.ar(car, 1, 1, pan);

	Out.ar(0, car*mute);
}).add;
)
