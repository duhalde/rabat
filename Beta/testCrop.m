clear all
close all
% Load impulse response from wav:
[h,fs] = wavread('sounds/Grundtvigs.wav');
h = h(:,1);

% Frequency range of interest 
cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest

% Get center frequencies in octave bands
freqs = rbtGetFreqs(cfmin,cfmax,1);

% Crop IR
[hCrop,idxStart,idxEnd,t] = rbtCropIR(h,fs);

% Filter impulse response
H = rbtIR2octBands(hCrop,fs,cfmin,cfmax);

% Determine knee points and Noise floor level
[knee, rmsNoise] = rbtLundeby(H,fs);

% Get decay curves
R = rbtBackInt(H);

% Get reverberation time
[RT, r2p, dynRange] = rbtRevTime(R,t);

semilogx(freqs,RT,'-.')
set(gca,'XTick',freqs)
axis([60 8000 0 max(RT)])