close all
clear all
load h1
fs = 48000;

sampleStart = rbaStartIR(h1);
[hC,idxEnd,tc] = rbaCropIR(h1,fs,sampleStart,9*fs);

h2 = hC.^2;
h2 = h2/max(h2);
kneepoint = 4*fs;

rmsNoise = 10*log10(sqrt(mean(h2(kneepoint:end).^2)));
hSmooth = 10*log10(smooth(h2,1000));
idx = find(hSmooth(1:kneepoint)<rmsNoise+10,1,'first');
[coeff,S] = polyfit((idx:kneepoint),hSmooth(idx:kneepoint)',1);
A = coeff(1);
B = coeff(2);
plot(10*log10(h2)), hold on
plot(hSmooth,'r'), 
plot(A*(1:length(hSmooth))+B,'k'),

E0 = 10^(B/10);
a = log(10^(A/10));
E = -(E0/a)*exp(a*kneepoint);

%%
%step = 1000;
%idx1 = 1:step:kneepoint-step;
%idx2 = idx1+step;
%for i = 1:length(idx1)
%rmsRun(i) = 10*log10(sqrt(mean(h2(idx1(i):idx2(i)).^2)));
%end

idx10 = find(rmsRun<rmsNoise+10,1,'first');
idx = (idx1(idx10)+idx2(idx10))/2;
[coeff,S] = polyfit(idx:kneepoint,10*log10(h2(idx:kneepoint))',1);
%A = coeff(1);
B = coeff(2);
%%
R = cumsum(h2(kneepoint:-1:1));
R1 = 10*log10(R(end:-1:1)+E);
R1 = R1-max(R1);
R2 = 10*log10(R(end:-1:1));
R2 = R2-max(R2);
plot(R1), hold on, plot(R2,'r')
%%
knee = 3*fs;
C = -(E0/a)*exp(a*knee)
R1 = cumsum(h2(knee*fs:-1:1));
R1 = R1(end:-1:1);
R2 = cumsum(h2(knee*fs:-1:1));
R2 = R2(end:-1:1);
%%
R1 = 10*log10(R1+C);
R1 = R1-max(R1);
R2 = 10*log10(R2);
R2 = R2-max(R2);
figure(2)
plot(tc(1:length(R1)),R1), hold on, plot(tc(1:length(R2)),R2,'r')