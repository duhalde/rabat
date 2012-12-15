clear all
close all
clc

path = '~/Dropbox/SpecialKursus/Measurements/ScaleModel/dirac/model3/';

[sigMod,fsMod] = wavread([path 'model.wav']);

%%
K = 20; % scale factor
fsRef = fsMod/K;
t = 0:1/fsRef:length(sigMod)/fsRef-1/fsRef;

% get center frequencies for reference and model
fRef = rbtGetFreqs(125,2000,1);
fMod = fRef*K;

%% reference ambience
TRef = 25;
hrRef = 40;
PaRef = 101.325;

% reference ambience
TMod = 17;
hrMod = 40;
PaMod = 101.325;

% air attenuation in dB/m
mfRef = mEvans(TRef,hrRef,PaRef,fRef);
mfMod = mEvans(TMod,hrMod,PaMod,fMod);

cRef = 344;
cMod = cRef;

% absorption discrepancies (ie. difference in absorption between reference and model)
bn = mfMod.*cMod-K*mfRef.*cRef;

% Compensation filter
H = zeros(length(t),length(bn));
for i = 1:length(bn)
    H(:,i) = 10.^(bn(i)*t/20);
end

% convert signal to octave bands
sigModOct = rbaIR2OctaveBands(sigMod,fsRef,min(fRef),max(fRef));

sigRef = sum(sigModOct.*H,2);

plot(t,sigRef)



