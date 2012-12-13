function m=mEvans(T,hr,Pa,f)
% function that calculates the energy attenuation coefficient m according 
% Evans & Bazley (1956)
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