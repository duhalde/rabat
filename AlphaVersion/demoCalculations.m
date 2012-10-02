% Demo script for calculating acoustic parameters from impulse response
clear all
close all

[h,fs] = wavread('IRtest.wav');  % Note this is a stereo signal
h = h(:,1);                      % Make mono signal
%fc = [63 125 250 500 1000 2000 4000 8000];

%h_band = rbtOctaveBand(h,fs,fc);
Hd = rbtFilterBank(1,44100,63,8000,0);
%%
t30 = zeros(length(fc),1);
for ii = 1:1%length(fc)
   Rband = rbtDecayCurve(h_band(ii,:));
   t30(ii) = rbtT30(Rband,fs);
   h(ii) = plot((0:length(Rband)-1)/fs,Rband); 
   hold all
   axis([0 length(h)/fs -80 0])
   drawnow;
end

%legend('63','125','250','500','1k','2k','4k','8k')

close all
Rband = Rband';
[v, norm1] = decay2_fit(Rband(:,1),[],[],1);