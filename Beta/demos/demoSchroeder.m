close all
clear all
clc

cfmin = 63;             % lowest center frequency of interest
cfmax = 4000;           % highest center frequency of interest
bandsPerOctave = 1;     % octave band filters, set to 3 for one-third-octaves

f = rbaGetFreqs(cfmin,cfmax,bandsPerOctave); 
[h,fs] = wavread('sounds/Grundtvigs.wav');
h = h(:,1);     % convert to mono by mean of stereo channels

% crop broadband signal at onset, but leave the noise floor
[hCrop, tCrop] = rbaCropIR(h,fs,'onset');

% filter into octave bands
H = rbaIR2OctaveBands(h,fs,min(f),max(f),bandsPerOctave);

% calculate the decay curve for each frequency band by backwards
% integration (schroeder integration)
Decay = rbaSchroeder(H,fs);

figure(1)
% decay curves with only onset crop
plot(tCrop,Decay)
xlabel('Time [s]')
ylabel('Normalized decay [dB]')
xlim([0 10])
% create cell array for legends, with frequency bands
for i=1:length(f)
leg{i} = num2str(f(i));
end
legend(leg)
% show title
title('decay curves with onset crop')
