function [h,t] = mlsdeconv(x,y,fs,varargin)
% 
%   Description: Computes the circular crosscorrelation function between 
%                x and y. If y is the output signal of a linear system, 
%                the result is a good approximation of the impulse response 
%                of the system. 
%
%   Usage: [h,t] = mlsdeconv(x,y,fs,'AmpCorr')
%
%   Input parameters:
%       - x: input signal.
%       - y: output signal.
%       - fs: sampling frequency.
%   Optional input parameters:
%       - 'AmpCorr': The use of this string enables the option of correcting
%       the IR with a scale factor. This scale factor depends on the MLS 
%       sequence used at the input of the system, i.e. x.
%   Output parameters:
%       - h: the measured IR.
%       - t: the corresponding time vector of the IR.
%
%   Author: Antoni Torras Rosell, Date: 12-6-2009
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 29-11-2012
%   Acoustic Technology, DTU 2012

% Initialize input
x = x(:);
y = y(:);

Y = fft(y);
Xinv = fft(rbaflip(x));
% Compute circular crosscorrelation
h = ifft(Y.*Xinv.*exp(-1j*2*pi*(0:length(Xinv)-1).'/length(Xinv))/length(x),'symmetric');
h = h.';
if mod(length(h),2) == 0 % Even number of samples
    h = [h(length(h)/2+1:end) h(1:length(h)/2)];
    t = linspace(-length(h)/2/fs,(length(h)/2 - 1)/fs,length(h));
else % Odd number of samples
    h = [h(ceil(length(h)/2)+1:end) h(1:ceil(length(h)/2))];
    t = linspace(-floor(length(h)/2)/fs,floor(length(h)/2)/fs,length(h));
end

if nargin == 4
    if strcmpi(varargin{1},'AmpCorr');
        % We have to compensate for the use of an MLS different than {+1,-1}
        A = transformCoef([-1 1],x); % [-1 1] is the right order, not [1 -1];
        % We can only compensate for the amplification factor, but not the offset
        h = length(x)/(A^2*(length(x)+1))*h;
    else
        error('Wrong Optional string! Use ''AmpCorr''');
    end
end