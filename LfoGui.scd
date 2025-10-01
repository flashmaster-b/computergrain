/**
 * Here we create the GUI for LFOs
 */
(
~createLfoGUI = {
	arg synth;
	var tFreq, tLo, tHi;

	var l = Window.new("LFO Control", Rect(0,0,260,200));
	l.view.decorator = FlowLayout(l.view.bounds);

	Knob(l, 80@80)
	.action_({
		arg k;
		synth.set(\freq, k.value*5);
		tFreq.string = (k.value*5).round(0.01);
	});
	Knob(l, 80@80)
	.action_({
		arg k;
		synth.set(\lo, k.value);
		tLo.string = k.value.round(0.01);
	});
	Knob(l, 80@80)
	.action_({
		arg k;
		synth.set(\hi, k.value);
		tHi.string = k.value.round(0.01);
	});

	tFreq = StaticText.new(l, 80@20).align_(\center);
	tLo = StaticText.new(l, 80@20).align_(\center);
	tHi = StaticText.new(l, 80@20).align_(\center);

	Button(l, 123@40)
	.states_([
		["Channel 0"],
		["Channel 1"],
		["Channel 2"],
		["Channel 3"],
		["Channel 4"]
	])
	.action_({
		arg b;
		synth.set(\channel, b.value);
	});

	Button(l, 123@40)
	.states_([
		["Size"],
		["Position"],
		["Speed"],
		["Density"],
		["Pan"]
	])
	.action_({
		arg b;
		synth.set(\control, b.value);
	});

	Button(l, 250@40)
	.states_([
		["Off"],
		["On", Color.black, Color.green]
	])
	.action_({
		arg b;
		synth.set(\on, b.value);
	});

	l.onClose = { synth.free; };

	l.front;

}

)

~createLfoGUI.(Synth(\lfo))