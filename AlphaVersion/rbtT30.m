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
%   Date: 30-9-2012, Last update: 30-9-2012
%   Acoustic Technology, DTU 2012

% Calculate in dB and normalize to 0 dB
%RdB = 10*log10(R); 
%RdB = RdB-max(RdB);

n5 = find(RdB<=-5,1);
n35 = find(RdB<=-35,1);

t30 = 2*(n35-n5)/fs;

