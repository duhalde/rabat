function sampleStart = rbtStartIR(h)
%
%   Description:    
%       The start of the impulse response should be determined from 
%       the broadband impulse response, where the signal first rises 
%       significantly above the background but is more than 20 dB below the
%       maximum.
%
%   Usage: sampleStart = rbtStartIR(h)
%
%   Input parameters:
%       - h: 
%   Output parameters:
%       - sampleStart: 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 11-9-2012, Last update: 11-9-2012
%   Acoustic Technology, DTU 2012
% 
%   Reference: ISO 3382-1:2009(E)
%

[m,n] = size(h);

if m<n
    h = h';
end

% Squared impulse response
IRsqr = h.^2;

% Assume the last 90% is noise and calculate noise level
NoiseLevel = mean(IRsqr(round(.9*end):end,:));

% Get maximum of squared impulse response
[max_val, max_idx] = max(IRsqr,[],1);

% Catch bad impulse response
if any(max_val < 100*NoiseLevel)
    disp('The SNR too bad or this is not an impulse response.');
    sampleStart = 1;
    return
end

% Normalize and find sample start
abs_dat = 10.*log10(IRsqr(1:max_idx)) - 10.*log10(max_val);
sampleStart = find(abs_dat > -20,1,'first');

end