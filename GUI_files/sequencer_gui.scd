// Sequencer
(
var buttonsize=50, columns=16, rows=8, window, top_level, track_buttons_container, ctrl_panel_container, header, buttons, track, sequencer_tab_buttons, stacked_buttons, sequencer_ctrl_1, sequencer_ctrl_2, start_instrument=\default, pattern, instruments, memory=~gm, tab_names=['melody', 'harmony', 'bass'];

// Initialize Memory
memory.atFail(\seq_mem, {
	memory.put(\seq_mem, Dictionary.newFrom([
		\currentOctave, 0,
		\melody_octave, 7,
		\harmony_octave, 4,
		\bass_octave, 2,
		\scale, Scale.major,
		\melody_scale, Scale.major,
		\harmony_scale, Scale.major,
		\bass_scale, Scale.major,
		\instrument, start_instrument,
		\melody_instrument, start_instrument,
		\harmony_instrument, start_instrument,
		\bass_instrument, start_instrument,
		\delta, 0.1,
		\sus, 0.1,
		\melody_sus, 0.1,
		\harmony_sus, 0.1,
		\bass_sus, 0.1,
		\amp, 0.7,
		\melody_amp, 0.7,
		\harmony_amp, 0.7,
		\bass_amp, 0.7,
		\pattern_out, 0]));
});

memory.at(\seq_mem).put(\reverb, Synth(\reverb, [\input, 99, \output, 0, \mix, 0.5, \room, 0.5, \damp, 0.5]));

instruments = [\default, \peep_sequencer, \sin_tone_sequencer, \buzzy_bram_sequencer, \phase_mod_sequencer];

// Build GUI
// Build window, top_level and header
window = ~build_window.value("Sequencer", ~style_1, buttonsize*columns+540, buttonsize*rows+280);
top_level = ~build_top_level.value(window, buttonsize*columns+520, buttonsize*rows+260, ~style_1);
header = ~build_sequencer_header.value(top_level, buttonsize*columns+500, 80, ~style_1, "Sequencer");

// Build Tabs
sequencer_tab_buttons = ~build_sequencer_tab_buttons.value(top_level, \stack, tab_names);

// Build Track
track_buttons_container = ~build_track_buttons_container.value(top_level, buttonsize*columns+40, (buttonsize) + (buttonsize*rows+20), ~style_1);
track = ~build_sequencer_track.value(track_buttons_container, buttonsize*columns+20, buttonsize+20, ~style_1, columns, buttonsize);

stacked_buttons = ~build_sequencer_tabbed_stack.value(track_buttons_container, sequencer_tab_buttons, buttonsize*columns+20, buttonsize*rows+20, 3, buttonsize, columns, rows, ~style_1);

// Built Control panel
ctrl_panel_container = ~build_track_buttons_container.value(top_level, 225+190, buttonsize*rows+70, ~style_1);
sequencer_ctrl_1 = ~build_sequencer_control_panel_1.value(ctrl_panel_container, 225, buttonsize*rows+70, ~style_1, instruments, stacked_buttons, memory);
sequencer_ctrl_2 = ~build_sequencer_control_panel_2.value(ctrl_panel_container, 190, buttonsize*rows+70, ~style_1, buttonsize, memory, stacked_buttons, memory.at(\seq_mem).at(\reverb));


Pdefn(\melody, Ppar(
	stacked_buttons[0][1].collect({
		arg c, r;
		var currentOctaveDegree = stacked_buttons[0][1].size - r - 1 + memory.at(\seq_mem).at(\melody_octave);
		Pbind(
			\instrument, Pdefn(\p_instrument, memory.at(\seq_mem).at(\instrument)),
			\scale, Pdefn(\p_scale, memory.at(\seq_mem).at(\scale)),
			\octave, Pdefn(\p_mel_octave, memory.at(\seq_mem).at(\melody_octave)),
			\degree, Pif(Pseq(stacked_buttons[0][1][r], inf).coin, currentOctaveDegree, \rest),
			\delta, Pdefn(\p_delta, memory.at(\seq_mem).at(\delta)),
			\sustain, Pdefn(\p_sus,  memory.at(\seq_mem).at(\sus)),
			\amp, Pdefn(\p_amp, memory.at(\seq_mem).at(\amp)),
			\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
			\track_index, Pdefn(\p_track_index, Pseq((0..15), inf)),
			\track_func, Pdefn(\p_track_func, Pfunc({|ev| ~update_track.value(ev.track_index, track)}));
)}), inf)).play;

Pdefn(\harmony, Ppar(
	stacked_buttons[1][1].collect({
		arg c, r;
		var currentHarmonyOctaveDegree = stacked_buttons[1][1].size - r - 1 + memory.at(\seq_mem).at(\harmony_octave);
		Pbind(
			\instrument, Pdefn(\p_instrument, memory.at(\seq_mem).at(\instrument)),
			\scale, Pdefn(\p_scale, memory.at(\seq_mem).at(\scale)),
			\octave, Pdefn(\p_harm_octave, memory.at(\seq_mem).at(\harmony_octave)),
			\degree, Pif(Pseq(stacked_buttons[1][1][r], inf).coin, currentHarmonyOctaveDegree, \rest),
			\delta, Pdefn(\p_delta, memory.at(\seq_mem).at(\delta)),
			\sustain, Pdefn(\p_sus,  memory.at(\seq_mem).at(\sus)),
			\amp, Pdefn(\p_amp, memory.at(\seq_mem).at(\amp)),
			\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
)}), inf)).play;

Pdefn(\bass, Ppar(
	stacked_buttons[2][1].collect({
		arg c, r;
		var currentBassOctaveDegree = stacked_buttons[2][1].size - r - 1 + memory.at(\seq_mem).at(\bass_octave);
		Pbind(
			\instrument, Pdefn(\p_instrument, memory.at(\seq_mem).at(\instrument)),
			\scale, Pdefn(\p_scale, memory.at(\seq_mem).at(\scale)),
			\octave, Pdefn(\p_bass_octave, memory.at(\seq_mem).at(\bass_octave)),
			\degree, Pif(Pseq(stacked_buttons[2][1][r], inf).coin, currentBassOctaveDegree, \rest),
			\delta, Pdefn(\p_delta, memory.at(\seq_mem).at(\delta)),
			\sustain, Pdefn(\p_sus,  memory.at(\seq_mem).at(\sus)),
			\amp, Pdefn(\p_amp, memory.at(\seq_mem).at(\amp)),
			\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
)}), inf)).play;


CmdPeriod.add({window.close;});
)
