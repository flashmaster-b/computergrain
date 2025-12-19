/**
 * Here we create the GUI for the individual FM synths
 */
(
~createFmGUI = {
	arg synth, channel, type;

	var carrier, ratio, index, vol, lowpass, tCarrier, tRatio, tIndex, tVol, tLowpass, bOff, bMute;
	var em = 30, width = (em+4)*5+5, height = em*5+60;
	var w = Window("FM synth CH " ++ channel, Rect(width*(channel/3).floor,900-((210+38)*(1+(channel%3)))-31,width,height));
	w.view.decorator = FlowLayout(w.view.bounds);

	carrier = Slider.new(w, em@(em*4))
	.action_({
		arg slider;
		synth.set(\carrier, slider.value);
		tCarrier.string = slider.value.round(0.001);
	})
	.value_(1.0);

	ratio = Slider.new(w, em@(em*4))
	.value_(0.5)
	.action_({
		arg slider;
		synth.set(\ratio, slider.value);
		tRatio.string = slider.value.round(0.001);
	});

	index = Slider.new(w, em@(em*4))
	.value_(0.2)
	.action_({
		arg slider;
		synth.set(\index, slider.value);
		tIndex.string = slider.value.round(0.001);
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

	StaticText.new(w,Rect(0,0,em,20))
		.string_("Carri")
		.font_(Font("Monaco", 11))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Ratio")
		.font_(Font("Monaco", 12))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Index")
		.font_(Font("Monaco", 12))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Vol")
		.font_(Font("Monaco", 12))
		.align_(\center);
	StaticText.new(w,Rect(0,0,em,20))
		.string_("Lowp")
		.font_(Font("Monaco", 12))
		.align_(\center);

	tCarrier = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tRatio = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tIndex = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tVol = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);
	tLowpass = StaticText.new(w,Rect(0,0,em,20))
		.font_(Font("Monaco", 11))
		.align_(\center);

	bOff = Button(w, Rect(0, 0, em, em))
	.states_([["Off"]])
	.action_({
		w.close;
	});

	bMute = Button(w, Rect(0, 0, 2*em, em))
	.states_([
		["Mute"],
		["Unmute", Color.black, Color.red]
	])
	.action_({
		arg button;
		synth.set(\mute, 1-button.value);
	});

	w.onClose = {
		synth.free;
		~synths.removeAt(channel);
		~sliders.removeAt(channel);
		b.sendMsg("/channel", channel, 0);
	};
	w.front;

	~sliders[channel] = (channel: channel, type: type, carrier: carrier, ratio: ratio, index: index, vol: vol, lowpass: lowpass, off: bOff, mute: bMute);
};
)