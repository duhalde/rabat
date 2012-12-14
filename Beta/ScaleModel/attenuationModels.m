% Testing different models of air attenuation
clear all
close all
f = rbtGetFreqs(63,64000,1);
T = 25;
hr = 40;
Pa = 101.325;
mE = mEvans(T,hr,Pa,f);
mISO = EACm(T,hr,Pa,f);

semilogx(f,mE-mISO,'-ro'), hold on
plot(f,mISO,'-s')
legend('Evans & Bazley','ISO','Location','NW')