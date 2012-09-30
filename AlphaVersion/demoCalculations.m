% Demo script for calculating acoustic parameters from impulse response
clear all
close all

[h,fs] = wavread('IRtest.wav');  % Note this is a stereo signal
h = h(:,1);                      % Make mono signal
R = rbtDecayCurve(h);            % This is the decay curve
t = (0:length(R)-1)/fs;          % Time vector

plot(t,R)

fc = [63 125 250 500 1000 2000 4000 8000];
h_band = rbtOctaveBand(h,fc);

t30 = zeros(length(fc),1);
for ii = 1:length(fc)
   Rband = rbtDecayCurve(h_band(ii,:));
   t30(ii) = rbtT30(Rband,fs);
   h(ii) = plot((0:length(Rband)-1)/fs,Rband); 
   hold all
   axis([0 length(h)/fs -80 0])
   drawnow;
end

legend('63','125','250','500','1k','2k','4k','8k')