clear all
close all
clc

[h,fs] = wavread('sounds/church.wav');
t = 0:1/fs:length(h)/fs-1/fs;
bandsPerOctave = 1;
freqs = rbaGetFreqs(63,4000,bandsPerOctave);
H = rbaIR2OctaveBands(h(:,1), fs, min(freqs), max(freqs), bandsPerOctave,1);

% plot an impulse respones for each band
figure(1)
for i = 1:length(freqs)
    subplot(3,4,i)
    plot(t,H(:,i))
    title([num2str(freqs(i)) ' Hz'])
end

%% plot power spectrum of impulse response
figure(2)
nfft = 2^(nextpow2(length(h)));
Fh1M = fft(h,nfft);
NumUniquePts = ceil((nfft+1)/2);
Fh1M = Fh1M(1:NumUniquePts);
f = (0:NumUniquePts-1)*fs/nfft;
semilogx(f,20*log10(abs(Fh1M)))
xlim([120 9000])
set(gca,'XTick',[125 250 500 1000 2000 4000 8000],...
    'XTickLabel',{'125','250','500','1k','2','4k','8k'})
title('Power spectrum')
xlabel('frequency')
ylabel('Hz')