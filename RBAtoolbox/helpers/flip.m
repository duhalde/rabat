function out = flip(in)
%
%   Description: Flip dimension of vector. Utility function for
%   deconvolution purposes.
%
%   Usage: out = flip(in)
%
%   Input parameters:
%       - x: Vector or matrix input
%   Output parameters:
%       - y: Vector or matrix fliped across rows.
%
%   Author: Antoni Torras Rosell 
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 29-11-2012
%   Acoustic Technology, DTU 2012

s = size(in);
idx = find(s == max(s));
if length(idx) > 1
	idx = idx(1);
end
out = flipdim(in, idx);