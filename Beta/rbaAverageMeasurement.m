function y = rbaAverageMeasurement(signal, fs, N)
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

% assemble excitation signal with N+1 sweeps
% using Tony's Trick - blazing fast - and no growing vectors in for-loops!
c = signal'; %
cc = c(:,ones(N+1,1));
signalExcite = cc(:)';

nrChannels = 1;
signalExciteSeconds = length(signalExcite)/fs;
signalSamples = length(signal);
% signalSeconds = signalSamples/fs;

% Open channels for playback and recording
playHandle = PsychPortAudio('Open', [], [], [], fs, nrChannels);
recHandle = PsychPortAudio('Open', [], 2, [], fs, nrChannels);

% Restore output message settings to default level
PsychPortAudio('Verbosity',outputMsg);

% Fill playback buffer
PsychPortAudio('FillBuffer', playHandle, signalExcite);

% Get I/O latency estimation
statusPlay = PsychPortAudio('GetStatus',playHandle);
statusRec = PsychPortAudio('GetStatus',recHandle);
dOut = PsychPortAudio('GetDevices',[],statusPlay.OutDeviceIndex);
dIn = PsychPortAudio('GetDevices',[],statusRec.InDeviceIndex);
outLatency = dOut.HighOutputLatency;
inLatency = dIn.HighInputLatency;

totalLatency = outLatency+inLatency;
compTime = 2;           % Estimated CPU time in seconds

% Allocate recording buffer
% ¿¿¿Is it possible to only allocate a shorter length, if the buffer is
% emptied every so often???
PsychPortAudio('GetAudioData', recHandle, signalExciteSeconds+totalLatency+compTime);

% initialize matrix for storing the recorded sweeps
y = zeros(signalSamples,1);

recordedAudio = [];

% Start recording

PsychPortAudio('Start', recHandle);

% Start playback
PsychPortAudio('Start', playHandle);

% Get playback status
status = PsychPortAudio('GetStatus',playHandle);

while status.Active == 0
    % wait for playback to begin
    status = PsychPortAudio('GetStatus',playHandle);
end

% allocate vectort for recording. Since it will be emptied every time
% it is longer than signalSamples, it is more than enough to allocate
% twice that length.
% recordedAudio = zeros(1,2*signalSamples);

% Record loop
onsetFound = 0;
avgCount = 0;
dismiss = 1;
while avgCount < N  % && status.Active == 1 % Record while playback is active
    % Read audiodata from recording buffer
    audioData  = PsychPortAudio('GetAudioData',recHandle);
    recordedAudio = [recordedAudio audioData];
    % check if recording is done
    status = PsychPortAudio('GetStatus',playHandle);
    
    % and make sure that the CPU load does not cause glitches
    if status.CPULoad > 0.95
        disp('Very high CPU load. Timing or sound glitches are likely to occur.')
    end
    
    % determine onset time of measurement system
    if length(recordedAudio) > signalSamples
        
        disp(['recAudio is now ' num2str(length(recordedAudio)) ' samples.'])
        
        if ~onsetFound
            disp('finding onset')
            % find the exact position of the sweep in the recorded signal
            [c,lags] = rbaCrossCorr(recordedAudio, signal);
            % find start index of the sweep in the first part of the
            % recording
            onset = lags(max(c)==c); % in samples
            % throw away the onset of the recording
            try
                recordedAudio = recordedAudio(onset:end);
                disp(['onset found as ' num2str(onset) ' samples.'])
                disp(['recAudio is now ' num2str(length(recordedAudio)) ' samples.'])
            catch
                error('Cannot determine onset of system. Impulse response might be shifted.')
                dismiss = 0;
            end
            onsetFound = 1; % onset has been found
        elseif dismiss
            disp('dismissing first sequence')
            % throw away the first excitation recording
            % it is used to allow the sound field to build up
            recordedAudio = recordedAudio(signalSamples+1:end);
            dismiss = 0;
        else
            avgCount = avgCount + 1;
            disp(['averaging ' num2str(avgCount) ' of ' num2str(N)])
            % and place the recorded sequence in a vector
            sequence = recordedAudio(1:signalSamples);
            if avgCount == 1
                y = sequence; % save first sequence
            else
                y = (y+sequence)/2; % perform averaging
            end
            % and remove used sequence from recording vector
            recordedAudio = recordedAudio(signalSamples+1:end);
        end
        
    end
    
end

% Stop audio recording
PsychPortAudio('Stop',recHandle,1);

% Close channels
PsychPortAudio('Close', recHandle);
PsychPortAudio('Close', playHandle);

end
