close all
clear all
clc

cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest
bandsPerOctave = 1;     % octave band filter

freqs = rbaGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);    
[h,fs] = wavread('sounds/church.wav');

[B,A] = rbaFilterBank(1,fs,cfmin,cfmax,1);

h = mean(h,2);     % convert to mono by mean of stereo

%intnoise = find(diff(h>1e-3),1,'first');      % Cut away onset
%h = h(intnoise:end);
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
t = 0:1/fs:length(h_bandDb)/fs-1/fs;
subplot(2,4,i), plot(t,h_bandDb(:,i)), hold on

maxIter=5;
avgTime= 50e-3; 
noiseHeadRoom=20;
dynRange=30;

[knee, rms_noise] = rbaLundeby(h_bandDb(:,i),fs,maxIter,avgTime,noiseHeadRoom,dynRange);
kneepoint(i) = knee(end);
noisefloor(i) = rms_noise(end);
plot(kneepoint(i)/fs,noisefloor(i),'ro')

onset = 1;
R = rbaBackInt(h_band(:,i),onset,kneepoint(i));
t = 0:1/fs:length(R)/fs-1/fs;
subplot(2,4,i), plot(t,R), hold on
xlabel('time / s')
ylim([noisefloor(i)-10 0])
set(gca,'XTick',[1:5])
end

