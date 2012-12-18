function H = rbaIR2OctaveBands(h,fs,cfmin,cfmax)
%
%   Description: Filters impulse response into octave bands
%
%   Usage: H = rbaIR2OctaveBands(h, fs, cfmin, cfmax)
%
%   Input parameters:
%       - h: A vector with the impulse response in the time domain.
%       - fs: Sample frequency
%       - cfmin: lowest center frequency of interest
%       - cfmax: highest center frequency of interest
%   Output parameters:
%       - H: A matrix with filtered impulse response in the selected octave
%            bands. Size is length(h) x number of bands
%
%   See also: rbaCropIR
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 9-11-2012, Last update: 30-11-2012
%   Acoustic Technology, DTU 2012

[m,n] = size(h);
 
if m<n
    h = h';
end


bandsPerOctave = 1;

% Get octave-band center frequencies
freqs = rbaGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);

% Calculate filter coeeficients
[B,A] = rbaFilterBank(bandsPerOctave,fs,cfmin,cfmax);

H = zeros(length(h),nCF);           
% filter rir with octave band filters
for i = 1:nCF 
H(:,i) = filter(B(:,i),A(:,i),h);   % Filtered IR
end