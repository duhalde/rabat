function rbaMagResp(g,fs,dynrange)
%MAGRESP   Magnitude response plot of positive frequencies
%   Usage:   magresp(g)
%            magresp(g,fs)
%            magresp(g,fs,dynrange)
%
%   MAGRESP(g) will display the magnitude response of the window on a log
%   scale (dB);
%
%   MAGRESP(g,fs) does the same for windows that are intended to be used
%   with signals with sampling rate fs. The x-axis will display Hz.
% 
%   MAGRESP(g,fs,dynrange) will limit the dynamic range.

%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 19-12-2012, Last update: 20-12-2012
%   Acoustic Technology, DTU 2012

% 	This file is a simplified version of the function MAGRESP from LTFAT
% 	LTFAT is an open source DSP Toolbox for Matlab and Octave.
% 	The code is licensed under GNU General Public License.
% 	Copyright (C) 2005-2012 Peter L. Soendergaard.


if nargin == 1
    fs = [];    
    dynrange = [];
elseif nargin == 2
    dynrange = [];    
end;

% default and only behaviour, at the moment.
realOnly = 1;

% normalize input signal
g = g./max(max(abs(g)));

if realOnly
  % Compute spectrum and normalize
  FF=abs(fft(real(g)));
  
  % Throw away the last half of the spectrum
  FF = FF(ceil(1:(length(FF)+1)/2)); 
  
  % Convert to dB. Add eps to avoid log of zero.
  FF=20*log10(FF+eps);

  xmin=0;

else

  % Compute spectrum and normalize. fftshift to center correctly for plotting.
  FF=fftshift(abs(fft(g)));
  
  % Convert to dB. Add eps to avoid log of zero.
  FF=20*log10(FF+eps);

  xmin=-1;

end

ymax=max(FF);
if ~isempty(dynrange)
  ymin = ymax-dynrange;
else
  ymin = min(FF);
end;

Lplot=length(FF);

% Only plot positive frequencies for real-valued signals.
if isempty(fs)
  xrange = linspace(xmin,1,Lplot).';
  axisvec = [xmin 1 ymin ymax];
else
  xrange = linspace(xmin*floor(fs/2),floor(fs/2),Lplot).';
  axisvec = [xmin*fs/2 fs/2 ymin ymax];
end;

plot(xrange,FF);
axis(axisvec);
ylabel('Magnitude response (dB)');

if isempty(fs)
  xlabel('Frequency (normalized) ');
else
  xlabel('Frequency (Hz)');
end;

legend('off');

end

