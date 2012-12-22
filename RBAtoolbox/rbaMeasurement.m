function y = rbaMeasurement(signal, fs, N, estimatedRT)
%
%   Description: Performs a system response measurement with the default
%   input and output ports of the computer operating system.
%
%   Usage: y = rbaMeasurement(signal, fs, N, estimatedRT)
%
%   Input parameters:
%       - signal         : Measurement Signal
%       - fs             : Sampling frequency
%       - N              : Number of Averages
%       - estimatedRT    : Estimated reverberation time in seconds
%
%   Output parameters:
%       - y             : Measured Signal
%
%   NB! This function requires PsychToolbox:
%   http://psychtoolbox.org/HomePage
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 23-9-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012
%



% Check if PsychPortAudio is installed
if  exist('PsychPortAudio','file') ~= 3
    error('PsychToolbox is required to run rbaMeasurement. Please visit http://psychtoolbox.org/HomePage')
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
playHandle = PsychPortAudio('Open', [], [], [], fs, nrChannels);
recHandle = PsychPortAudio('Open', [], 2, [], fs, nrChannels);

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

% initialize matrix for storing the recorded sweeps
Y = zeros(signalSeconds*fs,N);

% For-loop START
for k = 1:N

    recordedAudio = [];

    % Start recording

    PsychPortAudio('Start', recHandle);
    %disp('Recording started')

    % Start playback
    PsychPortAudio('Start', playHandle);

    % inform the user of the progress
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
    Y(:,k) = recordedAudio(sweepIdx:sweepEndIdx);

end

% Close channels
PsychPortAudio('Close', recHandle);
PsychPortAudio('Close', playHandle);

% take the ensemble average, i.e. along the 2nd dimension of Y
y = mean(Y,2);

end