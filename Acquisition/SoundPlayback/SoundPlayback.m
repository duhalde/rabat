function y = SoundPlayback(sig_type,varargin)
%
%   Description: Generate signal from ...
%
%   Usage: y = SoundPlayback(sig_type,varargin)
%   
%   Input parameters:
%       - sig_type: String specifing the type of signal to be generated
%         'logsin'  : Exponential sine sweep
%         'linsin'  : Linear sine sweep
%         'sin'     : Sine signal
%         'mls'     : MLS
%         'irs'     : IRS
%       - varargin: Variable input parameter list
%
%   Output parameters:
%       - y: sampled signal
% 
%   Details on signal types and input arguments:
% 
%   Signal types
%   ------------
%   
%   'logsin'    Creates a logarithmic sweep in the time domain. 
%               Usage: y = SoundPlayback('logsin',fs,f1,f2,length_sig)
%               Input parameters:  
%               - fs: Sampling frequency
%               - f1: Lower frequency
%               - f2: Upper frequency
%               - length_sec: Length of signal
%
%   'linsin'    Creates a linear sweep in the time domain.
%               Usage: y = SoundPlayback('linsin',fs,f1,f2,length_sig)
%               Input parameters:  
%               - fs: Sampling frequency
%               - f1: Lower frequency
%               - f2: Upper frequency
%               - length_sec: Length of signal
%
%   
%   'mls'       ... etc
% 
% 
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 11-9-2012, Last update: 14-9-2012
%   Acoustic Technology, DTU 2012
% 
%   TODO:   
%       - Make help text and make signals more similar, i.e make fs the 
%           first input argument etc.
%       - 'mls','irs' is missing helper function 'myprimpol'

switch lower(sig_type)
    case 'logsin'
        fs = varargin{1};
        f1 = varargin{2};
        f2 = varargin{3};
        length_sec = varargin{4};
        if nargin > 4
            arg = varargin{5:end};
        end
        y = log_sine_sweep(f1,f2,fs,length_sec,arg);
    
    case 'linsin'
        fs = varargin{1};
        f1 = varargin{2};
        f2 = varargin{3};
        length_sec = varargin{4};
        
        y = lin_sine_sweep(f1,f2,fs,length_sec);
        
    case 'mls'
        n = varargin{1};
        
        y = mls2(n);
    
    case 'sin'
        fs = varargin{1};
        f0 = varargin{2};
        length_sec = varargin{3};
        
        y = gen_sin(f0,fs,length_sec);
        
    case 'irs'
        n = varargin{1};
        
        y = irs2(n);
    otherwise
        error('Unknown method, choose one of: "logsin","linsin","mls","sin","irs"')
end

nrchannels = 1;    % One channel only -> Mono sound.
wavedata = y;      % Need sound vector as row vector, one row per channel.

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
pahandle = PsychPortAudio('Open', [], [], 0, fs, nrchannels);

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle, wavedata);

% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.
PsychPortAudio('Start', pahandle, 1, 0, 1);

% Wait length_sec seconds
WaitSecs(length_sec+0.5);

% Query current playback status and print it to the Matlab window:
s = PsychPortAudio('GetStatus', pahandle); disp(s);

% Stop playback:
PsychPortAudio('Stop', pahandle);

% Close the audio device:
PsychPortAudio('Close', pahandle);
