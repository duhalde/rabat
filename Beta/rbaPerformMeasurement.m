function y = rbaPerformMeasurement(signal, fs, N, estimatedRT, transient, latency)
%
%   Description:
%
%   Usage: y = rbaMeasurement(signal, fs, N, estimatedRT[, transient = 0, latency=1])
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
    case 4
        transient = 0;
        latency = 1;
    case 5
        latency = 1;
        if transient == 0 || transient == 1
            % everything ok
        else
            error('Transient must be set to either 0 or 1!')
        end
    case 6
        if latency == 1 || latency == 2
            % everything ok
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

if transient % each sweep are played with a quiet tale of estimatedRT
    % zero-pad
    signal = [signal(:)' zeros(1,estimatedRT*fs)];
else
    % sound field are built up with one sweep and recording are done with no quiet tales
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
    % do N recordings and let fade
    playbacks = 1:N;
    % process all
    extracts = 1:N;
else
    % do N+1 short recordings with no gap in between
    playbacks = 1:N+1;
    % but only process the last N recordings
    extracts = 2:N+1;
end

% initialize matrix for storing the recorded sweeps
% note length is to ensure that there is room enough
measurements = zeros(2*signalSeconds*fs,N);

% Record loop START
for k = playbacks

    % initialize vector of unknown length...
    recordedAudio = [];

    % Start recording
    PsychPortAudio('Start', recHandle);

    % Start playback
    PsychPortAudio('Start', playHandle);

    if transient
        disp(['Now recording sweep ' num2str(k) ' out of ' num2str(N)]);
    elseif k == 1
        disp('Sound field building up')
    else
        disp(['Now recording sweep ' num2str(k-1) ' out of ' num2str(N-1)]);
    end

    % Get playback status
    status = PsychPortAudio('GetStatus',playHandle);

    while status.Active == 0
        status = PsychPortAudio('GetStatus',playHandle);
        %disp('not active')
    end

    % Record while playback is active
    while status.Active == 1
        % Read audiodata from recording buffer
        audioData  = PsychPortAudio('GetAudioData',recHandle);
        recordedAudio = [recordedAudio audioData];

        if length(recordedAudio) > length(signal)*3;
             status = PsychPortAudio('GetStatus',recHandle);
             disp(status.Active);
             error('System is stalling');
        end

        % check if playback is done
        %disp('active')
        status = PsychPortAudio('GetStatus',playHandle);
        % make sure CPU laod is not too high
        if status.CPULoad > 0.95
            disp('Very high CPU load. Timing or sound glitches are likely to occur.')
        end
    end

    % when doing transient measurement
    %if transient
        % Make sure full sound decay has reached the microphone.
        % 500 ms corresponds to a sound travel distance of 171.5 m. Change this
        % value if any of the room dimensions exceeds 86 m.
        soundDecayDistance = 500e-3;
        WaitSecs(soundDecayDistance);
	%end

    % Stop audio recording
    PsychPortAudio('Stop',recHandle,1);
    disp('recording stopped')

    % Read audiodata from recording buffer
    % ctsstarttime could give a good estimate of the onset sample, to use
    % with rbaCropIR
    disp('data is being read')
    %[audioData,~,~,ctsstarttime] = PsychPortAudio('GetAudioData',recHandle);
    %recordedAudio = [recordedAudio audioData];
    disp('data is read')
    measurements(:,k) = [recordedAudio zeros(length(measurements)-length(recordedAudio))];
end

% initialize returning matrix, which holds the cropped recorded sweeps
Y = zeros(signalSeconds*fs,N);

% Process loop START
for m = extracts

    % find the exact position of the sweep in the recorded signal
    [c,lags] = rbaCrossCorr(measurements(:,m), signal);

    % uncertain if this error check should be done or not!
    % Compute goodness-of-fit
    cGoodnessOfFit = max(c)/(norm(measurements(:,m))*norm(signal));
    %
    %     if cGoodnessOfFit < 0.2    %  Perfectly correlated if cGoodnessOfFit = 1
    %         % Stop due to error and close channels
    %         PsychPortAudio('Close', recHandle);
    %         PsychPortAudio('Close', playHandle);
    %         error(['Signals are not correlated at all. Correlation goodness-of-fit is ' num2str(cGoodnessOfFit)])
    %     else

    sweepIdx = lags(max(c)==c);
    % and place the recorded sweep in a matrix
    if transient
        Y(:,m) = measurements(sweepIdx:sweepIdx+length(signal)-1,m);
    else
        % make sure that there are only N recorded sweeps in Y
        Y(:,m-1) = measurements(sweepIdx:sweepIdx+length(signal)-1,m);
    end
end
%     end

% Close channels
PsychPortAudio('Close', recHandle);
PsychPortAudio('Close', playHandle);

% take the ensemble average, i.e. along the 2nd dimension of Y
y = mean(Y,2);
%y = recordedAudio;

