function [EDT,r2p] = rbaEDT(R,t)
%
%   Description: Calculate Early Decay Time (EDT) as the slope of the
%   fitted decay curve from 0 dB to -10dB
%
%   Usage: [EDT,r2p] = rbaEDT(R,t)
%
%   Input parameters:
%       - R: Normalized decay curve calculated by e.g. Schröeders method. If R is a
%            matrix it is assumed that R holds multiple decay curves, for
%            instance if R is given i octave bands.
%       - t: Time vector in seconds.
%   Output parameters:
%       - EDT: Early Decay Time in seconds.
%       - r2p: Correlation coefficient 1000*(1-r2), with 0 corresponding 
%              to a perfect correlation between data and fit.
%              The decay curve is non-linear for r2p > 10. 
%              According to ISO 3382-1:2009 (sec. B.3)
%
%   Ref: ISO 3382-1:2009(E) section (A.2.2)
%
%   See also: rbaBackInt
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 10-11-2012, Last update: 10-11-2012
%   Acoustic Technology, DTU 2012

% Check if R is a vector or matrix
[m,n] = size(R);

% Make sure R is oriented correctly
if m<n
    R = R';
    [m,n] = size(R);
end

% Check size of t and make sure it's oriented correctly
[k,l] = size(t);
if k<l
    t = t';
end

% Allocate 
L = zeros(m,n);
rSqr = zeros(n,1);
EDT = zeros(n,1);
r2p = zeros(n,1);

for ii = 1:n
idx = find(R(:,ii)<-10,1,'first');    % Find first index where R is is below -10 dB

coeff = polyfit(t(1:idx),R(1:idx,ii),1);    % Linear regression

L(1:idx,ii) = coeff(1)*t(1:idx);    % Fitted curve

% Compute r^2
r2p(ii) = nonLinCheck(R(1:idx,ii),L(1:idx,ii));

% Check non-linearity according to ISO 3382-1:2009 (sec. B.3)
if 1000*(1-rSqr(ii)) > 10                 
    warning('The decay curve looks non-linear. The calculated EDT may be wrong.')
end

EDT(ii) = t(find(L(1:idx,ii)<-10,1,'first'));
r2p(ii) = 1000*(1-r2);
end
end

function rSqr = nonLinCheck(R1,L1)
    rSqr = sum((L1(:)-mean(R1)).^2)/sum((R1(:)-mean(R1)).^2);
end

