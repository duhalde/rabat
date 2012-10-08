% Testing new curve fitting by means of fminsearch
close all
clear all
clc

cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest
bandsPerOctave = 1;     % octave band filter

freqs = rbtGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);
[rir,fs] = wavread('../room.wav');

rir = rir(:,1);     % convert to mono

intnoise = find(diff(rir)>1e-3,1);      % Cut away onset 
rir = rir(intnoise:end);
t = 0:1/fs:length(rir)/fs-1/fs;

[B,A] = rbtHomemadeFilterBank(1,fs,cfmin,cfmax,1);

% filter rir with octave band filters
rir_band = zeros(length(rir),nCF);
data = zeros(length(rir_band), 2);

i = 1;
    disp(['Now processing band ' num2str(i) ' out of ' num2str(nCF)])
    rir_band(:,i) = filter(B(:,i),A(:,i),rir);          % Filtered IR
    rir_band(:,i) = rir_band(:,i).^2;                   % Squared IR
    rir_band(:,i) = 10*log(rir_band(:,i));                  % dB scale
    rir_band(:,i) = rir_band(:,i) - max(rir_band(:,i));     % Normalize
    % Fit curve to RIR
    
    [knee, rms_noise] = rbtLundeby(rir_band(:,i),fs);
    
