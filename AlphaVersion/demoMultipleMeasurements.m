% Demo script for testing RABAT measurement
clear all
close all
clc

% Generate logarithmic sine sweep
sigType = 'logsin'; % We can also use 'linsin', 'sin', 'mls' or 'irs'
fs = 44100;         % Sampling frequency
f1 = 1000;          % Lower frequency
f2 = 8000;          % Upper fr  equency
length_sig = 5;     % Duration of sweep in seconds
zero_pad = 0;       % zero padding (default value)
amp = 1;            % Amplitude (default value)
phase = 0;          % Phase (default value)

[sweep,t] = rbtGenerateSignal(sigType,fs,f1,f2,length_sig,zero_pad,amp,phase);

RT = 5;     % Estimated reverberation time of room
N = 3;      % Number of sweeps

% sweep with "silent" padding, with time for the natural decay*
sweepNull = [sweep zeros(1,RT*fs)];

% assemble measurement signal with N sweeps
% using Tony's Trick - blazing fast - and no growing vectors in for-loops!
c = sweepNull'; % or sweepNull(:)?
cc = c(:,ones(N,1));
measSig = cc(:)';

%% Use for actual rec/play measurement!
% recSig = rbtMeasurement(measSig,fs,RT,2);

%% Use for debug, without actual record and playback!
rir = wavread('rir/church');
% use loaded mono rir to simulate a recording in a room
sweepResp = RBTconv(sweepNull,rir(:,1));
% assemble recorded signal of N sweep responses
c = sweepResp(:);
cc = c(:,ones(N,1));
measSig = cc(:)';
% add random latency (up to 50ms) in both ends
recSig = [zeros(1,randi(50e-3*fs)) measSig zeros(1,randi(50e-3*fs))];
% add noise for debugging purpose
noise = randn(1,length(recSig));
recSig = recSig + noise;

%recSig = rbtMeasurement(measSig,fs,RT,2);
%recSig = [ 0 0 0 measSig 0 0 ];


%%
tic
[c,lags] = xcorr(recSig,sweep);
toc
tic
C = rbtXCorr(recSig,sweep);
toc

figure(1)
subplot(1,4,1)
plot(c)
subplot(1,4,2)
stem(lags,c)
subplot(1,4,3)
plot(C)
subplot(1,4,4)
stem(C)

%% find indices of each sweep in recSig
[~, sortedIndex] = sort(c);                    % sorted values
maxIndex = sort(lags(sortedIndex(end-(N-1):end)))  % Indices for N largest values 

%% extract measured sweeps for averaging
recSweeps = zeros(N,length(sweepNull));
for m = 1:N
    idx = maxIndex(m)+1:(maxIndex(m)+length(sweepNull));
    recSweeps(m,:) = recSig(idx);
end

% time average to get rid of background noise
meanRecSweep = mean(recSweeps);    % ensemble average
figure(2)
specgram(meanRecSweep)
%%
% Compute impulse response
h = sweepdeconv(sweep,meanRecSweep,f1,f2,fs);

