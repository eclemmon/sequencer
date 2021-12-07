// SynthDefs
(
// Granulator, buffer, pointer and input synthedefs
// H/t Eli Fieldsteel!
SynthDef.new(\inputRouter, {
	// Routes one input bus to an output, also allows for amplitude control.
	arg in=0, out=0, amp=1;
	var sig;
	sig = In.ar(in) * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\pointer, {
	// A pointer, written to a bus that 'trails' the realtime "head" of an audio bus.
	arg out=0, buf=0;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

SynthDef.new(\recordBuffer, {
	// Records a signal into a buffer from the pointer's position.
	arg ptrIn=0, recIn=0, buf=0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(recIn, 1);
	BufWr.ar(sig, buf, ptr);
}).add;

SynthDef.new(\granulatorSplitter, {
	// A helper audio bus splitter to send one audio inout to two audio buses out.
	arg in=10, out1=89, out2=99;
	var input;
	input = In.ar(in, 2);
	Out.ar([out1, out2], input);
}).add;

SynthDef.new(\granulatorSequencer, {
	// Granulator for the sequencer.
	arg amp=0.5, out=0, buf=0, attack=1, release=1, gate=1, sync=1, density=40, baseDur=0.05, durRand=1, rate=1, rateRand=1, pan=0, panRand=0, grainEnv=(-1), ptrBus=0, ptrSampleDelay=20000, ptrRandSamples=5000, minPtrDelay=1000;
	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl, ptr, ptrRand, totalDelay, maxGrainDur, grain;

	env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction:2);
	densCtrl = Select.ar(sync, [Dust.ar(density), Impulse.ar(density)]);
	durCtrl = baseDur * LFNoise1.ar(100).exprange(1/durRand, durRand);
	rateCtrl = rate * LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
	totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	ptr = In.ar(ptrBus, 1);
	ptr = ptr - totalDelay;
	ptr = ptr / BufFrames.kr(buf);

	maxGrainDur = (totalDelay / rateCtrl) /SampleRate.ir;
	durCtrl = min(durCtrl, maxGrainDur);

	grain = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		rateCtrl,
		ptr,
		2,
		panCtrl,
		grainEnv
	);

	sig = grain * env * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\hpf, {
	// 1ch Resonant highpass filter.
	arg amp=1, input=99, output=0, freq, rq;
	var hpf, sig, in;
	in = In.ar(input);
	hpf = RHPF.ar(in, freq, rq, mul: 1/rq.sqrt);
	sig = hpf * amp;
	Out.ar(output, sig);
}).add;

SynthDef.new(\lpf, {
	// 1ch Resonant lowpass filter
	arg amp=1, input=99, output=0, freq, rq;
	var lpf, sig, in;
	in = In.ar(input);
	lpf = RLPF.ar(in, freq, rq, mul: 1/rq.sqrt);
	sig = lpf * amp;
	Out.ar(output, sig);
}).add;

SynthDef.new(\lpf_2ch, {
	// 2ch Resonant lowpass filter
	arg amp=1, input=99, output=0, freq, rq;
	var lpf, sig, in;
	in = In.ar(input, 2);
	lpf = RLPF.ar(in, freq, rq, mul: 1/rq.sqrt;);
	sig = lpf * amp;
	Out.ar(output, sig);
}).add;

SynthDef(\delay_1ch, {
	// 1ch delay line with no feedback
	arg delaytime=0.6, output=0, input=99, amp=0.2;
	var in = In.ar(input, 1);
	var effect = DelayN.ar(in, delaytime, delaytime, amp);
	Out.ar(output, effect);
}).add;

SynthDef(\delay_2ch, {
	// 2ch delay line with no feedback
	arg delaytime=0.6, output=0, input=99, amp=0.2;
	var in = In.ar(input, 2);
	var effect = DelayN.ar(in, delaytime, delaytime, amp);
	Out.ar(output, effect);
}).add;

SynthDef.new(\sin_tone_sequencer, {
	// a sine tone synth
	arg freq=440, amp=1, bend=0, out=0, dur=1, gate=0;
	var sig, env;
	sig = SinOsc.ar(freq * bend.midiratio)!2;
	env = EnvGen.kr(Env.adsr(attackTime: 0.01), gate: gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\peep_sequencer,{
	// a sine tone peep.
	arg freq=100, amp=0.5, out=0, gate=0;
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.perc(0.001,0.25), gate: gate, doneAction:2) * amp;
	Out.ar(out, snd ! 2);
}).add;

SynthDef.new(\subtract_noise_synth_sequencer, {
	// A synth that generates windy-sounding pitches via subtractive synthesis
	arg out=0, amp=1, freq=440, texture_speed=5, attack=0.1, texture_dur=0.4, trig=0, dur=15, rq=0.001, pos=0, gate=0;
	var noise, rand_amp, filter, texture_trig, env, texture, pan;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	noise = ClipNoise.ar(1);
	rand_amp = LFNoise0.kr(0.5 + LFNoise0.kr(10).range(-0.1, 0.5));
	filter = RLPF.ar(noise*rand_amp, freq, rq: rq, mul: 0.1/rq.sqrt) * env;
	pan = Pan2.ar(filter, pos, amp * 0.5);
	Out.ar(out, pan);
}).add;

SynthDef(\sin_fb_synth_sequencer, {
	// Sin feedback synth
	arg out, gate=0, freq=440, amp=2, feedback_start=0.5, feedback_peak=1.0, texture_dur=0.1;
	var env, sig, lfo, sinfb, pan, feedback_env, texture_trig;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	feedback_env = EnvGen.kr(Env([feedback_start+0.01, feedback_peak, feedback_start+0.01], [texture_dur/2, texture_dur/2], curve: 'wel'), gate: gate);
	lfo = SinOsc.kr(0.2, mul: 1);
	sinfb = SinOscFB.ar(freq, feedback: feedback_env);
	sig = sinfb * env;
	pan = Pan2.ar(sig, pos: lfo, level: amp);
	Out.ar(out, pan);
}).add;

SynthDef.new(\reverb, {
	// 2 channel reverb
	arg input=99, output=0, mix=0, room=0, damp=0, amp=1;
	var in, sig;
	in = In.ar(input, 2);
	sig = FreeVerb2.ar(in[0], in[1], mix, room, damp, amp);
	Out.ar(output, sig);
}).add;

SynthDef.new(\buzzy_bram_sequencer, {
	// Buzzy saw wave synth with a lpf to take the edge off and a sin wave to assert the fundamental
	arg amp=1, out=0, freq=440, bend=0, rq=0.5, dur=1, gate=0;
	var pan, sig, trigger, saw, lpf, env;
	saw = LFSaw.ar(freq * bend.midiratio, mul:0.7)!2;
	lpf = RLPF.ar(saw, 1000, rq, 1/rq.sqrt);
	env = EnvGen.kr(Env.adsr, gate: gate, doneAction:2);
	sig = SinOsc.ar(freq * bend.midiratio) * amp * env * lpf;
	Out.ar(out, sig);
}).add;

SynthDef(\phase_mod_sequencer, {
	// A complicated phase mod instrument. Good for higher notes + very low notes. Souonds better with long tails as the instrument is designed to develop gracefully over long periods of time.
	arg amp, out=0, dur=3, attack=0.1, release=0.1, decay_time=0.1, decay_amp=0.7, freq=440, fmod_freq=533, fmod_mul=12, sustain_freq=660, pos=0, filter_env_start_freq=880, filter_env_end_freq=440, filter_sus_dur=1, filter_decay_dur=0.1, filter_release_time=0.1, tail_length=1, tail_length_level=0.1, mRatio=1, cRatio=1, gate=0;
	var pan, sig, env, filter, carrier, modulator, fmod_env, filter_env, lfo_amp;

	// Control Envelopes
	env = EnvGen.kr(
		Env([0,1,decay_amp,1,0],
			[attack, decay_time, dur-attack-release-decay_time-tail_length, tail_length],
			curve: ['wel', -2.0, -3, 0, -4],
		),
		gate: gate,
		doneAction: Done.freeSelf);
	fmod_env = EnvGen.kr(
		Env([0,1,1,tail_length_level,tail_length_level, 0],
			[attack, (dur/2)-attack-(tail_length/2)-0.1, tail_length, (dur/2)-(tail_length/2), 0.1],
			curve: 'wel',
		));
	filter_env = EnvGen.kr(
		Env([0.1, filter_env_start_freq, sustain_freq, sustain_freq, filter_env_end_freq],
			[attack, filter_decay_dur, filter_sus_dur-attack-filter_decay_dur-release, filter_release_time],
			curve: -3,
		));

	lfo_amp = (SinOsc.kr(0.5, mul: 0.5, add: 1) + SinOsc.kr(0.3, mul: 0.2, add: 1))*0.05;

	// Modulator and Carrier
	modulator = SinOsc.ar(freq * mRatio, mul: fmod_mul) * (fmod_env);
	carrier = SinOsc.ar(freq * cRatio, modulator.wrap(0,4pi), mul: 1 + lfo_amp);

	// Build signal
	sig = carrier * env;
	filter = LPF.ar(sig, filter_env);
	pan = Pan2.ar(filter, pos: pos, level: amp);
	Out.ar(out, pan);
}).add;
)

