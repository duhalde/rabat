% Testing new curve fitting by means of fminsearch
close all
clear all

cfmin = 63;             % lowest center frequency of interest
cfmax = 8000;           % highest center frequency of interest
bandsPerOctave = 1;     % octave band filter

freqs = rbtGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);
[rir,fs] = wavread('../room.wav');

rir = rir(:,1);     % convert to mono
t = 0:1/fs:length(rir)/fs-1/fs;

[B,A] = rbtHomemadeFilterBank(1,fs,cfmin,cfmax,1);

rir_band = zeros(length(rir),nCF);

% filter rir with octave band filters
for i = 1:nCF
    disp(['Now processing band ' num2str(i) ' out of ' num2str(nCF)])
    rir_band(:,i) = filter(B(:,i),A(:,i),rir);
    rir_band(:,i) =  10*log(rir_band(:,i).^2);
    rir_band(:,i) = rir_band(:,i) - max(rir_band(:,i));
    data = [rir_band(:,i) t'];
    v = decay2_fit(data,[],[],0);
    Fitted_Curve = 20*log10(decay_model(v,t',1));
    subplot(ceil(nCF/2),2,i)
    plot(t,rir_band(:,i)), hold on 
    plot(t,Fitted_Curve,'r')
    title([num2str(freqs(i),'%4.0f') ' Hz']);
end
