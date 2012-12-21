% Compare scale model measurements
% cd to measurements in DropBox
cd /Users/Oliver/Dropbox/SpecialKursus/Measurements/newScaleModel/

%% Load wav measurements in model and full scale
[h1full,fsFull] = wavread('full1.wav');
%[h2full,fsF2] = wavread('full2.wav');
h3full = wavread('full3.wav');
h4full = wavread('full4.wav');
h5full = wavread('full5.wav');
[h1model,fsModel] = wavread('model1.wav');
h2model = wavread('model2.wav');
h3model = wavread('model3.wav');
h4model = wavread('model4.wav');
h5model = wavread('model5.wav');
%% Crop IRs
[hCF,tF] = rbaCropIR(h1full,fsFull);
[hCM,tM] = rbaCropIR(h1model,fsModel);
%% Filter impulse response
cfmin = 1000;   % Corresponds to 100 Hz in full scale
cfmax = 64000;  % Corresponds to 6400 Hz in full scale
H = rbaIR2OctaveBands(hCM,fsModel,cfmin,cfmax);
%% Compute full-scale 
K = 10;
fFull = 
[hFull,tFull] = rbaScaleModel(hCM,fsModel,K,fFull,T,hr,Pa)
%%
figure(1)
plot(tF,hCF)
figure(2)
plot(tM,hCM)
%%
[hr,fs] = wavread('sounds/room.wav');
hr = hr(:,1);
H = rbaIR2OctaveBands(hr,fs,250,8000);
R2 = rbaSchroeder(H,fs,0,3e4);
%% Convert model to full scale by multiplying in the frequency domain
nfft = 2^(nextpow2(length(h1N))); 
Fh1M = fft(h1N,nfft);
NumUniquePts = ceil((nfft+1)/2); 
Fh1M = Fh1M(1:NumUniquePts);
f = (0:NumUniquePts-1)*fsModel/nfft; 
semilogx(f,20*log10(abs(Fh1M)))
%%
figure(2)
T = 25;
hr = 40;
Pa = 101.325;
mDirac = mEvans(T,hr,Pa,f);
mISO = EACm(T,hr,Pa,f);
%Fh1M = ifft(mEvans.*fft(h1M)'); 
plot(f,10*log10(mDirac)), hold on
plot(f,10*log10(mISO),'r')
%%
H = rbaIR2OctaveBands(h1M,fsModel,63,4000);
%R = rbaSchroeder(H,fsModel,0,1e5);
%%
rmsM = sqrt(mean(h1M(1:length(h1F)).^2));
rmsF = sqrt(mean(h1F.^2));