function conv_sig = rabat_conv(sig1,sig2)
%$RABAT_CONV  Fast implementation of convolution
%   conv_sig = rabat_conv(sig1,sig2)
%
%   Description:
%       Since Matlabs built-in convolve implements the mathematic
%       definition and not the fastest method for convolving, this function
%       is a must for everyone working with signal processing.
%
%   Inputs:
%       sig1:   the signal to be convolved with sig2
%       sig2:   the signal to be convolved with sig1
%
%   Outputs:
%       conv_sig:   the convolved signal. the length will be the sum of the
%                   lengths of the two input signals minus 1.
%
%   Example:
%     	auralization = rabat_conv(music_signal,room_impulse_response)
%

% Author: David Duhalde Rahbæk & Mathias Immanuel Nielsen & Oliver Lylloff
% Created: sep 5 2012
% Copyright RaBaT Toolbox, DTU 2012

%% Initializations

% usign repmat is really fast, when dealing with long signals
conv_sig = repmat(0,length(sig1)+length(sig2)-1,1);

% below is the usual way. fast for short signal, slow for long ones
% conv_sig = zeros(length(sig1)+length(sig2)-1,1);

%% Convolution

conv_sig = real(ifft(fft(sig1).*fft(sig2)));

