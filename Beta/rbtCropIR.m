function [hCrop,idxStart,idxEnd,t] = rbtCropIR(h,fs)
%
%   Description: Crop impulse response according to ISO 3382 and Lundeby's
%                method. Indices of start and end samples of the uncropped 
%                impulse repsonse can also be given in the output.
%
%   Usage: hCrop = rbtCropIR(h,fs)
%
%   Input parameters:
%       - h: Impulse response
%       - fs: Sampling frequency
%   Output parameters:
%       - hCrop: Cropped impulse response
%       - idxStart: Index of start sample
%       - idxEnd: Index of end sample
%   See also: rbtStartIR, rbtLundeby
%   
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 9-11-2012, Last update: 9-11-2012
%   Acoustic Technology, DTU 2012

[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

for i = 1:n
% Find start of impulse response
idxStart(i) = rbtStartIR(h(:,i));

% Determine knee point of decay curve based on Lundebys method
kneePoint = rbtLundeby(h(idxStart:end,i),fs);

% Crop impulse response
idxEnd(i) = idxStart(i)+ceil(kneePoint(end));

if n == 1
hCrop(:,i) = h(idxStart(i):idxEnd(i),i);
else
hCrop = zeros(m,n);
hCrop(:,i) = [h(idxStart(i):idxEnd(i),i);zeros(m-(idxEnd(i)-idxStart(i))-1,1)];
end

t = (0:1/fs:length(hCrop)/fs-1/fs)';
end