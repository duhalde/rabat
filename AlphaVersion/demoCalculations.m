% Demo script for calculating acoustic parameters from impulse response
clear all
%close all

[h,fs] = wavread('room.wav');  % Note this is a stereo signal
h = h(:,1);                      % Make mono signal
fc = [63 125 250 500 1000 2000 4000 8000];

%h = h(1:20000,1);
%plot(h)
h_band = rbtOctaveBand(h,fs,fc);
%a = int8(0);
%Hd = rbtFilterBank(1,44100,63,8000,a);

%out = filter(sig,Hd(1));
%%
figure(2)
t30 = zeros(length(fc),1);
for ii = 1:1%length(fc)
   Rband = rbtDecayCurve(h_band(ii,:));
   t30(ii) = rbtT30(Rband,fs);
   h(ii) = plot((0:length(Rband)-1)/fs,Rband); 
   hold all
   %axis([0 length(h)/fs -80 0])
   drawnow;
end

%legend('63','125','250','500','1k','2k','4k','8k')

figure(2)
Rband = Rband';
[v, norm1] = decay2_fit(Rband(:,1),[],[],1);
axis([0 20000 -70 10])
%%
[rir,fs] = wavread('room.wav');

rir = rir(:,1); % convert to mono

semilogy(rir.^2)
%%
noise = mean(abs(rir(end-round(0.1*length(rir)):end)))

plot(rir(rir>noise))