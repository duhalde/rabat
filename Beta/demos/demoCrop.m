clear all
close all
% Load impulse response from wav:
[h,fs] = wavread('sounds/LargeRevChamberRBA1.wav');
h = h(:,1);     % I only want a mono signal
t = 0:1/fs:length(h)/fs-1/fs;

export = 1;
path = '/Users/david/SVN/rabat/Report/figures/';
%% crop and plot result
[hCrop,tCrop,idxOnset,idxKnee] = rbaCropIR(h,fs,'tight');

f1 = figure(1);
plot(t,h)
hold on
plot(idxOnset/fs,h(idxOnset),'ro')
plot(idxKnee/fs,h(idxKnee),'go')
xlabel('Time [s]')
ylabel('Magnitude')
legend('ir','Onset','Knee point')

if export
    name = [path 'markedCrops.eps'];
    saveas(f1,name,'epsc');
else
    title('Original impulse response')
end
%%
f2 = figure(2);
plot(tCrop,hCrop)
xlabel('Time [s]')
ylabel('Magnitude')

if export
    name = [path 'Cropped.eps'];
    saveas(f2,name,'epsc');
else
    title('Cropped impulse response')
end
%% Split into octave bands
bandsPerOctave = 1;
f = rbaGetFreqs(63,4000,bandsPerOctave);

[h,t] = rbaCropIR(h,fs,'onset'); % crop onset on h
H = rbaIR2OctaveBands(h,fs,min(f),max(f),bandsPerOctave);
HCrop = rbaIR2OctaveBands(hCrop,fs,min(f),max(f),bandsPerOctave);

%% Get decay curves
hDecay = rbaSchroeder(H,fs,length(H));

hOnsetDecay = rbaSchroeder(H,fs);

hCropDecay = rbaSchroeder(HCrop,fs);

%% PLOTTING WITHOUT LUNDEBY

f3 = figure(3);
% decay curves with only onset crop
plot(t,hDecay)
xlabel('Time [s]')
ylabel('Normalized decay [dB]')
% create cell array for legends, with frequency bands
for i=1:length(f)
leg{i} = num2str(f(i));
end
legend(leg)
% export or show title
if export
    name = [path 'OnsetCrop.eps'];
    saveas(f3,name,'epsc');
else
    title('Original impulse response')
title('decay curves with only onset crop')
end


f4 = figure(4);
% decay curves with lundeby and onset crop
plot(t,hOnsetDecay)
xlabel('Time [s]')
ylabel('Normalized decay [dB]')
legend(leg)
% export or show title
if export
    name = [path 'FrequencyCrop.eps'];
    saveas(f4,name,'epsc');
else
    title('decay curves with onset crop and Lundeby on f-bands')
end

f5 = figure(5);
% decay curves with lundeby and onset crop
plot(tCrop,hCropDecay)
xlabel('Time [s]')
ylabel('Normalized decay [dB]')
legend(leg)
% export or show title
if export
    name = [path 'FrequencyAndBroadbandCrop.eps'];
    saveas(f5,name,'epsc');
else
    title('decay curves with onset crop and Lundeby on broadband and f-bands')
end