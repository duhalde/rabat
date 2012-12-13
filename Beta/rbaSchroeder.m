function R = rbaSchroeder(h,fs,flag,varargin)
%
%   Description: Compute decay curve from Schröders backwards integration
%                method
%
%   Usage: R = rbtSchroeder(h,fs,flag[,option])
%
%   Input parameters:
%       - h         : Impulse response
%       - fs        : Sampling frequency
%       - flag      : 1 or 0. Enable noise compensation 
%   Optional input parameters:
%       - 'Lundeby' : String enabling the use of Lundeby's method to determine
%                     the kneepoint between decay and noise floor (default)
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

if nargin == 3
    [knee, rmsNoise] = rbaLundeby(h,fs);
elseif nargin == 4 && strcmpi(varargin{1},'Lundeby');
    [knee, rmsNoise,varargout] = rbaLundeby(h,fs);
elseif nargin == 4 && isnumeric(varargin{1})
    knee = ceil(varargin{1});
    h2dB = 10*log10(h2);
    h2dB = h2dB-max(h2dB);
    rmsNoise = -sqrt(mean(h2dB(knee:end).^2));
elseif nargin<3 && nargin > 4
    error('Wrong number of input arguments')
end

%if (flag~=1 || flag~=0)
%    error('Flag must be set to 1 or 0')
%end

R = zeros(knee,n);

for i = 1:n
    
    % Noise compensation
    if flag == 1
        % Average in intervals of 5ms
        tAvg = ceil(fs*1e-3);
        hSmooth = smooth(h2dB(:,i),tAvg);
        idx = find(hSmooth(1:knee)<rmsNoise+10,1,'first');
        coeff = polyfit((idx:knee),hSmooth(idx:knee)',1);
   
        A = coeff(1);
        B = coeff(2);
        if A == 0   % Try another interval if A is zero
            tAvg = ceil(fs*10e-3);
            hSmooth = smooth(h2dB(:,i),tAvg);
            idx = find(hSmooth(1:knee)<rmsNoise+10,1,'first');
            coeff = polyfit((idx:knee),hSmooth(idx:knee)',1);
            A = coeff(1);
            B = coeff(2);
        end
        E0 = 10^(B/10);
        a = log(10^(A/10));
        E = -(E0/a)*exp(a*knee);
    else
        E = 0;
    end
    
    R(:,i) = cumsum(h2(knee:-1:1,i));
    R(:,i) = 10*log10(R(end:-1:1,i)+E);
    R(:,i) = R(:,i)-max(R(:,i));
end

end

function hSmooth = smooth(h,avgSamples)

% process in blocks
hSmoothSize = length(h)/avgSamples;
hSmooth = zeros(length(h),1);
for k = 1:floor(hSmoothSize)
    idx = ((k-1)*avgSamples+1):k*avgSamples;
    hSmooth(idx) = 20*log10(mean(10.^(h(idx)/20)));
end
% process rest - if it exists
if mod(length(h),avgSamples) ~= 0
    idx = k*avgSamples+1:length(h);
    hSmooth(idx) = 20*log10(mean(10.^(h(idx)/20)));
end
end