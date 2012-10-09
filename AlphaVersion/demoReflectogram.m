% Demonstration of reflectogram
clear all
close all

[h,fs] = wavread('../room.wav');

h = h(:,1);

R = rbtReflectogram(h);
R = R/max(R);

t = 0:1/fs:length(h)/fs-1/fs;

figure(1)
stem(t,R,'.');
axis([0 100e-3 0 1])

figure(2)
stem(t,abs(hilbert(h)),'.');
axis([0 100e-3 0 1])
