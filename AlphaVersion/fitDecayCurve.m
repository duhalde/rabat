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
figure(1)
plot(rir)
%%
intnoise = find(diff(rir)>1e-3,1);      % Cut away onset 
rir = rir(intnoise:end);
t = 0:1/fs:length(rir)/fs-1/fs;
figure(2)
plot(rir)
%%
[B,A] = rbtHomemadeFilterBank(1,fs,cfmin,cfmax,1);

% filter rir with octave band filters
rir_band = zeros(length(rir),nCF);
rir_scale = zeros(length(rir),nCF);
data = zeros(length(rir_band), 2);
intt = zeros(1,nCF);
for i = 1:nCF
    disp(['Now processing band ' num2str(i) ' out of ' num2str(nCF)])
    rir_band(:,i) = filter(B(:,i),A(:,i),rir);          % Filtered IR
    %rir_band(:,i) = abs(hilbert(rir_band(:,4)));
    rir_scale(:,i) = rir_band(:,i).^2;                   % Squared IR
    rir_scale(:,i) = 10*log(rir_scale(:,i));                  % dB scale
    rir_scale(:,i) = rir_scale(:,i) - max(rir_scale(:,i));     % Normalize
    %rir_band(:,i) = smooth(rir_band(:,i),200/fs);
    
    % Fit curve to RIR
    data = [rir_scale(:,i) t'];
    v = decay2_fit(data,[],[],0);
    Fitted_Curve = 20*log10(decay_model(v,t',1));
    [~,intt(i)] = max(diff(Fitted_Curve,2));            % Find knee-point
    subplot(ceil(nCF/2),2,i)
    plot(t,rir_scale(:,i)), hold on 
    plot(t,Fitted_Curve,'r')
    line([intt(i)/fs intt(i)/fs],[-300 0],'color','k')  % Plot knee-point
    title([num2str(freqs(i),'%4.0f') ' Hz']);
    axis([0 t(end) -300 0])
end
%%
% Cut away noise from RIR:

%rir_cut = zeros(length(rir),nCF);
for i = 1:1
   rir_cut = rir_band(1:intt(i)+2000,i); 
end
