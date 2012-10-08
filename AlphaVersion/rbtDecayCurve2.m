function Ld = rbtDecayCurve(h)
%
%   Description: Calculate the decay curve from Schröders backwards
%   integration method.
%
%   Usage: Ld = rbtDecayCurve(h)
%
%   Input parameters:
%       - h: Impulse response 
%   Output parameters:
%       - Ld: Normalized decay curve in dB 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 30-9-2012, Last update: 30-9-2012
%   Acoustic Technology, DTU 2012

% Find peak in impulse response
smooth = 0;
%if ~isempty(vargin)
%    smooth = 1;
%end


[~, k] = max(h);

R = cumsum(h(end:-1:k).^2);
R = R(end:-1:1);
if smooth
    h2T = sum(h(end:-1:k).^2);
    Ld = 10*log10(R./h2T);
else
    Ld = 10*log10(R);        % In dB
    Ld = R-max(Ld);           % Normalize
end