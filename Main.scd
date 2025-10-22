(
/**
 * COMPUTERGRAIN
 *
 * A grain synthesizer with two modes and multiple layers. Can be controlled via MIDI or GUI.
 * One mode (Land) overlays multiple channels with slightly different generation rates,
 * that creates modulations between layers for interesting soundscapes, and one mode
 * that is a classic grain synthesizer, one is a simple frequency modulation.
 *
 * Multiple samples can be chosen, that all have to be loaded on startup
 *
 * @author		Jürgen Buchinger <studio@differentspace.com>
 * @version 	5.3
 * @date		22 Oct 2025
 *
 *
 * To run the program you have to evaluate the code in this file, i.e. place
 * your cursor somwhere in this file and press Ctrl + Enter (or CMD + Enter on Mac).
 * The program will automatically load samples from the "Samples"-folder, but you can
 * also load with a file dialogue after start.
 *
 * All samples have to be mono wav-files!
 *
 * If you want to save your configuration of Synths and parameters, press "save"
 * on the main control panel, press "restore" to restore the configuration again.
 *
 * To record sound, press record, sound will be recorded immediately to the Recordings
 * directory in you working folder, press again to stop recording.
 *
 * MIDI MAPPINGS
 * Midi CC messages control the layer of the channel on which they are sent, so a
 * message on ch0 controls the synth on ch0. The control numbers can be set differently
 * in the file Midi.scd
 * cc num	30		31			32			33			34		35	36	37
 * control	size	size_spray	position	pos_spray	density	vol	pan	buffer
 */

o = Server.default.options;
o.numOutputBusChannels = 2; // individual layers can pan around 4 channels. Adjust your setup here.
o.maxLogins = 2;
s = Server.default;
s.waitForBoot({

	// figure out where we are.
	~root = thisProcess.nowExecutingPath.dirname;

	// load samples
	(~root +/+ "Samples.scd").load;

	// Save and restore functions
	(~root +/+ "SaveRestore.scd").load;

	// load synthdefs
	(~root +/+ "SynthDefs/Fm2.scd").load;
	(~root +/+ "SynthDefs/Grain.scd").load;
	(~root +/+ "SynthDefs/Land.scd").load;
	(~root +/+ "SynthDefs/Lfo.scd").load;

	// load Midi and OSC defs
	(~root +/+ "Midi.scd").load;
	// (~root +/+ "MidiC8.scd").load;  // uncomment this if you use a Command8 controller
	(~root +/+ "Osc.scd").load;

	// load GUI
	(~root +/+ "SynthGui.scd").load;
	(~root +/+ "LfoGui.scd").load;
	(~root +/+ "FmGui.scd").load;
	(~root +/+ "MainGui.scd").load;

	// creat synth directory
	~synths = Dictionary.new;
	~sliders = Dictionary.new;
	~lfos = Dictionary.new;
});
)