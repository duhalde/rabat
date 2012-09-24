function [y,t] = rbtGenerateSignal(sig_type,varargin)
%
%   Description: Generate signals 
%
%   Usage: [y,t] = rbtGenerateSignal(sig_type,varargin)
%   
%   Input parameters:
%       - sig_type: String specifing the type of signal to be generated
%         'logsin'  : Logarithmic sine sweep
%         'linsin'  : Linear sine sweep
%         'sin'     : Sine signal
%         'mls'     : MLS
%         'irs'     : IRS
%       - varargin: Variable input parameter list depending on signal
%
%   Output parameters:1
%       - y: sampled signal
%       - t: time vector in seconds
% 
%   Details on signal types and input arguments:
% 
%   Signal types
%   ------------
%   
%   'logsin'    Creates a logarithmic sweep in the time domain. 
%               Usage: [y,t] = rbtGenerateSignal('logsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
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
%               Usage: [y,t] = rbtGenerateSignal('linsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
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
%
%   'sin'       Creates a linear sweep in the time domain.
%               Usage: [y,t] = rbtGenerateSignal('sin',fs,f0,length_sig,amp,phase)
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
%   'mls'       Creates a Maximum-Length Sequence in GF(2^m), where GF stands for
%               Galois Field.
%               Usage: [y,t] = rbtGenerateSignal('mls',fs,varargin)
%               Input parameters:
%               - 
%               - 
%               Optional input parameters:
%               - 
% 
% 
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 11-9-2012, Last update: 18-9-2012
%   Acoustic Technology, DTU 2012
% 
%   TODO:   
%       - Should irs be included? Make help text.
%       - Rewrite mls and irs.
%       - Option to save as wavefile
%       - Add sweepwin to end signal

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
        elseif nargin > 5 && nargin < 9
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
        elseif nargin > 4 && nargin <8
            arg = varargin{4:end};
            [y,t] = gen_sin(f0,fs,length_sec,arg);
        else
            error('Too many input arguments')
        end
        end
        
    case 'mls'
        if nargin < 2
            error('Too few input arguments')
        else
        fs = varargin{1};
        n = varargin{2};
        if nargin == 3
            [y,t] = mls2(n,fs);
        elseif nargin > 3 && nargin < 5
            arg = varargin{3:end};
            [y,t] = mls2(n,fs,arg);
        else
            error('Too many input arguments')
        end
        end
            
    case 'irs'
        fs = varargin{1};
        n = varargin{2};
        [y,t] = irs2(n,fs);
    otherwise
        error('Unknown method, choose one of: "logsin","linsin","mls","sin","irs"')
end