% Demo script for testing RABAT measurement
clear all
close all
clc

% Generate logarithmic sine sweep
sigType = 'logsin'; % We can also use 'linsin', 'sin', 'mls' or 'irs'
fs = 44100;         % Sampling frequency
f1 = 100;           % Lower frequency
f2 = 15000;         % Upper fr  equency
length_sig = 5;     % Duration of sweep in seconds
zero_pad = 0;       % zero padding (default value)
amp = 1;            % Amplitude (default value)
phase = 0;          % Phase (default value)

[sweep,t] = rbtGenerateSignal(sigType,fs,f1,f2,length_sig,zero_pad,amp,phase);

% Apply sweepwindow here?

RT = 5;     % Estimated reverberation time of room
N = 1;      % Number of sweeps

% sweep with "silent" padding, with time for the natural decay
sweepNull = [sweep zeros(1,RT*fs)];

%%  Use for actual rec/play measurement!

% assemble measurement signal with N sweeps
c = sweepNull'; % or sweepNull(:)?
cc = c(:,ones(N,1));
measSig = cc(:)';

%recSig = rbtMeasurement(measSig,fs,RT,2);

%% Use for debug, without actual record and playback!

rir = wavread('church');
% use loaded mono rir to simulate a recording in a room
sweepResp = rbtConv(sweepNull,rir(:,1));
% assemble recorded signal of N sweep responses
c = sweepResp(:);
cc = c(:,ones(N,1));
measSig = cc(:)';
% add random latency (up to 50ms) in both ends
recSig = [zeros(1,randi(50e-3*fs)) measSig zeros(1,randi(50e-3*fs))];
% add noise for debugging purpose
noise = 1e-5*randn(1,length(recSig));
recSig = recSig + noise;
%figure(1)
%plot(recSig)
%% Determine cross correlation
[c,lags] = rbtCrossCorr(recSig,sweep);

% find indices of each sweep in recSig
[~, sortedIndex] = sort(c);                    % sorted values

maxIndex = sort(lags(sortedIndex(end-(N*5-1):end)))  % Indices for 5*N largest values 

%% Pick the right indices (just until we find a better solution) 
maxIndex = [maxIndex(10) maxIndex(13) maxIndex(16) maxIndex(19) maxIndex(23)];

% extract measured sweeps for averaging
recSweeps = zeros(N,length(sweepNull));
for m = 1:N
    idx = maxIndex(m)+1:(maxIndex(m)+length(sweepNull));
    recSweeps(m,:) = recSig(idx);
end

% time average to get rid of background noise
meanRecSweep = mean(recSweeps);                 % ensemble average
meanRecSweep = meanRecSweep(1:length(sweep));   % cut off to length of sweep
figure(2)
specgram(meanRecSweep)
%%
% Compute impulse response
h = sweepdeconv(sweep,meanRecSweep,f1,f2,fs);
figure(3)
plot(h)
%wavwrite(h(4:end-4),fs,'rirtest')
