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
	arg top_level, sequencer_tab_buttons, width, height, num_tab_buttons, buttonsize, columns, rows, style;
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
		var control;
		control = ControlSpec(0.1, 4, \linear, 0.1);
		memory.at(\seq_mem).put(\sus, noteDurationSlider.value);
		Pdefn(\p_sus, control.map(memory.at(\seq_mem).at(\sus)));
		noteDurationBox.value_(control.map(memory.at(\seq_mem).at(\sus)));
	});

	// Slider Control
	volumeSlider.action_({
		var control;
		control = ControlSpec(0, 0.7, \linear, 0.01);
		memory.at(\seq_mem).put(\amp, volumeSlider.value);
		memory.at(\seq_mem).at(\amp).postln;
		Pdefn(\p_amp, control.map(memory.at(\seq_mem).at(\amp)));
		volumeNumberBox.value_(control.map(memory.at(\seq_mem).at(\amp)));
	});

	compView.decorator.nextLine;

	// Scale Selection label
	scaleMenuLabel = StaticText(compView, Rect(0, 10, 130, 30))
	.string_("Scale Type")
	.font_(style.at("text_font"))
	.align_(\center);
	scaleMenuLabel.background = style.at("window_color");
	scaleMenuLabel.stringColor = Color.white;

	compView.decorator.nextLine;

	// Scale Selection Menu
	scaleMenu = PopUpMenu(compView, Rect(0, 10, 130, 30));
	scaleMenu.items = Scale.names;
	scaleMenu.value_(Scale.names.indexOf(\major));
	scaleMenu.action_({
		arg menu;
		Pdefn(\p_scale, Scale.at(menu.item));
	});

	compView.decorator.nextLine;

	// Instrument Selection Label
	instrumentLabel = StaticText(compView, Rect(0, 10, 130, 30))
	.string_("Instrument")
	.font_(style.at("text_font"))
	.align_(\center);
	instrumentLabel.background = style.at("window_color");
	instrumentLabel.stringColor = Color.white;

	compView.decorator.nextLine;

	// Instrument Selection Label
	instrumentMenu = PopUpMenu(compView, Rect(0, 10, 130, 30));
	instrumentMenu.items = instruments;
	instrumentMenu.value_(0);
	instrumentMenu.action_({
		arg menu;
		// [menu.item, menu.value].postln;
		memory.at(\seq_mem).put(\instrument, menu.item);
		Pdefn(\p_instrument, menu.item);
	});

	compView.decorator.nextLine;

	// Clear Sequencer Button
	clearButton = Button(compView, Rect(0, 10, 130, 30));
	clearButton.string = "clear sequencer";

	clearButton.action_({
		butCompViews.do({
			arg butCompView;
			butCompView[0].postln;
			butCompView[0].children(Button).do({
			arg item, i;
			if(item.value == 1, {item.valueAction = 0;})});
		});
	});

	compView;
};

~build_sequencer_control_panel_2 = {
	arg top, hwidth, hheight, style, buttonsize, memory, array, reverb;
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
		memory.at(\seq_mem).put(\currentOctave, memory.at(\seq_mem).at(\currentOctave) - 7);

		Pdefn(\pattern, Ppar(array.collect({
			arg c, r;
			var currentOctaveDegree = array.size - r - 1 + memory.at(\seq_mem).at(\currentOctave);
			Pbind(
				\instrument, Pdefn(\p_instrument, memory.at(\seq_mem).at(\instrument)),
				\scale, Pdefn(\p_scale, Scale.at(memory.at(\seq_mem).at(\scale))),
				\degree, Pif(Pseq(array[r], inf).coin, currentOctaveDegree, \rest),
				\dur, Pdefn(\p_dur, memory.at(\seq_mem).at(\dur)),
				\amp, Pdefn(\p_amp, memory.at(\seq_mem).at(\amp)),
				\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
							\track_index, Pdefn(\p_track_index, Pseq((0..15), inf)),
			\track_func, Pdefn(\p_track_func, Pfunc({|ev| ~update_track.value(ev.track_index)}));
		)}), inf));
	});

	plusOctBut.action_({
		memory.at(\seq_mem).put(\currentOctave, memory.at(\seq_mem).at(\currentOctave) + 7);

		Pdefn(\pattern, Ppar(array.collect({
			arg c, r;
			var currentOctaveDegree = array.size - r - 1 + memory.at(\seq_mem).at(\currentOctave);
			Pbind(
				\instrument, Pdefn(\p_instrument, memory.at(\seq_mem).at(\instrument)),
				\scale, Pdefn(\p_scale, Scale.at(memory.at(\seq_mem).at(\scale))),
				\degree, Pif(Pseq(array[r], inf).coin, currentOctaveDegree, \rest),
				\dur, Pdefn(\p_dur, memory.at(\seq_mem).at(\dur)),
				\amp, Pdefn(\p_amp, memory.at(\seq_mem).at(\amp)),
				\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
				\track_index, Pdefn(\p_track_index, Pseq((0..15), inf)),
				\track_func, Pdefn(\p_track_func, Pfunc({|ev| ~update_track.value(ev.track_index)}));
		)}), inf))
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

		}, {
			memory.at(\seq_mem).put(\pattern_out, 0);
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
)


