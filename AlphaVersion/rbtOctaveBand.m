function h_band = rbtOctaveBand(h,fs,varargin)
%
%   Description: Calculate octave bands   
%
%   Usage: h_band = rbtOctaveBand(h,varargin)
%
%   Input parameters:
%       - h: Impulse response
%   Optional input parameters:
%       - fc: Center frequencies as a vector fc = [125 250 500 ...]; 
%   Output parameters:
%       - y: Impulse response in octave bands with center frequencies fc
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 30-9-2012, Last update: 30-9-2012
%   Acoustic Technology, DTU 2012

if size(h,2) ~= 1
h = h(:,1);         % Only mono signal
end

if nargin == 2
    fc = [63 125 250 500 1000 2000 4000 8000];
elseif nargin == 3
    fc = varargin{1};
else
    error('Wrong number of input arguments')
end

% Calculate lower and upper cut-off frequncies
flow    = fc*2^(-0.5);
fup     = fc*2^(0.5);

% Allocate output vectors
h_band = nan(length(fc),length(h));

for i = 1:length(fc)
    [b, a] = butter(3, [flow(i)/(fs/2), fup(i)/(fs/2) ]);
    h_band(i,:) = filter(b,a,h);
    
    % Plot filters:
    %[h1,w]  = freqz(b,a);
    %x  = (0:numel(h1)-1)/numel(h1)*fs/2;
    %y   = 20*log10(abs(h1));
    %semilogx(x,y);
    %axis([20 10000 -40 0]);
    %drawnow;
    %pause(2);
end