function R = rbtReflectogram(h)
%
%   Description:    
%
%   Usage: R = rbtReflectogram(h)
%
%   Input parameters:
%       - h: Impulse response 
%   Output parameters:
%       - R: Squared envelope 
%
%   Reference: Kuttruff, Room Acoustics ch. 8.3
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 9-10-2012, Last update: 9-10-2012
%   Acoustic Technology, DTU 2012

env = sqrt(h.^2+hilbert(h).^2);
R = abs(env.^2);