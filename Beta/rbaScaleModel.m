function [hFull,tFull] = rbaScaleModel(hModel,fsModel,K,fFull,T,hr,Pa)
%
%   Description: Rescale impulse response measured in a 1/K scale model 
%   according to ISO 9613-1 and compensation for excess air attenuation.
%
%   Usage: [hFull,t] = rbaScaleModel(hModel,fsModel,K,fFull,T,hr,Pa)
%
%   Input parameters:
%       - hModel: Impulse response measured in scale model
%       - fsModel: Sampling frequency in scale model measurement
%       - K: Scale factor 1/K, e.g. 10 or 20
%       - fFull: Frequency of interest in full scale. Can e.g. be a vector
%           containing narrowband frequencies (e.g. octave bands [125 250 500...])
%       - T: Vector containing temperature in degree Celcius of the assumed
%           full scale reference TFull and in the measurement [TFull Tmod]. If
%           only one value is given, TFull = 25 C.
%       - hr: Vector containing relative humidity in % of the assumed full scale reference
%           and the actual measured in the measurement [hrFull hrMod]. If only
%           one value is given, hrFull = 40 %
%       - Pa: Vector containing the ambient atmospheric pressure in kPa of
%           full scale reference and the measured in the scale model [PaFull PaMod]. 
%           If only one value is given, PaFull = 101.325 kPa. If no value is given
%           PaFull = PaMod = 101.325 kPa
%   Output parameters:
%       - hFull: Full scale impulse response compensated for excess air
%           attenuation.
%       - tFull: Full-scale time vector
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 16-12-2012, Last update: 17-12-2012
%   Acoustic Technology, DTU 2012

% Crop impulse response
% More ideally should the knee point of each frequency band be found by
% Lundeby's method and then applied
hModel = rbaCropIR(hModel,fsModel);
fsFull = fsModel/K;
tMod = 0:1/fsModel:length(hModel)/fsModel-1/fsModel;
tFull = tMod*K;
fMod = fFull*K;

if length(T)==2
TFull = T(1);
TMod = T(2);
else
    TFull = 25;
    TMod = T(1);
end

if length(hr)==2
hrFull = hr(1);
hrMod = hr(2);
else
    hrFull = 40;
    hrMod = hr(1);
end

if nargin == 6
    PaFull = 101.325;
    PaMod = PaFull;
elseif nargin == 7
    if length(Pa)==2
        PaFull = Pa(1);
        PaMod = Pa(2);
    else
        PaFull = 101.325;
        PaMod = T(1);
    end
end
   
%mfFull = mEvans(TFull,hrFull,PaFull,fFull);
%mfMod = mEvans(TMod,hrMod,PaMod,fMod);
mfFull = EACm(TFull,hrFull,PaFull,fFull);
mfMod = EACm(TMod,hrMod,PaMod,fMod);

% Speed of sound in air (should be incorporated as an output in EACm)
cFull = 344;
cMod = cFull;

% absorption discrepancies (ie. difference in absorption between reference and model)
bn = mfMod.*cMod-K*mfFull.*cFull;

% Compensation filter
H = zeros(length(tMod),length(bn));
for i = 1:length(bn)
    H(:,i) = 10.^(bn(i)*tMod/20);
end

% convert signal to octave bands
sigModOct = rbaIR2OctaveBands(hModel,fsFull,min(fFull),max(fFull));

sigFullOct = zeros(size(sigModOct));
kn = zeros(size(sigModOct,2),1);
for i = 1:size(sigModOct,2)
knee = rbaLundeby(sigModOct(:,i),fsFull);
kn(i) = knee(end);
sigFullOct(:,i) = [(sigModOct(1:kn(i),i).*H(1:kn(i),i)); H(kn(i),i).*sigModOct(kn(i)+1:end,i)];
end

hFull = sum(sigFullOct,2);

end