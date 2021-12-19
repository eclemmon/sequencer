// CHECK SETTINGS OF COMP
ServerOptions.outDevices;
ServerOptions.inDevices;
MIDIFunc.trace(true);
MIDIFunc.trace(false);

(
var path;
path = thisProcess.nowExecutingPath.dirname;
path.postln;

// Set hardware in device
// Server.default.options.inDevice_("Scarlett 2i2 USB");
Server.default.options.inDevice_("Scarlett 18i8 USB");
// Set hardware out device
Server.default.options.outDevice_("Scarlett 18i8 USB");

// Set gloabal settings for scsynth server, assign server to a global var.
~server = Server.default;
/*~server.options.numOutputBusChannels_(8);
~server.options.numInputBusChannels_(8);*/
~server.waitForBoot(
	{
/*		// Set gobal channel monitor
		~monitor = [0,1];

		// Set global input channel array
		~input = [0,1];*/

		// LOAD SYNTH DEFS
		thisProcess.interpreter.executeFile(path +/+ "/synthdefs.scd");

		// LOAD GUI STYLES
		thisProcess.interpreter.executeFile(path +/+ "/GUI_files/GUI_Styles.scd");

		// LOAD GUI CONSTRUCTOR
		thisProcess.interpreter.executeFile(path +/+ "/GUI_files/GUI_Constructor.scd");

		// LOAD GRANULATOR FUNCTIONS
		thisProcess.interpreter.executeFile(path +/+ "/GUI_files/granulator_functions.scd");

		// Wait until boot is done and then begin launching the rest of the prograam
		~server.sync;

		// Set global memory storage
		if (~gm == nil, {
			~gm = Dictionary.new();
		});

		// Boot Sequencer
		thisProcess.interpreter.executeFile(path +/+ "/GUI_files/sequencer_gui.scd");
	};
);
)

