// Sequencer
(
var buttonsize=40, columns=16, rows=8, window, top_level, track_buttons_container, ctrl_panel_container, header, buttons, track, sequencer_tab_buttons, stacked_buttons, sequencer_ctrl_1, sequencer_ctrl_2, sequencer_ctrl_3, start_instrument=\default, pattern, instruments=[\default, \peep_sequencer, \sin_tone_sequencer, \buzzy_bram_sequencer, \phase_mod_sequencer, \sin_fb_synth_sequencer, \subtract_noise_synth_sequencer], memory=~gm, tab_names=['melody', 'harmony', 'bass'];

// #############################
// Initialize Base Memory Values
// #############################

memory.atFail(\seq_mem, {
	memory.put(\seq_mem, Dictionary.newFrom([
		// Some pattern data for start up.
		\currentOctave, 0,
		\melody_octave, 6,
		\harmony_octave, 4,
		\bass_octave, 2,
		\melody_scale, Scale.major,
		\harmony_scale, Scale.major,
		\bass_scale, Scale.major,
		\melody_instrument, start_instrument,
		\harmony_instrument, start_instrument,
		\bass_instrument, start_instrument,
		\delta, 0.1,
		\melody_sus, 0.1,
		\harmony_sus, 0.1,
		\bass_sus, 0.1,
		\melody_amp, 0.7,
		\harmony_amp, 0.7,
		\bass_amp, 0.7,
		\pattern_out, 79,
		\current_name, \melody,
		// Booleans for routing
		\reverb_on, false,
		\granulator_on, false,
		// Granulator data for start up.
		\granAmp, 0.5,
		\granOut, 0,
		\granAttack, 0.1,
		\granRelease, 0.1,
		\granGate, 1,
		\granSync, 1,
		\granDensity, 40,
		\granBaseDur, 40,
		\granDurRand, 1,
		\granRate, 1,
		\granRateRand, 1,
		\granPan, 0,
		\granPanRand, 0,
		\granGrainEnv, -1,
		\granPtrSampleDelay, 20000,
		\granPtrRandSamples, 5000,
		\granMinPtrDelay, 1000
	]));
});

// ##################################
// Create objects for sound synthesis
// ##################################

// Create a buffer
memory.at(\seq_mem).put(\buffer, Buffer.alloc(~server, ~server.sampleRate * columns * memory.at(\seq_mem).at(\delta), 1));

// Initialize input and pointer buses for granulator control.
memory.at(\seq_mem).put(\inputBus, Bus.audio(~server, 1));
memory.at(\seq_mem).put(\ptrBus, Bus.audio(~server, 1));

// Initialize groups to organize order of execution on the scsynth side.
memory.at(\seq_mem).put(\inputGroup, Group.new);
memory.at(\seq_mem).put(\ptrGroup, Group.after(memory.at(\seq_mem).at(\inputGroup)));
memory.at(\seq_mem).put(\recGroup, Group.after(memory.at(\seq_mem).at(\ptrGroup)));
memory.at(\seq_mem).put(\granGroup, Group.after(memory.at(\seq_mem).at(\recGroup)));

// Initialize reverb
memory.at(\seq_mem).put(\reverb, Synth(\reverb, [\input, 99, \output, 0, \mix, 0.5, \room, 0.5, \damp, 0.5], memory.at(\seq_mem).at(\granGroup)));

// Initialize pattern splitter
memory.at(\seq_mem).put(\granulatorSplitter, Synth(\granulatorSplitter, [\out1, 89, \out2, 0, \in, 79]));

// Initialize a router for buffer recording.
memory.at(\seq_mem).put(\sequencerInput, Synth(\inputRouter, [\in, 89, \out, memory.at(\seq_mem).at(\inputBus)], memory.at(\seq_mem).at(\inputGroup)));

// Set a pointer synth to trail the record 'playhead'
memory.at(\seq_mem).put(\pointer, Synth(\pointer,
	[\buf, memory.at(\seq_mem).at(\buffer),
		\out, memory.at(\seq_mem).at(\ptrBus)], memory.at(\seq_mem).at(\ptrGroup)));

// Start a buffer recording synth
memory.at(\seq_mem).put(\sequencerRecord,
	Synth(\recordBuffer, [
		\ptrIn, memory.at(\seq_mem).at(\ptrBus),
		\recIn, memory.at(\seq_mem).at(\inputBus),
		\buf, memory.at(\seq_mem).at(\buffer)
	], memory.at(\seq_mem).at(\recGroup))
);

// #########
// BUILD GUI
// #########

// Build window, top_level and header
window = ~build_window.value("Sequencer", ~style_1, buttonsize*columns+740, buttonsize*rows+380);
top_level = ~build_top_level.value(window, buttonsize*columns+720, buttonsize*rows+360, ~style_1);
header = ~build_sequencer_header.value(top_level, buttonsize*columns+700, 80, ~style_1, "Sequencer");

// Build Tabs
sequencer_tab_buttons = ~build_sequencer_tab_buttons.value(top_level, \stack, tab_names);

// Build Track
track_buttons_container = ~build_track_buttons_container.value(top_level, buttonsize*columns+40, (buttonsize) + (buttonsize*rows+20), ~style_1);
track = ~build_sequencer_track.value(track_buttons_container, buttonsize*columns+20, buttonsize+20, ~style_1, columns, buttonsize);

// Build the Sequencer Buttons
stacked_buttons = ~build_sequencer_tabbed_stack.value(track_buttons_container, sequencer_tab_buttons, buttonsize*columns+20, buttonsize*rows+20, 3, buttonsize, columns, rows, ~style_1, memory);

// Built Control panels
ctrl_panel_container = ~build_track_buttons_container.value(top_level, 225+190+200, buttonsize*rows+170, ~style_1);
sequencer_ctrl_1 = ~build_sequencer_control_panel_1.value(ctrl_panel_container, 225, buttonsize*rows+170, ~style_1, instruments, stacked_buttons, memory, columns);
sequencer_ctrl_2 = ~build_sequencer_control_panel_2.value(ctrl_panel_container, 190, buttonsize*rows+170, ~style_1, buttonsize, memory, stacked_buttons, memory.at(\seq_mem).at(\reverb), track);
sequencer_ctrl_3 = ~build_sequencer_control_panel_3.value(ctrl_panel_container, 200, buttonsize*rows+170, columns, ~style_1, memory, memory.at(\seq_mem).at(\granulatorSequencer));

// ##############
// Build Patterns
// ##############

Pdefn(\melody, Ppar(
	stacked_buttons[0][1].collect({
		arg c, r;
		var currentOctaveDegree = stacked_buttons[0][1].size - r + memory.at(\seq_mem).at(\melody_octave);
		Pbind(
			\instrument, Pdefn(\p_melody_instrument, memory.at(\seq_mem).at(\melody_instrument)),
			\scale, Pdefn(\p_scale, memory.at(\seq_mem).at(\melody_scale)),
			\octave, Pdefn(\p_melody_octave, memory.at(\seq_mem).at(\melody_octave)),
			\degree, Pif(Pseq(stacked_buttons[0][1][r], inf).coin, currentOctaveDegree, \rest),
			\delta, Pdefn(\p_delta, memory.at(\seq_mem).at(\delta)),
			\sustain, Pdefn(\p_melody_sus,  memory.at(\seq_mem).at(\melody_sus)),
			\amp, Pdefn(\p_melody_amp, memory.at(\seq_mem).at(\melody_amp)),
			\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
			\track_index, Pdefn(\p_track_index, Pseq((0..15), inf)),
			\track_func, Pdefn(\p_track_func, Pfunc({|ev| ~update_track.value(ev.track_index, track)}));
)}), inf)).play;

Pdefn(\harmony, Ppar(
	stacked_buttons[1][1].collect({
		arg c, r;
		var currentHarmonyOctaveDegree = stacked_buttons[1][1].size - r + memory.at(\seq_mem).at(\harmony_octave);
		Pbind(
			\instrument, Pdefn(\p_harmony_instrument, memory.at(\seq_mem).at(\harmony_instrument)),
			\scale, Pdefn(\p_scale, memory.at(\seq_mem).at(\harmony_scale)),
			\octave, Pdefn(\p_harmony_octave, memory.at(\seq_mem).at(\harmony_octave)),
			\degree, Pif(Pseq(stacked_buttons[1][1][r], inf).coin, currentHarmonyOctaveDegree, \rest),
			\delta, Pdefn(\p_delta, memory.at(\seq_mem).at(\delta)),
			\sustain, Pdefn(\p_harmony_sus,  memory.at(\seq_mem).at(\harmony_sus)),
			\amp, Pdefn(\p_harmony_amp, memory.at(\seq_mem).at(\harmony_amp)),
			\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
)}), inf)).play;

Pdefn(\bass, Ppar(
	stacked_buttons[2][1].collect({
		arg c, r;
		var currentBassOctaveDegree = stacked_buttons[2][1].size - r + memory.at(\seq_mem).at(\bass_octave);
		Pbind(
			\instrument, Pdefn(\p_bass_instrument, memory.at(\seq_mem).at(\bass_instrument)),
			\scale, Pdefn(\p_scale, memory.at(\seq_mem).at(\bass_scale)),
			\octave, Pdefn(\p_bass_octave, memory.at(\seq_mem).at(\bass_octave)),
			\degree, Pif(Pseq(stacked_buttons[2][1][r], inf).coin, currentBassOctaveDegree, \rest),
			\delta, Pdefn(\p_delta, memory.at(\seq_mem).at(\delta)),
			\sustain, Pdefn(\p_bass_sus,  memory.at(\seq_mem).at(\bass_sus)),
			\amp, Pdefn(\p_bass_amp, memory.at(\seq_mem).at(\bass_amp)),
			\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
)}), inf)).play;

CmdPeriod.add({window.close;});
)
