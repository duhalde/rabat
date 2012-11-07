function LF = rbtEarlyLateralEnergy(pL, p, fs)
%
%   Description:    Calculate early lateral energy (ISO-3382) (NOT TESTED)
%
%   Usage: LF = rbtEarlyLateralEnergy(h)
%
%   Input parameters:
%       - pL: Instantaneous sound pressure of the impulse response measured
%       with a figure-of-eight microphone
%       - p : Instantaneous sound pressure of the impulse response
%       - fs: Sampling frequency (asumming that both signal are measured withthe same sampling frequency)
%   Output parameters:
%       - LF: Calculated early lateral energy
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 07-11-2012
%   Acoustic Technology, DTU 2012


% ISO-3382-1_2009-2 A.14
if nargin < 3
    error('Not enough input arguments. See help rbtEarlyLateralEnergy')
end

if length(pL) < ceil(80e-3*fs)
    error('pL must be longer than 80ms')
end

if length(p) < ceil(80e-3*fs)
    error('p must be longer than 80ms')
end


LF = sum(pL(ceil(fs*5e-3)+1:ceil(fs*80e-3)+1).^2)/sum(p(1:ceil(fs*80e-3)+1).^2);



