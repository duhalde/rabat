function Hd = filterBank(BandsPerOctave,fs,cfmin,cfmax,varargin)
%
%   Description: Calculate standardized octave or 3rd-octave band second 
%       order section filters.
%
%   Usage: Hd = filterBank(BandsPerOctave,fs,cfmin,cfmax,1)
% 
%   Example: Hd = filterBank(1,44100,63,8000,0) creates 8 octave band
%   filters of 'Class 0' (acc. ANSI S1.11-2004) which can be used with
%   Matlab's FILTER() function
%
%   Input parameters:
%       - BandsPerOctave: bands per octave
%       - fs: sampling frequency
%       - cfmin: lowest center frequency of interest 
%       - cfmax: highest center frequency of interest
%       - class (optional): Filter class according to ANSI S1.11-2004,
%           either 0, 1 or 2.
%           Class 0: 0.15 dB ripple in pass band
%           Class 0: 0.30 dB ripple in pass band
%           Class 0: 0.50 dB ripple in pass band
% 
%   Output parameters:
%       - Hd: vector with filter-structs. Used like:
%           out = filter(sig,Hd(1));
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 1-10-2012, Last update: 1-10-2012
%   Acoustic Technology, DTU 2012


% input handling
if nargin == 5
    class = varargin{1};
    if ~isintegert(class) || class > 2
        error('class must be 0, 1 or 2')
    end
    classStr = ['Class ' num2str(class)];
elseif
    class = 1; % default filter class
    classStr = ['Class ' num2str(class)];
end
    
    
if BandsPerOctave == 3
    if cfmin < 25
        error('minimum center frequency is 25 Hz');
    elseif cfmax > 20000
        error('maximum center frequency is 20000 Hz');
    end
    % set filter order --NB check with ANSI S1.11-2004
    N = 8;
elseif BandsPerOctave == 1
    if cfmin < 31.5
        error('minimum center frequency is 31.5 Hz');
    elseif cfmax > 16000
        error('maximum center frequency is 16000 Hz');
    end
    % set filter order --NB check with ANSI S1.11-2004
    N = 6;
end


F0 = 1000;  % Center reference frequency (Hz)
f = fdesign.octave(BandsPerOctave,classStr,'N,F0',N,F0,fs);

F1 = validfrequencies(f) % get valid frequencies from filter
% note these are (1000).*((2^(1/3)).^[-10:7]) and not exactly 125, 1250...

tol = 1.01; % 1% tolerance, to compensate for roundoff in the lower frequencies -NB: Is this OK??!!

F1 = F1(F1>cfmin*tol)
F1 = F1(F1<cfmax)

nrCenterFrequencies = length(F1);

for i = 1:nrCenterFrequencies
    f.F0 = F1(i);
    Hd(i) = design(f,'butter');
end

end