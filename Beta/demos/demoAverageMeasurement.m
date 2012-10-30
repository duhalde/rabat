% Demo script for testing RABAT measurement
clear all
close all
clc

% Generate logarithmic sine sweep
sigType = 'logsin'; % We can also use 'linsin', 'sin', 'mls' or 'irs'
fs = 44100;         % Sampling frequency
f1 = 100;           % Lower frequency
f2 = 15000;         % Upper fr  equency
length_sig = 5;     % Duration of sweep in seconds
zero_pad = 0;       % zero padding (default value)
amp = 1;            % Amplitude (default value)
phase = 0;          % Phase (default value)

[sweep,t] = rbtGenerateSignal(sigType,fs,f1,f2,length_sig,zero_pad,amp,phase);

% Apply sweepwindow here?

RT = 1;     % Estimated reverberation time of room
N = 5;      % Number of sweeps

% sweep with "silent" padding, with time for the natural decay
% sweepNull = [sweep zeros(1,RT*fs)];


recSig = rbtMeasurementAverage(sweep,fs,RT,1,N);

%% plot spectrogram of recorded signal
% [~,F,T,P] = spectrogram(recSig,256,250,256,fs);
% 
% close(findobj('type','figure','name','spectrogram of recorded signal'))
% figure('Name','spectrogram of recorded signal','Position',[0 200 300 300])
% % plot spectrogram!! NOTE: a lot more difficult than with specgram, which
% % is no longer supported from Mathworks :-(
% surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
% view(0,90);
% xlabel('Time (Seconds)'); ylabel('Hz');



figure(2)
specgram(recSig)
%%
% Compute impulse response
h = sweepdeconv(sweep,recSig,f1,f2,fs);

figure(3)
plot(h)
%wavwrite(h(4:end-4),fs,'rirtest')

h = h./max(h);      % normalize
h = h.^2;           % square rir
h_dB = 10*log10(h); % convert to dB

close(findobj('type','figure','name','Impulse Response'))
figure('Name','Impulse Response','Position',[980 200 300 300])
plot(h_dB)

