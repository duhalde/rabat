function y = rbtMeasurement(signal, fs, N, estimatedRT ,latency)
%
%   Description:
%
%   Usage: y = rbtMeasurement(signal, fs, N, estimatedRT[, latency=1])
%
%   Input parameters:
%       - signal        : Measurement Signal
%       - fs            : Sampling frequency
%       - N             : Number of Averages
%       - estimatedRT   : Estimated reverberation time in seconds
%       - latency       : Latency setting for PsychPortAudio (default = 1) 
%                         Low latency setting (latency = 2)
%       
%   Output parameters:
%       - y             : Measured Signal
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 23-9-2012, Last update: 11-11-2012
%   Acoustic Technology, DTU 2012
%

% Error checking
switch nargin
    case 4
        latency = 1;
    case 5 
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

% zero-pad to wanted length
signal = [signal(:)' zeros(1,estimatedRT*fs)];

nrChannels = 1;
signalSeconds = length(signal)/fs;

% Open channels for playback and recording
playHandle = PsychPortAudio('Open', [], [], latency, fs, nrChannels);
recHandle = PsychPortAudio('Open', [], 2, latency, fs, nrChannels);

% Restore output message settings to default level
PsychPortAudio('Verbosity',outputMsg);

% Fill playback buffer
PsychPortAudio('FillBuffer', playHandle, signal);

% Get I/O latency estimatation
statusPlay = PsychPortAudio('GetStatus',playHandle);
statusRec = PsychPortAudio('GetStatus',recHandle);
dOut = PsychPortAudio('GetDevices',[],statusPlay.OutDeviceIndex);
dIn = PsychPortAudio('GetDevices',[],statusRec.InDeviceIndex);
outLatency = dOut.HighOutputLatency;
inLatency = dIn.HighInputLatency;

totalLatency = outLatency+inLatency;
compTime = 2;     % Estimated CPU time: 1 second.
% Allocate recording buffer     * Check Buffersize
PsychPortAudio('GetAudioData', recHandle, signalSeconds+totalLatency+compTime);

% initialize matrix for storing the recorded sweeps
Y = zeros(signalSeconds*fs,N);

% For-loop START
for k = 1:N
    
    recordedAudio = [];
    
    % Start recording
   tic
    PsychPortAudio('Start', recHandle);
    %disp('Recording started')
    
    % Start playback
    PsychPortAudio('Start', playHandle);
    
    disp(['Now recording sweep ' num2str(k) ' out of ' num2str(N)]);
    
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
    soundDecayDistance = 500e-3;
    WaitSecs(soundDecayDistance);       
    
    %disp('Playback finished');
    
    % Stop audio recording
    PsychPortAudio('Stop',recHandle,1); 
    
    % Use status struct to predict system latency
    % status.PredictedLatency 
 
    %disp('Recording stopped')
    
    % Read audiodata from recording buffer
    audioData = PsychPortAudio('GetAudioData',recHandle);
    recordedAudio = [recordedAudio audioData];
    % find the exact position of the sweep in the recorded signal
    [c,lags] = rbtCrossCorr(recordedAudio, signal);
    
    % Compute goodness-of-fit
    cGoodnessOfFit = max(c)/(norm(recordedAudio)*norm(signal));
    
    if cGoodnessOfFit < 0.2    %  Perfectly correlated if cGoodnessOfFit = 1
        % Stop due to error and close channels
        PsychPortAudio('Close', recHandle);
        PsychPortAudio('Close', playHandle);
        error(['Signals are not correlated at all. Correlation goodness-of-fit is ' num2str(cGoodnessOfFit)])
    else
        sweepIdx = lags(max(c)==c);
        % and place the recorded sweep in a matrix
        Y(:,k) = recordedAudio(sweepIdx:sweepIdx+length(signal)-1);
    end
end

% Close channels
PsychPortAudio('Close', recHandle);
PsychPortAudio('Close', playHandle);

% take the ensemble average, i.e. along the 2nd dimension of Y
y = mean(Y,2);

