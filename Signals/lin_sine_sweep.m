function [x,t,Sweeprate] = lin_sine_sweep(flow,fup,fs,T,varargin)
%
% LIN_SINE_SWEEP creates a linear sweep in the time domain.
%
% [x,t] = LIN_SINE_SWEEP(flow,fup,fs,T,zero_padding,amplitude,phase_rad)
%
% Input parameters:
%       - flow: lower frequency of the sweep.
%       - fup: upper frequency of the sweep.
%       - fs: sampling frequency.
%       - T: Period of the sweep in seconds.
%
% Optional input parameters:
%       - zero_padding: duration (in seconds) of the silences inserted
%         after each sweep. Its default value is 0.
%       - amplitude: amplitude of the sine sweep. Its default value is 1.
%       - phase_rad: initial phase in radians. Its default value is 0.
% Output parameters:
%       - x: sampled linear cosine sweep in seconds.
%       - t: the corresponding time vector in seconds.
%       - Sweeprate: Sweep rate in Hz/second.
%
% Author: Toni Torras, Date: 10-2-2009, Last update: 23-7-2009

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
% Convertion from lower and upper frequencies to f1 and f2
f1 = (3*flow-fup)/2;
f2 = (flow+fup)/2;
t = 0:1/fs:T-1/fs;
% See 'Acoustical Measurement by TDS', Rhichard C. Heyser
x = [amplitude*sin(2*pi*(f2-f1)*t.^2/(2*T) + 2*pi*(f2+f1)*t/2 + phase)...
    zeros(1,round(zero_padding*fs))];
% % My version:
% x = [amplitude*sin(2*pi*(fup-flow)*t.^2/(2*T) + 2*pi*flow*t + phase)...
%     zeros(1,zero_padding*fs)];
t = 0:1/fs:(T+zero_padding-1/fs);
Sweeprate =(f2-f1)/T;
