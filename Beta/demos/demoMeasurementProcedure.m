%% Measurement Procedures
%
%
%




%% Linear Sine Sweep

clear all
close all

sig_type = 'linsin';
fs = 44.1e3;
f1 = 1e3;
f2 = 8e3;

length_sec = 10;
disp('Generating Signal')
[y,t] = rbtGenerateSignalWin('linsin',fs,f1,f2,length_sec);
disp('Signal Generated')

estimatedRT = 1;

disp('Measurement:')
meas = rbtMeasurement(y, fs, 1, estimatedRT);

savedir = uigetdir;

disp('Saving Measurement')
wavwrite(meas, fs,[savedir '/' sig_type '_' datestr(now) '.wav'])

%% Logarithmic Sine Sweep

clear all
close all

sig_type = 'logsin';
fs = 44.1e3;
f1 = 1e3;
f2 = 8e3;

length_sec = 10;
disp('Generating Signal')
[y,t] = rbtGenerateSignalWin('linsin',fs,f1,f2,length_sec);
disp('Signal Generated')

estimatedRT = 1;

disp('Measurement:')
meas = rbtMeasurement(y, fs, 1, estimatedRT);

savedir = uigetdir;
filename = [sig_type '_' datestr(now) '.wav'];


disp('Saving Measurement')
wavwrite(meas, fs,[savedir '/' filename])


