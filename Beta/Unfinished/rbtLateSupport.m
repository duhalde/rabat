function STlate = rbtLateSupport(p, fs)
%
%   Description:    
%
%   Usage: STlate = rbtLateSupport(p, fs) (NOT TESTED)
%
%   Input parameters:
%       - p : Impulse response
%       - fs: Sampling frequency
%   Output parameters:
%       - STlate: Calculated late support (dB)
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 07-11-2012
%   Acoustic Technology, DTU 2012

% ISO-3382-1_2009-2 C.1

if nargin < 2
    error('Too few input arguments')
end

STlate = 10*log10(sum(p(ceil(100e-3*fs)+1:ceil(1*fs)+1).^2)/sum(p(1:ceil(10e-3*fs)+1).^2));