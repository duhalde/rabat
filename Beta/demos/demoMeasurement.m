% Demo script for testing RABAT measurement
clear all

% Generate logarithmic sine sweep
fs = 48000;         % Sampling frequency
f1 = 1000;           % Lower frequency
f2 = 8000;          % Upper frequency
length_sig = 5;     % Duration of sweep in seconds

[sweep,t] = rbaGenerateSignal('logsin',fs,f1,f2,length_sig);


% Start measurement
RT = 1;             % Estimated reverberation time of room
N = 4;              % number of sweeps to average over
transient = 0;
y = rbaMeasurement(sweep,fs,N,RT,transient);

% Compute impulse response
h = sweepdeconv(sweep,y,f1,f2,fs);

%
figure('Name','Spectrogram','Position',[0 400 400 400])
specgram(y,min(256,length(y)),fs)

figure('Name','Impulse response','Position',[420 400 400 400])
plot(h)