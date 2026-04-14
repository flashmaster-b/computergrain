/**
 * Here we create the GUI for the individual synths i.e. layers
 */
(
~createGrainGUI = {
	arg synth, channel, type;

	var size, size_spray, pos, speed, pos_spray, density, freq_spray, pitch, pan, vol, lowpass, wet, room, tSize, tSize_spray, tPos, tSpeed, tPos_spray, tDensity, tFreq_spray, tPitch, tPan, tVol, tLowpass, tWet, tRoom, tPosition, bBuffer, bSweep, bOff, bMute, bLowHigh, position, buttonStates;
	var em = 30, width = (em+4)*10+5, height = em*7+10;
	var w = Window(type ++ " synth CH " ++ channel, Rect(width*(channel/3).floor,900-((210+38)*(1+(channel%3)))-31,width,height));
	w.view.decorator = FlowLayout(w.view.bounds);

	// first row: knobs
	size_spray = Knob.new(w, em@em)
	.value_(0.0)
	.action_({
		arg knob;
		synth.set(\size_spray, knob.value);
		tSize_spray.string = knob.value.round(0.001);
	});
	pos_spray = Knob.new(w, em@em)
	.value_(0.0)
	.action_({
		arg knob;
		synth.set(\pos_spray, knob.value);
		tPos_spray.string = knob.value.round(0.001);
	});
	bSweep = Button(w,Rect(0,0,em,em))
	.states_([
		[""],
		[""]
	])
	.action_({
		arg button;
		synth.set(\sweep, button.value);
		if(button.value == 0) { pos.valueAction_(position.value) };
	})
	.value_(1);
	freq_spray = Knob.new(w, em@em)
	.value_(0.0)
	.action_({
		arg knob;
		synth.set(\freq_spray, knob.value);
		tFreq_spray.string = knob.value.round(0.001);
	});

	w.view.decorator.left = w.view.decorator.left + em + em + 8;

	bMute = Button(w, Rect(0, 0, em, em))
	.states_([
		[""],
		[""]
	])
	.action_({
		arg button;
		synth.set(\mute, 1-button.value);
	});
	bLowHigh = Button(w, Rect(0, 0, em, em))
	.states_([
		["Lo"],
		["Hi"]
	])
	.action_({
		arg button;
		synth.set(\pass, button.value);
	});
	wet = Knob.new(w, em@em)
	.value_(0)
	.action_({
		arg knob;
		synth.set(\wet, knob.value);
		tWet.string = knob.value.round(0.001);
	});


	w.view.decorator.nextLine;

	size = Slider.new(w, em@(em*4))
	.action_({
		arg slider;
		synth.set(\size, slider.value);
		tSize.string = slider.value.round(0.001);
	})
	.value_(0.3);

	pos = Slider.new(w, em@(em*4))
	.value_(0.0)
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
	density = Slider.new(w, em@(em*4))
	.value_(0.5)
	.action_({
		arg slider;
		synth.set(\density, slider.value);
		tDensity.string = slider.value.round(0.001);
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
	.value_(0.0)
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
	room = Slider.new(w, em@(em*4))
	.value_(1)
	.action_({
		arg slider;
		synth.set(\room, slider.value);
		tRoom.string = slider.value.round(0.001);
	});
	position = Slider.new(w, em@(em*4));

	StaticText.new(w,Rect(0,0,em,20))
		.string_("Size")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Pos'n")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Speed")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Densi")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Pitch")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Pan")
		.font_(Font("Monaco", 11))
	.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Vol")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Lowp")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Rev")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Pos")
		.font_(Font("Monaco", 11))
		.align_(\center);

	buttonStates = [];

	~samples.keysValuesDo {
		arg k, v;
		buttonStates = buttonStates.add([k, Color.black, Color.green]);
	};

	bBuffer = Button(w,Rect(0,0,7*em,em))
	.states_(buttonStates)
	.action_({
		arg button;
		synth.set(\buf, ~samples[button.string]);
	})
	.valueAction_(0);

	// to set the buffer by name
	bBuffer.addUniqueMethod(\valueActionLabel, {
		arg view, label;
		var index = view.states.detectIndex { arg s; s[0] == label; };
		if (index.notNil) {
			view.valueAction_(index);
		} {
			("No state with label '%' found.".format(label)).warn;
		};
	});

	bOff = Button(w, Rect(0, 0, em, em))
	.states_([["Off"]])
	.action_({
		w.close;
	});

		tSize = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tPos = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tSpeed = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tDensity = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tPitch = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tPan = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tVol = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tLowpass = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tRoom = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tPosition = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tSize_spray = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tPos_spray = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tFreq_spray = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tWet = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);


	w.onClose = {
		synth.free;
		~synths.removeAt(channel);
		~sliders.removeAt(channel);
		b.sendMsg("/channel", channel, 0);
	};
	w.front;

	~sliders[channel] = (channel: channel, type: type, buf: bBuffer, size: size, size_spray: size_spray, position: pos, speed: speed, pos_spray: pos_spray, density: density, freq_spray: freq_spray, pitch: pitch, pan: pan, vol: vol, lowpass: lowpass, off: bOff, mute: bMute, sweep: bSweep, pos: position);
};
)