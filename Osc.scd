/**
 * Here we are managing OSD definitions
 */

(

// send osc messages to visualisation on port 12345
b = NetAddr.new("127.0.0.1", 12345);

/**
 * We are updating the actual position slider via OSC messages
 */
OSCdef(\positionUpdate, { |msg|
	{ ~sliders[msg[3]][\pos].value = msg[4]; }.defer; // Update UI safely
}, '/posup');

/**
 * We are sending grain generation information and creation of new channels
 * as OSC messages for visualization
 */
OSCdef(\grain_visualization, { |msg|
	// actual_pos, actual_size, channel, position
	b.sendMsg("/grain", msg[4], msg[3], msg[5], msg[6]);
}, '/grain_viz');

OSCdef(\fm_visualization, { |msg|
	b.sendMsg("/fm", msg[3], msg[4], msg[5]);
}, '/fm_viz');

OSCdef(\new_channel, { |msg|
	b.sendMsg("/channel", 1);
}, '/new_ch');


/**
 * LFOs controlling parameters are also working with OSC messages
 */
OSCdef(\LFO, {
	arg msg;
	var keys = [\size, \position, \speed, \density, \pan, \carrier, \ratio, \index, \lowpass];
	{ ~sliders[msg[3]][keys[msg[4]]].valueAction_(msg[5]); }.defer; // Update UI safely
}, '/lfo');

)