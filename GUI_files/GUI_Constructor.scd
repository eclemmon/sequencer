//// GUI CONSTRUCTOR
(
~build_window = {
	arg window_title, style, width, height;
	Window(window_title, Rect(10, 10, width, height))
	.background_(style.at("window_color"))
	.front;
};

~build_top_level = {
	arg window, width, height, style;
	var compView = CompositeView(window, Rect(10, 10, width, height))
	.background_(style.at("top_level_frame_color"));
	compView.addFlowLayout(10@10);
	compView.decorator.gap_(0@10);
	compView;
};

~build_sequencer_header = {
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

~build_sequencer_tab_buttons = {
	arg top_level, stack, buttons;
	buttons = buttons.collect({ arg item;
		var button;
		button = Button(top_level, 100@40)
		.states_([[item, Color.black, Color.white], [item, Color.white, Color.black]]);
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

~build_sequencer_tabbed_stack = {
	arg top_level, sequencer_tab_buttons, width, height, num_tab_buttons, buttonsize, columns, rows, style, memory;
	var view, stack, buttonsStacked, compViews;

	view = View(top_level, Rect(0, 0, width, height));
	view.background = style.at("bank_frame_color");

	buttonsStacked = Array.fill(num_tab_buttons, {arg i; ~build_sequencer_buttons.value(view, buttonsize*columns, buttonsize*rows, style, columns, rows, buttonsize)});

	compViews = Array.fill(num_tab_buttons, {arg i; buttonsStacked[i][0]});
	compViews.postln;

	view.layout = VLayout(
		stack = StackLayout(
			*compViews;
		);
	);

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
		});

	});

	top_level.decorator.nextLine;
	buttonsStacked;
};

~build_track_buttons_container = {
	arg top_level, width, height, style;
	var compView = CompositeView(top_level, Rect(0, 0, width, height))
	.background_(style.at("top_level_frame_color"));
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);
	compView;
};

~build_sequencer_track = {
	arg top, hwidth, hheight, style, columns, buttonsize;
	var trackCompView, array, sequencer_track_data;

	// Track Composite View
	trackCompView = CompositeView(top, Rect(0, 0, buttonsize*columns+20, hheight-20));
	trackCompView.background = style.at("bank_frame_color");

	// Sequencer Track
	array = Array.fill(columns, { arg i;
		StaticText(trackCompView, Rect(i * buttonsize + 10, 10, buttonsize, buttonsize-20))
		.background_(Color.white)
	});

	top.decorator.nextLine;

	sequencer_track_data = [trackCompView, array]
};

~build_sequencer_buttons = {
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


~build_sequencer_control_panel_1 = {
	arg top, hwidth, hheight, style, instruments=[\default], butCompViews, memory;
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
		Pdefn(\p_delta, control.map(memory.at(\seq_mem).at(\delta)));
		speedNumberBox.value_(memory.at(\seq_mem).at(\delta));
	});

	noteDurationSlider.action_({
		var control, control_name, pdef_name;
		control = ControlSpec(0.1, 4, \linear, 0.1);
		control_name = ~build_control_name.value(memory, \sus);
		pdef_name = \p_ ++ control_name;
		memory.at(\seq_mem).put(control_name, noteDurationSlider.value);
		Pdefn(pdef_name.asSymbol, control.map(memory.at(\seq_mem).at(control_name)));
		noteDurationBox.value_(control.map(memory.at(\seq_mem).at(control_name)));
	});

	// Slider Control
	volumeSlider.action_({
		var control, control_name, pdef_name;
		control = ControlSpec(0, 0.7, \linear, 0.01);
		control_name = ~build_control_name.value(memory, \amp);
		pdef_name = \p_ ++ control_name;
		memory.at(\seq_mem).put(control_name, volumeSlider.value);
		Pdefn(pdef_name.asSymbol, control.map(memory.at(\seq_mem).at(control_name)));
		volumeNumberBox.value_(control.map(memory.at(\seq_mem).at(control_name)));
	});

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

	// Instrument Selection Label
	instrumentMenu = PopUpMenu(compView, Rect(0, 10, hwidth-25, 30));
	instrumentMenu.items = instruments;
	instrumentMenu.value_(0);
	instrumentMenu.action_({
		arg menu;
		var control_name, pdef_name;
		control_name = ~build_control_name.value(memory, \instrument);
		pdef_name = \p_ ++ control_name;
		memory.at(\seq_mem).put(control_name, menu.item);
		Pdefn(pdef_name.asSymbol, menu.item);
	});

	compView.decorator.nextLine;

	// Clear Sequencer Button
	clearButton = Button(compView, Rect(0, 10, hwidth-25, 30));
	clearButton.string = "clear sequencer";

	clearButton.action_({
		butCompViews.do({
			arg butCompView;
			butCompView[0].postln;
			butCompView[0].children(Button).do({
				arg item, i;
				if(item.value == 1, {item.valueAction = 0;})
			});
		});
	});

	compView;
};

~build_sequencer_control_panel_2 = {
	arg top, hwidth, hheight, style, buttonsize, memory, stacked_buttons, reverb, track;
	var control2CompView, octaveLabel, minusOctBut, plusOctBut, quantLabel, quantSlider, quantNumberBox, mixKnob, roomKnob, dampKnob, reverbButton, outDevices, inDevices, inDevicesSelector, outDevicesSelector, outDevice, inDevice, inDevicesSelectorText, outDevicesSelectorText;

	outDevices = ["Default"] ++ ServerOptions.outDevices;
	inDevices = ["Default"] ++ ServerOptions.inDevices;
	outDevice = "Default";
	inDevice = "Default";


	// Control Comp View 2
	control2CompView = CompositeView(top, Rect(0, 0, hwidth, hheight));
	control2CompView.background = style.at("bank_frame_color");
	control2CompView.addFlowLayout(10@10);
	control2CompView.decorator.gap_(10@10);

	// Octave  Label
	octaveLabel = StaticText(control2CompView, Rect(0, 0, hwidth-20, 30))
	.string_("Octave")
	.font_(style.at("text_font"))
	.align_(\center);
	octaveLabel.background = style.at("window_color");
	octaveLabel.stringColor = Color.white;

	control2CompView.decorator.nextLine;

	// Octave Buttons
	minusOctBut = Button(control2CompView, 80@40);
	minusOctBut.string = "-";

	plusOctBut = Button(control2CompView, 80@40);
	plusOctBut.string = "+";

	// Octave Button Actions
	minusOctBut.action_({
		var cn_octave, pdef_name;
		cn_octave = ~build_control_name.value(memory, \octave);
		pdef_name = \p_ ++ cn_octave;
		memory.at(\seq_mem).put(cn_octave, memory.at(\seq_mem).at(cn_octave) - 1);
		Pdefn(pdef_name.asSymbol, memory.at(\seq_mem).at(cn_octave.asSymbol))
	});

	plusOctBut.action_({
		var cn_octave, pdef_name;
		cn_octave = ~build_control_name.value(memory, \octave);
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
			memory.at(\seq_mem).put(\pattern_out, 99);
			memory.at(\seq_mem).put(\reverb_on, true)

		}, {
			memory.at(\seq_mem).put(\pattern_out, 0);
			memory.at(\seq_mem).put(\reverb_on, false)
		});
		Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out));
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

	// In and Out Selectors
	inDevicesSelectorText = StaticText(control2CompView, 170/3@30)
	.string_("In")
	.stringColor_(Color.white)
	.background_(style.at("window_color"))
	.align_(\center);

	inDevicesSelector = PopUpMenu(control2CompView, (170/3*2-10)@30)
	.items_(inDevices)
	.action_({arg deviceName;
		deviceName.item.postln;
		Server.default.options.inDevice = deviceName.item;
	});

	outDevicesSelectorText = StaticText(control2CompView, 170/3@30)
	.string_("Out")
	.stringColor_(Color.white)
	.background_(style.at("window_color"))
	.align_(\center);

	outDevicesSelector = PopUpMenu(control2CompView, (170/3*2-10)@30)
	.items_(outDevices)
	.action_({arg deviceName;
		deviceName.item.postln;
		Server.default.options.outDevice = deviceName.item;
	});
};

~build_sequencer_control_panel_3 = {
	arg top, hwidth, hheight, style, memory, granulator;
	var control3CompView, granulatorLabel, granulatorOnButton, ampKnob, grainLengthKnob, playBackRateKnob, posChangeRateKnob, panChangeRateKnob;

	// Control Comp View 3
	control3CompView = CompositeView(top, Rect(0, 0, hwidth, hheight));
	control3CompView.background = style.at("bank_frame_color");
	control3CompView.addFlowLayout(10@10);
	control3CompView.decorator.gap_(10@10);

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

	// Trigger Rate
	ampKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	ampKnob.mode =\vert;
	ampKnob.value = 0.5;
	ampKnob.action_({
		var control;
		control = ControlSpec(0, 1, \linear, 0.01);
		~set_granulator_amp.value(memory, control.map(ampKnob.value));
	});

	// Grain Length
	grainLengthKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	grainLengthKnob.mode =\vert;
	grainLengthKnob.value = 0.5;
	grainLengthKnob.action_({
		var control;
		control = ControlSpec(0.05, 1, \linear, 0.01);
		granulator.set(\dur, control.map(grainLengthKnob.value));
	});

	// Playback Rate
	playBackRateKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-40/3, hwidth-40/3));
	playBackRateKnob.mode =\vert;
	playBackRateKnob.value = 0.5;
	playBackRateKnob.action_({
		var control;
		control = ControlSpec(-3, 3, \linear, 0.01);
		granulator.set(\rate, control.map(playBackRateKnob.value));
	});

	control3CompView.decorator.nextLine;

	["PB Pos Rate", "Pan Change Rate"].do({
		arg item, i;
		var label;
		label = StaticText(control3CompView, Rect(0, 0, hwidth-30/2, 30))
		.string_(item)
		.font_(style.at("text_font"))
		.align_(\center);
		label.background = style.at("bank_frame_color");
	});

	control3CompView.decorator.nextLine;

	// rate of change in Play back position for the gran to start
	posChangeRateKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-30/2, hwidth-40/3));
	posChangeRateKnob.mode =\vert;
	posChangeRateKnob.value = 0.5;
	posChangeRateKnob.action_({
		var control;
		control = ControlSpec(0.1, 2, \linear, 0.01);
		granulator.set(\posChangeRate, control.map(posChangeRateKnob.value));
	});

	// Pan Controls
	panChangeRateKnob = Knob.new(control3CompView, Rect(0, 0, hwidth-30/2, hwidth-40/3));
	panChangeRateKnob.mode =\vert;
	panChangeRateKnob.value = 0.5;
	panChangeRateKnob.action_({
		var control;
		control = ControlSpec(0, 2, \linear, 0.01);
		granulator.set(\posChangeRate, control.map(panChangeRateKnob.value));
	});
};

~volume_midi_control = {
	arg object, val;
	object.children().at(1).value_(val/127);
	object.children().at(2).value_(val/127);
};

~knob_midi_control = {
	arg object, index, val;
	object.children(Knob).at(index).value_(val/127);
};

~button_midi_control = {
	arg object, index;
	object.children(Button).at(index).doAction;
};

~bend_midi_control = {
	arg object, val;
	object.children().at(1).value_(val/16383);
	object.children().at(2).value_(val/16383);
};

~update_track = {
	arg index, track;
	if((index == 0), {
		{ track[1][index].background_(Color.rand) }.defer;
		{ track[1][track[1].size-1].background_(Color.white) }.defer;
	}, {
		{ track[1][index].background_(Color.rand) }.defer;
		{ track[1][index-1].background_(Color.white) }.defer;
	});
};

~build_control_name = {
	arg memory, name;
	var str;
	str = memory.at(\seq_mem).at(\current_name) ++ "_" ++ name;
	str.asSymbol;
};

)


