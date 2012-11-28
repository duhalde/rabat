function [c, lags] = rbaCrossCorr(h1,h2)
%$rbaCrossCorr  Robust implementation of Cross Correlation
%   [c, lags] = rbaCrossCorr(h1,h2)
%
%   Description:
%       Since Matlabs built-in cross correlation sends calculations to
%       fftfilt, when length(f)>=10*length(h), and fftfilt does not support
%       longer signals than 2^20=1048576, the need for a more robust
%       implementation was born.
%       This function is written with the purpose of determining the exact
%       position of a single sweep response in a room acoustic measurement,
%       which consists of the response of several sweeps.
%       The cross correlation searches for patterns, similar to h, in
%       signal f. It is closely related to the convolution function
%       (can you see the difference?)
%
%   Inputs:
%       f:   the long signal (e.g. recorded measurement)
%       h:   the short signal (e.g. prototype sweep)
%
%   Outputs:
%       c:   the cross correlation of the to signals.
%    lags:   a vector containing the lags in samples for each value in the
%            cross correlation vector.
%
%   Example:
%     	[c, lags] = rbaCrossCorr(multipleMeasuredSweeps,originalSweep)
%
% Author: David Duhalde Rahbæk & Mathias Immanuel Nielsen & Oliver Lylloff
% Created: sep 5 2012 Updated: nov 28 2012
% Copyright RaBaT Toolbox, DTU 2012


%% Calculation of cross correlation
h1 = h1(:);
h2 = h2(:);
Lh1 = length(h1);
Lh2 = length(h2);

Ly = Lh1+Lh2-1;   % find length of cross correlation

% to get the highest speed from fft() and ifft(),
% the signal lengths should be a power of 2
LyPow2 = pow2(nextpow2(Ly));  % find smallest power of 2 > Ly

% perform fourier transform with zero-padding to length LyPow2
H1 = fft(h1, LyPow2);     % fast Fourier transform
H2 = fft(h2, LyPow2);	    % fast Fourier transform
Y = H1.*conj(H2);         % muliply in frequency domain

% now go back to time-domain and force real values.
c = real(ifft(Y, LyPow2));       % Inverse fast Fourier transform

% get index of lags
maxlag = Lh1-1;
lags = -maxlag:maxlag;

c = [c(end-maxlag+1:end,:); c(1:maxlag+1,:)];


