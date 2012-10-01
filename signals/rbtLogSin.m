function [x,t] = rbtLogSin(f1,f2,fs,length_sec,varargin)
% 
% rbtLogSin creates a logarithmic sweep in the time domain.
%
% [x,t] = rbtLogSin(f1,f2,fs,length_sec,zero_padding,amplitude,phase)
%
% Input parameters:
%       - f1: lower frequency of the sweep.
%       - f2: upper frequency of the sweep.
%       - fs: sampling frequency.
%       - length_sec: duration of the sweep in seconds.
%
% Optional input parameters:
%       - zero_padding: duration (in seconds) of the silence inserted
%         after each sweep.
%       - amplitude: amplitude of the sine sweep. Its default value is 1.
%       - phase_rad: initial phase in radians. Its default value is 0.
% Output parameters:
%       - x: sampled logarithmic sine sweep in seconds.
%       - t: the corresponding time vector in seconds.
%
%   Author: Toni Torras, Date: 15-7-2009.
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 27-9-2012

if f1 == 0
    f1 = eps;
end
switch nargin
    case 4
        zero_padding = 0;
        amplitude = 1;
        phase = 0;
    case 5
        zero_padding = varargin{1};
        amplitude = 1;
        phase = 0;
    case 6
        zero_padding = varargin{1};
        amplitude = varargin{2};
        phase = 0;
    case 7
        zero_padding = varargin{1};
        amplitude = varargin{2};
        phase = varargin{3};
    otherwise
        error('Wrong number of input arguments.');
end
t = 0:1/fs:length_sec-1/fs;
x = [amplitude*sin(length_sec*2*pi*f1/log(f2/f1)*(exp(t*log(f2/f1)/length_sec)-1) + phase)...
    zeros(1,round(zero_padding*fs))];
t = 0:1/fs:(length_sec+zero_padding-1/fs);