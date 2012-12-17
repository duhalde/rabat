function [hCrop,t] = rbaCropIR(h,fs,varargin)
%
%   Description: Crop impulse response according to ISO 3382 and optionally 
%                Lundeby's method.
%
%   Usage: [hCrop,t] = rbaCropIR(h,fs[,knee])
%
%   Input parameters:
%       - h: Broadband impulse response. If h is a matrix then it's assumed
%       that h holds multiple broadband IRs which are aligned by xcorr
%       - fs: Sampling frequency
%
%   Optional input parameters:
%       - knee: An integer corresponding to the knee point of the broadband 
%               impulse response. That is the sample at which the decay and
%               noise floor meet.
%
%   Output parameters:
%       - hCrop: Cropped impulse response. 
%       - t: Time vector of cropped impulse response
%   
%   See also: rbaLundeby
%   
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 9-11-2012, Last update: 13-12-2012
%   Acoustic Technology, DTU 2012

[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

% Allocate
idxStart = zeros(1,n);
idxEnd = zeros(1,n);
hCrop = zeros(m,n);

% Find start sample of IR and crop onset
for i = 1:n
idxStart(i) = rbaStartIR(h(:,i));
end
idxStart = min(idxStart);

for i = 1:n
hCropOnset = h(idxStart:end,i);
    
if nargin == 2
    % Determine knee point of decay curve based on Lundebys method
    kneePoint = rbaLundeby(hCropOnset,fs);
elseif nargin == 3 
    % Get knee point from input
    kneePoint = ceil(varargin{1})-idxStart; 
end
% Crop impulse response
idxEnd(i) = ceil(kneePoint(end));

if n == 1
hCrop = hCropOnset(1:idxEnd(i),i);
else
hCrop(:,i) = [hCropOnset(1:idxEnd(i)); zeros(m-idxEnd(i),1)];
if i > 1
    [c, lags] = xcorr(hCrop(:,i-1), hCrop(:,i));
    delay = lags(max(c)==c);
    if delay > 0
        hCrop(:,i-1) = [hCrop(delay+1:end,i-1); zeros(delay,1)];
    elseif delay < 0
        hCrop(:,i) = [hCrop(abs(delay)+1:end,i); zeros(abs(delay),1)];
    end
end
end
end
t = (0:1/fs:length(hCrop)/fs-1/fs)';
end

function sampleStart = rbaStartIR(h)
% Description:    
%   The start of the impulse response should be determined from 
%   the broadband impulse response, where the signal first rises 
%   significantly above the background but is more than 20 dB below the
%   maximum.
%
% Squared impulse response
IRsqr = h.^2;

% Assume the last 90% is noise and calculate noise level
NoiseLevel = mean(IRsqr(round(.9*end):end,:));

% Get maximum of squared impulse response
[max_val, max_idx] = max(IRsqr,[],1);

% Catch bad impulse response
if any(max_val < 100*NoiseLevel)
    sampleStart = 1;
    return
end

% Normalize and find sample start
abs_dat = 10.*log10(IRsqr(1:max_idx)) - 10.*log10(max_val);
sampleStart = find(abs_dat > -20,1,'first');
if isempty(sampleStart)
    sampleStart = 1;
end
end
