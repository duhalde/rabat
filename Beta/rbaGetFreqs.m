function freqs = rbaGetFreqs(cfmin,cfmax,BandsPerOctave)
%
%   Description: Return standardized octave band center frequencies vector
%   for plotting purposes in Acoustics.
%
%   Usage: freqs = rbaGetFreqs(cfmin,cfmax,BandsPerOctave)
%
%   Input parameters:
%       - cfmin: lowest center frequency of interest 
%       - cfmax: highest center frequency of interest
%       - BandsPerOctave: bands per octave
%   Output parameters:
%       - freqs: vector with center frequencies between cfmin and cfmax
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 1-10-2012, Last update: 17-12-2012
%   Acoustic Technology, DTU 2012

% input handling
if nargin == 2
    BandsPerOctave = 1;
    % return octave band frequencies by default.
end

% error handling
if (BandsPerOctave ~= 1) && (BandsPerOctave ~= 3)
    error('only octave bands and 3rd octave bands supported!')
    
% 3rd octave band functionality    
elseif BandsPerOctave == 3
    freqs = [25 31.5 40 50 63 80 100 125 160 200 250 315 ...
        400 500 630 800 1000 1250 1600 2000 2500 3150 4000 ...
        5000 6300 8000 10000 12500 16000 20000 25000 32000 40000 50000 64000];
    freqs = freqs(freqs<=cfmax); % cut away f's above cfmax
    freqs = freqs(freqs>=cfmin); % cut away f's below cfmin
    
% octave band functionality
else
    freqs = [16 31.5 63 125 250 500 1000 2000 4000 ...
    	 8000 16000 32000 64000];
    freqs = freqs(freqs<=cfmax); % cut away f's above cfmax
    freqs = freqs(freqs>=cfmin); % cut away f's below cfmin
end

end