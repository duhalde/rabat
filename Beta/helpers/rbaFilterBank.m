function [B,A] = rbaFilterBank(BandsPerOctave,fs,cfmin,cfmax)
%
%   Description: Calculate octave or 3rd-octave band filters according 
%	to the ANSI S1.11-2004.
%
%   Usage: Hd = filterBank(BandsPerOctave,fs,cfmin,cfmax)
%
%   Example: Hd = filterBank(1,44100,63,8000,0) creates 8 octave band
%   filters of 'Class 0' (acc. ANSI S1.11-2004) which can be used with
%   Matlab's FILTER() function or your convolution function of choice.
%
%   Input parameters:
%       - BandsPerOctave: bands per octave
%       - fs: sampling frequency
%       - cfmin: lowest center frequency of interest
%       - cfmax: highest center frequency of interest
%
%   Output parameters:
%       - Hd: vector with filter-structs. Used like:
%           out = filter(sig,Hd(1));
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 1-10-2012, Last update: 17-12-2012
%   Acoustic Technology, DTU 2012


% input handling

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

fc = rbaGetFreqs(cfmin,cfmax,BandsPerOctave); % center frequencies
nCF = length(fc); % number of center frequencies

% initialize output variables
B = zeros(2*N+1,nCF);
A = zeros(2*N+1,nCF);

% determine the filter coefficients
for m = 1:nCF
	% by using these corner frequencies, which will match up between
	% neighbouring bands, it is ensured that the butterworth filter
	% representation will add up to 1
    fUpper = fc(m) * 2^(1/(2*BandsPerOctave)) / (fs/2); % find normalized upper
    fLower = fc(m) / 2^(1/(2*BandsPerOctave)) / (fs/2); % and lower frequencies
    
	% make sure that the nyquist theorem (fs/2 > max(f)) is not violated.
    if fUpper > 1 || fLower > 1
        error(['You are violating the Nyquist Theorem. The ' num2str(fc(m))...
               ' Hz band cannot be processed, with a sampling frequency of ' num2str(fs)]);
    end
	% assign corner frequencies
    WN = [fLower,fUpper];
	% get butterworth parameters.
    [B(:,m),A(:,m)] = butter(N,WN);
end

end