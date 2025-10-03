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
		arg path;
		var sample;
		var i=0;
		path.do {
			arg filename;
			filename.postln;
			sample = Buffer.read(s, filename,0,-1,{
				arg b;
				if(b.numChannels == 1) {
					~samples.put(b.path.split($/).last.split($.)[0], b);
				} {
					("Sample is no wav file or does contain more than one channel: "+b.path).postln;
				}
			});
		};
	},nil,true,~root);
}
)

/**
 * Uncomment this if you want to use a predefined set of samples and not use the dialog.
 * Copy as often as you need to load all your samples. Be aware to use only mono
 * wav-Files, this will not be tested here and if it is not a mono wav-File the
 * synth will simply not make a sound.
 *

~samples["Hearbeat"] = Buffer.read(s, ~root +/+ "Samples/heartbeat.wav");
~samples["Bell"] = Buffer.read(s, ~root +/+ "Samples/bell_mono.wav");
~samples["Iron Gate"] = Buffer.read(s, ~root +/+ "Samples/iron-gate-vibrating.wav");
)

*/