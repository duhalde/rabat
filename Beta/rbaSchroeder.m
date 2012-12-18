function R = rbaSchroeder(h,fs,flag,varargin)
%
%   Description: Compute decay curve from Schr�ders backwards integration
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
    %[knee, rmsNoise] = rbaLundeby(h,fs);
elseif nargin == 4 && strcmpi(varargin{1},'Lundeby');
    %[knee, rmsNoise] = rbaLundeby(h,fs);
elseif nargin == 4 && isnumeric(varargin{1})
    knee = ceil(varargin{1});
    h2dB = 10*log10(h2(:,1));
    h2dB = h2dB-max(h2dB);
    rmsNoise = mean(h2dB(knee:end));
elseif nargin<3 && nargin > 4
    error('Wrong number of input arguments')
end

%if (flag~=1 || flag~=0)
%    error('Flag must be set to 1 or 0')
%end

R = zeros(length(h),n);

for i = 1:n
    
    [knee, rmsNoise] = rbaLundeby(h(:,i),fs);
    knee = knee(end);
    rmsNoise = rmsNoise(end);
    % Noise compensation
    if flag == 1
        h2dB = 10*log10(h2(:,i));
        h2dB = h2dB-max(h2dB);
        % Average in intervals of 5ms
        tAvg = ceil(fs*5e-3);
        hSmooth = smooth(h2dB,tAvg);
        idx = find(hSmooth(1:knee)<rmsNoise+10,1,'first');
        coeff = polyfit((idx:knee),hSmooth(idx:knee)',1);
   
        A = coeff(1);
        B = coeff(2);
        if A == 0   % Try another interval if A is zero
            tAvg = ceil(fs*10e-3);
            hSmooth = smooth(h2dB,tAvg);
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
    
    R(1:knee,i) = cumsum(h2(knee:-1:1,i));
    R(1:knee,i) = 10*log10(R(knee:-1:1,i)+E);
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