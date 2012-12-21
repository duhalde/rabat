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
%       - CT: Calculated centre time in seconds
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012

% input handling
if nargin < 2
    error('Too few input arguments')
end

% Check size of h
[m,n] = size(h);
% ensure that octave bands are in the columns
if m<n
    h = h';
    [m,n] = size(h);
end

% initialize output column vector
TS = zeros(1,n);
idxstart = zeros(1,n);

for i = 1:n
% Determine proper onset of impulse response
[~,idxstart(i)] = max(h(:,i));
if idxstart(i) > floor(5e-3*fs)
idxstart(i) = idxstart(i)-floor(5e-3*fs);
else
    idxstart(i) = 1;
end
h2 = h(idxstart(i):end,i).^2;
% create time vector
t = 0:1/fs:length(h2)/fs-1/fs;
% Calculate Centre time parameter
TS(:,i) = sum(t*h2)/sum(h2);

end

end