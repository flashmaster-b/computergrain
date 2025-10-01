/**
 * A multi-channel granulator
 */

(
SynthDef(\land, {
	/**
	 * vol is volume,
	 * select is the selected synth,
	 * sweep is if we loop through the buffer or rest at position
	 *
	 * all parameters are [0..1]
	 */
	arg buf, size=0.5, size_spray=0.2, position=0.5, pos_spray=0.2, density=0.4, pitch=0.5, vol=0.0, sweep=0, pan=1.0, mute=1.0;

	/**
	 * the buffer to read from, we select from pre loaded buffers here
	 */
	var buffer = Select.kr(buf%17, [~b0, ~b1, ~b2, ~b3, ~b4, ~b5, ~b6, ~b7, ~b8, ~b9, ~b10, ~b11, ~b12, ~b13, ~b14, ~b15, ~b16]);

	/**
	 * The minimum and maximum grain size. Grains will be
	 * generated randomly (but slewed) between those limits.
	 * We use very small minimum values here, because even
	 * click sounds can generate nice modulation when
	 * overlayed over each other.
	 */
	var land_size = size.exprange(0.0002, 0.1);

	/**
	 * The jitter for the grain size, in seconds (0.1 ms - 100 ms)
	 * Will be added to grain size.
	 */
	var jitter = size_spray.range(0.0001, 0.1);

	/**
	 * the starting position in the buffer for new grains, or,
	 * if sweep = 1, the speed with which to loop through
	 * the buffer
	 */
	var pos = Select.kr(sweep, [
			position,
			Phasor.ar(0, BufRateScale.kr(buffer)/BufFrames.kr(buffer) * position.exprange(0.1,10), 0, 1)
	]);

	/**
	 * The amount of spray, i.e. the amount that the
	 * starting position is randomly moved forward or backward
	 * for each grain.
	 * It is set as a multiple of the whole duration of the buffer
	 * in each direction, i.e. 0.5 is a completely random
	 * starting position, 0.05 a spray of 10 % of the whole
	 * duration of the buffer.
	 */
	var spray = pos_spray.range(0.001, 0.5);

	/**
	 * the frequency with which to change position and length of grains
	 */
	var freq = density.exprange(0.01,5);

	/**
	 * the speed at which to play the grains
	 */
	var speed = pitch.exprange(0.5, 2);

	var sig;

	sig = GrainBuf.ar(
		1,
		Impulse.ar(ExpRand(50,50.5)!10),
		LFNoise1.ar(freq!10).exprange(land_size,land_size+jitter),
		buffer,
		speed,
		(pos + LFNoise1.kr(freq!10).bipolar(spray)).wrap(0,1)
	);
	sig = Normalizer.ar(sig, vol);
	sig = SplayAz.ar(4, sig, pan, 1, 4);
	Out.ar(0, sig*mute);
}).add;
)