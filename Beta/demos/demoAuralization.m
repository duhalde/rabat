clear all
close all
clc

[talk,fs1] = wavread('sounds/gspi.wav');
soundsc(talk,fs1);
%%
[rir,fs2] = wavread('sounds/HagiaIreneMosque.wav');
rir = rir(:,1);

soundsc(rir,fs2);

if fs1 ~= fs2
    error('sampling frequencies must be equal. Consider resampling.')
else
    fs = fs1;
    clear fs1 fs2
end
%%
talkInRoom = rbaLinearConv(talk,rir);

soundsc(talkInRoom,fs)


