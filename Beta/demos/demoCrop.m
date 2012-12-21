clear all
close all
% Load impulse response from wav:
[h,fs] = wavread('sounds/LargeRevChamberRBA1.wav');
h = h(:,1);     % I only want a mono signal
t = 0:1/fs:length(h)/fs-1/fs;

%% crop and plot result
[hCrop,tCrop,idxOnset,idxKnee] = rbaCropIR(h,fs);

figure(1)
plot(t,h)
hold on
plot(idxOnset/fs,h(idxOnset),'ro')
plot(idxKnee/fs,h(idxKnee),'ro')
xlabel('Time [s]')
ylabel('Magnitude')

figure(2)
plot(tCrop,hCrop)
xlabel('Time [s]')
ylabel('Magnitude')

%% Split into octave bands
bandsPerOctave = 1;
f = rbaGetFreqs(63,4000,bandsPerOctave);

H = rbaIR2OctaveBands(h,fs,min(f),max(f),bandsPerOctave);
HCrop = rbaIR2OctaveBands(hCrop,fs,min(f),max(f),bandsPerOctave);

%% Get decay curves
hDecay = rbaSchroeder(H,fs,0);
hDecayComp = rbaSchroeder(H,fs,1);

hCropDecay = rbaSchroeder(HCrop,fs,0);
hCropDecayComp = rbaSchroeder(HCrop,fs,1);

%%

figure(1)
for i = 1:2
RR5 = floor(0.95*length(RR(:,i)));
RD5 = floor(0.95*length(RD(:,i)));
subplot(1,2,i)
plot(RR(:,i)), hold all
plot(RD(:,i))
title([num2str(freqs(i)) ' Hz'])
ylim([-65 0])
plot(RR5,RR(RR5,i),'or')
plot(RD5,RD(RD5,i),'or')
hold off
end
legend('Rabat','Dirac')
%%

% Get reverberation time
[RTD, r2pD, dynRangeD] = rbaReverberationTime(RD,tD,'all');
[RTR, r2pR, dynRangeR] = rbaReverberationTime(RR,tR,'all');

% Results from Dirac
T30 = [5.196 7.447 7.376 5.968 4.976 4.308 3.344 2.349 1.414 0.849];
T20 = [6.141	7.531	7.309	5.892	4.989	4.312	3.333	2.284	1.379	0.937];
%%
figure(2)
semilogx(freqs,T20(2:end-1),'--ob'), hold on
plot(freqs,T30(2:end-1),'--db')

plot(freqs,RTR(1,:),'r--o')
plot(freqs,RTR(2,:),'r--d')

plot(freqs,RTD,'k--x'),

set(gca,'XTick',freqs)
axis([60 8000 0 max(T30)+1])
legend('Dirac-derived T20','Dirac-derived T20','RABAT-derived T20','RABAT-derived T30','RABAT T20 from Dirac rec.')