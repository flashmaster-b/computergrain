/**
 * Here we create the main GUI for the creation of new layers, recording, etc.
 */
(
w = Window.new("COMPUTERGRAIN MAIN CONTROL", Rect(0,0,760,90));
w.view.decorator = FlowLayout(w.view.bounds);
Button(w, Rect(0,0,80,80))
.states_([
	["New Grain", Color.black, Color.yellow]
])
.mouseDownAction_({
	for(0,~synths.size) {
		arg i;
		if(~synths.includesKey(i)) {} {
			~synths[i] = Synth(\grain, [\vol, 0.0, \channel, i]);
			~createGrainGUI.(~synths[i], i, "Grain");
			b.sendMsg("/channel", i, 1);
		};
	}
});

Button(w, Rect(0,0,80,80))
.states_([
	["New Land", Color.black, Color.yellow]
])
.mouseDownAction_({
	for(0,~synths.size) {
		arg i;
		if(~synths.includesKey(i)) {} {
			~synths[i] = Synth(\land, [\vol, 0.0]);
			~createGrainGUI.(~synths[i], i, "Land");
		};
	}
});

Button(w, Rect(0,0,80,80))
.states_([
	["New FM", Color.black, Color.yellow]
])
.mouseDownAction_({
	for(0,~synths.size) {
		arg i;
		if(~synths.includesKey(i)) {} {
			~synths[i] = Synth(\fm2, [\vol, 0.0]);
			~createFmGUI.(~synths[i], i, "FM");
		};
	}
});

Button(w, Rect(0,0,80,80))
.states_([
	["New LFO", Color.black, Color.green¨]
])
.mouseDownAction_({
	~createLfoGUI.(Synth(\lfo));
});

Button(w, Rect(0,0,80,80))
.states_([
	["All Off", Color.black, Color.magenta]
])
.mouseDownAction_({
	~sliders.do {
		arg s;
		s[\off].valueAction = 0;
	};
});

Button(w, 80@80)
.states_([
	["Load\nsamples", Color.black, Color.cyan]
])
.mouseDownAction = ~openFiles;

Button(w, 80@80)
.states_([
	["Save\nstate", Color.black, Color.cyan]
])
.mouseDownAction = ~saveState;

Button(w, Rect(0,0,80,80))
.states_([
	["Restore\nstate", Color.black, Color.cyan]
])
.mouseDownAction = ~restoreState;

~rec = Button(w, Rect(0,0,80,80))
.states_([
	["Record", Color.black, Color.white],
	["Stop", Color.black, Color.red]
])
.action_({
	arg b;
	if(b.value==1) {
		"Recording...".postln;
		s.record(~root +/+ "Recordings/%.wav".format(Date.getDate.format("%Y-%m-%dT%H%M%S")), 0, 2);

	} {
		"Stopping".postln;
		s.stopRecording;
	}
});

w.onClose = {
	~sliders.do {
		arg s;
		s[\off].valueAction = 0;
	};
	b.sendMsg("/shutdown", 1);
};

w.front;
)
