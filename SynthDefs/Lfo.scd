/**
 * This is the synth for LFO controls
 */
(
SynthDef("lfo", {
	arg freq=0.1, lo=0, hi=1, channel=0, control=0, on=0;
	var sig;
	sig = SinOsc.kr(freq).linlin(-1, 1, lo, hi);
	SendReply.kr(Impulse.kr(freq*100)*on, "/lfo", [channel, control, sig]); // Send value to slider
}).add;
)