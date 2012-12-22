function [knee, rmsNoise] = rbaLundeby(h,fs,maxIter,avgTime,noiseHeadRoom,dynRange)
%
%   Description: Determine the sample (knee-point) at which the sound decay of IR meets
%                the noise-floor.
%
%   Usage: [knee, rmsNoise] = rbaLundeby(h,fs,maxIter,avgTime,noiseHeadRoom,dynRange)
%
%   Input parameters:
%       - h: Impulse response (best results are obtained if the impulse response has been cropped at the onset)
%       - fs: Sampling frequency
%   Optional input parameters:
%       - maxIter: Maximum number of iterations (default = 5)
%       - avgTime: Time averaging in seconds (default = 50e-3). Longer
%       intervals are better for lower frequencies.
%       - noiseHeadRoom: Interval in dB above noise level to be used for
%       fitting curve (default = 10 dB)
%       - dynRange: Dynamic range in dB to be used in calculating fit.
%       Larger ranges are better if impulse response allows it (default =
%       20 dB)
%   Output parameters:
%       - knee: Knee-point in samples
%       - rmsNoise: The root-mean-square level of noise floor in dB
%
%   Reference: Lundeby, A, T E Vigran, H Bietz, and M Vorlander. 
%              Uncertainties of Measurements in Room Acoustics. 
%              Acta Acustica United with Acustica 81 (4): 344?355. (1995)
%               
%              Antsalo, P, A Makivirta, V Valimaki, T Peltonen, and M Karjalainen.
%              Estimation of Modal Decay Parameters From Noisy Response Measurements. 
%              Convention paper. (2012)
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 11-9-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012

if nargin < 3
    maxIter = 5;            %run maximun 5 times
    avgTime = 50e-3;        % 10-50 ms averaging
    intervalsIn10dB = 10;   % 3-10
    noiseHeadRoom = 10;     % dB
    dynRange = 20;          % dB
    
end

% Make sure h is oriented properly
[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

% Allocate
h2 = zeros(m,n);
hSqrSmooth = zeros(m,n);
for i = 1:n
    % Squared impulse response normalized in dB
    h2(:,i) = 10*log10(h(:,i).^2);
    h2(:,i) = h2(:,i)-max(h2(:,i));
    %% STEP 1
    % averaging over 10-50 ms to make a smoother curve
    
    avgSamples = round(avgTime*fs);  % number of samples to average over
    
    % smooth the response
    hSqrSmooth(:,i) = smooth(h2(:,i),avgSamples);
    
    rmsNoise = zeros(maxIter+1,1);
    %% STEP 2
    % determine background noise level
    noise_data = hSqrSmooth(floor(0.9*length(hSqrSmooth(:,i))):end,i);
    % find rms value of noise_data
    rmsNoise(1) = -sqrt(mean(noise_data.^2));
    
    %% STEP 3
    % last averaged time interval, with value above noise floor + 5 dB
    id2(i) = find(hSqrSmooth(:,i)>(rmsNoise(1)+noiseHeadRoom),1,'last');
    
    % linear regression on smoothed rir until the SPL is noise floor + 5dB
    coeff = polyfit((0:id2(i)-1)',hSqrSmooth(1:id2(i),i),1);
    
    a = coeff(1);
    b = coeff(2);
    
    %% STEP 4
    % preliminary cross point
    preCross = zeros(maxIter+1,1);
    preCross(1) = (rmsNoise(1)-b)/a;
    %if preCross(1)>length(h2)
    %    preCross(1) = length(h2);
    %end
    %% STEP 5
    % find number of samples in 10 dB decay
    numSamplesIn10dB = ceil(-10/a);
    % divide 10dB into 10 intervals
    avgSamples = ceil(numSamplesIn10dB/intervalsIn10dB);
    
    %% STEP 6
    hSqrSmooth(:,i) = smooth(h2(:,i),avgSamples);
    
    
    %% STEP 7
    
    for k=1:maxIter
        % cross point between decay and noise-5dB
        noiseIdx = ceil((rmsNoise(k)-noiseHeadRoom-b)/a);
        % make sure we have 10% of response in noise estimate
        if noiseIdx > floor(0.9*length(h2))
            noiseIdx = floor(0.9*length(h2));
        end
        
        % determine background noise level
        noise_data = hSqrSmooth(noiseIdx:end,i);
        % find rms value of noise_data NOTE Negative values, since impulse
        % response is normalised to 0 dB
        rmsNoise(k+1) = -sqrt(mean(noise_data.^2));
        
        %% STEP 8
        % last averaged time interval, with value above noise floor + 5 dB
        id2 = find(hSqrSmooth(:,i)>(rmsNoise(k+1)+noiseHeadRoom),1,'last');
        % last averaged time interval, with value above noise floor + 15 dB
        id1 = find(hSqrSmooth(:,i)>(rmsNoise(k+1)+dynRange+noiseHeadRoom),1,'last');
        if isempty(id1)
            id1 = 1;
        end

        % linear regression on smoothed rir until the SPL is noise floor + 5dB
        coeff = polyfit((id1:id2)',hSqrSmooth(id1:id2,i),1);
        a = coeff(1);
        b = coeff(2);
        %% STEP 9
        % preliminary cross point
        preCross(k+1) = (rmsNoise(k+1)-b)/a;
    end
    
    knee = floor(preCross);
    
end

% make sure the knee point is not outside the impulse response
for i = 1:length(knee)
    if knee(i) > length(h)
        knee(i) = length(h);
    end
end

end

function hSmooth = smooth(h,avgSamples)
% Smoothing function for time-averaging
% process in blocks
hSmoothSize = length(h)/avgSamples;
hSmooth = zeros(length(h),1);
for k = 1:floor(hSmoothSize)
    idx = ((k-1)*avgSamples+1):k*avgSamples;
    hSmooth(idx) = 20*log10(mean(10.^(h(idx)/20)));
end
% process rest - if it exists
if mod(length(h),avgSamples) ~= 0
    idx = k*avgSamples+1:length(h);
    hSmooth(idx) = 20*log10(mean(10.^(h(idx)/20)));
end

end