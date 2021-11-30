// CHECK SETTINGS OF COMP
ServerOptions.outDevices;
ServerOptions.inDevices;
MIDIFunc.trace(true);
MIDIFunc.trace(false);

(
var path;
path = thisProcess.nowExecutingPath.dirname;
path.postln;

// Server.default.options.inDevice_("new_music_for_strings");
/*Server.default.options.outDevice_("MacBook Pro Speakers");
Server.default.options.inDevice_("MacBook Pro Microphone");*/
// Server.default.options.inDevice_("Scarlett 2i2 USB");
// Server.default.options.outDevice_("Scarlett 2i2 USB");
// Server.default.options.outDevice_("SuperCollider Out");
~server = Server.default;
~server.options.numOutputBusChannels_(2);
~server.options.numInputBusChannels_(4);
~server.waitForBoot(
	{
		// Set Global Monitor and Input
		~monitor = [0,1];
		// ~input = [2,3];
		~input = [0,1];

		// LOAD SYNTH DEFS
		thisProcess.interpreter.executeFile(path +/+ "/synthdefs.scd");

		// LOAD GUI STYLES
		thisProcess.interpreter.executeFile(path +/+ "/GUI_files/GUI_Styles.scd");

		// LOAD GUI CONSTRUCTOR
		thisProcess.interpreter.executeFile(path +/+ "/GUI_files/GUI_Constructor.scd");

		~server.sync;
		// Set global memory storage
		~gm = Dictionary.new();

		// Boot Sequencer
		thisProcess.interpreter.executeFile(path +/+ "/GUI_files/sequencer_gui.scd");



	};
);
)

