/**
 * COMPUTERGRAIN
 *
 * A grain synthesizer with two modes and multiple layers. Can be controlled via MIDI or GUI.
 * One mode overlays multiple channels with slightly different generation rates,
 * that creates modulations between layers for interesting soundscapes, and one mode
 * that is a classic grain synthesizer.
 *
 * Multiple buffers can be chosen, that all have to be loaded on startup
 *
 * @author		Jürgen Buchinger <studio@differentspace.com>
 * @version 	4.3
 * @date		23 Jul 2025
 *
 *
 * To run the program you have to
 * 1) put the paths to your sound samples in the code (just below)
 * 2) evaluate the first code block to boot the server (adust to your setup first)
 * 3) Evaluate the second code block for everything else
 *
 * To evaluate a code block, simply move the cursor inside the block and press [CTRL] + [Enter]
 *
 * MIDI MAPPINGS
 * Midi CC messages control the layer of the channel on which they are sent, so a message on ch0 controls
 * the synth on ch0
 * cc num		30		31			32			33			34		35		36		37		38		39
 * control		size	size_spray	position	pos_spray	density	vol		pan		buffer	vol		freq_spray
 */


/**
 * Boot server first. Individual layers can pan around 4 channels. Adjust your setup here. =================================================
 */
(
o = Server.default.options;
o.numOutputBusChannels = 2;
o.maxLogins = 2;
s = Server.default;
s.boot;
b = NetAddr.new("127.0.0.1", 12345);
)

/**
 * Load sound files, connect MIDI devices, setup MIDI controls and OSC controls, start synthesizers and GUI ================================
 */
(

/**
 * Loading buffers happenes here, adjust your filenames accodingly (use the whole path)!
 * You can load 16 Buffers. More if you adjust the code down the line.
 */
~b0 = Buffer.read(s, "/home/juergen/Fieldrecordings/walking-in-light-snow.wav");
~b1 = Buffer.read(s, "");
~b2 = Buffer.read(s, "");
~b3 = Buffer.read(s, "");
~b4 = Buffer.read(s, "");
~b5 = Buffer.read(s, "");
~b6 = Buffer.read(s, "");
~b7 = Buffer.read(s, "");
~b8 = Buffer.read(s, "");
~b9 = Buffer.read(s, "");
~b10 = Buffer.read(s, "");
~b11 = Buffer.read(s, "");
~b12 = Buffer.read(s, "");
~b13 = Buffer.read(s, "");
~b14 = Buffer.read(s, "");
~b15 = Buffer.read(s, "");
~b16 = Buffer.read(s, "");


MIDIClient.init();
MIDIIn.connectAll;

/**
 * We are updating the actual position slider via OSC messages
 */
OSCdef(\positionUpdate, { |msg|
	{ ~sliders[msg[3]][\pos].value = msg[4]; }.defer; // Update UI safely
}, '/posup');

/**
 * We are sending grain values as OSC messages for visualization
 * pos, actual_size, channel, position
 */
OSCdef(\grain_visualization, { |msg|
	b.sendMsg("/grain", msg[4], msg[3], msg[5], msg[6]);
}, '/grain_viz');

OSCdef(\fm_visualization, { |msg|
	b.sendMsg("/fm", msg[3], msg[4], msg[5]);
}, '/fm_viz');


/**
 * MIDI controls are defined here
 * default is one channel per layer
 */

MIDIFunc.cc({
	arg val, ccNum, chan;
    // Map CC messages to synth parameters for the given channel
    var synth = ~synths[chan];
	var sliders = ~sliders[chan];
	var v = val/127;
    if (synth.notNil) {
        switch(ccNum,
            30, {
				synth.set(\size, v);
				Routine {
					sliders[\size].valueAction_(v);
				}.play(AppClock);
			},
            31, {
				Routine {
					sliders[\size_spray].valueAction_(v);
				}.play(AppClock);
				synth.set(\size_spray, v);
			},
            32, {
				Routine {
					sliders[\position].valueAction_(v);
				}.play(AppClock);
				synth.set(\position, v);
			},
            33, {
				Routine {
					sliders[\pos_spray].valueAction_(v);
				}.play(AppClock);
				synth.set(\pos_spray, v);
			},
            34, {
				Routine {
					sliders[\density].valueAction_(v);
				}.play(AppClock);
				synth.set(\density, v);
			},
            35, {
				Routine {
					sliders[\pitch].valueAction_(v);
				}.play(AppClock);
				synth.set(\pitch, v);
			},
            38, {
				Routine {
					sliders[\pan].valueAction_(v);
				}.play(AppClock);
				synth.set(\pan, v);
			},
            37, {
				Routine {
					sliders[\buf].valueAction = (val % 17);
				}.play(AppClock);
				synth.set(\buf, val);
			},
			36, {
				Routine {
					sliders[\vol].valueAction_(v);
				}.play(AppClock);
				synth.set(\vol, v);
			},
			39, {
				Routine {
					sliders[\freq_spray].valueAction(v);
				}.play(AppClock);
				synth.set(\freq_spray, v);
			}
        );
    };
}); // Listen to all devices, on all channels

/**
 * This is for playing the pitch with notes
 * deactivated now, because it interferes with the recording thing

MIDIFunc.noteOn({
	arg vel, note, chan;
    var synth = ~synths[chan];
	var slider = ~sliders[chan][\pitch];
	var v = note.linlin(55,79,0,1);
	"vel: %, note: %, chan: %".format(v,note,chan).postln;
	Routine {
		slider.valueAction = v;
	}.play(AppClock);
	synth.set(\pitch, v);
});

*/

/**
 * Start recording with MIDI control.
 * Used to start recording synced from python's data_control_v2
 */

MIDIFunc.noteOn({
	arg vel;
	Routine {
		~rec.valueAction = 1;
	}.play(AppClock);
}, 55, 0); // note 55 on ch 0

MIDIFunc.noteOff({
	arg vel;
	Routine {
		~rec.valueAction = 0;
	}.play(AppClock);
}, 55, 0); // note 55 on ch 0


// turn on and off sweep
MIDIFunc.noteOn({
	arg vel, num, chan;
    var synth = ~synths[chan];
	var sliders = ~sliders[chan];
	if(synth.notNil) {
		Routine {
			sliders[\sweep].valueAction = 1;
		}.play(AppClock);
	};
}, 0); // note 0

MIDIFunc.noteOff({
	arg vel, num, chan;
    var synth = ~synths[chan];
	var sliders = ~sliders[chan];
	if(synth.notNil) {
		Routine {
			sliders[\sweep].valueAction = 0;
		}.play(AppClock);
	}
}, 0); // note 0


/** to test the speaker configuration */
SynthDef.new(\spt, {
	arg ch=0, vol=0.5;
	var sig;
	sig = BrownNoise.ar(vol);
	Out.ar(ch, sig);
}).add;

SynthDef.new(\rot, {
	arg f = 0.25;
	var p = Phasor.ar(0, f, 0, 1);
	SendReply.kr(Impulse.kr(30), "\pan", [0, p]);
}).add;


/**
 * The Grain Synthesizer
 * all input values [0..1]
 */

SynthDef.new(\grain, {
	arg buf=0, size=0.2, size_spray=0.1, position=0.5, pb_speed=0.5, pos_spray=0.01, density=0.7, freq_spray=0.1, pitch=0.5, vol=0.0, sweep=0, pan=1.0, low_pass=1, channel=0, mute=1.0;

	/**
	 * variable for holding the output signal
	 */
	var sig;

	/**
	 * the buffer to read from, we select from pre loaded buffers here
	 */
	var buffer = Select.kr(buf%17, [~b0, ~b1, ~b2, ~b3, ~b4, ~b5, ~b6, ~b7, ~b8, ~b9, ~b10, ~b11, ~b12, ~b13, ~b14, ~b15, ~b16]);

	/**
	 * The grain size in ms. Will be between 1 - 600 ms
	 */
	var grain_size = size.linlin(0, 1, 0.001, 0.6);

	/**
	 * The jitter for the grain size, in seconds (0.1 ms - 100 ms)
	 * Will be added to grain size.
	 */
	var jitter = size_spray.linlin(0,1,0.0, 0.1);

	/**
	 * The amount of spray, i.e. the amount that the
	 * starting position is randomly moved forward or backward
	 * for each grain.
	 * It is set as a multiple of the whole duration of the buffer
	 * in each direction, i.e. 0.5 is a completely random
	 * starting position, 0.05 a spray of 10 % of the whole
	 * duration of the buffer.
	 */
	var spray = pos_spray.linlin(0,1,0.0, 0.5);


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



/**
 * The multi-channel granulator
 */

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

/**
 * A simple FM synthesizer
 */
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

/**
 * Here we create the GUI for the individual layers
 */

~createSynthGUI = {
	arg synth, channel, type;

	var size, size_spray, pos, speed, pos_spray, density, freq_spray, pitch, pan, vol, lowpass, tSize, tSize_spray, tPos, tSpeed, tPos_spray, tDensity, tFreq_spray, tPitch, tPan, tVol, tLowpass, tPosition, bBuffer, bSweep, bOff, bMute, position;
	var em = 40, width = (em+4)*12+5, height = em*5+60;
	var w = Window(type ++ " synth CH " ++ channel, Rect(1920-(width*((channel/4).floor+1)),(40+((height+30)*(channel%4))),width,height));
	w.view.decorator = FlowLayout(w.view.bounds);

	size = Slider.new(w, em@(em*4))
	.action_({
		arg slider;
		synth.set(\size, slider.value);
		tSize.string = slider.value.round(0.001);
	})
	.value_(0.35);

	size_spray = Slider.new(w, em@(em*4))
	.value_(0.1)
	.action_({
		arg slider;
		synth.set(\size_spray, slider.value);
		tSize_spray.string = slider.value.round(0.001);
	});
	pos = Slider.new(w, em@(em*4))
	.value_(0.5)
	.action_({
		arg slider;
		synth.set(\position, slider.value);
		tPos.string = slider.value.round(0.001);
	});
	speed = Slider.new(w, em@(em*4))
	.value_(0.5)
	.action_({
		arg slider;
		synth.set(\pb_speed, slider.value);
		tSpeed.string = slider.value.round(0.001);
	});
	pos_spray = Slider.new(w, em@(em*4))
	.value_(0.1)
	.action_({
		arg slider;
		synth.set(\pos_spray, slider.value);
		tPos_spray.string = slider.value.round(0.001);
	});
	density = Slider.new(w, em@(em*4))
	.value_(0.8)
	.action_({
		arg slider;
		synth.set(\density, slider.value);
		tDensity.string = slider.value.round(0.001);
	});
	freq_spray = Slider.new(w, em@(em*4))
	.value_(0.1)
	.action_({
		arg slider;
		synth.set(\freq_spray, slider.value);
		tFreq_spray.string = slider.value.round(0.001);
	});
	pitch = Slider.new(w, em@(em*4))
	.value_(0.5)
	.action_({
		arg slider;
		synth.set(\pitch, slider.value);
		tPitch.string = slider.value.round(0.001);
	});
	pan = Slider.new(w, em@(em*4))
	.value_(0.5)
	.action_({
		arg slider;
		synth.set(\pan, slider.value);
		tPan.string = slider.value.round(0.001);
	});
	vol = Slider.new(w, em@(em*4))
	.value_(0.02)
	.action_({
		arg slider;
		synth.set(\vol, slider.value);
		tVol.string = slider.value.round(0.001);
	});
	lowpass = Slider.new(w, em@(em*4))
	.value_(1)
	.action_({
		arg slider;
		synth.set(\low_pass, slider.value);
		tLowpass.string = slider.value.round(0.001);
	});
	position = Slider.new(w, em@(em*4));

	StaticText.new(w,Rect(0,0,em,20)).string = " Size";
	StaticText.new(w,Rect(0,0,em,20)).string = " Jitter";
	StaticText.new(w,Rect(0,0,em,20)).string = " Position";
	StaticText.new(w,Rect(0,0,em,20)).string = " Speed";
	StaticText.new(w,Rect(0,0,em,20)).string = " Spray";
	StaticText.new(w,Rect(0,0,em,20)).string = " Density";
	StaticText.new(w,Rect(0,0,em,20)).string = " Spray";
	StaticText.new(w,Rect(0,0,em,20)).string = " Pitch";
	StaticText.new(w,Rect(0,0,em,20)).string = " Pan";
	StaticText.new(w,Rect(0,0,em,20)).string = " Volume";
	StaticText.new(w,Rect(0,0,em,20)).string = " Lowpass";
	StaticText.new(w,Rect(0,0,em,20)).string = " Pos";

	tSize = StaticText.new(w,Rect(0,0,em,20));
	tSize_spray = StaticText.new(w,Rect(0,0,em,20));
	tPos = StaticText.new(w,Rect(0,0,em,20));
	tSpeed = StaticText.new(w,Rect(0,0,em,20));
	tPos_spray = StaticText.new(w,Rect(0,0,em,20));
	tDensity = StaticText.new(w,Rect(0,0,em,20));
	tFreq_spray = StaticText.new(w,Rect(0,0,em,20));
	tPitch = StaticText.new(w,Rect(0,0,em,20));
	tPan = StaticText.new(w,Rect(0,0,em,20));
	tVol = StaticText.new(w,Rect(0,0,em,20));
	tLowpass = StaticText.new(w,Rect(0,0,em,20));
	tPosition = StaticText.new(w,Rect(0,0,em,20));

	bSweep = Button(w,Rect(0,0,2*em,em))
	.states_([
		["Position", Color.black, Color.grey],
		["Sweep", Color.black, Color.red]
	])
	.action_({
		arg button;
		synth.set(\sweep, button.value);
		if(button.value == 0) { pos.valueAction_(position.value) };
	});

	bBuffer = Button(w,Rect(0,0,7*em,em))
	.states_([
		[~b0.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b1.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b2.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b3.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b4.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b5.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b6.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b7.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b8.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b9.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b10.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b11.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b12.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b13.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b14.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b15.path.split($/).last.split($.)[0], Color.black, Color.green],
		[~b16.path.split($/).last.split($.)[0], Color.black, Color.green]
	])
	.action_({
		arg button;
		synth.set(\buf, button.value);
	});

	bOff = Button(w, Rect(0, 0, em, em))
	.states_([["Off"]])
	.action_({
		synth.free;
		~synths.removeAt(channel);
		~sliders.removeAt(channel);
		w.close;
	});

	bMute = Button(w, Rect(0, 0, 2*em, em))
	.states_([
		["Mute", Color.black, Color.clear],
		["Unmute", Color.black, Color.red]
	])
	.action_({
		arg button;
		synth.set(\mute, 1-button.value);
	});

	w.front;

	~sliders[channel] = (channel: channel, type: type, buf: bBuffer, size: size, size_spray: size_spray, position: pos, speed: speed, pos_spray: pos_spray, density: density, freq_spray: freq_spray, pitch: pitch, pan: pan, vol: vol, lowpass: lowpass, off: bOff, mute: bMute, sweep: bSweep, pos: position);
};


/**
 * Here we create the GUI for the creation of new layers, recording, etc.
 */

w = Window.new("COMPUTER GRAIN CTRL WINDOW", Rect(0,0,700,100));
w.view.decorator = FlowLayout(w.view.bounds);
Button(w, Rect(0,0,80,80))
.states_([
	["New Grain"]
])
.mouseDownAction_({
	for(0,~synths.size) {
		arg i;
		if(~synths.includesKey(i)) {} {
			~synths[i] = Synth(\grain, [\vol, 0.0, \channel, i]);
			~createSynthGUI.(~synths[i], i, "Grain");
		};
	}
});

Button(w, Rect(0,0,80,80))
.states_([
	["New Land"]
])
.mouseDownAction_({
	for(0,~synths.size) {
		arg i;
		if(~synths.includesKey(i)) {} {
			~synths[i] = Synth(\land, [\vol, 0.0]);
			~createSynthGUI.(~synths[i], i, "Land");
		};
	}
});

Button(w, Rect(0,0,80,80))
.states_([
	["New FM"]
])
.mouseDownAction_({
	for(0,~synths.size) {
		arg i;
		if(~synths.includesKey(i)) {} {
			~synths[i] = Synth(\fm2, [\vol, 0.0]);
			~createSynthGUI.(~synths[i], i, "FM");
		};
	}
});

Button(w, Rect(0,0,80,80))
.states_([
	["All Off"]
])
.mouseDownAction_({
	~sliders.do {
		arg s;
		s[\off].valueAction = 0;
	};
});

Button(w, Rect(0,0,80,80))
.states_([
	["Save"]
])
.mouseDownAction_({
	var f = File("/%-cg-state.csv".format(Date.getDate.format("%Y-%m-%dT%H%M%S")), "w");
	~sliders.do {
		arg s;
		f.write("%, '%', %, %, %, %, %, %, %, %, %, %, %, %\n".format(s.[\channel], s[\type], s[\buf].value, s[\size].value, s[\size_spray].value, s[\position].value, s[\speed].value, s[\pos_spray].value, s[\density].value, s[\freq_spray].value, s[\pitch].value, s[\pan].value, s[\vol].value, s[\sweep].value));
	};
	f.close;
});



Button(w, Rect(0,0,80,80))
.states_([
	["Load"]
])
.mouseDownAction_({
	var f;
	Dialog.openPanel({
		arg path;
		f = CSVFileReader.readInterpret(path);
		f.postln;
		f.do {
			arg item;
			item[1].postln;
			if(item[1] == \Land) {
				~synths[item[0]] = Synth(\land, [\channel, item[0]]);
			} {
				if(item[1] == \Grain) {
					~synths[item[0]] = Synth(\grain, [\channel, item[0]]);
				} {
					~synths[item[0]] = Synth(\fm2, [\channel, item[0]]);
				};
			};
			~createSynthGUI.(~synths[item[0]], item[0], item[1]);
			~sliders[item[0]][\buf].valueAction = item[2];
			~sliders[item[0]][\size].valueAction_(item[3]);
			~sliders[item[0]][\size_spray].valueAction_(item[4]);
			~sliders[item[0]][\speed].valueAction_(item[6]);
			~sliders[item[0]][\pos_spray].valueAction_(item[7]);
			~sliders[item[0]][\density].valueAction_(item[8]);
			~sliders[item[0]][\freq_spray].valueAction_(item[9]);
			~sliders[item[0]][\pitch].valueAction_(item[10]);
			~sliders[item[0]][\pan].valueAction_(item[11]);
			~sliders[item[0]][\vol].valueAction_(item[12]);
			~sliders[item[0]][\sweep].valueAction = item[13];
			~sliders[item[0]][\position].valueAction_(item[5]);
		};
	});
});

Button(w, Rect(0,0,80,80))
.states_([
	["Close"]
])
.mouseDownAction_({
	~sliders.do {
		arg s;
		s[\off].valueAction = 0;
	};
	w.close;
	b.sendMsg("/shutdown", 1);
});

~rec = Button(w, Rect(0,0,80,80))
.states_([
	["Record", Color.black, Color.clear],
	["Stop", Color.black, Color.red]
])
.action_({
	arg b;
	if(b.value==1) {
		"Recording...".postln;
		s.record("/%-cg-audio.wav".format(Date.getDate.format("%Y-%m-%dT%H%M%S")), 0, 2);

	} {
		"Stopping".postln;
		s.stopRecording;
	}
});

w.front;

~synths = Dictionary.new;
~sliders = Dictionary.new;
)
