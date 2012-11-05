close all
clear all
clc

cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest
bandsPerOctave = 1;     % octave band filter

freqs = rbtGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);    
[h,fs] = wavread('sounds/church.wav');

[B,A] = rbtHomemadeFilterBank(1,fs,cfmin,cfmax,1);

h = mean(h,2);     % convert to mono by mean of stereo

intnoise = find(diff(h>1e-3),1,'first');      % Cut away onset
h = h(intnoise:end);
t = 0:1/fs:length(h)/fs-1/fs;

% filter rir with octave band filters
h_band = zeros(length(h),nCF);
%R = zeros(length(h),nCF);
data = zeros(length(h_band), 2);

for i = 1:8;  % select Hz band
disp(['Now processing ' num2str(freqs(i)) ' Hz band.'])

h_band(:,i) = filter(B(:,i),A(:,i),h);          % Filtered IR
%h_band(:,i) = h_band(:,i)./max(abs(h_band(:,i))); % normalize
h_bandSqr(:,i) = h_band(:,i).^2;                   % Squared IR
h_bandDb(:,i) = 10.*log10(h_bandSqr(:,i));         % dB SPL scale
subplot(2,4,i), plot(h_bandDb(:,i)), hold on
maxIter=5;
avgTime= 50e-3; 
noiseHeadRoom=20;
dynRange=30;

[knee, rms_noise] = rbtLundeby(h_bandDb(:,i),fs,maxIter,avgTime,noiseHeadRoom,dynRange);
kneepoint(i) = knee(end);
noisefloor(i) = rms_noise(end);
plot(kneepoint(i),noisefloor(i),'ro')

onset = 1;
R = rbtBackInt(h_band(:,i),onset,kneepoint(i));
subplot(2,4,i), plot(R), hold on
clear R
end

