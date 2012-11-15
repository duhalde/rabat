function R = rbtBackInt(h,onset,kneepoint)
%
%   Description: Compute decay curve from Schröders backwards integration
%                method
%
%   Usage: R = rbtBackInt(h,onset,kneepoint)
%
%   Input parameters:
%       - h         : Impulse response 
%       - onset     : Index value at onset
%       - kneepoint : Index value at kneepoint between sound decay and noise floor
%   Output parameters:
%       - R: Normalized decay curve in dB 
%
%   Ref: ISO 3382-1:2009(E) section 5.3.3
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 30-10-2012, Last update: 5-11-2012
%   Acoustic Technology, DTU 2012

% Check size of h
[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

switch nargin
    case 1
        onset = uint32(1);
        kneepoint = uint32(length(h));
    case 2
        onset = uint32(onset);
        kneepoint = uint32(length(h));
    case 3
        onset = uint32(onset);
        kneepoint = uint32(floor(kneepoint));
    otherwise
        error('Wrong number of input argument')
end

R = zeros(m,n);

for i = 1:n
R(:,i) = cumsum(h(kneepoint:-1:onset,i).^2);
R(:,i) = R(end:-1:1,i);
R(:,i) = 10*log10(R(:,i));        % In dB
R(:,i) = R(:,i)-max(R(:,i));      % Normalize
end