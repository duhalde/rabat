function y = rbaConv(f,h)
%$RABAT_CONV  Fast implementation of convolution
%   y = rbaConv(f, h)
%
%   Description:
%       Matlabs built-in convolve implements the mathematic
%       definition and not the fastest method for convolving, this function
%       is a must for everyone working with signal processing.
%
%   Inputs:
%       f:   the signal to be convolved with h
%       h:   the signal to be convolved with f
%
%   Outputs:
%       y:   the convolved signal. the length will be the sum of the
%                   lengths of the two input signals minus 1.
%
%   Example:
%     	auralization = rbaConv(music_signal,room_impulse_response)
%
% Author: David Duhalde Rahbæk & Mathias Immanuel Nielsen & Oliver Lylloff
% 2012
% Created: sep 5 2012 Updated: 28/11/2012


%% Convolution
f = f(:);
h = h(:);

Ly = length(f)+length(h)-1;   % find length of output signal

% to get the highest speed from fft() and ifft(),
% the signal lengths should be a power of 2
LyPow2 = pow2(nextpow2(Ly));  % find smallest power of 2 > Ly

% perform fourier transform with zero-padding to length LyPow2
F = fft(f, LyPow2);           % fast Fourier transform
H = fft(h, LyPow2);	          % fast Fourier transform
Y = F.*H;                     % muliply in frequency domain

% now go back to time-domain
y = real(ifft(Y, LyPow2));       % Inverse fast Fourier transform

% and cut back to the wanted result length Ly
y = y(1:Ly);                  % Take just the first N elements
y = y/max(abs(y));            % Normalize the output ???? Should this be done????


