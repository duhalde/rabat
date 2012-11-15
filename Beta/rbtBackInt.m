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