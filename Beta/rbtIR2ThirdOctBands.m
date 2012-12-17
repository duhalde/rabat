function H = rbaIR2ThirdOctBands(h,fs,cfmin,cfmax)
%
%   Description: Filters impulse response into third octave bands
%
%   Usage: H = rbaIR2ThirdOctBands(h,fs,...)
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
%   Date: 9-11-2012, Last update: 9-11-2012
%   Acoustic Technology, DTU 2012

bandsPerOctave = 3;
freqs = rbaGetFreqs(cfmin,cfmax,bandsPerOctave);
nCF = length(freqs);    
[B,A] = rbaFilterBank(bandsPerOctave,fs,cfmin,cfmax,1);

H = zeros(length(h),nCF);           % filter rir with octave band filters

for i = 1:nCF 
H(:,i) = filter(B(:,i),A(:,i),h);   % Filtered IR
end