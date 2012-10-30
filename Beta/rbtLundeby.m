function [knee, rmsNoise] = rbtLundeby(h2,fs,maxIter,avgTime,noiseHeadRoom,dynRange)

% NOTE function mag2db is from Control Systems Toolbox, should be changed to
% 20*log10...

if nargin < 3
    %run maximun 5 times
    maxIter = 5;
    avgTime = 10e-3;     % 10-50 ms averaging
    noiseHeadRoom = 10; % dB
    dynRange = 20;      % dB

end

%% STEP 1
% averaging over 10-50 ms to make a smoother curve

avgSamples = round(avgTime*fs);  % number of samples to average over

% smooth the response
hSqrSmooth = smooth(h2,avgSamples);

rmsNoise = zeros(maxIter+1,1);
%% STEP 2
% determine background noise level
noise_data = hSqrSmooth(floor(0.9*length(hSqrSmooth)):end);
% find rms value of noise_data
rmsNoise(1) = -sqrt(mean(noise_data.^2));

%% STEP 3
% last averaged time interval, with value above noise floor + 5 dB
id2 = find(hSqrSmooth>(rmsNoise(1)+noiseHeadRoom),1,'last');

% linear regression on smoothed rir until the SPL is noise floor + 5dB
coeff = polyfit((0:id2-1)',hSqrSmooth(1:id2),1);

a = coeff(1);
b = coeff(2);

%% STEP 4
% preliminary cross point
preCross = zeros(maxIter+1,1);
preCross(1) = (rmsNoise(1)-b)/a;

%% STEP 5
% find number of samples in 10 dB decay
numSamplesIn10dB = ceil(-10/a);
% divide 10dB into 10 intervals
avgSamples = ceil(numSamplesIn10dB/10);

%% STEP 6
hSqrSmooth = smooth(h2,avgSamples);

%% subplot settings
xdim = 2;
ydim = round((maxIter+1)/xdim);

%figure

%% STEP 7

for k=1:maxIter
    %%
    % Plots for debugging  
    %subplot(xdim,ydim,k); plot(hSqrSmooth); hold all;
    %plot([0,length(hSqrSmooth)],[rmsNoise(k), rmsNoise(k)],'r--');
    
    % cross point between decay and noise-5dB
    noiseIdx = ceil((rmsNoise(k)-noiseHeadRoom-b)/a);
    % make sure we have 10% of response in noise estimate
    if noiseIdx > floor(0.9*length(h2))
        noiseIdx = floor(0.9*length(h2));
    end
    
    %plot([noiseIdx,noiseIdx],[min(hSqrSmooth),0],'k--');
    
    
    % determine background noise level
    noise_data = hSqrSmooth(noiseIdx:end);
    % find rms value of noise_data NOTE Negative values, since impulse 
    % response is normalised to 0 dB
    rmsNoise(k+1) = -sqrt(mean(noise_data.^2));
    
    %% STEP 8
    % last averaged time interval, with value above noise floor + 5 dB
    id2 = find(hSqrSmooth>(rmsNoise(k+1)+noiseHeadRoom),1,'last');
    % last averaged time interval, with value above noise floor + 15 dB
    id1 = find(hSqrSmooth>(rmsNoise(k+1)+dynRange+noiseHeadRoom),1,'last');
    if isempty(id1)
        id1 = 1;
    end
    
    %plot([0,length(hSqrSmooth)],[rmsNoise(k+1)+noiseHeadRoom,rmsNoise(k+1)+noiseHeadRoom],'b--')
    %plot([0,length(hSqrSmooth)],[rmsNoise(k+1)+dynRange+noiseHeadRoom,rmsNoise(k+1)+dynRange+noiseHeadRoom],'b--')
    
    % linear regression on smoothed rir until the SPL is noise floor + 5dB
    coeff = polyfit((id1:id2)',hSqrSmooth(id1:id2),1);
    a = coeff(1);
    b = coeff(2);
    %% STEP 9
    % preliminary cross point
    preCross(k+1) = (rmsNoise(k+1)-b)/a;
    x = (0:length(hSqrSmooth));
    %plot(x,a.*x+b,'k');
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