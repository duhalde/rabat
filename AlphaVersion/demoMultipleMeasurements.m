% Demo script for testing RABAT measurement
clear all
clc

% Generate logarithmic sine sweep
fs = 44100;         % Sampling frequency
f1 = 1000;           % Lower frequency
f2 = 8000;          % Upper frequency
length_sig = 5;     % Duration of sweep in seconds
zero_pad = 0;       % zero padding (default value)
amp = 1;            % Amplitude (default value)
phase = 0;          % Phase (default value)

[sweep,t] = rbtGenerateSignal('logsin',fs,f1,f2,length_sig,zero_pad,amp,phase);

RT = 1;             % Estimated reverberation time of room
N = 3;
sweepNull = [sweep zeros(1,RT*fs)];
% Start measurement®

measSig = sweepNull;
for i = 1:N-1
measSig = [measSig sweepNull];
end

recSig = rbtMeasurement(measSig',fs,RT,2);

[C lags] = xcorr(recSig,sweep);
stem(lags,C)
%y = mean(recSig);

%%
% Compute impulse response
%h = sweepdeconv(sweep,recSig,f1,f2,fs);

%specgram(y,min(256,length(y)),fs)