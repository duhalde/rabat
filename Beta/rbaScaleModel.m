function [hFull,tFull] = rbaScaleModel(hModel,fsModel,K,fFull,T,hr,Pa)
%
%   Description: Rescale impulse response measured in a 1/K scale model 
%   according to ISO 9613-1 and compensation for excess air attenuation.
%   NOTE: This function is still under development and further testing is
%   needed in order to verify its functionality.
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
%   Date: 16-12-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012

tMod = (0:1/fsModel:length(hModel)/fsModel-1/fsModel);
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
[mfFull,cFull] = EACm(TFull,hrFull,PaFull,fFull);
[mfMod,cMod] = EACm(TMod,hrMod,PaMod,fMod);

% absorption discrepancies (ie. difference in absorption between reference and model)
bn = mfMod.*cMod-K*mfFull.*cFull;

% Compensation filter
H = zeros(length(tMod),length(bn));
for i = 1:length(bn)
    H(:,i) = 10.^(bn(i)*tMod/20);
end

% convert signal to octave bands
sigModOct = rbaIR2OctaveBands(hModel,fsModel,min(fMod),max(fMod));

sigFullOct = zeros(size(sigModOct));
kn = zeros(size(sigModOct,2),1);
for i = 1:size(sigModOct,2)
knee = rbaLundeby(sigModOct(:,i),fsModel);
kn(i) = knee(end);
sigFullOct(:,i) = [(sigModOct(1:kn(i),i).*H(1:kn(i),i)); H(kn(i),i).*sigModOct(kn(i)+1:end,i)];
end

hFull = sum(sigFullOct,2);

end

function [m,c] = EACm(T,hr,Pa,f)
% function that calculates the energy attenuation coefficient m according 
% to iso 9613 -1
% T, temperature at measurement, in Celcius
% hr, specified relative humidity, in procent
% pa, ambient atmospheric pressure, in kilopascals
% f, frequency of the octave band
%
% Authors: Bolberg & Olesen
% Modified by:
% Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 16-12-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012
% 
% Initial values
Pr = 101.325; % reference ambient atmospheric pressure, in kilopascals
T0 = 293.15; % reference air temperature, in kelvin
T01 = 273.15; % Triple point isotherm temperature, in kelvin
c = 343.2*(T01+T)/T0; % Speed of sound in air at T degrees.
% Use degrees celcius for simplicity:
T = T + T01;
% Calculation
C = -6.8346.*(T01./T).^(1.261)+4.6151; Psat = 10.^(C).*Pr;
h = hr.*(Psat./Pr)./(Pa./Pr);
fr0 = (Pa./Pr).*(24+4.04*10.^(4).*h.*(0.02+h)./(0.391+h));
frN = (Pa./Pr).*(T./T0).^(-1./2).*(9+280.*h.*exp(-4.170.*((T./T0).^(-1./3)-1)));
nmax=max([length(T) length(h)]);
m = zeros(nmax,length(f));
for i=1:nmax
Alpha = 8.686.*f.^(2).*((1.84.*10.^(-11).*(Pa./Pr).^(-1).*(T(i)./T0)...
.^(1./2))+(T(i)./T0).^(-5./2)... 
.*(0.01275.*exp(-2239.1./T(i)).*(fr0(i)+(f.^(2)./fr0(i)))...
.^(-1)+0.1068.*exp(-3352.0./T(i))... 
.*(frN(i)+(f.^(2)./frN(i))).^(-1)));
m(i,:) = Alpha./(10.*log10(exp(1))); 
end
end

function m=mEvans(T,hr,Pa,f)
% function that calculates the energy attenuation coefficient m according 
% Evans & Bazley (1956)
% T, temperature at measurement, in Celcius
% hr, specified relative humidity, in procent
% pa, ambient atmospheric pressure, in kilopascals
% f, frequency of the octave band
%
% Authors: Bolberg & Olesen
%
% Modified by:
% Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 16-12-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012
%
% Initial values
Pr = 101.325; % reference ambient atmospheric pressure, in kilopascals
T0 = 293.15; % reference air temperature, in kelvin
T01 = 273.15; % Triple point isotherm temperature, in kelvin
T = T+T01;
c=343;
C = -6.8346.*(T01./T).^(1.261)+4.6151; Psat = 10.^(C).*Pr;
h = hr.*(Psat./Pr)./(Pa./Pr); relxk=1.92.*h.^(1.3).*10.^5;
muMax =0.00214;
nmax=max([length(T) length(hr)]);
for i=1:nmax % Calculation
mc=(33+0.2.*T(i))*f.^2.*10.^(-12); M=2.*muMax./c;
mm=M.*f./((relxk(i)./(2.*pi.*f))+((2.*pi.*f)./relxk(i)));
m(i,:)=mc+mm;
end
end