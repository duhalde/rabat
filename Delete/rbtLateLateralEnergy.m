function LLE = rbtLateLateralEnergy(pL, p10, fs)
%
%   Description:    Calculate late lateral energy (ISO-3382) (NOT TESTED)
%
%   Usage: LLE = rbtLateLateralEnergy(pL, p10, fs)
%
%   Input parameters:
%       - pL : Instantaneous sound pressure of the impulse response measured with a figure-of-eight microphone
%       - p10: Instantaneous sound pressure of the impulse response
%       measured at 10m  from the source
%       - fs : Sampling frequency, assuming both signals are measured with
%       the same sampling frequency
%   Output parameters:
%       - LLE: Late Lateral Energy (dB)
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 05-11-2012
%   Acoustic Technology, DTU 2012

if nargin < 3
   error('Too few input arguments. See help rbtLateLateralEnergy'); 
end

LLE = 10*log10(sum(pL(ceil(fs*80e-3)+1:end).^2)/sum(p10.^2));