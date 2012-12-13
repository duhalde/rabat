% Compare scale model measurements
% cd to measurements in DropBox
cd /Users/Oliver/Dropbox/SpecialKursus/Measurements/ScaleModel/dirac

%% Load wav measurements in model and full scale
[h1full,fsFull] = wavread('model1/fullScale.wav');
h2full = wavread('model2/fullScale.wav');
h3full = wavread('model3/fullScale.wav');
h4full = wavread('model4/fullScale.wav');
h5full = wavread('model5/fullScale.wav');
[h1model,fsModel] = wavread('model1/model.wav');
h2model = wavread('model2/model.wav');
h3model = wavread('model3/model.wav');
h4model = wavread('model4/model.wav');
h5model = wavread('model5/model.wav');
%% Crop IRs
[hCF,tF] = rbaCropIR(h1full,fsFull,length(h1full));
[hCM,tM] = rbaCropIR(h1model,fsModel,length(h1model));
%%
H = rbaIR2OctaveBands(hCF,fsFull,250,2000);
R = rbaSchroeder(H,fsFull,1,1.8e5);
%% Convert model to full scale by multiplying in the frequency domain
nfft = 2^(nextpow2(length(hCM))); 
Fh1M = fft(hCM,nfft);
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
H = rbaIR2OctaveBands(h1F,fsFull,250,1000);
R = rbaSchroeder(H,fsModel,0,1e5);
%%
rmsM = sqrt(mean(h1M(1:length(h1F)).^2));
rmsF = sqrt(mean(h1F.^2));