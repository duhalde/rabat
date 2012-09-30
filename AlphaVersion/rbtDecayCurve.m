function R = rbtDecayCurve(h)
%
%   Description: Calculate the decay curve from Schröders backwards
%   integration method.
%
%   Usage: R = rbtDecayCurve(h)
%
%   Input parameters:
%       - h: Impulse response 
%   Output parameters:
%       - R: Normalized decay curve in dB 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 30-9-2012, Last update: 30-9-2012
%   Acoustic Technology, DTU 2012

% Find peak in impulse response
[maxpeak k] = max(h);

R = cumsum(h(end:-1:k).^2);
R = R(end:-1:1);
R = 10*log10(R);        % In dB
R = R-max(R);           % Normalize
