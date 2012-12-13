function m = EACm(T,hr,Pa,f)
% function that calculates the energy attenuation coefficient m according 
% to iso 9613 -1
% T, temperature at measurement, in kelvin
% hr, specified relative humidity, in procent
% pa, ambient atmospheric pressure, in kilopascals
% f, frequency of the octave band
%
% Authors: Bolberg & Olesen
%
% Initial values
Pr = 101.325; % reference ambient atmospheric pressure, in kilopascals
T0 = 293.15; % reference air temperature, in kelvin
T01 = 273.15; % Triple point isotherm temperature, in kelvin
% Calculation
C = -6.8346.*(T01./T).^(1.261)+4.6151; Psat = 10.^(C).*Pr;
h = hr.*(Psat./Pr)./(Pa./Pr);
fr0 = (Pa./Pr).*(24+4.04*10.^(4).*h.*(0.02+h)./(0.391+h));
frN = (Pa./Pr).*(T./T0).^(-1./2).*(9+280.*h.*exp(-4.170.*((T./T0).^(-1./3)-1)));
nmax=max([length(T) length(h)]);
for i=1:nmax
Alpha = 8.686.*f.^(2).*((1.84.*10.^(-11).*(Pa./Pr).^(-1).*(T(i)./T0)...
.^(1./2))+(T(i)./T0).^(-5./2)... 
.*(0.01275.*exp(-2239.1./T(i)).*(fr0(i)+(f.^(2)./fr0(i)))...
.^(-1)+0.1068.*exp(-3352.0./T(i))... 
.*(frN(i)+(f.^(2)./frN(i))).^(-1)));
m(i,:) = Alpha./(10.*log10(exp(1))); 
end