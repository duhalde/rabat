function y = rbaCircularConv(f,h)
%RBACONV    Fast implementation of a circular convolution
%   Description:
%       Matlabs built-in convolve implements the mathematic
%       definition and not the fastest method for convolving, this function
%       is a must for everyone working with signal processing.
%
%   Usage:
%     	y = rbaCircularConv(signal,filter)
% 
%   Input parameters:
%       f:   the signal to be convolved with h
%       h:   the signal to be convolved with f
%
%   Output parameters:
%       y:   the convolved signal. The length will be the same as inputs.
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 5-9-2012, Last update: 20-12-2012
%   Acoustic Technology, DTU 2012


% Ensure that inputs are both row vectors.
f = f(:);
h = h(:);

%n = length(f)+length(h)-1;   % find length of output signal

% perform fourier transform with zero-padding to length LyPow2
F = fft(f);            % fast Fourier transform
H = fft(h);	        
Y = F.*H;                    % muliply in frequency domain

% now go back to time-domain
y = ifft(Y,'symmetric');     % Inverse fast Fourier transform

end