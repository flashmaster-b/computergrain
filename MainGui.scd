/**
 * Here we create the main GUI for the creation of new layers, recording, etc.
 */
(
w = Window.new("COMPUTERGRAIN CTRL WINDOW", Rect(0,0,780,100));
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
			~createGrainGUI.(~synths[i], i, "Grain");
			b.sendMsg("/channel", i, 1);
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
			~createGrainGUI.(~synths[i], i, "Land");
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
			~createGrainGUI.(~synths[i], i, "FM");
		};
	}
});

Button(w, Rect(0,0,80,80))
.states_([
	["New LFO"]
])
.mouseDownAction_({
	~createLfoGUI.(Synth(\lfo));
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
	var f = File("/home/juergen/%-cg-state.csv".format(Date.getDate.format("%Y-%m-%dT%H%M%S")), "w");
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
		s.record("/home/juergen/%-cg-audio.wav".format(Date.getDate.format("%Y-%m-%dT%H%M%S")), 0, 2);

	} {
		"Stopping".postln;
		s.stopRecording;
	}
});

w.front;
)
