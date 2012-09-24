function y = rbtMeasurement(signal, fs, estimatedRT ,latency)
%
%   Description:    
%
%   Usage: y = rbtMeasurement(signal, fs[, latency=1])
%
%   Input parameters:
%       - signal    : Measurement Signal
%       - fs        : Sampling frequency
%       - latency   : Latency setting (default)
%   Output parameters:
%       - y     : Measured Signal 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 23-9-2012, Last update: 24-9-2012
%   Acoustic Technology, DTU 2012

% error checking
if nargin < 3
   error('Missing input arguments!');
elseif nargin < 4
    latency = 1;
elseif nargin > 3 && (latency == 1 || latency == 2)
    InitializePsychSound;
else
    error('Latency must be either 1 or 2!')
end

nrChannels = 1;
inputSignalLength = length(signal)/fs;
recordedAudio = [];

% Open channels for playback and recording
playHandle = PsychPortAudio('Open', [], [], latency, fs, nrChannels);
recHandle = PsychPortAudio('Open', [], 2, latency, fs, nrChannels);

% Fill playback buffer
PsychPortAudio('FillBuffer', playHandle, signal);

% Allocate recording buffer     * Check Buffersize
PsychPortAudio('GetAudioData', recHandle, inputSignalLength*2);

% Start recording
PsychPortAudio('Start', recHandle, 1, 0, 1, []);
disp('Recording Started')

% Start playback
PsychPortAudio('Start', playHandle, 1, 0, 0);
disp('Playback Started');

% Get playback status
status = PsychPortAudio('GetStatus',playHandle);

% Record while playback is active
while status.Active
    % Read audiodata from recording buffer
    audioData = PsychPortAudio('GetAudioData',recHandle);
    recordedAudio = [recordedAudio audioData];
    
    status = PsychPortAudio('GetStatus',playHandle);
    %status.Active
end

status

WaitSecs(estimatedRT*1.5);

% Stop audio recording
PsychPortAudio('Stop',recHandle);
disp('Recording stopped')

% Read audiodata from recording buffer
audioData = PsychPortAudio('GetAudioData',recHandle);
recordedAudio = [recordedAudio audioData];

% Close channels
PsychPortAudio('Close', recHandle);
PsychPortAudio('Close', playHandle);


y = recordedAudio';







