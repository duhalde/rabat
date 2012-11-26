function [knee, rmsNoise,varargout] = rbtLundeby(h,fs,maxIter,avgTime,noiseHeadRoom,dynRange)
%
%   Description:    
%
%   Usage: y = function_name(x,...)
%
%   Input parameters:
%       - x: 
%   Output parameters:
%       - y: 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 11-9-2012, Last update: 11-9-2012
%   Acoustic Technology, DTU 2012

if nargin < 3
    maxIter = 5;            %run maximun 5 times
    avgTime = 10e-3;        % 10-50 ms averaging
    intervalsIn10dB = 10;   % 3-10
    noiseHeadRoom = 10;     % dB
    dynRange = 20;          % dB

end

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
    
    %plot([0,length(hSqrSmooth)],[rmsNoise(k+1)+noiseHeadRoom,rmsNoise(k+1)+noiseHeadRoom],'b--')
    %plot([0,length(hSqrSmooth)],[rmsNoise(k+1)+dynRange+noiseHeadRoom,rmsNoise(k+1)+dynRange+noiseHeadRoom],'b--')
    
    % linear regression on smoothed rir until the SPL is noise floor + 5dB
    coeff = polyfit((id1:id2)',hSqrSmooth(id1:id2,i),1);
    a = coeff(1);
    b = coeff(2);
    %% STEP 9
    % preliminary cross point
    preCross(k+1) = (rmsNoise(k+1)-b)/a;
    %if preCross(k+1)>length(h2)
    %    preCross(k+1) = length(h2);
    %end
    x = (0:length(hSqrSmooth(:,i)));
    %plot(x,a.*x+b,'k');
end

knee = floor(preCross);
A = fs*10^(a/10);
B = 10^(b/10);
C = -(B/A)*exp(A * knee(end)/fs);
varargout{1} = C;
end
end

function hSmooth = smooth(h,avgSamples)

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