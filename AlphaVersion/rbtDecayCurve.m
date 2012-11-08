function [R,varargout] = rbtDecayCurve(h,fs,cfmin,cfmax,method)
%
%   Description: Calculate the decay curve from Schröders backwards
%   integration method.
%
%   Usage: R = rbtDecayCurve(h,fs,cfmin,cfmax,method)
%
%   Input parameters:
%       - h: Impulse response
%       - fs: 
%       - cfmin, cfmax
%       - method: 
%   Output parameters:
%       - R: Normalized decay curve in dB 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 30-9-2012, Last update: 30-9-2012
%   Acoustic Technology, DTU 2012    

switch lower(method)

    case 'schroeder'
        
    case 'lundeby'
        
    case 'non-linear'
    
    rir = h;
    
    bandsPerOctave = 1;     % octave band filter    
    freqs = rbtGetFreqs(cfmin,cfmax,bandsPerOctave);
    nCF = length(freqs);    
        
    [B,A] = rbtHomemadeFilterBank(1,fs,cfmin,cfmax,1);

    t = 0:1/fs:length(rir)/fs-1/fs;
    
    % Allocate
    rir_band = zeros(length(rir),nCF);
    rir_scale = zeros(length(rir),nCF);
    R = zeros(length(rir),nCF);
    intt = zeros(1,nCF);
    
    for i = 1:nCF
    disp(['Now processing band ' num2str(i) ' out of ' num2str(nCF)])
    rir_band(:,i) = filter(B(:,i),A(:,i),rir);          % Filtered IR
    %rir_band(:,i) = abs(hilbert(rir_band(:,4)));
    rir_scale(:,i) = rir_band(:,i).^2;                   % Squared IR
    rir_scale(:,i) = 10*log(rir_scale(:,i));                  % dB scale
    rir_scale(:,i) = rir_scale(:,i) - max(rir_scale(:,i));     % Normalize
    %rir_band(:,i) = smooth(rir_band(:,i),200/fs);
    
    % Fit curve to RIR
    data = [rir_scale(:,i) t'];
    v = decay2_fit(data,[],[],0);
    fittedCurve = 20*log10(decay_model(v,t',1));
    [~,intt(i)] = max(diff(fittedCurve,2));            % Find knee-point
    
    end

    R = fittedCurve;
    varargout{1} = intt;
    
    otherwise
          error('Unknown method, choose one of: "schroeder","lundeby","non-linear"')
end



% Find peak in impulse response
%[maxpeak k] = max(h);

%R = cumsum(h(end:-1:k).^2);
%R = R(end:-1:1);
%R = 10*log10(R);        % In dB
%R = R-max(R);           % Normalize