(
~saveState = {
	Dialog.savePanel({
		arg path;
		var f = File(path, "w");
		~sliders.do {
			arg s;
			f.write("%, '%', %, %, %, %, %, %, %, %, %, %, %, %\n".format(s.[\channel], s[\type], s[\buf].value, s[\size].value, s[\size_spray].value, s[\position].value, s[\speed].value, s[\pos_spray].value, s[\density].value, s[\freq_spray].value, s[\pitch].value, s[\pan].value, s[\vol].value, s[\sweep].value));
		};
		f.close;
	},{},~root);
};

~restoreState = {
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
			~createGrainGUI.(~synths[item[0]], item[0], item[1]);
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
	},{},false,~root);
};
)