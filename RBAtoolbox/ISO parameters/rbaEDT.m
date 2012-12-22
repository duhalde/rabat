function [EDT,r2p,stdDev] = rbaEDT(R,t)
%
%   Description: Calculate Early Decay Time (EDT) from the slope of a
%   fitted regression line from 0 dB to -10dB according to ISO 3382.
%
%   Usage: [EDT,r2p,stdDev] = rbaEDT(R,t)
%
%   Input parameters:
%       - R: Normalized decay curve calculated by e.g. Schröeders method. If R is a
%            matrix it is assumed that R holds multiple decay curves, for
%            instance if R is given i octave bands.
%       - t: Time vector in seconds.
%   Output parameters:
%       - EDT: Early Decay Time in seconds. If the input R is a mxn matrix, EDT
%       is returned as a vector 1xn long. 
%       - r2p: Correlation coefficient 1000*(1-r2), with 0 corresponding
%              to a perfect correlation between data and fit.
%              The decay curve is non-linear for r2p > 10.
%              According to ISO 3382-1:2009 (sec. B.3)
%       - stdDev : Standard deviation of the linear regression fit.
%
%   Ref: ISO 3382-1:2009(E) section (A.2.2)
%
%   See also: rbaReverberationTime, rbaSchroeder, rbaCropIR, rbaLundeby
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 10-11-2012, Last update: 21-11-2012
%   Acoustic Technology, DTU 2012

% Check if R is a vector or matrix
[m,n] = size(R);

% Make sure R is oriented correctly
if m<n
    R = R';
    [~,n] = size(R);
end

% Check size of t and make sure it's oriented correctly
[k,l] = size(t);
if k<l
    t = t';
end

% Allocate
EDT = zeros(1,n);
r2p = zeros(1,n);
idx = zeros(1,n);
dynRange = zeros(1,n);
stdDev = zeros(1,n);
% Calculate EDT for each column of R:
for ii = 1:n
    % If the decay curve has been truncated with user specified values,
    % e.g. - 100 dB, determine the last index of the original decay.
    idxFloor = find(R(:,ii)>min(R(:,ii)),1,'last');
    % Cut away the last 5% to remove the bend on the decay curve.
    idx(ii) = floor(0.95*length(R(1:idxFloor,ii)));  
    dynRange(ii) = R(1,ii)-R(idx(ii),ii);   % Calculate the dynamic range
    if dynRange(ii)<15
       warning('The dynamic range is less than 15 dB. The EDT might be untrustworthy.')
    end
    % Make a linear regression
    idx10 = find(R(1:idx(ii),ii)<-10,1,'first');
    coeff = polyfit(t(1:idx10),R(1:idx10,ii),1);
    L = coeff(1)*t(1:idx10)+coeff(2);
    % Check for non-linearity of fitted curve
    r2 = nonLinCheck(R(1:idx10,ii),L(1:idx10));
    r2p(ii) = 1000*(1-r2);
    if r2p(ii) > 10
        warning('The decay looks non-linear.')
    end
    stdDev(ii) = std(R(1:idx10,ii)-L(1:idx10));
    EDT(ii) = 6*(-10/coeff(1));
end
end


function rSqr = nonLinCheck(R1,L1)
rSqr = sum((L1(:)-mean(R1)).^2)/sum((R1(:)-mean(R1)).^2);
end

