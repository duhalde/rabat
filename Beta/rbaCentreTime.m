function TS = rbaCentreTime(h,fs)
%
%   Description:    Calculate centre time in accordance with ISO-3382
%
%   Usage: CT = rbaCentreTime(h,fs)
%
%   Input parameters:
%       - h: Impulse response
%		- fs: Sampling frequency 
%   Output parameters:
%       - CT: 	Calculated centre time
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 17-12-2012
%   Acoustic Technology, DTU 2012

% input handling
if nargin < 2
    error('Too few input arguments')
end

% convert h to mono, if stereo
DIM = size(h);
if DIM(1)<DIM(2)
    h = h(1,:);
else
    h = h(:,1);
end

t = 0:1/fs:length(h)/fs-1/fs;

TS = sum(t*h)/sum(h);

end