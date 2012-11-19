% Measurement procedure
% Runs Linear sine sweep, log sine sweep and MLS
% 

%% Linear Sine Sweep

clear all
close all

sig_type = 'linsin';
fs = 48000;
f1 = 22;
f2 = 22*(fs/48);

length_sec = 5.46;
disp('Generating Signal')
[y,t] = rbtGenerateSignalWin(sig_type,fs,f1,f2,length_sec);
disp('Signal Generated')

estimatedRT = 1;

disp('Measurement:')
meas = rbtMeasurement(y, fs, 1, estimatedRT);

savedir = uigetdir;

disp('Saving Measurement')
wavwrite(meas, fs,32,[savedir '/' sig_type '_' datestr(now,'dd-mmm-HH-MM') '.wav'])

%% Logarithmic Sine Sweep

clear all
close all

sig_type = 'logsin';
fs = 48000;
f1 = 22;
f2 = 22*(fs/48);

lengthSec = 5.46;
disp('Generating Signal')
[sig,t] = rbtGenerateSignalWin(sig_type,fs,f1,f2,lengthSec);
disp('Signal Generated')

estimatedRT = 1;
repetitions = 5;

WaitSecs(5);
disp('Measurement:')
meas = rbtMeasurement(sig, fs, repetitions, estimatedRT);

savedir = uigetdir;
filename = [sig_type '_' datestr(now,'dd-mmm-HH-MM') '.wav'];


disp('Saving Measurement')
%meas = 0.9*meas./max(meas);
wavwrite(meas, fs,32,[savedir '/' filename])

%% MLS

clear all
close all

sig_type = 'mls';
fs = 48000;

seq = rbtMls(19,'fs',fs);
repetitions = 1;
estimatedRT = 2;
%%
meas = rbtMeasurement(seq, fs, repetitions, estimatedRT);

savedir = uigetdir;
filename = [sig_type '_' datestr(now,'dd-mmm-HH-MM-SS') '.wav'];

wavwrite(meas, fs,32,[savedir '/' filename])