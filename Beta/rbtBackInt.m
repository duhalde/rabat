function R = rbtBackInt(h,onset,kneepoint)
%
%   Description: Compute decay curve from Schröders backwards integration
%                method
%
%   Usage: R = rbtBackInt(h,kneepoint)
%
%   Input parameters:
%       - h         : Impulse response 
%       - onset     : Index value at onset
%       - kneepoint : Index value at kneepoint between sound decay and noise floor
%   Output parameters:
%       - R: Normalized decay curve in dB 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 30-10-2012, Last update: 30-10-2012
%   Acoustic Technology, DTU 2012

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

R = cumsum(h(kneepoint:-1:onset).^2);
R = R(end:-1:1);
R = 10*log10(R);        % In dB
R = R-max(R);           % Normalize
%R = R';