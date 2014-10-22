% Demo script for testing RABAT measurement
clear all
clc

%% Generate logarithmic sine sweep

% Define measurement signal parameters

%  We are interested in reverberation times in octave bands
%   [125 250 500 1000 2000 4000]
f1 = 125*2^(-1/2);
f2 = 4000*2^(1/2);

% For applying a time-window the sweep range must be wider than [f1:f2].
% Note that Nyquist frequency must not be exceeded
flow = f1/2;
fup = f2*2;

% Samplingfrequency should be greater than fup*2. 44.1kHz is very common
% for built-in soundcards
fs = 48e3;

% Define signal type and length of measurement signal in seconds
sig_type = 'logsin';
length_sig = 3;

% Generate measurement signal
[y,t] = rbaGenerateSignal(sig_type,fs,flow,fup,length_sig);

% Generate window
L = length(y);
win = sweepwin(L,flow,fup,f1,f2,sig_type);

% Apply time-window function
sweep = y.*win;

figure(1)
%figure('Name','Spectrogram','Position',[0 400 400 400])
specgram(sweep)
%% Start measurement Steady-state
N = 4;              % number of sweeps to average over
y = rbaAverageMeasurement(sweep,fs,N);

%% Start measurement transient
N = 12; % Number of averages
estimatedRT = 1; % Estimated reverberation time

measuredResult = rbaMeasurement(sweep, fs, N, estimatedRT);
%% Compute impulse response
h = sweepdeconv(measuredResult,y,f1,f2,fs);

%%
figure(2)
%figure('Name','Spectrogram','Position',[0 400 400 400])
specgram(y,min(256,length(y)),fs)

figure(3)
%figure('Name','Impulse response','Position',[420 400 400 400])
plot(h)

%%
[hCrop,t] = rbaCropIR(h,fs);
figure(4)
%figure('Name','Cropped Impulse response','Position',[420 400 400 400])
plot(t,hCrop)

