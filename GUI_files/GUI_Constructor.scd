//// GUI CONSTRUCTOR
(
~build_window_seq = {
	// Builds the main window that contains everything
	arg window_title, style, width, height;
	Window(window_title, Rect(10, 10, width, height))
	.background_(style.at("window_color"))
	.front;
};

~build_top_level_seq = {
	// Buildts a top level composite view that manages child views' spacing.
	arg window, width, height, style;
	var compView = CompositeView(window, Rect(10, 10, width, height))
	.background_(style.at("top_level_frame_color"));
	compView.addFlowLayout(10@10);
	compView.decorator.gap_(0@10);
	compView;
};

~build_sequencer_header_seq = {
	// Builds a header frame with a static text box with the title of the window
	arg top, hwidth, hheight, style, string;
	var guiTitle;
	guiTitle = StaticText(top, Rect(10, 10, hwidth, hheight));
	guiTitle.string = "Sequencer";
	guiTitle.background = style.at("header_frame_color");
	guiTitle.font = style.at("header_font");
	guiTitle.align = \center;
	top.decorator.nextLine;
	guiTitle;
};

~build_sequencer_tab_buttons_seq = {
	// Builds the tab buttons that select different levels of sequencers.
	arg top_level, stack, buttons;
	buttons = buttons.collect({ arg item;
		var button;
		button = Button(top_level, 100@40)
		.states_([[item, Color.black, Color.white], [item, Color.white, Color.black]]);
		// When one button is turned on, it turns off the rest. Probably can be safely
		// removed as the same code appears below when the button actions are defined
		// further.
		button.action_({
			arg button;
			buttons.do({
				arg item, i;
				if (button != item, {
					if (item.value == 1,
						{ item.value = 0 }
					);
				}, {
					button.value = 1;
				});
			});
		});
		button;
	});

	buttons[0].value = 1;
	top_level.decorator.nextLine;

	buttons;
};

~build_sequencer_tabbed_stack_seq = {
	// Builds n stacks of columns * rows buttons that control different sequencer levels.
	arg top_level, sequencer_tab_buttons, width, height, num_tab_buttons, buttonsize, columns, rows, style, memory;
	var view, stack, buttonsStacked, compViews;

	// A view container to place a vertical + stack layout.
	view = View(top_level, Rect(0, 0, width, height));
	view.background = style.at("bank_frame_color");

	// Builds an array of sequencer buttons (themselves a 2DArray).
	buttonsStacked = Array.fill(num_tab_buttons, {arg i; ~build_sequencer_buttons_seq.value(view, buttonsize*columns, buttonsize*rows, style, columns, rows, buttonsize)});

	// The individual composite views that the buttons will be placed.
	compViews = Array.fill(num_tab_buttons, {arg i; buttonsStacked[i][0]});

	// Places the button compviews in the StackLayout
	view.layout = VLayout(
		stack = StackLayout(
			*compViews;
		);
	);

	// The tab buttons gain the action of controlling which stack of buttons is shown
	sequencer_tab_buttons.do({
		arg item, i;
		item.action_({
			arg button;
			stack.index = i;
			memory.at(\seq_mem).put(\current_name, button.string);
			sequencer_tab_buttons.do({
				arg item, i;
				if (button != item, {
					if (item.value == 1,
						{ item.value = 0 }
					);
				}, {
					button.value = 1;
				});
			});
			// Set the buttons and sliders on the GUI from memory.
			~set_buttons_sliders_numBoxes.value(memory);
		});

	});

	top_level.decorator.nextLine;
	buttonsStacked;
};

~build_track_buttons_container_seq = {
	// Builds a frame to contain and organize the track and the stack of buttons.
	arg top_level, width, height, style;
	var compView = CompositeView(top_level, Rect(0, 0, width, height))
	.background_(style.at("top_level_frame_color"));
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);
	compView;
};

~build_sequencer_track_seq = {
	// Builds the sequencer track.
	arg top, hwidth, hheight, style, columns, buttonsize;
	var trackCompView, array, sequencer_track_data;

	// Track Composite View
	trackCompView = CompositeView(top, Rect(0, 0, buttonsize*columns+20, hheight-20));
	trackCompView.background = style.at("bank_frame_color");

	// Sequencer Track: A set of static texts that change colors when the pattern
	// scrolls over it.
	array = Array.fill(columns, { arg i;
		StaticText(trackCompView, Rect(i * buttonsize + 10, 10, buttonsize, buttonsize-20))
		.background_(Color.white)
	});

	top.decorator.nextLine;

	sequencer_track_data = [trackCompView, array]
};

~build_sequencer_buttons_seq = {
	// A function to build a 2D array of buttons that turn on and off the notes
	// selected in the sequencer pattern.
	arg top, hwidth, hheight, style, columns, rows, buttonsize;
	var butCompView, array, sequencer_button_data;

	// Button Composite View
	butCompView = CompositeView(top, Rect(0, 0, buttonsize*columns, buttonsize*rows));
	butCompView.background = style.at("bank_frame_color");

	// Sequencer Buttons
	array = 0!columns!rows;

	array.do{ |rows, i|
		rows.do{ |cell, j|
			// var buttonsize=50;
			Button(butCompView, Rect(j*buttonsize, i*buttonsize, buttonsize, buttonsize))
			.states_([
				["", style.at("text_color"), Color.white],
				["", Color.white, style.at("text_color")],
			])
			.action_{ |v|
				array[i][j] = v.value;
			};
		};
	};

	sequencer_button_data = [butCompView, array];
};


~build_sequencer_control_panel_1_seq = {
	// Builds the control panel 1 for the sequencer
	arg top, hwidth, hheight, style, instruments=[\default], butCompViews, memory, columns;
	var compView, speedSliderLabel, volumeSliderLabel, speedSlider, volumeSlider, speedNumberBox, volumeNumberBox, scaleMenuLabel, scaleMenu, instrumentLabel, instrumentMenu, clearButton, durationSliderLabel, noteDurationSlider, noteDurationBox;

	// Slider Composite View
	compView = CompositeView(top, Rect(0, 0, hwidth, hheight));
	compView.background = style.at("bank_frame_color");
	compView.addFlowLayout(10@10);
	compView.decorator.gap_(10@10);

	// Sequencer Speed Control Label
	speedSliderLabel = StaticText(compView, Rect(0, 10, 60, 30))
	.string_("Speed")
	.font_(style.at("text_font"))
	.align_(\center);
	speedSliderLabel.background = style.at("window_color");
	speedSliderLabel.stringColor  = Color.white;

	// Sequencer Duration Control Label
	durationSliderLabel = StaticText(compView, Rect(0, 10, 60, 30))
	.string_("Note Dur")
	.font_(style.at("text_font"))
	.align_(\center);
	durationSliderLabel.background = style.at("window_color");
	durationSliderLabel.stringColor  = Color.white;

	// Volume Label
	volumeSliderLabel = StaticText(compView, Rect(65, 10, 60, 30))
	.string_("Volume")
	.font_(style.at("text_font"))
	.align_(\center);
	volumeSliderLabel.background = style.at("window_color");
	volumeSliderLabel.stringColor = Color.white;

	// Sequencer Speed Control Slider
	speedSlider = Slider(compView, Rect(0, 10, 60, 150));
	speedSlider.value = 0.1;

	// Note Duration Control Slider
	noteDurationSlider = Slider(compView, Rect(0, 10, 60, 150));
	noteDurationSlider.value = 0.5;

	// Volume Control Slider
	volumeSlider = Slider(compView, Rect(65, 10, 60, 150));
	volumeSlider.value = 1;

	compView.decorator.nextLine;

	// Boxes that list the values controlled by the sliders above.
	speedNumberBox = NumberBox(compView, Rect(20, 20, 60, 20));
	speedNumberBox.value = 0.1;

	noteDurationBox = NumberBox(compView, Rect(20, 20, 60, 20));
	noteDurationBox.value = 0.1;

	volumeNumberBox = NumberBox(compView, Rect(20, 20, 60, 20));
	volumeNumberBox.value = 0.7;

	// Sequencer Speed Slider Control Action
	speedSlider.action_({
		var control;
		control = ControlSpec(0.05, 2, \exp, 0.01);
		memory.at(\seq_mem).put(\delta, speedSlider.value);
		memory.at(\seq_mem).at(\buffer).numFrames = ~server.sampleRate * columns * memory.at(\seq_mem).at(\delta);
		Pdefn(\p_delta, control.map(memory.at(\seq_mem).at(\delta)));
		speedNumberBox.value_(memory.at(\seq_mem).at(\delta));
	});

	// Store slider to memory so it can be retrieved and set easily.
	memory.at(\seq_mem).put(\speedSlider, speedSlider);

	// Slider that changes the duration of the pb of the notes in the sequencer
	noteDurationSlider.action_({
		var control, control_name, pdef_name;
		control = ControlSpec(0.1, 4, \linear, 0.1);
		control_name = ~build_control_name_seq.value(memory, \sus);
		pdef_name = \p_ ++ control_name;
		memory.at(\seq_mem).put(control_name, noteDurationSlider.value);
		Pdefn(pdef_name.asSymbol, control.map(memory.at(\seq_mem).at(control_name)));
		noteDurationBox.value_(control.map(memory.at(\seq_mem).at(control_name)));
	});

	// Store slider to memory so it can be retrieved and set easily.
	memory.at(\seq_mem).put(\noteDurationSlider, noteDurationSlider);

	// Volume Slider Control Action
	volumeSlider.action_({
		var control, control_name, pdef_name;
		control = ControlSpec(0, 0.7, \linear, 0.01);
		control_name = ~build_control_name_seq.value(memory, \amp);
		pdef_name = \p_ ++ control_name;
		memory.at(\seq_mem).put(control_name, volumeSlider.value);
		Pdefn(pdef_name.asSymbol, control.map(memory.at(\seq_mem).at(control_name)));
		volumeNumberBox.value_(control.map(memory.at(\seq_mem).at(control_name)));
	});

	// Store slider to memory so it can be retrieved and set easily.
	memory.at(\seq_mem).put(\volumeSlider, volumeSlider);

	compView.decorator.nextLine;

	// Scale Selection label
	scaleMenuLabel = StaticText(compView, Rect(0, 10, hwidth-25, 30))
	.string_("Scale Type")
	.font_(style.at("text_font"))
	.align_(\center);
	scaleMenuLabel.background = style.at("window_color");
	scaleMenuLabel.stringColor = Color.white;

	compView.decorator.nextLine;

	// Scale Selection Menu
	scaleMenu = PopUpMenu(compView, Rect(0, 10, hwidth-25, 30));
	scaleMenu.items = Scale.names;
	scaleMenu.value_(Scale.names.indexOf(\major));
	scaleMenu.action_({
		arg menu;
		Pdefn(\p_scale, Scale.at(menu.item));
	});

	compView.decorator.nextLine;

	// Instrument Selection Label
	instrumentLabel = StaticText(compView, Rect(0, 10, hwidth-25, 30))
	.string_("Instrument")
	.font_(style.at("text_font"))
	.align_(\center);
	instrumentLabel.background = style.at("window_color");
	instrumentLabel.stringColor = Color.white;

	compView.decorator.nextLine;

	// Instrument selection menu
	instrumentMenu = PopUpMenu(compView, Rect(0, 10, hwidth-25, 30));
	instrumentMenu.items = instruments;
	instrumentMenu.value_(0);
	instrumentMenu.action_({
		arg menu;
		var control_name, pdef_name;
		control_name = ~build_control_name_seq.value(memory, \instrument);
		pdef_name = \p_ ++ control_name;
		memory.at(\seq_mem).put(control_name, menu.item);
		memory.at(\seq_mem).put(control_name ++ '_idx', menu.value);
		Pdefn(pdef_name.asSymbol, menu.item);
	});

	// Store menu to memory so it can be retrieved and set easily.
	memory.at(\seq_mem).put(\instrumentMenu, instrumentMenu);

	compView.decorator.nextLine;

	// Clear Sequencer Button
	clearButton = Button(compView, Rect(0, 10, hwidth-25, 30));
	clearButton.string = "clear sequencer";

	clearButton.action_({
		butCompViews.do({
			arg butCompView;
			butCompView[0].children(Button).do({
				arg item, i;
				if(item.value == 1, {item.valueAction = 0;})
			});
		});
	});

	compView;
};

~build_sequencer_control_panel_2_seq = {
	// Builds the control panel 2 for the sequencer
	arg top, hwidth, hheight, style, buttonsize, memory, stacked_buttons, reverb, track;
	var control2CompView, octaveLabel, minusOctBut, plusOctBut, quantLabel, quantSlider, quantNumberBox, mixKnob, roomKnob, dampKnob, reverbButton, sequencerOutMonitor;

	// Control Comp View 2
	control2CompView = CompositeView(top, Rect(0, 0, hwidth, hheight));
	control2CompView.background = style.at("bank_frame_color");
	control2CompView.addFlowLayout(10@10);
	control2CompView.decorator.gap_(10@10);

	// Octave Change Label
	octaveLabel = StaticText(control2CompView, Rect(0, 0, hwidth-20, 30))
	.string_("Octave")
	.font_(style.at("text_font"))
	.align_(\center);
	octaveLabel.background = style.at("window_color");
	octaveLabel.stringColor = Color.white;

	control2CompView.decorator.nextLine;

	// Octave Change Buttons
	minusOctBut = Button(control2CompView, 80@40);
	minusOctBut.string = "-";

	plusOctBut = Button(control2CompView, 80@40);
	plusOctBut.string = "+";

	// Octave Button Actions
	minusOctBut.action_({
		var cn_octave, pdef_name;
		cn_octave = ~build_control_name_seq.value(memory, \octave);
		pdef_name = \p_ ++ cn_octave;
		memory.at(\seq_mem).put(cn_octave, memory.at(\seq_mem).at(cn_octave) - 1);
		Pdefn(pdef_name.asSymbol, memory.at(\seq_mem).at(cn_octave.asSymbol))
	});

	plusOctBut.action_({
		var cn_octave, pdef_name;
		cn_octave = ~build_control_name_seq.value(memory, \octave);
		pdef_name = \p_ ++ cn_octave;
		memory.at(\seq_mem).put(cn_octave, memory.at(\seq_mem).at(cn_octave) + 1);
		Pdefn(pdef_name.asSymbol, memory.at(\seq_mem).at(cn_octave.asSymbol))
	});

	control2CompView.decorator.nextLine;

	// QUANTIZATION SLIDER LABEL
	quantLabel = StaticText(control2CompView, Rect(0, 0, 170, 30))
	.string_("Quantization")
	.font_(style.at("text_font"))
	.align_(\center);
	quantLabel.background = style.at("window_color");
	quantLabel.stringColor = Color.white;

	control2CompView.decorator.nextLine;

	// QUANTIZATION SLIDER
	quantSlider = Slider(control2CompView, Rect(0, 0, 120, 30));
	quantSlider.orientation = \horizontal;
	quantSlider.step = 1.0/4;
	quantSlider.action_({
		quantNumberBox.value_(quantSlider.value * 4);
		if (quantSlider.value == 0, {
			Pdefn(\pattern).quant = nil;
		}, {
			Pdefn(\pattern).quant = quantSlider.value * 4;
		});

	});

	// QUANTIZATION SLIDER NUMBER BOX
	quantNumberBox =  NumberBox(control2CompView, Rect(0, 20, 40, 30));
	quantNumberBox.value = 0;

	// REVERB BUTTON ON/OFF
	reverbButton = Button(control2CompView, 170@30)
	.states_([["Turn Reverb On", Color.white, style.at("text_color")], ["Turn Reverb Off", Color.white, Color.red]])
	.action_({
		if (reverbButton.value == 1, {
			// Set Granulator Splitter out2 to 99
			// Set granulator out to reverb
			memory.at(\seq_mem).at(\reverb).set(\gate, 1);
			memory.at(\seq_mem).put(\reverb_on, true);
			memory.at(\seq_mem).at(\granulatorSplitter).set(\out2, 99);
			memory.at(\seq_mem).at(\granulatorSequencer).set(\out, 99);
		}, {
			// Set splitter and granulator out to main
			memory.at(\seq_mem).at(\reverb).set(\gate, 0);
			memory.at(\seq_mem).at(\granulatorSplitter).set(\out2, 0);
			memory.at(\seq_mem).at(\granulatorSequencer).set(\out, 0);
			memory.at(\seq_mem).put(\reverb_on, false);
		});
	});

	// REVERB LABELS
	["Mix", "Room", "Damp"].do({
		arg item, i;
		var label;
		label = StaticText(control2CompView, Rect(0, 0, 170-20/3, 30))
		.string_(item)
		.font_(style.at("text_font"))
		.align_(\center);
		label.background = style.at("bank_frame_color");
	});

	// REVERB CONTROL KNOBS
	mixKnob = Knob.new(control2CompView, Rect(0, 0, 170-20/3, 170-20/3));
	mixKnob.mode =\vert;
	mixKnob.value = 0.5;
	mixKnob.action_({
		reverb.set(\mix, mixKnob.value);
	});

	roomKnob = Knob.new(control2CompView, Rect(0, 0, 170-20/3, 170-20/3));
	roomKnob.mode =\vert;
	roomKnob.value = 0.5;
	roomKnob.action_({
		reverb.set(\room, roomKnob.value);
	});

	dampKnob = Knob.new(control2CompView, Rect(0, 0, 170-20/3, 170-20/3));
	dampKnob.mode =\vert;
	dampKnob.value = 0.5;
	dampKnob.action_({
		reverb.set(\damp, dampKnob.value);
	});

	control2CompView.decorator.nextLine;

	["Seq Lvl", "Gran Lvl"].do({
		arg item, i;
		var label;
		label = StaticText(control2CompView, Rect(0, 0, 170-20/3, 30))
		.string_(item)
		.font_(style.at("text_font"))
		.align_(\center);
		label.background = style.at("bank_frame_color");
	});

	control2CompView.decorator.nextLine;

	sequencerOutMonitor = ~build_level_indicator.value(memory.at(\seq_mem).at(\pattern_out), control2CompView, 170-20/3, 110);

	sequencerOutMonitor = ~build_level_indicator.value(memory.at(\seq_mem).at(\granOut), control2CompView, 170-20/3, 110);

	control2CompView;
};

~build_sequencer_control_panel_3_seq = {
	// Builds the control panel 3 for the sequencer
	arg top, hwidth, hheight, columns, style, memory, granulator;
	var control3CompView, granulatorLabel, granulatorOnButton, ampKnob, grainDensityKnob, grainBaseDurKnob, durRandKnob, grainRateKnob, grainRateRandKnob, grainPanKnob, grainPanRandKnob, grainPtrDelayKnob, grainPtrDelayRandKnob, grainMinPtrDelayKnob, blackHoleSeqButton;

	// Control Comp View 3
	control3CompView = CompositeView(top, Rect(0, 0, hwidth, hheight));
	control3CompView.background = style.at("bank_frame_color");
	control3CompView.addFlowLayout(10@10);
	control3CompView.decorator.gap_(10@5);

	// Granulator Label
	granulatorLabel = StaticText(control3CompView, Rect(0, 0, hwidth-20, 30))
	.string_("Granulator")
	.font_(style.at("text_font"))
	.align_(\center);
	granulatorLabel.background = style.at("window_color");
	granulatorLabel.stringColor = Color.white;

	// Granulatory Button On/Off
	granulatorOnButton = Button(control3CompView, Rect(0, 0, hwidth-20, 30))
	.states_([["Turn Granulator On", Color.white, style.at("text_color")], ["Turn Granulator Off", Color.white, Color.red]])
	.action_({
		if (granulatorOnButton.value == 1, {
			if (memory.at(\seq_mem).at(\reverb_on), {
				// Set granulator out to bus 99
				memory.at(\seq_mem).put(\granOut, 99);
				// Turn Granulator On
				~turn_granulator_on.value(memory);
			}, {
				// else send granulator to main out
				memory.at(\seq_mem).put(\granOut, 0);
				~turn_granulator_on.value(memory);
			});
			// Set granulator on to true
			memory.at(\seq_mem).put(\granulator_on, true);
		}, {
			//
			~turn_granulator_off.value(memory);
			// Set granulator on to false
			memory.at(\seq_mem).put(\granulator_on, false);
		});
	});

	control3CompView.decorator.nextLine;

	// Amp, density, and base duration labels
	["Amp", "Density", "Base Dur"].do({
		arg item, i;
		var label;
		label = StaticText(control3CompView, Rect(0, 0, hwidth-40/3, 30))
		.string_(item)
		.font_(style.at("text_font"))
		.align_(\center);
		label.background = style.at("bank_frame_color");
	});

	control3CompView.decorator.nextLine;

	// Granulator Amplitude
	ampKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	ampKnob.mode =\vert;
	ampKnob.value = 0.5;
	ampKnob.action_({
		var control;
		control = ControlSpec(0, 1, \linear, 0.01);
		~set_granulator_amp.value(memory, control.map(ampKnob.value));
	});

	// Granulator Density Control
	grainDensityKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainDensityKnob.mode =\vert;
	grainDensityKnob.value = 0.5;
	grainDensityKnob.action_({
		var control;
		control = ControlSpec(1, 200, \exp, 0.1);
		~set_granulator_density.value(memory, control.map(grainDensityKnob.value));
	});

	// Base Duration of Grains
	grainBaseDurKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainBaseDurKnob.mode =\vert;
	grainBaseDurKnob.value = 0.5;
	grainBaseDurKnob.action_({
		var control;
		control = ControlSpec(0.05, 2, \exp, 0.01);
		~set_granulator_base_duration.value(memory, control.map(grainBaseDurKnob.value))
	});

	control3CompView.decorator.nextLine;

	// Duration randomization, playback rate, rate randomization label creation
	["Dur Rand", "PB Rate", "Rate Rand"].do({
		arg item, i;
		var label;
		label = StaticText(control3CompView, Rect(0, 0, hwidth-40/3, 30))
		.string_(item)
		.font_(style.at("text_font"))
		.align_(\center);
		label.background = style.at("bank_frame_color");
	});

	control3CompView.decorator.nextLine;

	// Grain Duration Randomization
	durRandKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	durRandKnob.mode =\vert;
	durRandKnob.value = 1;
	durRandKnob.action_({
		var control;
		control = ControlSpec(1, 0.005, \linear, 0.01);
		~set_granulator_duration_randomization.value(memory, control.map(durRandKnob.value));
	});

	// Grain Playback Rate
	grainRateKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainRateKnob.mode =\vert;
	grainRateKnob.value = 0.25; // set to start at 1
	grainRateKnob.action_({
		var control;
		control = ControlSpec(0.01, 4, \linear, 0.01);
		~set_granulator_rate.value(memory, control.map(grainRateKnob.value));
	});

	// Playback Rate Randomization
	grainRateRandKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainRateRandKnob.mode =\vert;
	grainRateRandKnob.value = 0.99;
	grainRateRandKnob.action_({
		var control;
		control = ControlSpec(0.01, 0.99, \linear, 0.01);
		~set_granulator_rate_randomization.value(memory, control.map(grainRateRandKnob.value))
	});

	control3CompView.decorator.nextLine;

	// Pan, pan randomization, pointer delay label creation
	["Pan", "Pan Rand", "Ptr Delay"].do({
		arg item, i;
		var label;
		label = StaticText(control3CompView, Rect(0, 0, hwidth-40/3, 30))
		.string_(item)
		.font_(style.at("text_font"))
		.align_(\center);
		label.background = style.at("bank_frame_color");
	});

	// Grainulator Pan
	grainPanKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainPanKnob.mode =\vert;
	grainPanKnob.value = 0.5;
	grainPanKnob.action_({
		var control;
		control = ControlSpec(-1, 1, \linear, 0.01);
		~set_granulator_pan.value(memory, control.map(grainPanKnob.value));
	});

	// Grain Pan Randomization
	grainPanRandKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainPanRandKnob.mode =\vert;
	grainPanRandKnob.value = 0.0;
	grainPanRandKnob.action_({
		var control;
		control = ControlSpec(0, 1, \linear, 0.01);
		~set_granulator_pan_randomization.value(memory, control.map(grainPanRandKnob.value));
	});

	// Grain Pointer Delay
	grainPtrDelayKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainPtrDelayKnob.mode =\vert;
	grainPtrDelayKnob.value = 0.5;
	grainPtrDelayKnob.action_({
		var control;
		control = ControlSpec(0, ~server.sampleRate * columns * memory.at(\seq_mem).at(\delta), \linear, 0.01);
		~set_granulator_pointer_sample_delay.value(memory, control.map(grainPtrDelayKnob.value))
	});

	// Pointer delay randomization, minimum pointer delay, and black hole label creation
	["Ptr Delay Rand", "Min Ptr Delay", "Black Hole"].do({
		arg item, i;
		var label;
		label = StaticText(control3CompView, Rect(0, 0, hwidth-40/3, 40))
		.string_(item)
		.font_(style.at("text_font"))
		.align_(\center);
		label.background = style.at("bank_frame_color");
	});

	// Grainulator Pointer Delay Randomization
	grainPtrDelayRandKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainPtrDelayRandKnob.mode =\vert;
	grainPtrDelayRandKnob.value = 0.5;
	grainPtrDelayRandKnob.action_({
		var control;
		control = ControlSpec(0, ~server.sampleRate * columns * memory.at(\seq_mem).at(\delta), \linear, 0.01);
		~set_granulator_pointer_sample_randomization.value(memory, control.map(grainPtrDelayRandKnob.value));
	});

	// Grain Minimum Pointer Delay
	grainMinPtrDelayKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainMinPtrDelayKnob.mode =\vert;
	grainMinPtrDelayKnob.value = 1000 / ~server.sampleRate;
	grainMinPtrDelayKnob.action_({
		var control;
		control = ControlSpec(1, ~server.sampleRate * columns * memory.at(\seq_mem).at(\delta), \linear, 0.01);
		~set_granulator_minimum_pointer_delay.value(memory, control.map(grainMinPtrDelayKnob.value));
	});

	// Black Hole Button. Sends the sequencers out to nowhere (but leaves it running for the
	// buffer writing. These leaves the granulator on 'reading' and processing the unheard
	// sequencer.
	blackHoleSeqButton = Button.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3))
	.states_([["On", Color.white, style.at("text_color")], ["Off", Color.white, Color.red]])
	.action_({
		if (blackHoleSeqButton.value == 1, {
			// Send the splitter out to the ether
			memory.at(\seq_mem).at(\granulatorSplitter).set(\out2, 110);
		}, {
			if (memory.at(\seq_mem).at(\reverb_on), {
				memory.at(\seq_mem).at(\granulatorSplitter).set(\out2, 99);
			}, {
				memory.at(\seq_mem).at(\granulatorSplitter).set(\out2, 0);
			});
		});
	});

	control3CompView;
};

~update_track_seq = {
	// Updates the track, giving one of the StaticText objects a random color and turning
	// off the previous index.
	arg index, track;
	if((index == 0), {
		{ track[1][index].background_(Color.rand) }.defer;
		{ track[1][track[1].size-1].background_(Color.white) }.defer;
	}, {
		{ track[1][index].background_(Color.rand) }.defer;
		{ track[1][index-1].background_(Color.white) }.defer;
	});
};

~build_control_name_seq = {
	// A helper function that builds a control name according to the name defined.
	arg memory, name;
	var str;
	str = memory.at(\seq_mem).at(\current_name) ++ "_" ++ name;
	str.asSymbol;
};

~set_buttons_sliders_numBoxes_seq = {
	// Function that sets specific sliders/buttons/menus that should update when the
	// tab button changes.
	arg memory;
	var control_name;
	memory.at(\seq_mem).at(\noteDurationSlider).value = memory.at(\seq_mem).at(~build_control_name_seq.value(memory, \sus));
	memory.at(\seq_mem).at(\volumeSlider).value = memory.at(\seq_mem).at(~build_control_name_seq.value(memory, \amp));
	memory.at(\seq_mem).at(\instrumentMenu).value = memory.at(\seq_mem).at(~build_control_name_seq.value(memory, \instrument) ++ '_idx');
};

~build_level_indicator = {
	arg input, container, width, height;
	var bus, indicator, updateIndicator, soundSynth, val;

	container.onClose_({   // stop routine when the window is closed
		updateIndicator.stop;
		updateIndicator.free
	});

	bus = Bus.control();
	bus.postln;
	soundSynth = Synth(\levelIndicator_1ch, [\input, input, \bus, bus], addAction: 'addToTail');

	indicator = LevelIndicator(container, Rect(0,0,width,height))
	.warning_(0.5)           // set warning level
	.critical_(0.7)          // set critical level
	.background_(Color.white) // set Color
	.drawsPeak_(true)
	.style_('\led')
	.stepWidth_(3);       // draw Peak Values

	// update the Indicator's value with a routine
	updateIndicator = fork{
		loop{
			bus.get({   // get current value from the bus
				arg value;
				{
					indicator.value_(value);     // set Indicator's value
					indicator.peakLevel_(value); // set Indicator's peak value
				}.defer(); // schedule in the AppClock
			});
			0.01.wait; // indicator will be updated every 0.01 seconds
		}
	};

};

)


