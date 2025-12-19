/**
 * Loading buffers happenes here. All files from the directory "Samples" in
 * the working directory will be loaded. They have to be wav-files and mono!
 *
 */
(
var myPath;

~samples = Dictionary.new;

myPath = PathName.new(~root +/+ "Samples/");
myPath.files.do {
	arg f;
	var buf;
	buf = Buffer.read(s, f.fullPath, 0, -1, {
		arg b;
			if(b.numChannels == 1) {
				~samples.put(b.path.split($/).last.split($.)[0], b);
			} {
				("Sample is no wav file or does contain more than one channel: "+b.path).postln;
		}
	});
};

~openFiles = {
	Dialog.openPanel({
		arg paths;
		var sample;
		var i=0;
		paths.do {
			arg filename;
			filename.basename.postln;
			sample = Buffer.read(s, filename,0,-1, {
				arg b;
				if(b.numChannels == 1) {
					~samples.put(b.path.split($/).last.split($.)[0], b);
				} {
					("Sample is no wav file or does contain more than one channel: "+b.path).postln;
				}
			});
		};
	},nil,true,~root);
};

~showSamples = {
	var num = ~samples.size;
	var width = 300;
	var em = 30;
	var w = Window("Samples", Rect(100,200,width,num*(em+10)));
	w.view.decorator = FlowLayout(w.view.bounds);

	~samples.keysDo {
		arg k;
		var p;
		Button(w,Rect(0,0,width-5,30))
		.states_([
			[k],
			[k, Color.red]
		])
		.action_({
			arg button;
			if(button.value == 1) {
				p = ~samples[button.string].play;
			} {
				p.free;
			}
		});
	};

	w.front;
};

)