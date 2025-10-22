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
}
)