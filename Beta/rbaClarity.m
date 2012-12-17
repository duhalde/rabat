function C = rbaClarity(ir,fs,time)
%
%   Description:    Calculate clarity (C30,C50,C80) from impulse response (ISO-3382)
%
%   Usage: C = rbaClarity(ir,fs,time)
%
%   Input parameters:
%       - ir: Impulse response
%       - fs: Sampling frequency
%       - time (optional): The time parameter in ms, until which the integration runs,
%               		   e.g. 80 for C80
%   Output parameters:
%       - C: Calculated clarity parameter (C80 by default)
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 05-11-2012, Last update: 17-12-2012
%   Acoustic Technology, DTU 2012

if nargin < 2
    error('Too few input arguments')
elseif nargin == 2
    time = 80;  % calculate C80 by default    
end

% convert ir to mono, if stereo
DIM = size(ir);
if DIM(1)<DIM(2)
    ir = ir(1,:);
else
    ir = ir(:,1);
end

% find index of integration time in ir
int_idx = ceil(time*1e-3*fs);
% error handling
if int_idx > length(ir)
    error('Impulse response must be longer than wanted time integration!')
end
% calculate Clarity parameter, see ISO-3382-1 (A.12) or Note 4213 by Anders
% Christian Gade pp. 16 for definition.
C = 10*log10(sum(ir(1:int_idx).^2)/sum(ir(int_idx:end).^2));