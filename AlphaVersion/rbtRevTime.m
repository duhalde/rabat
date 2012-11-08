function RT = rbtRevTime(RdB,fs,time)
%
%   Description: Calculate T30/T60 from decay curve
%
%   Usage: RT = rbtRevTime(R,fs)
%
%   Input parameters:
%       - R: Decay curve in dB
%       - fs: Sampling frequency
%   Output parameters:
%       - t30: Reverberation time 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 1-10-2012, Last update: 1-10-2012
%   Acoustic Technology, DTU 2012

if nargin < 3
    time = 30;  % default behaviour si to calc. T30
end

[~, idxStart] = min(abs(RdB+5));
[~, idxEnd] = min(abs(RdB+time+5));

% t = 0:1/fs:length(RdB)/fs-1/fs;
% 
% p = polyfit(t,RdB,1);
% p(1)

RT = 60/time*(idxStart-idxEnd)/fs;


