%% RBA ISO parameter Demo Script %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This demo script shows the steps for
%   1. Importing a measured impulse response
%   2. Cropping and normalizing
%   3. Filtering into octave bands
%   4. Computing decay curves by Schroeder backwards integration
%   5. Obtaining ISO parameters: T30, EDT, C80, D50 and Ts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[h,fs] = wavread('sound/ReverberationChamberDTU.wav');