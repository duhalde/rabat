function y = SoundPlayback(f1,f2,fs,length_sec)
%
%   Description: Generate log sine sweep and play
%
%   Usage: y = SoundPlayback(f1,f2,fs,length_sec)
%
%   Input parameters:
%       - f1: Lower frequency
%       - f2: Upper frequency
%       - fs: Sampling frequency
%       - length_sec: Length of signal
%   Output parameters:
%       - y: sampled signal
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 11-9-2012, Last update: 11-9-2012
%   Acoustic Technology, DTU 2012
% 
%   TODO:   
%       - Implement varargin for different signals
%       - 

y = log_sine_sweep(f1,f2,fs,length_sec);

freq = fs;
nrchannels = 1;    % One channel only -> Mono sound.
wavedata = y;      % Need sound vector as row vector, one row per channel.

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle, wavedata);

% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.
PsychPortAudio('Start', pahandle, 1, 0, 1);

% Wait length_sec seconds
WaitSecs(length_sec+0.5);

% Query current playback status and print it to the Matlab window:
s = PsychPortAudio('GetStatus', pahandle); disp(s);

% Stop playback:
PsychPortAudio('Stop', pahandle);

% Close the audio device:
PsychPortAudio('Close', pahandle);