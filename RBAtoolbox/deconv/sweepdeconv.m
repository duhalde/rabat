function [h,t] = sweepdeconv(x,y,f1,f2,fs,varargin)
%
%   Usage: [h,t] = sweepdeconv(x,y,f1,f2,fs)
%
%   Input parameters:
%       - x: Excitation signal (Linear or Logarithmic sweep)
%       - y: Measured signal
%       - f1: Lower frequency of interest
%       - f2: Higher frequency of interest
%       - fs: Sampling frequency
%   Output parameters:
%       - h: impulse response.
%       - t: time vector of the impulse response.
%
%   Author: Toni Torras, Date: 3-1-2009, Last update: 26-6-2009    
x = x(:);
y = y(:);

Xinv = fft([zeros(length(y)-1,1) ; rbaflip(x)]);
F = Xinv.*exp(-1j*2*pi*(0:length(Xinv)-1).'/length(Xinv))./(Xinv.*conj(Xinv));

Y = fft([y ; zeros(length(x)-1,1)]);

if nargin == 6 && strcmpi(varargin{1},'filter')
   [bband,aband] = butter(2,[2*f1/fs floor(1e4*(2*f2/fs-eps))/1e4]);
   Hband = freqz(bband,aband,length(x)+length(y)-1,'whole');
   h = ifft(F.*Y.*Hband,'symmetric');
else
   h = ifft(F.*Y,'symmetric');
end

h = h.';

if mod(length(h),2) == 0 % Even number of samples
   h = [h(length(h)/2+1:end) h(1:length(h)/2)];
   t = linspace(-length(h)/2/fs,(length(h)/2 - 1)/fs,length(h)); 
else % Odd number of samples
   h = [h(ceil(length(h)/2)+1:end) h(1:ceil(length(h)/2))];
   t = linspace(-floor(length(h)/2)/fs,floor(length(h)/2)/fs,length(h)); 
end