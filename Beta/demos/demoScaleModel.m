% Demo measurement procedure
% Scale model

clear all
close all

sig_type = 'logsin';

sigma = 20; % Scale factor
fs = 192000;
f1 = 22*sigma;
f2 = 22*(fs/48);

length_sec = 2.73;  
disp('Generating Signal')
[y,t] = rbaGenerateSignal(sig_type,fs,f1,f2,length_sec);

disp('Signal Generated')
%%
estimatedRT = 2;

disp('Measurement:')
meas = rbtMeasurement(y, fs, 1, estimatedRT);

savedir = uigetdir;

disp('Saving Measurement')
wavwrite(meas, fs,32,[savedir '/' sig_type '_' datestr(now,'dd-mmm-HH-MM') '.wav'])