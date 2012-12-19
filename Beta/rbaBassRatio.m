function BR = rbaBassRatio(h,fs)
%
%   Description:    Calculate Bass Ratio (ISO-3382)
%
%   Usage: BR = rbaBassRatio(h,fs)
%
%   Input parameters:
%       - h: Impulse response 
%       - h: Sampling frequency 
%   Output parameters:
%       - BR: Calculated Bass Ratio
%
% 	references:
% 	[1] Niels Werner Adelman-Larsen, Eric R. Thompson and Anders Christian Gade
% 	Suitable reverberation times for halls for rock and pop music
% 	Journal of the Acoustical Society of America, 2010, Vol. 127, nr. 1, pp. 247-255

%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 17-12-2012
%   Acoustic Technology, DTU 2012

% convert h to mono, if stereo
DIM = size(h);
if DIM(1)<DIM(2)
    h = h(1,:);
else
    h = h(:,1);
end

% get octave band frequency vector from 63 to 2000 Hz
f = rbaGetFreqs(63,2000,1);

R = rbaDecayCurve(h, fs, min(f), max(f),'non-linear');
% find reverberation time for the frequencies
RT = rbaRevTime(R, fs);

% calculate Bass Ratio, definiton is given in [1]
BR = (RT(f==63)+RT(f==125))/(RT(f==500)+RT(f==1000)+RT(f==2000));

end