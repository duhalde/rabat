function [B,A] = rbtHomemadeFilterBank(BandsPerOctave,fs,cfmin,cfmax,varargin)
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
    if mod(class,1) ~= 0 || (class > 2)
        error('class must be 0, 1 or 2')
    end
else
    class = 1; % default filter class
end
    
if BandsPerOctave == 1
    if cfmin < 31.5
        error('minimum center frequency is 31.5 Hz');
    elseif cfmax > 16000
        error('maximum center frequency is 16000 Hz');
    end
    % set filter order --NB check with ANSI S1.11-2004
    N = 3;
elseif BandsPerOctave == 3
    if cfmin < 25
        error('minimum center frequency is 25 Hz');
    elseif cfmax > 20000
        error('maximum center frequency is 20000 Hz');
    end
    % set filter order --NB check with ANSI S1.11-2004
    N = 4;
else
    error('Only 1 or 3 bands per octave is supported, at the moment.')
end

% determine filter class for design purposes
switch class
    case 0
        ripple = 0.15;
    case 1
        ripple = 0.30;
    case 2
        ripple = 0.50;
end


f0 = 1000;  % Center reference frequency (Hz)
freqs = rbtGetFreqs(cfmin,cfmax,BandsPerOctave); % center frequencies
nCF = length(freqs); % number of center frequencies

fc = zeros(nCF,1);

idf0 = find(freqs==f0);
% assign exact center frequencies below f0

fc(1:idf0-1) = 1000./(2.^(1/BandsPerOctave).^((idf0-1):-1:1));

% assign f0
fc(idf0) = f0;

% assign exact center frequencies above f0

fc(idf0+1:nCF) = 1000.*(2.^(1/BandsPerOctave).^(1:nCF-idf0));

B = zeros(2*N+1,nCF);
A = zeros(2*N+1,nCF);

for m = 1:nCF
    fupper = fc(m) * 2^(1/(2*BandsPerOctave)) / (fs/2); % find normalized upper
    flower = fc(m) / 2^(1/(2*BandsPerOctave)) / (fs/2); % and lower frequencies

    WN = [flower,fupper];
    [B(:,m),A(:,m)] = butter(N,WN);
end

end