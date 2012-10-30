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
%   Date: 23-9-2012, Last update: 30-10-2012
%   Acoustic Technology, DTU 2012


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

InitializePsychSound;           % Initialize PsychPortAudio

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
    
    WaitSecs(500e-3);       % Make sure full sound decay has reached microphone
    
    disp('Playback finished');
    
    % Stop audio recording
    PsychPortAudio('Stop',recHandle,1); 
    
    disp('Recording stopped')
    
    % Read audiodata from recording buffer
    audioData = PsychPortAudio('GetAudioData',recHandle);
    recordedAudio = [recordedAudio audioData];
    
    % find the exact position of the sweep in the recorded signal
    [c,lags] = rbtCrossCorr(recordedAudio, signal);
    
    % Compute goodness-of-fit
    cGoodnessOfFit = max(c)/(norm(recordedAudio)*norm(signal));
    
    if cGoodnessOfFit < 0.2    %  Perfectly correlated if cGoodnessOfFit = 1
        error(['Signals are not correlated. Correlation goodness-of-fit is' num2str(cGoodnessOfFit)])
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
