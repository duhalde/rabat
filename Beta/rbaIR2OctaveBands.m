function H = rbaIR2OctaveBands(h,fs,cfmin,cfmax,bandsPerOctave,reverse)
%
%   Description: Filters impulse response into octave bands
%
%   Usage: H = rbaIR2OctaveBands(h, fs, cfmin, cfmax)
%          H = rbaIR2OctaveBands(h, fs, cfmin, cfmax, bandsPerOctave)
%          H = rbaIR2OctaveBands(h, fs, cfmin, cfmax, bandsPerOctave, reverse)
%
%   Input parameters:
%       - h: A vector with the impulse response in the time domain.
%       - fs: Sample frequency
%       - cfmin: lowest center frequency of interest
%       - cfmax: highest center frequency of interest
%   Optional input parameters:
%       - bandsPerOctave: number of bands per octave.
%           defaults to 1 (octave bands)
%       - reverse: Logical 1 or 0. Allows the user to select a reverse filtering method,
%           which will reduce distortion in the signal, when using narrow
%           banded filters, e.g. low frequency third octave filters.
%   Output parameters:
%       - H: A matrix with filtered impulse response in the selected octave
%            bands. Size is length(h) x number of bands
%
%   See also: rbaCropIR
% 
% 	References: 
%   [1] Finn Jacobsen and Jens Holger Rindel. TIME REVERSED DECAY MEASUREMENTS 
%       Journal ofsound and Vibration (1987) 117(l), 187-190
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 9-11-2012, Last update: 30-11-2012
%   Acoustic Technology, DTU 2012

% input checking, setting default values of optional inputs.
if nargin == 4
    bandsPerOctave = 1;
    reverse = 0;
elseif nargin == 5
    reverse = 0;
end

[m,n] = size(h);

if m<n
    h = h';
end

% Get octave-band center frequencies
freqs = rbaGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);

% Calculate filter coeeficients
[B,A] = rbaFilterBank(bandsPerOctave,fs,cfmin,cfmax);

H = zeros(length(h),nCF);
% filter rir with octave band filters
if reverse
    % apply reverse filtering method, see [1].
    h = flipud(h);  % time reverse signal
    for i = 1:nCF
        H(:,i) = filter(B(:,i),A(:,i),h);   % apply filter
        H(:,i) = flipud(H(:,i));  % time reverse signal again
    end
else
    % filter in a regular fashion
    for i = 1:nCF
        H(:,i) = filter(B(:,i),A(:,i),h);   % apply filter
    end
end

end