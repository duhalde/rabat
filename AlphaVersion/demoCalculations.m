% Demo script for calculating acoustic parameters from impulse response
clear all
close all

[h,fs] = wavread('IRtest.wav');  % Note this is a stereo signal
R = rbtDecayCurve(h(:,1));  % This is the decay curve

h_band = rbtOctaveBand(h);

t30 = zeros(size(h_band,1),1);

for ii = 1:size(h_band,1)
   Rband = rbtDecayCurve(h_band(ii,:));
   t30(ii) = rbtT30(Rband,fs);
end