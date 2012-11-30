function R = rbaSchroeder(h,fs,varargin)
%
%   Description: Compute decay curve from Schröders backwards integration
%                method
%
%   Usage: R = rbtSchroeder(h,onset,kneepoint)
%
%   Input parameters:
%       - h         : Impulse response
%       - fs        : Sampling frequency
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

if nargin == 2
    [knee, rmsNoise] = rbaLundeby(h,fs);
elseif nargin == 3 && strcmpi(varargin{1},'Lundeby');
    [knee, rmsNoise,varargout] = rbaLundeby(h,fs);
elseif nargin == 3 && isnumeric(varargin{1})
    knee = ceil(varargin{1});
    rmsNoise = sqrt(mean(h2(knee:end).^2));
elseif nargin<2 && nargin > 3
    error('Wrong number of input arguments')
end
    
R = zeros(knee,n);

for i = 1:n
   
    rmsNoise = 10*log10(sqrt(mean(h2(knee:end,i).^2)));
    hSmooth = 10*log10(smooth(h2(:,i),1000));
    idx = find(hSmooth(1:knee)<rmsNoise+10,1,'first');
    coeff = polyfit((idx:knee),hSmooth(idx:knee)',1);

    A = coeff(1);
    B = coeff(2);

    E0 = 10^(B/10);
    a = log(10^(A/10));
    E = -(E0/a)*exp(a*knee);
    
    R(:,i) = cumsum(h2(knee:-1:1),i);
    R(:,i) = 10*log10(R(:,i)+E);
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