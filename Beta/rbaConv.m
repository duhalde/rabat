function y = rbaConv(f,h)
%RBACONV    Fast implementation of convolution
%   Description:
%       Matlabs built-in convolve implements the mathematic
%       definition and not the fastest method for convolving, this function
%       is a must for everyone working with signal processing.
%       NOTE: no normalization is done! This would interfere with
%       auralization uses, which would not be scaled correctly anymore.
%
%   Usage:
%     	auralization = rbaConv(music_signal,room_impulse_response)
% 
%   Input parameters:
%       f:   the signal to be convolved with h
%       h:   the signal to be convolved with f
%
%   Output parameters:
%       y:   the convolved signal. the length will be the sum of the
%            lengths of the two input signals minus 1.
%
% Author: David Duhalde Rahbæk & Mathias Immanuel Nielsen & Oliver Lylloff
% 2012
% Created: sep 5 2012 Updated: 19/12/2012


% Ensure that inputs are both row vectors.
f = f(:);
h = h(:);

n = length(f)+length(h)-1;   % find length of output signal

% to get the highest speed from fft() and ifft(),
% the signal lengths should be a power of 2
nfft = pow2(nextpow2(Ly));   % find smallest power of 2 > Ly

% perform fourier transform with zero-padding to length LyPow2
F = fft(f, nfft);            % fast Fourier transform
H = fft(h, nfft);	        
Y = F.*H;                    % muliply in frequency domain

% now go back to time-domain
y = real(ifft(Y, nfft));     % Inverse fast Fourier transform

% and cut back to the wanted result length Ly
y = y(1:n);                  % Take just the first N elements

end