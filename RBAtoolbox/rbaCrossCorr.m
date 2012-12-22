function [c, lags] = rbaCrossCorr(f, g)
%$rbaCrossCorr  Robust implementation of Cross Correlation
%   [c, lags] = rbaCrossCorr(f, g)
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
%
%   Inputs:
%       f:   Vector contaning the long signal (e.g. recorded measurement)
%       g:   Vector contaning the short signal (e.g. prototype sweep)
%
%   Outputs:
%       c:   the cross correlation of the to signals.
%    lags:   a vector containing the lags in samples for each value in the
%            cross correlation vector.
%
%   Example:
%     	[c, lags] = rbaCrossCorr(multipleMeasuredSweeps,originalSweep)
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-9-2012, Last update: 28-11-2012
%   Acoustic Technology, DTU 2012


%% Calculation of cross correlation
f = f(:); % Som nedenstående
g = g(:); % Det er et farligt trick!
Lf = length(f);
Lg = length(g);

Ly = Lf+Lg-1;   % find length of cross correlation

% to get the highest speed from fft() and ifft(),
% the signal lengths should be a power of 2
LyPow2 = pow2(nextpow2(Ly));  % find smallest power of 2 > Ly

% perform fourier transform with zero-padding to length LyPow2
F = fft(f, LyPow2);     % fast Fourier transform
G = fft(g, LyPow2);	    % fast Fourier transform
Y = F.*conj(G);         % muliply in frequency domain

% now go back to time-domain and force real values.
c = real(ifft(Y, LyPow2));       % Inverse fast Fourier transform

% get index of lags
maxlag = Lf-1;
lags = -maxlag:maxlag;

% crop output c to match lags
c = [c(end-maxlag+1:end,:); c(1:maxlag+1,:)];

end
