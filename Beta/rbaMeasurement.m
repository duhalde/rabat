function y = rbaMeasurement(signal, fs, N, estimatedRT, transient, latency)
%
%   Description: Performs a system response measurement with the default
%   input and output of the system.
%
%   Usage: y = rbtMeasurement(signal, fs, N, estimatedRT[, transient = 0, latency=1])
%
%   Input parameters:
%       - signal        : Measurement Signal
%       - fs            : Sampling frequency
%       - N             : Number of Averages
%       - estimatedRT   : Estimated reverberation time in seconds
%       - transient     : Measurement type, set 1 for transient, otherwise
%                           A steady state mesurement are used
%                           (transient = 0) default
%       - latency       : Optional latency setting for PsychPortAudio
%                           Normal latency setting (latency = 1) default
%                           Low (fast) latency setting (latency = 2)
%
%   Output parameters:
%       - y             : Measured Signal
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 23-9-2012, Last update: 2-12-2012
%   Acoustic Technology, DTU 2012
%

% Error checking
switch nargin
    case 5
        latency = 1;
    case 6
        if latency == 1 || latency == 2

        else
            error('Latency must be set to either 1 or 2!')
        end
    otherwise
        error('Wrong number of input arguments')
end

% Disable most status messages from PsychPortAudio during
% initialization
outputMsg = PsychPortAudio('Verbosity');
if outputMsg > 2
    PsychPortAudio('Verbosity',2);
end

InitializePsychSound;   % Initialize PsychPortAudio

if transient
% zero-pad to wanted length
signal = [signal(:)' zeros(1,estimatedRT*fs)];
end

nrChannels = 1;
signalSeconds = length(signal)/fs;

% Open channels for playback and recording
playHandle = PsychPortAudio('Open', [], [], latency, fs, nrChannels);
recHandle = PsychPortAudio('Open', [], 2, latency, fs, nrChannels);

% Restore output message settings to default level
PsychPortAudio('Verbosity',outputMsg);

% Fill playback buffer
PsychPortAudio('FillBuffer', playHandle, signal);

% Get I/O latency estimation
statusPlay = PsychPortAudio('GetStatus',playHandle);
statusRec = PsychPortAudio('GetStatus',recHandle);
dOut = PsychPortAudio('GetDevices',[],statusPlay.OutDeviceIndex);
dIn = PsychPortAudio('GetDevices',[],statusRec.InDeviceIndex);
outLatency = dOut.HighOutputLatency;
inLatency = dIn.HighInputLatency;

totalLatency = outLatency+inLatency;
compTime = 2;           % Estimated CPU time
%soundDecayTime = 5;    % ISO 3382-1 suggest a delay of at least 5s + estimated RT

% Allocate recording buffer     * Check Buffersize
PsychPortAudio('GetAudioData', recHandle, signalSeconds+totalLatency+compTime);

if transient
    % initialize matrix for storing the recorded sweeps
    Y = zeros(signalSeconds*fs,N);
    loopVals = 1:N;
else
    % initialize matrix for storing the recorded sweeps
    Y = zeros(signalSeconds*fs,N);
    loopVals = 1:N+1;
end

% For-loop START
for k = loopVals

    recordedAudio = [];

    % Start recording

    PsychPortAudio('Start', recHandle);
    %disp('Recording started')

    % Start playback
    PsychPortAudio('Start', playHandle);

    % inform the user of the progress
    if transient
        disp(['Now recording sweep ' num2str(k) ' out of ' num2str(N)]);
    elseif k == 1
        disp('Sound field building up')
    else
        disp(['Now recording sweep ' num2str(k-1) ' out of ' num2str(N)]);
    end

    % Get playback status
    status = PsychPortAudio('GetStatus',playHandle);

    while status.Active == 0
        status = PsychPortAudio('GetStatus',playHandle);
    end

    % Record while playback is active
    while status.Active == 1
        % Read audiodata from recording buffer
        audioData  = PsychPortAudio('GetAudioData',recHandle);
        recordedAudio = [recordedAudio audioData];
        % check if recording is done
        status = PsychPortAudio('GetStatus',playHandle);
        if status.CPULoad > 0.95
            disp('Very high CPU load. Timing or sound glitches are likely to occur.')
        end
    end

    
    % Make sure full sound decay has reached the microphone.
    % 500 ms corresponds to a sound travel distance of 171.5 m. Change this
    % value if any of the room dimensions exceeds 86 m.
    if transient
        soundDecayDistance = 500e-3;
    else % wait only for a very short time
        soundDecayDistance = 50e-3;
    end
    WaitSecs(soundDecayDistance);

    % Stop audio recording
    PsychPortAudio('Stop',recHandle,1);

    % Read audiodata from recording buffer
    audioData = PsychPortAudio('GetAudioData',recHandle);
    recordedAudio = [recordedAudio audioData];
    % find the exact position of the sweep in the recorded signal
    [c,lags] = rbaCrossCorr(recordedAudio, signal);
    
    % find start index of the recorded sweep
    sweepIdx = lags(max(c)==c);
    % since we know the length of the output signal, we only save the same
    % length of the input
    sweepEndIdx = sweepIdx+length(signal)-1;
    
    % and place the recorded sweep in a matrix
    if transient
        Y(:,k) = recordedAudio(sweepIdx:sweepEndIdx);
    elseif k == 1   % do not save the build-up sweep
        continue;
    else    % treat sescond sweep as the first recording
        Y(:,k-1) = recordedAudio(sweepIdx:sweepEndIdx);
    end

end

% Close channels
PsychPortAudio('Close', recHandle);
PsychPortAudio('Close', playHandle);

% take the ensemble average, i.e. along the 2nd dimension of Y
y = mean(Y,2);
%y = recordedAudio;

