function BR = rbaBassRatio(ir,fs)
%
%   Description:    Calculate Bass Ratio (ISO-3382)
%
%   Usage: BR = rbaBassRatio(x,...)
%
%   Input parameters:
%       - x: 
%   Output parameters:
%       - BR: 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 08-11-2012
%   Acoustic Technology, DTU 2012

% references:
% [1]
% Niels Werner Adelman-Larsen, Eric R. Thompson and Anders Christian Gade
% Suitable reverberation times for halls for rock and pop music
% Journal of the Acoustical Society of America, 2010, Vol. 127, nr. 1, pp. 247-255

% get frequency vector, default is octave band frequencies from 63-4000 Hz
f = rbaGetFreqs;

R = rbaDecayCurve(ir, fs, min(f), max(f),
% find reverberation time for the frequencies
RT = rbaReverberationTime(ir, fs, f);

% calculate Bass Ratio, definiton is given in [1]
BR = (RT(f==63)+RT(f==125))/(RT(f==500)+RT(f==1000)+RT(f==2000));