function y = RecordAudio(maxseconds, Fs)
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
recordedaudio = [];

% Open audio device for recording. Mode == 2: Only recording. Latency == 0:
% Low latency. Recording on 1 channel.
pahandle = PsychPortAudio('Open', [], 2, 0, Fs, nrchannels);


% Preallocate recording buffer with length (s)
PsychPortAudio('GetAudioData', pahandle, maxseconds*2);

% Start recording. 1 repetition.
PsychPortAudio('Start', pahandle, 1, 0, 1, maxseconds);
disp('Recording Started');

while length(recordedaudio)/Fs < maxseconds

% Extract audio data
audiodata = PsychPortAudio('GetAudioData', pahandle);
recordedaudio = [recordedaudio audiodata];

end

audiodata = PsychPortAudio('GetAudioData', pahandle);
recordedaudio = [recordedaudio audiodata];

% Close connection
PsychPortAudio('Close',pahandle);

y = recordedaudio';