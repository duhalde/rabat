clear all
% Load impulse response from wav:
[h,fs] = wavread('meas5NoDirac.wav');
%h = h(:,1);
t = 0:1/fs:length(h)/fs-1/fs;

% Frequency range of interest 
cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest

% Filter IR into octave bands
H = rbtIR2octBands(h,fs,cfmin,cfmax);

[hCrop,idxStart,idxEnd] = rbtCropIR(H,fs);

[knee, rmsNoise] = rbtLundeby(hCrop,fs);
%%
t = 0:1/fs:length(h)/fs-1/fs;
for i = 7:7;%1:size(H,2)
R = rbtBackInt(hCrop(:,i));
[RT(i), r2p, dynRange] = rbtRevTime(R,t);
plot(t,R), hold all
end

