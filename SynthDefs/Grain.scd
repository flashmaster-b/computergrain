/**
 * A Grain Synthesizer
 * all input values [0..1]
 *
 * Sends back the actual position of each spawned grain
 * to /posup and the grain values to /grain_viz for visualisation
 */
(
SynthDef.new(\grain, {
	arg buf=0, size=0.3, size_spray=0.0, position=0.0, pb_speed=0.5, pos_spray=0.0, density=0.5, freq_spray=0.0, pitch=0.5, vol=0.0, sweep=1, pan=1.0, low_pass=1, channel=0, mute=1.0;

	/**
	 * variable for holding the output signal
	 */
	var sig;

	/**
	 * the buffer to read from, we select from pre loaded buffers here
	 */
	var buffer = buf;

	/**
	 * The grain size in ms. Will be between 1 - 600 ms
	 */
	var grain_size = size.linlin(0, 1, 0.001, 0.6);

	/**
	 * The jitter for the grain size, in seconds (0.1 ms - 100 ms)
	 * Will be added to grain size.
	 */
	var jitter = size_spray.linlin(0, 1, 0.0, 0.1);

	/**
	 * The amount of spray, i.e. the amount that the
	 * starting position is randomly moved forward or backward
	 * for each grain.
	 * It is set as a multiple of the whole duration of the buffer
	 * in each direction, i.e. 0.5 is a completely random
	 * starting position, 0.05 a spray of 10 % of the whole
	 * duration of the buffer.
	 */
	var spray = pos_spray.linexp(0.0, 1.0, 0.001, 0.501) - 0.001;

	/**
	 * The frequency with which to generate grains
	 * this together with the size of the grain
	 * denominates the density of the sound, i.e.
	 * how many grains are playing at the same time.
	 * Will be between 1 and 300 Hz
	 * We will calculate the frequency on the base of
	 * density and size arguments
	 */
	var freq = 1/grain_size * density.linexp(0,1,0.05,100) + LFNoise0.ar(1/grain_size * density.linexp(0,1,0.05,100), freq_spray);

	/**
	 * the starting position in the buffer for new grains, or,
	 * if sweep = 1, the speed with which to loop through
	 * the buffer
	 */
	var pos = Select.kr(sweep, [
		(position + LFNoise0.ar(freq).bipolar(spray)).wrap(0,1),
		(position + Phasor.ar(sweep, BufRateScale.kr(buffer)/BufFrames.kr(buffer) * pb_speed.linexp(0,1,0.1,10), 0, 1) +
			LFNoise0.ar(freq).bipolar(spray)).wrap(0,1)
	]);

	/**
	 * how much to pitch the sample up or down
	 * we will allow for one octave up and down,
	 * i.e. 15 steps, where 7 is the initial pitch.
	 */
	var speed = pitch.linlin(0,1,-12,12).round(1).midiratio;

	/**
	 * the panning between the four channels
	 */
	var pan_ = pan.linlin(0,1,0,2);

	var trigger = Impulse.ar(freq);

	var actual_size = LFNoise0.ar(freq).range(grain_size, grain_size+jitter);

	var lp_freq = (low_pass+0.1).linexp(0.1,1.1,200,20000);

	SendReply.kr(Impulse.kr(24), "/posup", [channel, pos]); // Send pos value

	SendReply.ar(trigger, "/grain_viz", [actual_size, pos, channel, position]); // Send grain values

	sig = GrainBuf.ar(
		1,
		trigger,
		actual_size,
		buffer,
		speed,
		pos
	);
	sig = Normalizer.ar(sig, vol);
	sig = LPF.ar(sig, lp_freq);
	sig = PanAz.ar(4, sig, pan_, 1.0, 4.0);
	Out.ar(0,sig*mute);
}).add;
)