/**
 * Loading buffers happenes here.
 * This will load samples with a dialog, if you do not want to use
 * the dialog every time you start the synth, or give individual names
 * to Samples, use the format below and comment this
 */
(
~samples = Dictionary.new;
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


/**
 * Uncomment this if you want to use a predefined set of samples and not use the dialog.
 * Copy as often as you need to load all your samples. Be aware to use only mono
 * wav-Files, this will not be tested here and if it is not a mono wav-File the
 * synth will simply not make a sound.
 */

// ~samples["Name of sample for gui"] = Buffer.read(s, "/path/to/your/file.wav");
)
