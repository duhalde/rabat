% Demo measurement procedure
% Scale model

clear all
close all

sig_type = 'logsin';

sigma = 20; % Scale factor
fs = 48000;
f1 = 22;
f2 = 22*(fs/48);
length_sec = 2.73;
[y,t] = rbaGenerateSignal(sig_type,fs,f1,f2,length_sec);
%%
estimatedRT = 3;
N = 5;
meas = rbaMeasurement(y, fs, N, estimatedRT);
hR = sweepdeconv(y,meas,f1,f2,fs);
plot(hR)
%%
% Frequency range of interest
cfmin = 250;             % lowest center frequency of interest
cfmax = 4000;           % highest center frequency of interest

% Get center frequencies in octave bands
freqs = rbaGetFreqs(cfmin,cfmax,1);

% Crop IR
idxStartR = rbaStartIR(hR);
[hCropR,idxEndR,tR] = rbaCropIR(hR,fsR,idxStartR,floor(6.271e5));
HR = rbaIR2octBands(hCropR,fs,cfmin,cfmax);

for ii = 1:length(freqs)
subplot(2,2,ii)
plot(tR(1:length(HR(:,ii))),HR(:,ii)), hold all
end

%%
savedir = uigetdir;

disp('Saving Measurement')
wavwrite(meas, fs,32,[savedir '/' sig_type '_' datestr(now,'dd-mmm-HH-MM') '.wav'])