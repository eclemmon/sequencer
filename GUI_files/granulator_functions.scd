(

~turn_granulator_on = {
	arg memory;
	// Initialize granulator synth def
	memory.at(\seq_mem).put(\granulatorSequencer,
		Synth(\granulatorSequencer, [
			\amp, memory.at(\seq_mem).at(\granAmp),
			\out, memory.at(\seq_mem).at(\granOut),
			\buf, memory.at(\seq_mem).at(\buffer),
			\attack, memory.at(\seq_mem).at(\granAttack),
			\release, memory.at(\seq_mem).at(\granRelease),
			\gate, 1,
			\sync, memory.at(\seq_mem).at(\granSync),
			\density, memory.at(\seq_mem).at(\granDensity),
			\baseDur, memory.at(\seq_mem).at(\granBaseDur),
			\durRand, memory.at(\seq_mem).at(\granDurRand),
			\rate, memory.at(\seq_mem).at(\granRate),
			\rateRand, memory.at(\seq_mem).at(\granRateRand),
			\pan, memory.at(\seq_mem).at(\granPan),
			\panRand, memory.at(\seq_mem).at(\granPanRand),
			\grainEnv, memory.at(\seq_mem).at(\granEnv),
			\ptrBus, memory.at(\seq_mem).at(\ptrBus),
			\ptrSampleDelay, memory.at(\seq_mem).at(\granPtrSampleDelay),
			\ptrRandSamples, memory.at(\seq_mem).at(\granPtrRandSamples),
			\minPtrDelay, memory.at(\seq_mem).at(\granMinPtrDelay)
		], memory.at(\seq_mem).at(\granGroup))
	);
};

~turn_granulator_off = {
	arg memory;
	memory.at(\seq_mem).at(\granulatorSequencer).set(\gate, 0);
	memory.at(\seq_mem).put(\granulatorSequencer, nil)
};

~set_granulator_amp = {
	arg memory, val;
	memory.at(\seq_mem).put(\granAmp, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\amp, memory.at(\seq_mem).at(\granAmp));
};

~set_granulator_out = {
	arg memory, val;
	memory.at(\seq_mem).put(\granOut, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\out, memory.at(\seq_mem).at(\granOut));
};

~set_granulator_attack = {
	arg memory, val;
	memory.at(\seq_mem).put(\granAttack, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\attack, memory.at(\seq_mem).at(\granAttack));
};

~set_granulator_release = {
	arg memory, val;
	memory.at(\seq_mem).put(\granRelease, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\release, memory.at(\seq_mem).at(\granRelease));
};

~set_granulator_sync = {
	arg memory, val;
	memory.at(\seq_mem).put(\granSync, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\sync, memory.at(\seq_mem).at(\granSync));
};

~set_granulator_density = {
	arg memory, val;
	memory.at(\seq_mem).put(\granDensity, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\density, memory.at(\seq_mem).at(\granDensity));
};

~set_granulator_base_duration = {
	arg memory, val;
	memory.at(\seq_mem).put(\granBaseDur, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\baseDur, memory.at(\seq_mem).at(\granBaseDur));
};

~set_granulator_duration_randomization = {
	arg memory, val;
	memory.at(\seq_mem).put(\granDurRand, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\durRand, memory.at(\seq_mem).at(\granDurRand));
};

~set_granulator_rate = {
	arg memory, val;
	memory.at(\seq_mem).put(\granRate, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\rate, memory.at(\seq_mem).at(\granRate));
};

~set_granulator_rate_randomization = {
	arg memory, val;
	memory.at(\seq_mem).put(\granSync, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\out, memory.at(\seq_mem).at(\granSync));
};

~set_granulator_pan = {
	arg memory, val;
	memory.at(\seq_mem).put(\granPan, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\pan, memory.at(\seq_mem).at(\granPan));
};

~set_granulator_pan_randomization = {
	arg memory, val;
	memory.at(\seq_mem).put(\granPanRand, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\panRand, memory.at(\seq_mem).at(\granPanRand));
};

~set_granulator_grain_envelope = {
	arg memory, val;
	memory.at(\seq_mem).put(\granGrainEnv, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\grainEnv, memory.at(\seq_mem).at(\granGrainEnv));
};

~set_granulator_pointer_sample_delay = {
	arg memory, val;
	memory.at(\seq_mem).put(\granPtrSampleDelay, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\ptrSampleDelay, memory.at(\seq_mem).at(\granPtrSampleDelay));
};

~set_granulator_pointer_sample_randomization = {
	arg memory, val;
	memory.at(\seq_mem).put(\granPtrRandSamples, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\ptrRandSamples, memory.at(\seq_mem).at(\granPtrRandSamples));
};

~set_granulator_minimum_pointer_delay = {
	arg memory, val;
	memory.at(\seq_mem).put(\granMinPtrDelay, val);
	memory.at(\seq_mem).at(\granulatorSequencer).set(\minPtrDelay, memory.at(\seq_mem).at(\granMinPtrDelay));
};

)

