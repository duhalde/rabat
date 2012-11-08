function BR = rbtBassRatio(ir,fs)
%
%   Description:    Calculate Bass Ratio (ISO-3382)
%
%   Usage: BR = rbtBassRatio(x,...)
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

% convert ir to mono, if stereo
DIM = size(ir);
if DIM(1)<DIM(2)
    ir = ir(1,:);
else
    ir = ir(:,1);
end

% get frequency vector, default is octave band frequencies from 125-4000 Hz
f = rbtGetFreqs(63,2000,1);

R = rbtDecayCurve(ir, fs, min(f), max(f),'non-linear');
% find reverberation time for the frequencies
RT = rbtRevTime(R, fs);

% calculate Bass Ratio, definiton is given in [1]
BR = (RT(f==63)+RT(f==125))/(RT(f==500)+RT(f==1000)+RT(f==2000));