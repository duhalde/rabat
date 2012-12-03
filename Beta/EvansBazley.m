function m = EvansBazley(f,humidity,ps,T)
% 
%   Description: Calculate air attenuation from Evans & Bazley [1956]
%
%   Input parameters:
%       f: Frequency
%       humidity: Humidity in %
%       ps: atmospheric pressure [atm]
%       T: Temperature in C
%   Output parameters:
%       m: attenuation coefficient as function of f
%
c = 343;
mu = 2.14e-3;
M = 2*mu/c;
ps0 = 1;    % Ref atmospheric pressure 1 Atm
T0 = 273.16;
T = T0+T;
psat = ps0*10^(-6.8346*(T0/T)^1.261 + 4.6151);
h = ps0*(humidity/ps)*(psat/ps0);
k = 1.92*h^(1.3)*1e5;
d = k./(2*pi*f);
m = 1e-12*(33 + 0.2).*f.^2 + (M.*f)./(d+(1./d));
end