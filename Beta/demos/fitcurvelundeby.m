% Testing new curve fitting by Lundeby method
close all
clear all
clc

cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest
bandsPerOctave = 1;     % octave band filter

freqs = rbaGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);
[rir,fs] = wavread('/Users/Oliver/Dropbox/Specialkursus/Measurements/LargeRoom/Dirac/meas1NoDirac.wav');

%rir = rir(:,1);     % convert to mono
%%
intnoise = find(diff(rir)>1e-3,1);      % Cut away onset
rir = rir(intnoise:end);
t = 0:1/fs:length(rir)/fs-1/fs;
%%
[B,A] = rbaFilterBank(1,fs,cfmin,cfmax,1);

% filter rir with octave band filters
rir_band = zeros(length(rir),nCF);
data = zeros(length(rir_band), 2);

i = 8;  % select Hz band
disp(['Now processing ' num2str(freqs(i)) ' Hz band.'])

rir_band(:,i) = filter(B(:,i),A(:,i),rir);          % Filtered IR
subplot(2,2,1); plot(rir_band(:,i))
rir_band(:,i) = rir_band(:,i)./max(abs(rir_band(:,i))); % normalize
subplot(2,2,2); plot(rir_band(:,i))
rir_band(:,i) = rir_band(:,i).^2;                   % Squared IR
subplot(2,2,3); plot(rir_band(:,i))
rir_band(:,i) = 10.*log10(rir_band(:,i));         % dB SPL scale
subplot(2,2,4); plot(rir_band(:,i))


maxIter=5;
avgTime= 50e-3;
noiseHeadRoom=10;
dynRange=20;

[knee, rms_noise] = rbaLundeby(rir_band(:,i),fs,maxIter,avgTime,noiseHeadRoom,dynRange)


