function [T20,r2T20,T30,r2T30] = rbtRevTime(R,t)
%
%   NOTE: Note finished
%
%   Description: Calculate reverberation time from decay curve.
%
%   Usage: RT = rbtRevTime(R,t)
%
%   Input parameters:
%       - R: Normalized decay curve calculated by e.g. Schröeders method. If R is a
%            matrix it is assumed that R holds multiple decay curves, for
%            instance if R is given i octave bands.
%       - t: Time vector in seconds.
%   Output parameters:
%       - RT: Reverberation time in seconds.
%             
%       - r2 : Correlation coefficient squared. r2 = [0:1], with 1 corresponding 
%              to a perfect correlation between data and fit.
%
%   Ref: ISO 3382-1:2009(E) section (A.2.2)
%
%   See also: rbtBackInt
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 05-11-2012
%   Acoustic Technology, DTU 2012

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

L = zeros(m,n);
rSqr = zeros(n,1);

for ii = 1:n
kappa(:,ii) = curvature(R(:,ii));
idx = find(abs(kappa(:,ii))>1e-4,1,'first');
idx5 = find(R(1:idx,ii)<-5,1,'first');
idx25 = find(R(:,ii)<-25,1,'first');
idx35 = find(R(:,ii)<-35,1,'first');
idxEnd = find(R(1:idx,ii)<-35,1,'first');

if isempty(idxEnd)
   idxEnd = find(R(1:idx,ii)<-25,1,'first');
else 
    flag = 1;
end
    
coeff = polyfit(t(idx5:idxEnd),R(idx5:idxEnd,ii),1);
L(idx5:idxEnd,ii) = coeff(1)*t(idx5:idxEnd);

% Find first indices where R is is below -5 dB, -25 dB and -35 dB
%idx5 = find(R(:,ii)<-5,1,'first');   
%idx25 = find(R(:,ii)<-25,1,'first');
%idx35 = find(R(:,ii)<-35,1,'first');

%coeff20 = polyfit(t(idx5:idx25),R(idx5:idx25,ii),1);
%coeff30 = polyfit(t(idx5:idx35),R(idx5:idx35,ii),1);

%L20(idx5:idx25,ii) = coeff20(1)*t(idx5:idx25);
%L30(idx5:idx35,ii) = coeff30(1)*t(idx5:idx35);

% Compute r^2
rSqr(ii) = nonLinCheck(R(idx5:idxEnd,ii),L(idx5:idxEnd,ii));
%rSqr30(ii) = nonLinCheck(R(idx5:idx35,ii),L30(idx5:idx35,ii));

% Check non-linearity according to ISO 3382-1:2009 (sec. B.3)
if 1000*(1-rSqr(ii)) > 10                 
    disp('The decay curve looks non-linear. The calculated EDT may be wrong.')
end

T20(ii) = t(find(L(1:idx25,ii)<-25,1,'first')) - t(find(L(1:idx5,ii)<-5,1,'first'));
r2T20(ii) = rSqr(ii);

if flag == 1;
T30(ii) = t(find(L(1:idx35,ii)<-35,1,'first')) - t(find(L(1:idx5,ii)<-5,1,'first'));
r2T30(ii) = rSqr(ii);
end

end
end

function rSqr = nonLinCheck(R1,L1)
    rSqr = sum((L1(:)-mean(R1)).^2)/sum((R1(:)-mean(R1)).^2);
end

function k = curvature(R)
k = norm(diff(R,2))./(1+diff(R).^2).^(3/2);
k = k-max(k);
end