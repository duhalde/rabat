function [knee, rms_noise] = rbtLundeby(h2,fs,maxIter,avgTime,noiseHeadRoom,dynRange)

if nargin < 3
    %run maximun 5 times
    maxIter = 5;
    avgTime = 1e-3;     % 10-50 ms averaging
    noiseHeadRoom = 10; % dB
    dynRange = 20;      % dB

end

%% STEP 1
% averaging over 10-50 ms to make a smoother curve

avgSamples = round(avgTime*fs);  % number of samples to average over

% smooth the response
hSqrSmooth = smooth(h2,avgSamples);

%% STEP 2
% determine background noise level
noise_data = hSqrSmooth(floor(0.9*length(hSqrSmooth)):end);
% find rms value of noise_data
rms_noise = -sqrt(mean(noise_data.^2));

%% STEP 3
% last averaged time interval, with value above noise floor + 5 dB
id2 = find(hSqrSmooth>(rms_noise+noiseHeadRoom),1,'last');

% linear regression on smoothed rir until the SPL is noise floor + 5dB
coeff = polyfit((0:id2-1)',hSqrSmooth(1:id2),1);

a = coeff(1);
b = coeff(2);

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
hSqrSmooth = smooth(h2,avgSamples);


%% STEP 7

for k=1:maxIter
    
    % cross point between decay and noise-5dB
    noiseIdx = ceil((rms_noise-noiseHeadRoom-b)/a);
    % make sure we have 10% of response in noise estimate
    if noiseIdx > floor(0.9*length(h2))
        noiseIdx = floor(0.9*length(h2));
    end
    
    % determine background noise level
    noise_data = hSqrSmooth(noiseIdx:end);
    % find rms value of noise_data NOTE Negative values, since impulse 
    % response is normalised to 0 dB
    rms_noise = -sqrt(mean(noise_data.^2));
    
    %% STEP 8
    % last averaged time interval, with value above noise floor + 5 dB
    id2 = find(hSqrSmooth>(rms_noise+noiseHeadRoom),1,'last');
    % last averaged time interval, with value above noise floor + 15 dB
    id1 = find(hSqrSmooth>(rms_noise+dynRange+noiseHeadRoom),1,'last');
    
    % linear regression on smoothed rir until the SPL is noise floor + 5dB
    coeff = polyfit((id1:id2)',hSqrSmooth(id1:id2),1);
    a = coeff(1);
    b = coeff(2);
    %% STEP 9
    % preliminary cross point
    preCross(k+1) = (rms_noise-b)/a;
end

knee = preCross;
end

function hSmooth = smooth(h,avgSamples)

% process in blocks
hSmoothSize = length(h)/avgSamples;
hSmooth = zeros(length(h),1);
for k = 1:floor(hSmoothSize)
    idx = ((k-1)*avgSamples+1):k*avgSamples;
    hSmooth(idx) = mag2db(mean(db2mag( h(idx))));
end
% process rest - if it exists
if mod(length(h),avgSamples) ~= 0
    idx = k*avgSamples+1:length(h);
    hSmooth(idx) = mag2db(mean(db2mag(h(idx))));
end
end