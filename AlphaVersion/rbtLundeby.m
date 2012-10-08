function [knee, rms_noise] = rbtLundeby(h2,fs,maxIter)

if nargin < 3
    %run maximun 5 times
    maxIter = 5;
end

%% STEP 1
% averaging over 10-50 ms to make a smoother curve

avg_time = 1e-3;    % 10-50 ms averaging

avgSamples = avg_time*fs;  % number of samples to average over

% smooth the response
h2_avg = smooth(h2,avgSamples);

%% STEP 2
% determine background noise level
noise_data = h2_avg(floor(0.9*length(h2_avg)):end);
% find rms value of noise_data
rms_noise = sqrt(mean(noise_data.^2));

%% STEP 3
% last averaged time interval, with value above noise floor + 5 dB
id2 = find(h2_avg>(-rms_noise+5),1,'last');

% linear regression on smoothed rir until the SPL is noise floor + 5dB
[a b] = polyfit((0:id2-1)*avgSamples,h2_avg(1:id2),1);

%% STEP 4
% preliminary cross point
preCross = zeros(maxIter+1,1);
preCross(1) = (rms_noise-b)/a;

%% STEP 5
% find number of samples in 10 dB decay
numSamplesIn10dB = ceil(-10/a);
% divide 10dB into 10 intervals
avgSamples = ceil(numSamplesIn10dB/10);

%% STEP 6
h2_avg = smooth(h2,avgSamples);


%% STEP 7

for k=1:maxIter
    
    % cross point between decay and noise-5dB
    noiseIdx = (rms_noise-5-b)/a;
    % make sure we have 10% of response in noise estimate
    if noiseIdx > floor(0.9*length(h2))
        noiseIdx = floor(0.9*length(h2));
    end
    
    % determine background noise level
    noise_data = h2_avg(floor(noiseIdx):end);
    % find rms value of noise_data
    rms_noise = sqrt(mean(noise_data.^2));
    
    %% STEP 8
    % last averaged time interval, with value above noise floor + 5 dB
    id2 = find(h2_avg>(rms_noise+5),1,'last');
    % last averaged time interval, with value above noise floor + 15 dB
    id1 = find(h2_avg>(rms_noise+15),1,'last');
    
    % linear regression on smoothed rir until the SPL is noise floor + 5dB
    [a b] = polyfit((id1:id2)*avgSamples,h2_avg(id1:id2),1);
    
    %% STEP 9
    % preliminary cross point
    preCross(k+1) = (rms_noise-b)/a;
end

knee = preCross(end);
end

function h_avg = smooth(h,avgSamples)

% process in blocks
h_avg = zeros(ceil(length(h)/avgSamples),1);
for k = 1:ceil(length(h)/avgSamples)-1
    h_avg(k) = mag2db(mean(db2mag( h(((k-1)*avgSamples+1):k*avgSamples))));
end
% process rest - if it exists
if mod(length(h),avgSamples) ~= 0
    h_avg(k+1) = mag2db(mean(db2mag(h(k*avgSamples+1:end))));
end
end
