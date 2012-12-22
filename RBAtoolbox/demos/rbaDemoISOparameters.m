%% RBA ISO parameter Demo Script %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This demo script shows the steps for
%   1. Importing a measured impulse response
%   2. Cropping the impulse response
%   3. Filtering into octave bands
%   4. Computing decay curves by Schroeder backwards integration
%   5. Obtaining ISO parameters: T60, EDT, C80, D50 and Ts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read impulse response from measurement
[h,fs] = wavread('ReverberationChamberDTU.wav'); 
[hCrop,t] = rbaCropIR(h,fs,'onset');    % Crop away onset
OctaveBands = 1;                        % Working with 1/1 octave bands
% Find octave bands in frequency interval of interest
freqs = rbaGetFreqs(63,8000,OctaveBands); 
reverse = 0;
% Filter impulse response into octave bands
H = rbaIR2OctaveBands(hCrop,fs,min(freqs),max(freqs),OctaveBands,reverse);
% Compute common ISO 3382-1 parameters
C = rbaClarity(H,fs);
D = rbaDefinition(H,fs);
Ts = rbaCentreTime(H,fs);
% T60 and EDT requires computation of decay curves
R = rbaSchroeder(H,fs);                 % Compute decay curves
[RT, r2pRT, dynRange,stdDevRT] = rbaReverberationTime(R,t,'best');
[EDT,r2pEDT,stdEDT] = rbaEDT(R,t);
% Print parameters in Command Window
ISOmatrix = [RT;EDT;D;C;Ts];
str = ['T60  ';'EDT  ';'D50  ';'C80  ';'Ts   '];
disp([str num2str(ISOmatrix,3)])