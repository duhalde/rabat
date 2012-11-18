clear all
close all
% Load impulse response from wav:
[hD,fsD] = wavread('Dirac/meas5NoDirac.wav');
[measRabat3,fsR] = wavread('RABAT/logsin_12-Nov-2012-150952.wav');

sig_type = 'logsin';
fs = 48000;
f1 = 22;
f2 = 22*(fs/48);

lengthSec = 5.46;
[sweep,t] = rbtGenerateSignalWin(sig_type,fs,f1,f2,lengthSec);

hR = sweepdeconv(sweep,measRabat3,f1,f2,fs);

% Frequency range of interest 
cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest

% Get center frequencies in octave bands
freqs = rbtGetFreqs(cfmin,cfmax,1);

% Crop IR
[hCropD,idxStartD,idxEndD,tD] = rbtCropIR(hD,fsD);
[hCropR,idxStartR,idxEndR,tR] = rbtCropIR(hR,fsR);

% Filter impulse response
HD = rbtIR2octBands(hCropD,fsD,cfmin,cfmax);
HR = rbtIR2octBands(hCropR,fsR,cfmin,cfmax);

% Determine knee points and Noise floor level
[kneeD, rmsNoiseD] = rbtLundeby(HD,fsD);
[kneeR, rmsNoiseR] = rbtLundeby(HR,fsR);

% Get decay curves
RD = rbtBackInt(HD);
RR = rbtBackInt(HR);

% Get reverberation time
[RTD, r2pD, dynRangeD] = rbtRevTime(RD,tD,'all');
[RTR, r2pR, dynRangeR] = rbtRevTime(RR,tR,'all');

% Results from Dirac 
T30 = [5.196 7.447 7.376 5.968 4.976 4.308 3.344 2.349 1.414 0.849];
T20 = [6.141	7.531	7.309	5.892	4.989	4.312	3.333	2.284	1.379	0.937]; 
%%
semilogx(freqs,T20(2:end-1),'--o'), hold on
plot(freqs,RTD,'k--s'), plot(freqs,RTR(1,:),'r--.')
set(gca,'XTick',freqs)
axis([60 8000 0 max(T30)+1])
legend('Dirac-derived T30','RABAT derived from Dirac rec.','RABAT derived from RABAT rec.')