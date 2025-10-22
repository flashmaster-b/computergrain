/**
 * MIDI controls are defined here
 * default is one channel per layer
 */
(

// connect all midi clients (you can change this if neccessary)
MIDIClient.init();
MIDIIn.connectAll;

MIDIFunc.cc({
	arg val, ccNum, chan;
    // Map CC messages to synth parameters for the given channel
	// mappings for FM synth are backwards compatible
    var synth = ~synths[chan];
	var sliders = ~sliders[chan];
	var v = val/127;
    if (synth.notNil) {
        switch(ccNum,
            30, {
				if (sliders[\type].asString == "FM") {
					synth.set(\ratio, v);
					Routine {
						sliders[\ratio].valueAction_(v);
					}.play(AppClock);
				} {
					synth.set(\size, v);
					Routine {
						sliders[\size].valueAction_(v);
					}.play(AppClock);
				};
			},
            31, {
				Routine {
					sliders[\size_spray].valueAction_(v);
				}.play(AppClock);
				synth.set(\size_spray, v);
			},
            32, {
				if (sliders[\type].asString == "FM") {
					synth.set(\index, v);
					Routine {
						sliders[\index].valueAction_(v);
					}.play(AppClock);
				} {
					Routine {
						sliders[\position].valueAction_(v);
					}.play(AppClock);
					synth.set(\position, v);
				};
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
				if (sliders[\type].asString == "FM") {
					synth.set(\carrier, v);
					Routine {
						sliders[\carrier].valueAction_(v);
					}.play(AppClock);
				} {
					Routine {
						sliders[\pitch].valueAction_(v);
					}.play(AppClock);
					synth.set(\pitch, v);
				};
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
)