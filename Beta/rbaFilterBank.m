function [B,A] = rbaFilterBank(BandsPerOctave,fs,cfmin,cfmax)
%
%   Description: Calculate octave or 3rd-octave band filters according 
%	to the ANSI S1.11-2004. Note: The filters are only trustworthy for
%	frequencies bands at and above 63 Hz at this time.
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
%       - B: Numerator filter coefficients.
%       - A: Denominator filter coefficients.
%       - Both A and B are on matrixform, where each column
%         represents a frequency band.
% 
% 	References: 
%   [1] ANSI SANSI S1.11-2004: Specifications for
%       Octave-Band and Fractional-Octave-Band Analog and
%       Digital Filters.
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 1-10-2012, Last update: 18-12-2012
%   Acoustic Technology, DTU 2012


% input handling

if BandsPerOctave == 1
    if cfmin < 31.5
        error('minimum center frequency is 31.5 Hz');
    elseif cfmin < 60
        warning('Filters may not be trustworthy below the 63 Hz band.')
    elseif cfmax > 64000
        error('maximum center frequency is 64000 Hz');
    end
    % set filter order --NB check with ANSI S1.11-2004
    N = 3;
elseif BandsPerOctave == 3
    if cfmin < 25
        error('minimum center frequency is 25 Hz');
    elseif cfmin < 60
        warning('Filters may not be trustworthy below the 63 Hz band.')
    elseif cfmax > 64000
        error('maximum center frequency is 64000 Hz');
    end
    % set filter order --NB check with ANSI S1.11-2004
    N = 3;
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
    fupper = fc(m) * 2^(1/(2*BandsPerOctave)); % find upper
    flower = fc(m) / 2^(1/(2*BandsPerOctave)); % and lower cutoff
    
    % To be implemented at a later time:
	% As suggested in [1] a bilinear transform is used in the filter design.
    %Qr = fc(m)/(fupper-flower); 
	%Qd = (pi/2/N)/(sin(pi/2/N)) * Qr;
	%alpha = (1 + sqrt(1 + 4 * Qd^2))/2/Qd;
    
	% assign normalized corner frequencies
    %W1 = fc(m)/(fs/2)/alpha;
	%W2 = fc(m)/(fs/2)/alpha;
	
	% make sure that the nyquist theorem (fs/2 > max(f)) is not violated.
    if flower/(fs/2) > 1 || fupper/(fs/2) > 1
	    error(['You are violating the Nyquist Theorem. The ' num2str(fc(m))...
	              ' Hz band cannot be processed, with a sampling frequency of '...
	              num2str(fs)]);
	end
    
	% get butterworth parameters.
    [B(:,m),A(:,m)] = butter(N,[flower/(fs/2),fupper/(fs/2)]);
    end
    % For future reference this can be applied in order to obtain proper
    % filters at low frequencies
    %[B(:,m),A(:,m)] = butter(N,[W1,W2]);
end