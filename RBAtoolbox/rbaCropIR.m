function [hCrop,t,Onset,Knee] = rbaCropIR(h,fs,typeOfCrop)
%
%   Description: Crop impulse response according to ISO 3382 and optionally
%                Lundeby's method.
%
%   Usage: [hCrop,t,Onset,Knee] = rbaCropIR(h,fs)
%          [hCrop,t,Onset,Knee] = rbaCropIR(h,fs,'onset')
%          [hCrop,t,Onset,Knee] = rbaCropIR(h,fs,'tight')
%
%   Input parameters:
%       - h: Broadband impulse response. If h is a matrix then it's assumed
%       that h holds multiple broadband IRs which are aligned by xcorr
%       - fs: Sampling frequency
%
%   Optional input parameters:
%       - typeOfCrop: determines the methods used for cropping
%           'onset': crops to -20 dB before peak (default)
%           'tight': crops both at onset and at the intersection between
%           noise and decay, i.e. the knee point
%
%   Output parameters:
%       - hCrop: Cropped impulse response.
%       - t: Time vector of cropped impulse response
%
%       NOTE: the returned indexes are relative to the time of the input.
%       And points out the boundaries of output t in the input h.
%       - Onset: Sample at which impulse begins
%       - Knee: Sample at which sound decay meets noise floor (knee point).
%                   if no cut is made at the knee (typeOfCut = 'onset', default) 
%                   the length of h is returned.
%
%   See also: rbaLundeby
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 9-11-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012

[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

if nargin == 2
    cutAtOnset = 1;
    cutAtKnee = 0;
elseif nargin == 3
    switch lower(typeOfCrop)
        case 'onset'
            cutAtKnee = 0;
        case 'tight'
            cutAtKnee = 1;
        otherwise
            error('Wrong string argument. Use ''onset'', ''tight'', or leave it out!')
    end
end

% Allocate
idxStart = zeros(1,n);
knee = zeros(1,n);

% Find start sample of IR and crop onset
for i = 1:n
    idxStart(i) = rbaStartIR(h(:,i));
end
Onset = min(idxStart); % location of onset
% crop impulse at onset
hCrop = h(Onset:end,:);

if cutAtKnee
    for i = 1:n
        % Determine knee point of decay curve based on Lundebys method
        kneePoints = rbaLundeby(hCrop(:,i),fs);
        
        % use last iteration value
        knee(i) = ceil(kneePoints(end));
        
        % Crop impulse response
        if n == 1   % if only one
            hCrop = hCrop(1:knee(i),i);
        else % if several irs, they will be lined up by their peaks, and zero-padded
            hCrop(:,i) = [hCrop(1:knee(i)); zeros(m-knee(i),1)];
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
end
% define output time vector
t = (0:1/fs:length(hCrop)/fs-1/fs)';

if knee == 0
    % no knee point has been found
    Knee = length(h);
else
    % return onset and knee point with reference to the time of the input
    Knee = knee + Onset;   % knee are found after cutting at idxStart
end

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
