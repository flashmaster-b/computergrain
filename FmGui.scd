/**
 * Here we create the GUI for the individual FM synths
 */
(
~createFmGUI = {
	arg synth, channel, type;

	var carrier, ratio, index, vol, lowpass, tCarrier, tRatio, tIndex, tVol, tLowpass, bOff, bMute;
	var em = 40, width = (em+4)*5+5, height = em*5+60;
	var w = Window("FM synth CH " ++ channel, Rect(0,0,width,height));
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

	StaticText.new(w,Rect(0,0,em,20)).string = " Carrier";
	StaticText.new(w,Rect(0,0,em,20)).string = " Ratio";
	StaticText.new(w,Rect(0,0,em,20)).string = " Index";
	StaticText.new(w,Rect(0,0,em,20)).string = " Volume";
	StaticText.new(w,Rect(0,0,em,20)).string = " Lowpass";

	tCarrier = StaticText.new(w,Rect(0,0,em,20));
	tRatio = StaticText.new(w,Rect(0,0,em,20));
	tIndex = StaticText.new(w,Rect(0,0,em,20));
	tVol = StaticText.new(w,Rect(0,0,em,20));
	tLowpass = StaticText.new(w,Rect(0,0,em,20));

	bOff = Button(w, Rect(0, 0, em, em))
	.states_([["Off"]])
	.action_({
		synth.free;
		~synths.removeAt(channel);
		~sliders.removeAt(channel);
		b.sendMsg("/channel", channel, 0);
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
	};
	w.front;

	~sliders[channel] = (channel: channel, type: type, carrier: carrier, ratio: ratio, index: index, vol: vol, lowpass: lowpass, off: bOff, mute: bMute);
};
)