function [hFull,t] = rbaScaleModel(hModel,fsModel,K,fFull,T,hr,Pa)
%
%   Description: Rescale impulse response measured in a scale model 1:K
%   according to ISO 9613-1 and compensation for excess air attenuation.
%
%   Usage: [hFull,t] = rbaScaleModel(hModel,fsModel,K,fFull,T,hr,Pa)
%
%   Input parameters:
%       - hModel: Impulse response measured in scale model
%       - fsModel: Sampling frequency in scale model measurement
%       - K: Scale factor 1:K, e.g. 10 or 20
%       - fFull: Frequency of interest in full scale. Can e.g. be a vector
%           containing narrowband frequencies (e.g. octave bands [125 250 500...])
%       - T: Vector containing temperature in degree Celcius of the assumed
%           full scale reference Tref and in the measurement [Tref Tmod]. If
%           only one value is given, Tref = 25 C.
%       - hr: Vector containing relative humidity in % of the assumed full scale reference
%           and the actual measured in the measurement [hrRef hrMod]. If only
%           one value is given, hrRef = 40 %
%       - Pa: Vector containing the ambient atmospheric pressure in kPa of
%           full scale reference and the measured in the scale model [PaRef PaMod]. 
%           If only one value is given, PaRef = 101.325 kPa. If no value is given
%           PaRef = PaMod = 101.325 kPa
%   Output parameters:
%       - hFull: Full scale impulse response compensated for excess air
%           attenuation.
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 16-12-2012, Last update: 16-12-2012
%   Acoustic Technology, DTU 2012

% Crop impulse response
% More ideally should the knee point of each frequency band be found by
% Lundeby's method and then applied
hModel = rbaCropIR(hModel,fsModel);
fsRef = fsModel/K;
t = 0:1/fsRef:length(hModel)/fsRef-1/fsRef;
fMod = fFull*K;

if length(T)==2
TRef = T(1);
TMod = T(2);
else
    TRef = 25;
    TMod = T(1);
end

if length(hr)==2
hrRef = hr(1);
hrMod = hr(2);
else
    hrRef = 40;
    hrMod = hr(1);
end

if nargin == 6
    PaRef = 101.325;
    PaMod = PaRef;
elseif nargin == 7
    if length(Pa)==2
        PaRef = Pa(1);
        PaMod = Pa(2);
    else
        PaRef = 101.325;
        PaMod = T(1);
    end
end
   
%mfRef = mEvans(TRef,hrRef,PaRef,fRef);
%mfMod = mEvans(TMod,hrMod,PaMod,fMod);
mfRef = EACm(TRef,hrRef,PaRef,fRef);
mfMod = EACm(TMod,hrMod,PaMod,fMod);

% Speed of sound in air (should be incorporated as an output in EACm)
cRef = 344;
cMod = cRef;

% absorption discrepancies (ie. difference in absorption between reference and model)
bn = mfMod.*cMod-K*mfRef.*cRef;

% Compensation filter
H = zeros(length(t),length(bn));
for i = 1:length(bn)
    H(:,i) = 10.^(bn(i)*t/20);
end

% convert signal to octave bands
sigModOct = rbaIR2OctaveBands(hModel,fsRef,min(fRef),max(fRef));

hFull = sum(sigModOct.*H,2);

end