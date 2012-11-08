function D = rbtDefinition(ir,fs,time)
%
%   Description:    Calculate definition (D50) (ISO-3382)
%
%   Usage: D = rbtDefiniton(x,...)
%
%   Input parameters:
%       - ir: Impulse response
%       - fs: Sampling frequency
%       - time: The time parameter in ms, until which the integration runs,
%               e.g. 50 for D50
%   Output parameters:
%       - D: Calculated definition (D50, by default)
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 05-11-2012, Last update: 08-11-2012
%   Acoustic Technology, DTU 2012

if nargin < 2
    error('Too few input arguments')
elseif nargin == 2
    time = 50;  % calculate D%= by default
end

% convert ir to mono, if stereo
DIM = size(ir);
if DIM(1)<DIM(2)
    ir = ir(1,:);
else
    ir = ir(:,1);
end
% find index of integration time in ir
int_idx = time*1e-3*fs;
% error handling
if int_idx > length(ir)
    error('Impulse response must be longer than wanted time intergration!')
end

% calculate Clarity parameter, see ISO-3382-1 (A.11)
D = sum(ir(1:int_idx).^2)/sum(ir.^2);
