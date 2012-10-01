function t30 = rbtT30(RdB,fs)
%
%   Description: Calculate T30 from decay curve
%
%   Usage: t30 = rbtT30(R,fs)
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


[~, id5] = min(abs(RdB+5));
[~, id35] = min(abs(RdB+65));

% t = 0:1/fs:length(RdB)/fs-1/fs;
% 
% p = polyfit(t,RdB,1);
% p(1)

t30 = 2*(id35-id5)/fs;


