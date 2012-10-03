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
t = 0:1/fs:length(rir)/fs-1/fs;

[B,A] = rbtHomemadeFilterBank(1,fs,cfmin,cfmax,1);

% filter rir with octave band filters
rir_band = zeros(length(rir),nCF);
data = zeros(length(rir_band), 2);
for i = 1:nCF
    disp(['Now processing band ' num2str(i) ' out of ' num2str(nCF)])
    rir_band(:,i) = filter(B(:,i),A(:,i),rir);          % Filtered IR
    rir_band(:,i) = rir_band(:,i).^2;                   % Squared IR
    rir_band(:,i) = 10*log(rir_band(:,i));                  % dB scale
    rir_band(:,i) = rir_band(:,i) - max(rir_band(:,i));     % Normalize
    % Fit curve to RIR
    data = [rir_band(:,i) t'];
    v = decay2_fit(data,[],[],0);
    Fitted_Curve = 20*log10(decay_model(v,t',1));
    [~,intt(i)] = max(diff(Fitted_Curve,2));            % Find knee-point
    subplot(ceil(nCF/2),2,i)
    plot(t,rir_band(:,i)), hold on 
    plot(t,Fitted_Curve,'r')
    line([intt(i)/fs intt(i)/fs],[-300 0],'color','k')  % Plot knee-point
    title([num2str(freqs(i),'%4.0f') ' Hz']);
end
