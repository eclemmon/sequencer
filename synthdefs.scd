// SynthDefs
(

SynthDef.new(\recordBufSequencer, {
	arg input=0, buffer, loop=1, run=1, trigger=1, recLevel=1.0, preLevel = 0.0;
	var record;
	record = RecordBuf.ar(SoundIn.ar(input),
		buffer,
		recLevel: recLevel,
		preLevel: preLevel,
		loop: loop,
		run: run,
		trigger: trigger);
}).add;

// H/t Eli Fieldsteel!
SynthDef.new(\inputRouter, {
	arg in=0, out=0, amp=1;
	var sig;
	sig = In.ar(in) * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\pointer, {
	arg out=0, buf=0;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

SynthDef.new(\recordBuffer, {
	arg ptrIn=0, recIn=0, buf=0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(recIn, 1);
	BufWr.ar(sig, buf, ptr);
}).add;

SynthDef.new(\granulatorSplitter, {
	arg in=10, out1=89, out2=99;
	var input;
	input = In.ar(in, 2);
	Out.ar([out1, out2], input);
}).add;

SynthDef(\granulatorSequencer, {
	arg out, triggerRate=10, dur=0.1, sndbuf, rate=1, posChangeRate=5, interp=2, panRate=0, amp=1;
	var gran, trigger, pos, pan;
	trigger = Dust.kr(triggerRate);
	pos = Dust.kr(posChangeRate);
	pan = LFNoise1.kr(10);
	gran = GrainBuf.ar(2, trigger, dur, sndbuf, pos, interp, 2, pan, mul: amp);
	Out.ar(out, gran);
}).add;

SynthDef.new(\hpf, {
	arg amp=1, input=99, output=0, freq, rq;
	var hpf, sig, in;
	in = In.ar(input);
	hpf = RHPF.ar(in, freq, rq, mul: 1/rq.sqrt;);
	sig = hpf * amp;
	Out.ar(output, sig);
}).add;

SynthDef.new(\lpf, {
	arg amp=127, input=99, output=0, freq, rq;
	var hpf, sig, in;
	in = In.ar(input);
	hpf = RLPF.ar(in, freq, rq, mul: 1/rq.sqrt;);
	sig = hpf * amp.linlin(0, 127, 0, 1);
	Out.ar(output, sig);
}).add;

SynthDef.new(\lpf_2ch, {
	arg amp=127, input=99, output=0, freq, rq;
	var lpf, sig, in;
	in = In.ar(input, 2);
	lpf = RLPF.ar(in, freq, rq, mul: 1/rq.sqrt;);
	sig = lpf * amp.linlin(0, 127, 0, 1);
	Out.ar(output, sig);
}).add;

SynthDef(\delay_1ch, {
	arg delaytime=0.6, output=0, input=99, amp=0.2;
	var in = In.ar(input, 1);
	var effect = DelayN.ar(in, delaytime, delaytime, amp);
	Out.ar(output, effect);
}).add;

SynthDef(\delay_2ch, {
	arg delaytime=0.6, output=0, input=99, amp=0.2;
	var in = In.ar(input, 2);
	var effect = DelayN.ar(in, delaytime, delaytime, amp);
	Out.ar(output, effect);
}).add;

SynthDef(\audio_router_2ch, {
	arg amp, input=0, output=0;
	var in;
	in = In.ar(input, 2);
	Out.ar(output, in);
}).add;

SynthDef.new(\ringModOctaver, {
	// credit David Siah & Miller Puckette
	arg amp, input=99, output=0, octave=0.5;
	var in, freq, hasFreq, sig;
	in = In.ar(input, 1);
	# freq, hasFreq = Pitch.kr(in, median:7, execFreq: 1);
	sig = SinOsc.ar(freq: freq * octave) * in + in;
	Out.ar(output, sig * amp);
}).add;

SynthDef.new(\sin_tone, {
	arg freq=440, amp=1, gate=0, bend=0;
	var sig, env;
	sig = SinOsc.ar(freq * bend.midiratio)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;

SynthDef.new(\sin_tone_sequencer, {
	arg freq=440, amp=1, bend=0, out=0, dur=1;
	var sig, env;
	sig = SinOsc.ar(freq * bend.midiratio)!2;
	env = EnvGen.kr(Env.perc(releaseTime: dur+0.5), doneAction:2);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\peep_sequencer,{
	arg freq=100, amp=0.5, out=0;
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.perc(0.001,0.25), doneAction:2) * amp;
	Out.ar(out, snd ! 2);
}).add;

SynthDef.new(\buzzy_bram, {
	arg amp=20, out=0, freq=440, gate=0, bend=0, rq=0.5;
	var pan, sig, trigger, saw, lpf, env;
	saw = LFSaw.ar(freq * bend.midiratio, mul:0.7)!2;
	lpf = RLPF.ar(saw, 1000, rq, 1/rq.sqrt);
	env = EnvGen.kr(Env.adsr, gate, doneAction:2) * 1.5;
	sig = SinOsc.ar(freq * bend.midiratio) * amp * env * lpf;
	Out.ar(out, sig);
}).add;

SynthDef.new(\subtract_noise_synth, {
	arg out=0, amp=1, freq=440, texture_speed=5, attack=0.1, texture_dur=0.4, trig=0, dur=15, rq=0.001, pos=0, gate=0;
	var noise, rand_amp, filter, texture_trig, env, texture, pan;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	noise = ClipNoise.ar(1);
	rand_amp = LFNoise0.kr(0.5 + LFNoise0.kr(10).range(-0.1, 0.5));
	filter = RLPF.ar(noise*rand_amp, freq, rq: rq, mul: 0.1/rq.sqrt) * env;
	pan = Pan2.ar(filter, pos, amp * 0.5);
	Out.ar(out, pan);
}).add;

SynthDef(\sin_fb_synth, {
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

SynthDef(\phase_mod, {
	arg amp, out=0, dur=15, attack=0.1, release=0.1, decay_time=0.1, decay_amp=0.7, freq=440, fmod_freq=533, fmod_mul=12, sustain_freq=660, pos=0, gate=0, filter_env_start_freq=880, filter_env_end_freq=440, filter_sus_dur=15, filter_decay_dur=0.1, filter_release_time=0.1, tail_length=4, tail_length_level=0.1, mRatio=1, cRatio=1;
	var pan, sig, env, filter, carrier, modulator, fmod_env, filter_env;

	// Control Envelopes
	env = EnvGen.kr(
		Env([0,1,decay_amp,1,0],
			[attack, decay_time, dur-attack-release-decay_time-tail_length, tail_length],
			curve: ['wel', -2.0, -3, 0, -4],
			releaseNode: 3
		),
		gate: gate,
		doneAction: Done.freeSelf);
	fmod_env = EnvGen.kr(
		Env([0,1,1,tail_length_level,tail_length_level, 0],
			[attack, (dur/2)-attack-(tail_length/2)-0.1, tail_length, (dur/2)-(tail_length/2), 0.1],
			curve: 'wel',
			releaseNode: 2
		),
		gate: gate);
	filter_env = EnvGen.kr(
		Env([0.1, filter_env_start_freq, sustain_freq, sustain_freq, filter_env_end_freq],
			[attack, filter_decay_dur, filter_sus_dur-attack-filter_decay_dur-release, filter_release_time],
			curve: -3,
			releaseNode: 2
		),
		gate: gate);

	// Modulator and Carrier
	modulator = SinOsc.ar(freq * mRatio, mul: fmod_mul) * fmod_env;
	carrier = SinOsc.ar(freq * cRatio, modulator.wrap(0,4pi));

	// Build signal
	sig = carrier * env;
	filter = LPF.ar(sig, filter_env);
	pan = Pan2.ar(filter, pos: pos, level: amp * 1.1);
	Out.ar(out, pan);
}).add;

SynthDef.new(\reverb, {
	arg input=99, output=0, mix=0, room=0, damp=0, amp=1;
	var in, sig;
	in = In.ar(input, 1);
	sig = FreeVerb.ar(in, mix, room, damp, amp);
	Out.ar(output, sig!2);
}).add;

SynthDef.new(\buzzy_bram_sequencer, {
	arg amp=20, out=0, freq=440, bend=0, rq=0.5, dur=1;
	var pan, sig, trigger, saw, lpf, env;
	saw = LFSaw.ar(freq * bend.midiratio, mul:0.7)!2;
	lpf = RLPF.ar(saw, 1000, rq, 1/rq.sqrt);
	env = EnvGen.kr(Env.sine(dur+0.5), doneAction:2);
	sig = SinOsc.ar(freq * bend.midiratio) * amp * env * lpf;
	Out.ar(out, sig);
}).add;

SynthDef(\phase_mod_sequencer, {
	arg amp, out=0, dur=3, attack=0.1, release=0.1, decay_time=0.1, decay_amp=0.7, freq=440, fmod_freq=533, fmod_mul=12, sustain_freq=660, pos=0, filter_env_start_freq=880, filter_env_end_freq=440, filter_sus_dur=1, filter_decay_dur=0.1, filter_release_time=0.1, tail_length=1, tail_length_level=0.1, mRatio=1, cRatio=1;
	var pan, sig, env, filter, carrier, modulator, fmod_env, filter_env, lfo_amp;

	// Control Envelopes
	env = EnvGen.kr(
		Env([0,1,decay_amp,1,0],
			[attack, decay_time, dur-attack-release-decay_time-tail_length, tail_length],
			curve: ['wel', -2.0, -3, 0, -4],
		),
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

