function [RT, r2p,dynRange] = rbaReverberationTime(R,t,varargin)
%
%
%   Description: Calculate reverberation time from decay curve.
%
%   Usage: [RT, r2p, dynRange] = rbtReverberationTime(R,t,'all')
%
%   Input parameters:
%       - R: Normalized decay curve calculated by e.g. Schröeders method. If R is a
%            matrix it is assumed that R holds multiple decay curves, for
%            instance if R is given i octave bands.
%       - t: Time vector in seconds.
%   Optional input parameters:
%            - 'best': Get the best RT (T60 > T30 > T20)
%                      depending on the dynamic range. (default)
%            - 'all' : Get all T20, T30, T60 in a matrix if the dynamic
%                      range allows it.
%   Output parameters:
%       - RT: Reverberation time in seconds.
%             The size of RT depends on the available dynamic range and 
%             the input string option.
%             If a dynamic range of 65 dB is available then T60, T30 and
%             T20 is computed (if option 'all' i chosen), e.g. if R has 
%             4 columns (4 octave bands) then RT is a 3x4 matrix:
%
%                  ( 1.2, 1.1, 1.4, 1.3 ) : T20 
%             RT = ( 1.1, 1.3, 1.2, 1.2 ) : T30
%                  ( 0.9, 1.0, 1.1, 1.2 ) : T60
%                   
%       - r2p: Correlation coefficient 1000*(1-r2), with 0 corresponding 
%              to a perfect correlation between data and fit.
%              The decay curve is non-linear for r2p > 10. 
%              According to ISO 3382-1:2009 (sec. B.3)
%
%   Ref: ISO 3382-1:2009(E) and ISO 3382-2:2008
%
%   See also: rbtBackInt
% 
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 29-11-2012
%   Acoustic Technology, DTU 2012

if nargin == 2
    option = 'best'; 
elseif nargin == 3
    option = varargin{1};
end

% Get size of R
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
dynRange = zeros(1,n);

% Calculate the available dynamic range by assuming the last 5% is noise.
for ii = 1:n
    idx = floor(0.95*length(R(:,ii)));  % Cut away the last 5%.
    dynRange(ii) = R(1,ii)-R(idx,ii);   % Calculate the dynamic range
end

if min(dynRange)<65
    if min(dynRange)<35
        if min(dynRange)<25
            error('Dynamic range too small to compute RT. Consider using EDT.')
        else 
            switch lower(option) 
                case 'best'
                    [RT,r2] = varT(R,t,idx,[5 25]);
                    r2p = 1000*(1-r2);
                case 'all'
                    [RT,r2] = varT(R,t,idx,[5 25]);
                    r2p = 1000*(1-r2);
            end
        end
    else
        switch lower(option) 
            case 'best'
                [RT,r2] = varT(R,t,idx,[5 35]);
                r2p = 1000*(1-r2);
            case 'all'
                [RT20,r220] = varT(R,t,idx,[5 25]);
                [RT30,r230] = varT(R,t,idx,[5 35]);
                RT = [RT20; RT30];
                r2p = 1000*[1-r220; 1-r230];
        end
    end
else
    switch lower(option) 
        case 'best'
            [RT,r2] = varT(R,t,idx,[5 65]);
            r2p = 1000*(1-r2);
        case 'all'
            [RT20,r220] = varT(R,t,idx,[5 25]);
            [RT30,r230] = varT(R,t,idx,[5 35]);
            [RT60,r260] = varT(R,t,idx,[5 65]);
            RT = [RT20; RT30; RT60];
            r2p = 1000*[1-r220; 1-r230; 1-r260];
    end
end

end


function [RT,r2] = varT(R,t,idx,lim)
[~,n] = size(R);
[k,~] = size(t);
up = lim(1); 
low =lim(2);
L = zeros(k,n);
RT = zeros(1,n);
r2 = zeros(1,n);
for ii = 1:n
    idxup = find(R(1:idx,ii)<-up,1,'first');
    idxlow = find(R(1:idx,ii)<-low,1,'first');
    coeff = polyfit(t(idxup:idxlow),R(idxup:idxlow,ii),1);
    L(:,ii) = coeff(1)*t+coeff(2);
    
    if low == 65
        RT(ii) = -60/coeff(1);
    elseif low == 35
        RT(ii) = 2*(-30/coeff(1));
    elseif low == 25
        RT(ii) = 3*(-20/coeff(1));
    end
    r2(ii) = nonLinCheck(R(idxup:idxlow,ii),L(idxup:idxlow,ii));
end
end


function rSqr = nonLinCheck(Ri,Li)
    rSqr = sum((Li(:)-mean(Ri)).^2)/sum((Ri(:)-mean(Ri)).^2);
end