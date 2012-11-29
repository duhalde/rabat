function G = rbaStrength(h,h10,fs,varargin)
%
%   Description:    Calculate sound strength (G)
%
%   Usage: G = rbaStrength(h,h10,fs,tInf)
%
%   Input parameters:
%       - h: Impulse response
%       - h10: Impulse response measured at a distance of 10 m in a free field
%       - fs: Sampling frequency
%   Optional input:
%       - tInf: The time in seconds that is greater than or equal to 
%           the point at which the decay curve has decreased by 30 dB.
%   Output parameters:
%       - G: Strength in dB
%
%   Ref: ISO 3382-1:2009(E) section (A.2.1)
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 23-11-2012
%   Acoustic Technology, DTU 2012
%

[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

if nargin == 3
    tInf = m;
elseif nargin == 4
    tInf = varargin{1};
    tInf = ceil(tInf*fs);   % tInf in samples
    if tInf > m
        tInf = m;
        tSet = m/fs;        % For use in warning message
        warning(['tInf too long - set to ' num2str(tSet)])
    end
else 
    error('wrong number of input arguments.')
end

for i = 1:n
G(i) = 10*log10(sum(h(1:tInf,i).^2)/sum(h10(1:tInf).^2));
end