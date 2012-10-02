clear all
close all
clc

%% filter a room response
cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest
bandsPerOctave = 1;     % octave band filter

freqs = rbtGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);
[rir,fs] = wavread('../room.wav');

rir = rir(:,1);     % convert to mono
t = 0:1/fs:length(rir)/fs-1/fs;

figure(1)
plot(t,rir)
title('Impulse Response')
xlabel('t / s')

% figure(2)
% plot(abs(fft(rir)))
% title('frequency spectrum')
% xlabel('frequency / Hz')
% set(gca,'XTick',freqs)

% wrong way of cutting RIR
% noise = max(abs(rir(end-round(0.1*length(rir)):end)))
% 
% rir_cut = rir(abs(rir)>noise);
% t_cut = 0:1/fs:length(rir_cut)/fs-1/fs;
% figure(2)
% plot(t_cut,rir_cut)
% title('cut impulse response')
% xlabel('t / s')
%%
[B,A] = rbtHomemadeFilterBank(1,fs,cfmin,cfmax,1);

%%
rir_bands = zeros(length(rir),1);

figure(3)

hold all
% filter rir with octave band filters
for i = 1:nCF
    rir_band = filter(B(:,i),A(:,i),rir);
    decay_curve = rbtDecayCurve(rir_band);
    t = 0:1/fs:length(decay_curve)/fs-1/fs;
    subplot(ceil(nCF/2),2,i)
    plot(t,decay_curve);
    title([num2str(freqs(i),'%4.0f') ' Hz']);
end


