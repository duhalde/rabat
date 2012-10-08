clear all
close all

[h,fs] = wavread('../room.wav');  % Note this is a stereo signal
h = h(:,1)+0.2*rand(size(h(:,1)));                      % Make mono signal
fc = [63 125 250 500 1000 2000 4000 8000];


h_band = rbtOctaveBand(h,fs,fc);

h = h_band(3,:);

noise = h(ceil(length(h)*0.9):end);

meanSquareNoise = 0;%mean(noise.^2);


%h2 = sqrt(h2);
 [~, k] = max(h);
 
 R = cumsum(h(end:-1:k).^2-meanSquareNoise);
 R = R(end:-1:1);
% 
 h2T = sum(h(k:end).^2);
 L2 = 10*log10(R./h2T);
% 
 t = 0:1/fs:(length(L2)-1)/fs;
 
 plot(t,L2)