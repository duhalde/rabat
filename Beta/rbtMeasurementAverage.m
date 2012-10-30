function y = rbtMeasurementAverage(signal, fs, estimatedRT ,latency, N)
%
%   Description:
%
%   Usage: y = rbtMeasurement(signal, fs, estimatedRT[, latency=1])
%
%   Input parameters:
%       - signal    : Measurement Signal
%       - fs        : Sampling frequency
%       - latency   : Latency setting (default)
%       - N         : Number of Averages
%   Output parameters:
%       - y     : Measured Signal
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 23-9-2012, Last update: 26-9-2012
%   Acoustic Technology, DTU 2012

% error checking
if nargin < 3
    error('Missing input arguments!');
elseif nargin < 4
    latency = 1;
elseif nargin > 3 && (latency == 1 || latency == 2)
    InitializePsychSound;
else
    error('Latency must be set to either 1 or 2!')
end

% zero-pad to wanted length
signal = [signal(:)' zeros(1,estimatedRT*fs)];

nrChannels = 1;
signalSeconds = length(signal)/fs;


% Open channels for playback and recording
playHandle = PsychPortAudio('Open', [], [], latency, fs, nrChannels);
recHandle = PsychPortAudio('Open', [], 2, latency, fs, nrChannels);

% Fill playback buffer
PsychPortAudio('FillBuffer', playHandle, signal);

% Allocate recording buffer     * Check Buffersize
%
% OLY NOTE:
% Consider using ceil(size(signalSeconds,2)/fs) instead of signalSeconds*2
PsychPortAudio('GetAudioData', recHandle, signalSeconds+500e-3); % allow 500 ms for latency

% initialize matrix for storing the recorded sweeps
Y = zeros(signalSeconds*fs,N);

% For-loop START
for k = 1:N
    
    recordedAudio = [];
    
    % Start recording
    
    PsychPortAudio('Start', recHandle);
    disp('Recording started')
    
    % Start playback
    PsychPortAudio('Start', playHandle);
    disp('Playback started');
    
    % Get playback status
    status = PsychPortAudio('GetStatus',playHandle);
    
    while status.Active == 0
        status = PsychPortAudio('GetStatus',playHandle);
    end
    
    % Record while playback is active
    while status.Active == 1
        % Read audiodata from recording buffer
        audioData = PsychPortAudio('GetAudioData',recHandle);
        recordedAudio = [recordedAudio audioData];
        % check if recording is done
        status = PsychPortAudio('GetStatus',playHandle);
    end
    
    WaitSecs(100e-3);
    
    disp('Playback finished');
    
    % Stop audio recording
    PsychPortAudio('Stop',recHandle,1); 
    
    disp('Recording stopped')
    
    % Read audiodata from recording buffer
    audioData = PsychPortAudio('GetAudioData',recHandle);
    recordedAudio = [recordedAudio audioData];
    
    % find the exact position of the sweep in the recorded signal
    [c,lags] = rbtCrossCorr(recordedAudio, signal);

    sweepIdx = lags(max(c)==c);
    % and place the recorded sweep in a matrix
    Y(:,k) = recordedAudio(sweepIdx:sweepIdx+length(signal)-1);
end

% Close channels
PsychPortAudio('Close', recHandle);
PsychPortAudio('Close', playHandle);

% take the ensemble average, i.e. along the 2nd dimension of Y
y = mean(Y,2);
