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

% convert ir to mono, if stereo
DIM = size(ir);
if DIM(1)<DIM(2)
    ir = ir(1,:);
else
    ir = ir(:,1);
end

t = 0:1/fs:length(ir)/fs-1/fs;

TS = sum(t*ir)/sum(ir);