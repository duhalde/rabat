function [y,t] = gen_sin(f0,fs,length_sec,varargin)
%
% GEN_SIN returns a sampled sine function and its corresponding time
%   vector. It is taken into account the effect of the very last sample when
%   calculating the corresponding Fourier Transform, i.e. the sine is sampled
%   within the interval of time from '0' to 'length_sec-1/fs'.
%
%   [y,t] = gen_sin(f0,fs,length_sec,amplitude,phase_rad)
%
%   Input parameters:
%       - f0: frequency of oscillation.
%       - fs: sampling frequency.
%       - length_sec: duration of the signal in seconds.
%   Optional input parameters:
%       - amplitude: amplitude of the sine. Its default value is 1.
%       - phase: initial phase of the sine in radians. Its default value is 0.
%   Ouput parameters:
%       - y: the sampled sine.
%       - t: the corresponding time vector in seconds.
%
%   See also BAD_GEN_SIN, GEN_TRIANGLE, GEN_SQUARE.
%
%   Author: Toni Torras, Date: 18-1-2009, Last update: 20-2-2009

if nargin == 4
    amplitude = varargin{1};
    phase = 0;
elseif nargin == 5
    amplitude = varargin{1};
    phase = varargin{2};
elseif nargin > 5
    error('Wrong usage! More than five input arguments are not supported!')
elseif nargin < 3
    error('Wrong usage! Less than three input arguments are not supported!') 
else
    amplitude = 1;
    phase = 0;
end
t = 0:1/fs:length_sec-1/fs;
y = amplitude*sin(2*pi*f0*t + phase);
% if mod(length_sec,1/f0)
%     warning('The length of the signal is not a multiple of the period of the sine!');
% elseif f0 > fs/2
%     warning('Nyquist Theorem is not fulfilled!');
% end