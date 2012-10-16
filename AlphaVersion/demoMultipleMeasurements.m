% Demo script for testing RABAT measurement
clear all
close all
clc

% Generate logarithmic sine sweep
fs = 44100;         % Sampling frequency
f1 = 1000;           % Lower frequency
f2 = 8000;          % Upper frequency
length_sig = 5;     % Duration of sweep in seconds
zero_pad = 0;       % zero padding (default value)
amp = 1;            % Amplitude (default value)
phase = 0;          % Phase (default value)

[sweep,t] = rbtGenerateSignal('logsin',fs,f1,f2,length_sig,zero_pad,amp,phase);

RT = 1;     % Estimated reverberation time of room
N = 3;      % Number of sweeps

% sweep with "silent" padding, with room for natural decay
sweepNull = [sweep zeros(1,RT*fs)];

% assemble measurement signal with N sweeps
c = sweepNull';
cc = c(:,ones(N,1));
measSig = cc(:)';

% recSig = rbtMeasurement(measSig,fs,RT,2);
recSig = [ 0 0 0 measSig 0 0 ];
%%
[C lags] = xcorr(recSig,sweep);

figure(1)
stem(lags,C)

% find indices of each sweep in recSig
[~, sortedIndex, ~] = unique(C);                    % Unique sorted values
maxIndex = sort(lags(sortedIndex(end-(N-1):end)));  % Indices for N largest values 

% extract measured sweeps for averaging
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

