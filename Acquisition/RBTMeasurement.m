function y = RBTMeasurement(signal, fs, latency)
%
%   Description:    
%
%   Usage: y = RBTMeasurement(signal, fs[, latency=1])
%
%   Input parameters:
%       - signal    : Measurement Signal
%       - fs        : Sampling frequency
%       - latency   : Latency setting (defau)
%   Output parameters:
%       - y     : Measured Signal 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 23-9-2012, Last update: 23-9-2012
%   Acoustic Technology, DTU 2012

if nargin < 2
   error('Missing input arguments');
end

if nargin < 3
    latency = 1;
end

if nargin > 2 && latency > 0
    InitializePsychSound;
end

wavedata = signal;
nrchannels = 1;
length = max(size(wavedata))/fs;
recordedaudio = [];

% Open channels for playback and recording
playhandle = PsychPortAudio('Open', [], [], latency, fs, nrchannels);
rechandle = PsychPortAudio('Open', [], 2, latenct, fs, nrchannels);

% Fill playback buffer
PsychPortAudio('FillBuffer', playhandle, wavedata);

% Allocate recording buffer     * Check Buffersize
PsychPortAudio('GetAudioData', rechandle, length*2);

% Start recording
PsychPortAudio('Start', rechandle, 1, 0, 1, []);
Disp('Recording Started')

% Start playback
PsychPortAudio('Start', playhandle, 1, 0, 0);
Disp('Playback Started');

% Get playback status
status = PsychPortAudio('GetStatus',playhandle);


% Record while playback is active
while status.Active == 1
    % Read audiodata from recording buffer
    audiodata = PsychPortAudio('GetAudioData',rechandle);
    recordedaudio = [recordedaudio audiodata];
    
    status = PsychPortAudio('GetStatus',playhandle);
end


% Stop audio recording
PsychPortAudio('Stop',rechandle);

% Read audiodata from recording buffer
audiodata = PsychPortAudio('GetAudioData',rechandle);
recordedaudio = [recordedaudio audiodata];

% Close channels
PsychPortAudio('Close', rechandle);
PsychPortAudio('Close', playhandle);


y = recordedaudio';







