function [hCrop,idxEnd,t] = rbaCropIR(h,fs,idxStart,varargin)
%
%   Description: Crop impulse response according to ISO 3382 and optionally 
%                Lundeby's method. Indices of start and end samples of the 
%                uncropped impulse repsonse can also be given in the output.
%
%   Usage: [hCrop,idxEnd,t] = rbaCropIR(h,fs,idxStart[,knee])
%
%   Input parameters:
%       - h: Impulse response. If h is a matrix then it's assumed that the
%       impulse response are divided into e.g. octave bands.
%       - fs: Sampling frequency
%       - idxStart : Integer specifying the start sample of the broadband 
%                    impulse response.
%
%   Optional input parameters:
%       - knee: An integer corresponding to the knee point of the impulse
%               response. That is the sample at which the decay and and 
%               noise floor meet.
%
%   Output parameters:
%       - hCrop: Cropped impulse response. If h is a matrix then hCrop is a
%       matrix with cropped impulse response for each column of h
%       zero-padded to same length. 
%       - idxEnd: Index of end sample. If h is a matix then idxEnd is a
%       vector.
%       - t: Time vector of cropped impulse response
%   
%   See also: rbaStartIR, rbaLundeby
%   
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 9-11-2012, Last update: 29-11-2012
%   Acoustic Technology, DTU 2012

[m,n] = size(h);

if m<n
    h = h';
    [m,n] = size(h);
end

% Allocate
idxEnd = zeros(1,n);

for i = 1:n
if nargin == 3
    % Determine knee point of decay curve based on Lundebys method
    kneePoint = rbaLundeby(h(idxStart:end,i),fs);
elseif nargin == 4 
    % Get knee point from input
    kneePoint = ceil(varargin{1}); 
end
% Crop impulse response
idxEnd(i) = ceil(kneePoint(end));

if n == 1
hCrop(:,i) = h(idxStart:idxStart+idxEnd(i),i);
else
hCrop = zeros(m,n);
hCrop(:,i) = [h(idxStart:idxStart+idxEnd(i),i);zeros(m-(idxEnd(i)-idxStart)-1,1)];
end

t = (0:1/fs:length(hCrop)/fs-1/fs)';
end