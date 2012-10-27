function y = rbtConv(f,h)
%$RABAT_CONV  Fast implementation of convolution
%   conv_sig = rabat_conv(sig1,sig2)
%
%   Description:
%       Since Matlabs built-in convolve implements the mathematic
%       definition and not the fastest method for convolving, this function
%       is a must for everyone working with signal processing.
%
%   Inputs:
%       f:   the (music?) signal to be convolved with h 
%       h:   the (filter?) signal to be convolved with f
%
%   Outputs:
%       g:   the convolved signal. the length will be the sum of the
%                   lengths of the two input signals minus 1.
%
%   Example:
%     	auralization = rbtConv(music_signal,room_impulse_response)
%

% Author: David Duhalde Rahbæk & Mathias Immanuel Nielsen & Oliver Lylloff
% Created: sep 5 2012
% Copyright RaBaT Toolbox, DTU 2012


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


