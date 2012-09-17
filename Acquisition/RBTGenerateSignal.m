function [y,t] = RBTGenerateSignal(sig_type,varargin)
%
%   Description: Generate signal from ...
%
%   Usage: [y,t] = RBTGenerateSignal(sig_type,varargin)
%   
%   Input parameters:
%       - sig_type: String specifing the type of signal to be generated
%         'logsin'  : Exponential sine sweep
%         'linsin'  : Linear sine sweep
%         'sin'     : Sine signal
%         'mls'     : MLS
%         'irs'     : IRS
%       - varargin: Variable input parameter list depending on signal
%
%   Output parameters:
%       - y: sampled signal
%       - t: time vector in seconds
% 
%   Details on signal types and input arguments:
% 
%   Signal types
%   ------------
%   
%   'logsin'    Creates a logarithmic sweep in the time domain. 
%               Usage: y = SoundPlayback('logsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
%               Input parameters:  
%               - fs: Sampling frequency
%               - f1: Lower frequency
%               - f2: Upper frequency
%               - length_sec: Length of signal in seconds.
%               Optional input parameters:
%               - zero_pad: Duration (in seconds) of zero padding (default = 0).
%               - amp: Amplitude of the sine sweep (default = 1).
%               - phase: Initial phase in rad (default = 0).
%
%
%   'linsin'    Creates a linear sweep in the time domain.
%               Usage: y = SoundPlayback('linsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
%               Input parameters:  
%               - fs: Sampling frequency
%               - f1: Lower frequency
%               - f2: Upper frequency
%               - length_sec: Length of signal
%               Optional input parameters:
%               - zero_pad: Duration (in seconds) of zero padding (default = 0).
%               - amp: Amplitude of the sine sweep (default = 1).
%               - phase: Initial phase in rad (default = 0).
%
%   'sin'    Creates a linear sweep in the time domain.
%               Usage: y = SoundPlayback('sin',fs,f0,length_sig,amp,phase)
%               Input parameters:  
%               - fs: Sampling frequency
%               - f1: Lower frequency
%               - f2: Upper frequency
%               - length_sec: Length of signal
%               Optional input parameters:
%               - amp: Amplitude of the sine sweep (default = 1).
%               - phase: Initial phase in rad (default = 0).   
%
%
%
%   'mls'       ... etc
% 
% 
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 11-9-2012, Last update: 17-9-2012
%   Acoustic Technology, DTU 2012
% 
%   TODO:   
%       - 'mls','irs' is missing helper function 'myprimpol'
%       - Should irs be included? Make help text.
%       - Option to save as wavefile

switch lower(sig_type)
    case 'logsin'
        if nargin < 5
            error('Too few input arguments')
        else  
        fs = varargin{1};
        f1 = varargin{2};
        f2 = varargin{3};
        length_sec = varargin{4};
        if nargin == 5  
        [y,t] = log_sine_sweep(f1,f2,fs,length_sec);
        elseif nargin > 5 && nargin < 9
            arg = varargin{5:end};
            [y,t] = log_sine_sweep(f1,f2,fs,length_sec,arg);
        elseif nargin > 8
            error('Too many input arguments')
        end
        end
    
    case 'linsin'
        if nargin < 5
            error('Too few input arguments')
        else
        fs = varargin{1};
        f1 = varargin{2};
        f2 = varargin{3};
        length_sec = varargin{4};
        if nargin == 5 
            [y,t] = lin_sine_sweep(f1,f2,fs,length_sec);
        elseif nargin > 4 && nargin < 9
            arg = varargin{5:end};
            [y,t] = lin_sine_sweep(f1,f2,fs,length_sec,arg);
        else
            error('Too many input arguments')
        end
        end
        
    case 'sin'
        if nargin < 4
            error('Too few input arguments')
        else
        fs = varargin{1};
        f0 = varargin{2};
        length_sec = varargin{3};
        if nargin == 4
            [y,t] = gen_sin(f0,fs,length_sec);
        elseif nargin > 3 && nargin <8
            arg = varargin{4:end};
            [y,t] = gen_sin(f0,fs,length_sec,arg);
        else
            error('Too many input arguments')
        end
        end
        
    case 'mls'
        n = varargin{1};
        
        y = mls2(n);
      
    case 'irs'
        n = varargin{1};
        
        y = irs2(n);
    otherwise
        error('Unknown method, choose one of: "logsin","linsin","mls","sin","irs"')
end