function R = rbtBackIntComp(h,kneepoint,energyCompensation)
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
%       - method    : 'comp' - with energy compensation (default)
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

if isempty(kneepoint)
    kneepoint = length(h);
else
    kneepoint = floor(kneepoint);
end

R = zeros(kneepoint,n);
h2 = zeros(m,1);

for i = 1:n
    
    h2 = h(:,i).^2;
    
    R(:,i) = cumsum(h2(kneepoint:-1:1));
    R(:,i) = R(end:-1:1,i);
    R(:,i) = 10*log10(R(:,i));        % In dB
    R(:,i) = R(:,i)-max(R(:,i));      % Normalize
    
    
    if energyCompensation
        
        if kneepoint > floor(0.9*length(h2))
            noiseIdx = floor(0.9*length(h2));
        else
            noiseIdx = kneepoint;
        end
        rmsNoise = sqrt(mean(h2(noiseIdx:end).^2));
        
        idx = find(h2>rmsNoise*10,1,'last');    % Add 10 dB
        
        coeff = polyfit(idx:noiseIdx,h2(idx:noiseIdx)',1);
        
        A = coeff(1);
        B = coeff(2);
        
        E = - (B/A)*exp(A*noiseIdx);
        h2 = h2 + E;
    end
end



end
