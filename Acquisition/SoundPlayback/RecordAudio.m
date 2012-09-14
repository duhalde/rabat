function y = RecordAudio(length, Fs)
%
%   Description:    
%
%   Usage: y = function_name(x,...)
%
%   Input parameters:
%       - length: Recording length (s)
%       - Fs    : Sampling frequency (Hz)
%   Output parameters:
%       - y: 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 14-9-2012, Last update: 14-9-2012
%   Acoustic Technology, DTU 2012

% Enable low-latency recording
InitializePsychSound;

nrchannels = 1;

% Open audio device for recording. Mode == 2: Only recording. Latency == 0:
% Low latency. Recording on 1 channel.
pahandle = PsychPortAudio('Open', [], 2, 0, Fs, nrchannels);


% Preallocate recording buffer with length (s)
PsychPortAudio('GetAudioData', pahandle, length);

% Start recording. 1 repetition.
PsychPortAudio('Start', pahandle, 1, 0, 0, length);
disp('Recording Started');
WaitSecs(length);

PsychPortAudio('Stop', pahandle);


audiodata = PsychPortAudio('GetAudioData', pahandle);

PsychPortAudio('Close',pahandle);

y = audiodata';