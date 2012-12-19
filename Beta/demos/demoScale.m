clear all
close all
clc

path = '~/Dropbox/SpecialKursus/Measurements/newScaleModel/';

[sigMod,fsMod] = wavread([path 'scalemodel1.wav']);

[hCrop,t] = rbaCropIR(sigMod,fsMod);

sigMod = hCrop;
figure(1)
plot(t,hCrop)
% ylim([-3e-9 3e-9])
title('Cropped impulse response in scale model')
%% Scale all parameters
K = 20; % scale factor
fsRef = fsMod/K;
t = 0:1/fsMod:length(sigMod)/fsMod-1/fsMod;
tRef = t*K;
% get center frequencies for reference and model
fRef = rbaGetFreqs(125,1000,1);
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
%mfRef = mEvans(TRef,hrRef,PaRef,fRef); 
%mfMod = mEvans(TMod,hrMod,PaMod,fMod);
mfRef = EACm(TRef,hrRef,PaRef,fRef);
mfMod = EACm(TMod,hrMod,PaMod,fMod);


cRef = 344;
cMod = cRef;

% absorption discrepancies (ie. difference in absorption between reference and model)
bn = mfMod.*cMod-K*mfRef.*cRef;

% Compensation filter
H = zeros(length(tRef),length(bn));
for i = 1:length(bn)
    H(:,i) = 10.^(bn(i)*tRef/20);
end

% convert signal to octave bands
sigModOct = rbaIR2OctaveBands(hCrop,fsRef,min(fRef),max(fRef));

for i = 1:size(sigModOct,2)
[knee, rmsNoise] = rbaLundeby(sigModOct(:,i),fsRef);
kn(i) = knee(end);
rm(i) = rmsNoise(end);
%sigRefOct(:,i) = (sigModOct(1:kn(i),i).*H(1:kn(i),i));
sigRefOct(:,i) = [(sigModOct(1:kn(i),i).*H(1:kn(i),i)); H(kn(i),i).*sigModOct(kn(i)+1:end,i)];
end
sigRef = sum(sigRefOct,2);
figure(2)
plot(tRef,sigRef)
% ylim([-3e-9 3e-9])

%%

[hFull,tRef] = rbaScaleModel(sigMod,fsMod,K,fRef,[TRef TMod],[hrRef hrMod]);
figure(3)
plot(tRef,hFull)
ylim([-3e-9 3e-9])