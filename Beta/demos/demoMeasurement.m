% Demo script for testing RABAT measurement
clear all

% Generate logarithmic sine sweep
fs = 48000;         % Sampling frequency
f1 = 1000;           % Lower frequency
f2 = 8000;          % Upper frequency
length_sig = 5;     % Duration of sweep in seconds
zero_pad = 0;       % zero padding (default value)
amp = 1;            % Amplitude (default value)
phase = 0;          % Phase (default value)

[sweep,t] = rbtGenerateSignal('logsin',fs,f1,f2,length_sig,zero_pad,amp,phase);


% Start measurement
RT = 1;             % Estimated reverberation time of room
y = rbtMeasurement(sweep,fs,RT,2);

% Compute impulse response
h = sweepdeconv(sweep,y,f1,f2,fs);

specgram(y,min(256,length(y)),fs)