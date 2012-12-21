function R = rbaSchroeder(h,fs,knee)
%
%   Description: Compute decay curve from Schröders backwards integration
%                method
%
%   Usage: R = rbtSchroeder(h,fs,noiseComp[,option])
%
%   Input parameters:
%       - h         : Impulse response
%       - fs        : Sampling frequency
%   Optional input parameters:
%       - knee      : Index value for the kneepoint in samples
%   Output parameters:
%       - R: Normalized decay curve in dB
%
%   Ref: ISO 3382-1:2009(E) section 5.3.3
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 30-10-2012, Last update: 30-11-2012
%   Acoustic Technology, DTU 2012

% Check size of h
[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

h2 = h.^2;

R = zeros(m,n);

for i = 1:n
   
    % Calculate knee and RMS noise from Lundeby 
    if nargin == 2
    [knee, rmsNoise] = rbaLundeby(h(:,i),fs);
    knee = knee(end);
    rmsNoise = rmsNoise(end);        
    % Calculate knee and RMS noise from user input
    elseif nargin == 3
    h2dB = 10*log10(h2(:,1));
    h2dB = h2dB-max(h2dB);
    rmsNoise = mean(h2dB(knee:end));
    end
    
%% !!for later reference!!    
%     % Noise compensation
%     rmsNoise can be found e.g. from rbaLundeby() or as an average of the
%     last 10 % of h
% 
%     if noiseComp == 1
%         h2dB = 10*log10(h2(:,i));
%         h2dB = h2dB-max(h2dB);
%         % Average in intervals of 5ms
%         tAvg = ceil(fs*10e-3);
%         hSmooth = smooth(h2dB,tAvg);
%         idx = find(hSmooth(1:knee)<rmsNoise+10,1,'first');
%         coeff = polyfit((idx:knee),hSmooth(idx:knee)',1);
%         A = coeff(1);
%         B = coeff(2);
%         if A == 0   % Try another interval if A is zero
%             tAvg = ceil(fs*10e-3);
%             hSmooth = smooth(h2dB,tAvg);
%             idx = find(hSmooth(1:knee)<rmsNoise+10,1,'first');
%             coeff = polyfit((idx:knee),hSmooth(idx:knee)',1);
%             A = coeff(1);
%             B = coeff(2);
%         end
%         E0 = 10^(B/10);
%         a = log(10^(A/10));
%         E = -(E0/a)*exp(a*knee);
%         % E should be a positive parameter, if it's negative something went wrong.
%         if E < 0    
%             E = 0;
%         end
%         else
%         E = 0;      
%     end
    R(1:knee,i) = cumsum(h2(knee:-1:1,i));
    R(1:knee,i) = 10*log10(R(knee:-1:1,i));
    R(1:knee,i) = R(1:knee,i)-max(R(1:knee,i));
    
    % Catch small values of decay curve and limit to 100 dB dynamic range
    % This will result in a decay curve ending in a bend towards -100 dB
    % and constant from there.
    idx = find(R(1:knee,i) < -100);
    if ~isempty(idx)
    R(idx,i) = -100;
    end
    R(knee+1:end,i) = -100;
end

end


function hSmooth = smooth(h,avgSamples)
% process in blocks
hSmoothSize = length(h)/avgSamples;
hSmooth = zeros(length(h),1);
for k = 1:floor(hSmoothSize)
    idx = ((k-1)*avgSamples+1):k*avgSamples;
    hSmooth(idx) = mean(h(idx));
end
% process rest - if it exists
if mod(length(h),avgSamples) ~= 0
    idx = k*avgSamples+1:length(h);
    hSmooth(idx) = mean(h(idx));
end

end