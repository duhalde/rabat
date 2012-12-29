function [y,t] = rbaGenerateSignal(sig_type,varargin)
%
%   Description: 
%          Generate measurement signal
%
%   Usage:
%          [y,t] = rbaGenerateSignal('logsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
%          [y,t] = rbaGenerateSignal('linsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
%          [y,t] = rbaGenerateSignal('sin',fs,f0,length_sig,amp,phase)
%          [y,t] = rbaGenerateSignal('mls',fs, n, amp, zero_pad, offset)
%          
%
%   Input parameters:
%       - sig_type: String specifing the type of signal to be generated
%         'logsin'  : Logarithmic sine sweep
%         'linsin'  : Linear sine sweep
%         'sin'     : Sine signal
%         'mls'     : MLS
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
%               Usage: [y,t] = rbaGenerateSignal('logsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
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
%               Usage: [y,t] = rbaGenerateSignal('linsin',fs,f1,f2,length_sig,zero_pad,amp,phase)
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
%   'sin'       Creates a single sine tone.
%               Usage: [y,t] = rbaGenerateSignal('sin',fs,f0,length_sig,amp,phase)
%               Input parameters:
%               - fs: Sampling frequency
%               - f0: frequency
%               - length_sec: Length of signal
%               Optional input parameters:
%               - amp: Amplitude of the sine sweep (default = 1).
%               - phase: Initial phase in rad (default = 0).
%
%
%   'mls'       Creates a Maximum-Length Sequence in GF(2^m), where GF stands for
%               Galois Field.
%               Usage: [y,t] = rbaGenerateSignal('mls',fs, n, amp, zero_pad, offset)
%               Input parameters:
%               - fs: Sampling frequency
%               - n : Integer that determines the order of GF and thus the length of the sequence, i.e. 2^m-1
%               Optional input parameters:
%               - amp: Amplitude. By default, the sequence only takes the values 0 and 1.
%                       Use 'Amplitude' if you want to change 1 for another value.
%               - zero_pad: duration (in seconds) of the silence inserted after
%                       the sequence. By default it is set to 0.
%               - offset: It is possible to introduce an offset in order to change the two values of the MLS signal. You can use it in combination
%                           with 'Amplitude'.
%
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 11-9-2012, Last update: 21-12-2012
%   Acoustic Technology, DTU 2012

switch lower(sig_type)
    case 'logsin'
        if nargin < 5
            error('Too few input arguments')
        else
        fs = varargin{1};
        f1 = varargin{2};
        f2 = varargin{3};
        length_sec = varargin{4};
        win_len = 1.1;
        if nargin == 5
        [y ,t] = rbaLogSin(f1,f2,fs,length_sec);
        elseif nargin > 5 && nargin < 9
            arg = varargin{5:end};
            [y,t] = rbaLogSin(f1,f2,fs,length_sec,arg);
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
            [y,t] = rbaLinSin(f1,f2,fs,length_sec);
        elseif nargin > 5 && nargin < 9
            arg = varargin{5:end};
            [y,t] = rbaLinSin(f1,f2,fs,length_sec,arg);
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
            [y,t] = rbaSin(f0,fs,length_sec);
        elseif nargin > 4 && nargin <8
            arg = varargin{4:end};
            [y,t] = rbaSin(f0,fs,length_sec,arg);
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
            [y,t] = rbaMls(n,'fs',fs);
        elseif nargin > 3 && nargin < 5
            arg = varargin{3:end};
            [y,t] = rbaMls(n,'fs',fs,arg);
        else
            error('Too many input arguments')
        end
        end

    case 'irs'
        fs = varargin{1};
        n = varargin{2};
        [y,t] = rbaIrs(n,fs);
    otherwise
        error('Unknown method, choose one of: "logsin","linsin","mls","sin"')
end
end

function [x,t] = rbaLogSin(f1,f2,fs,length_sec,varargin)
%
% rbaLogSin creates a logarithmic sweep in the time domain.
%
% [x,t] = rbaLogSin(f1,f2,fs,length_sec,zero_padding,amplitude,phase)
%
% Input parameters:
%       - f1: lower frequency of the sweep.
%       - f2: upper frequency of the sweep.
%       - fs: sampling frequency.
%       - length_sec: duration of the sweep in seconds.
%
% Optional input parameters:
%       - zero_padding: duration (in seconds) of the silence inserted
%         after each sweep.
%       - amplitude: amplitude of the sine sweep. Its default value is 1.
%       - phase_rad: initial phase in radians. Its default value is 0.
% Output parameters:
%       - x: sampled logarithmic sine sweep in seconds.
%       - t: the corresponding time vector in seconds.
%
%   Author: Toni Torras, Date: 15-7-2009.
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 27-9-2012

if f1 == 0
    f1 = eps;
end
switch nargin
    case 4
        zero_padding = 0;
        amplitude = 1;
        phase = 0;
    case 5
        zero_padding = varargin{1};
        amplitude = 1;
        phase = 0;
    case 6
        zero_padding = varargin{1};
        amplitude = varargin{2};
        phase = 0;
    case 7
        zero_padding = varargin{1};
        amplitude = varargin{2};
        phase = varargin{3};
    otherwise
        error('Wrong number of input arguments.');
end
t = 0:1/fs:length_sec-1/fs;
x = [amplitude*sin(length_sec*2*pi*f1/log(f2/f1)*(exp(t*log(f2/f1)/length_sec)-1) + phase)...
    zeros(1,round(zero_padding*fs))];
t = 0:1/fs:(length_sec+zero_padding-1/fs);
end

function [x,t,Sweeprate] = rbaLinSin(flow,fup,fs,T,varargin)
%
% rbaLinSin creates a linear sweep in the time domain.
%
% [x,t] = rbaLinSin(flow,fup,fs,T,zero_padding,amplitude,phase_rad)
%
% Input parameters:
%       - flow: lower frequency of the sweep.
%       - fup: upper frequency of the sweep.
%       - fs: sampling frequency.
%       - T: Period of the sweep in seconds.
%
% Optional input parameters:
%       - zero_padding: duration (in seconds) of the silences inserted
%         after each sweep. Its default value is 0.
%       - amplitude: amplitude of the sine sweep. Its default value is 1.
%       - phase_rad: initial phase in radians. Its default value is 0.
% Output parameters:
%       - x: sampled linear cosine sweep in seconds.
%       - t: the corresponding time vector in seconds.
%       - Sweeprate: Sweep rate in Hz/second.
%
%   Author: Toni Torras, Date: 23-7-2009.
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 27-9-2012

switch nargin
    case 4
        zero_padding = 0;
        amplitude = 1;
        phase = 0;
    case 5
        zero_padding = varargin{1};
        amplitude = 1;
        phase = 0;
    case 6
        zero_padding = varargin{1};
        amplitude = varargin{2};
        phase = 0;
    case 7
        zero_padding = varargin{1};
        amplitude = varargin{2};
        phase = varargin{3};
    otherwise
        error('Wrong number of input arguments.');
end
% Convertion from lower and upper frequencies to f1 and f2
f1 = (3*flow-fup)/2;
f2 = (flow+fup)/2;
t = 0:1/fs:T-1/fs;
% See 'Acoustical Measurement by TDS', Rhichard C. Heyser
x = [amplitude*sin(2*pi*(f2-f1)*t.^2/(2*T) + 2*pi*(f2+f1)*t/2 + phase)...
    zeros(1,round(zero_padding*fs))];
% % My version:
% x = [amplitude*sin(2*pi*(fup-flow)*t.^2/(2*T) + 2*pi*flow*t + phase)...
%     zeros(1,zero_padding*fs)];
t = 0:1/fs:(T+zero_padding-1/fs);
Sweeprate =(f2-f1)/T;

end

function [y,t] = rbaSin(f0,fs,length_sec,varargin)
%
%   rbaSin returns a sampled sine function and its corresponding time
%   vector. It is taken into account the effect of the very last sample when
%   calculating the corresponding Fourier Transform, i.e. the sine is sampled
%   within the interval of time from '0' to 'length_sec-1/fs'.
%
%   [y,t] = rbaSin(f0,fs,length_sec,amplitude,phase_rad)
%
%   Input parameters:
%       - f0: frequency of oscillation.
%       - fs: sampling frequency.
%       - length_sec: duration of the signal in seconds.
%   Optional input parameters:
%       - amplitude: amplitude of the sine. Its default value is 1.
%       - phase: initial phase of the sine in radians. Its default value is 0.
%   Ouput parameters:
%       - y: the sampled sine.
%       - t: the corresponding time vector in seconds.
%
%
%
%   Author: Toni Torras, Date: 20-2-2009
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 27-9-2012

if nargin == 4
    amplitude = varargin{1};
    phase = 0;
elseif nargin == 5
    amplitude = varargin{1};
    phase = varargin{2};
elseif nargin > 5
    error('Wrong usage! More than five input arguments are not supported!')
elseif nargin < 3
    error('Wrong usage! Less than three input arguments are not supported!')
else
    amplitude = 1;
    phase = 0;
end
t = 0:1/fs:length_sec-1/fs;
y = amplitude*sin(2*pi*f0*t + phase);
% if mod(length_sec,1/f0)
%     warning('The length of the signal is not a multiple of the period of the sine!');
% elseif f0 > fs/2
%     warning('Nyquist Theorem is not fulfilled!');
% end
end

function [seq,varargout] = rbaMls(m,varargin)
% rbaMls computes a Maximum-Length Sequence in GF(2^m), where GF stands for
% Galois Field. It also returns the corresponding time vector.
%
%   Usage: [seq,t,idx,flagWarn] = rbaMls(m,'opt1',val_opt1,'opt2',val_opt2,...)
%
%   Input parameters:
%       - m: Integer that determines the order of GF and thus the length of
%       the sequence, i.e. 2^m-1.
%
%   Optional Input parameters:
%       - Amplitude: By default, the sequence only takes the values 0 and 1.
%       Use 'Amplitude' if you want to change 1 for another value.
%       - fs: sampling frequency. This determines the returned time vector.
%       By default, it is set to 44100 Hz.
%       - ZeroPadding: duration (in seconds) of the silence inserted after
%       the sequence. By default it is set to 0.
%       - Offset: It is possible to introduce an offset in order to change
%       the two values of the MLS signal. You can use it in combination
%       with 'Amplitude'.
%
%   Output parameters:
%       - seq: The MLS sequence.
%       - t: The corresponding time vector. If 'fs' is not given, it
%       assumes 44100 Hz.
%       - idx: It is a vector specifying the non-zero coefficients of the
%       used primitive polynomial. For example, if the primitive polynomial
%       is 1 + x + x^3 = 1*x^0 + 1*x^1 + 0*x^2 + 1*x^3, then 'idx' is [1 1
%       0] (Note that the coefficient of the biggest order, i.e. x^m, is not
%       included as it is always 1).
%       - flagWarn: Flag used by the GUI_SignalGen. It is 0 if everything is
%       ok. It is 2 if the typed polynomial is not primitive.
%
%       For a more general and powerful mls generating function see also MLS.
%
%   Author: Toni Torras, Date: 1-7-2009.
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 27-9-2012

%% Let's read the optional parameters:
if nargin > 1 && mod(nargin,2) ~= 0
    for k = 1:2:nargin-1
        if ischar(varargin{k})
            if strcmpi(varargin{k},'Amplitude')
                amplitude = varargin{k+1};
            elseif strcmpi(varargin{k},'Offset')
                offset = varargin{k+1};
            elseif strcmpi(varargin{k},'fs')
                fs = varargin{k+1};
            elseif strcmpi(varargin{k},'ZeroPadding')
                zeroPad = varargin{k+1};
            else
                error('''%s'', wrong property! Check the help.',varargin{k});
            end
        end
    end
elseif nargin > 1
    error('Wrong number of input arguments!!!')
end
if ~exist('amplitude','var')
    amplitude = 1;
end
if ~exist('offset','var')
    offset = 0;
end
if ~exist('zeroPad','var')
    zeroPad = 0;
end
if ~exist('fs','var')
    fs = 44100;
end
Nbar = 16; % The computation load increases with m. If m > 16 a waitbar is shown.
%% Let's create the sequence:
pol = myprimpol(m);
idx = find(pol(1:end-1) == 1);
seq = zeros(1,2^m-1);
state = [1 zeros(1,m-1)];
if m > Nbar
    h = waitbar(0,sprintf('Computing MLS signal for m = %d...',m));
end
for ii = 1:2^m-1
    if (m > Nbar) && (mod(ii,floor((2^m-1)/10)) == 0 || ii == 2^m-1)
        h = waitbar(ii/(2^m-1));
    end
    seq(ii) = state(1,1);
    state = [state(2:end) mod(sum(state(1,idx)),2)];
end
if m > Nbar
    close(h);
end
% MLS {0,1} ==> MLS {+1,-1}
seq = -2*seq+1;
% Extra modifications if required
seq = [amplitude*seq+offset zeros(1,fs*zeroPad)];
varargout{1} = (0:1:(length(seq)-1))/fs;
varargout{2} = idx;
varargout{3} = 0;
end

function [seq,varargout] = rbaIrs(m,varargin)
% rbaIrs computes a Inverse Repeated Sequence defined from the corresponding
% MLS sequence of period 2^m-1. It also returns the corresponding time vector.
%
%   Usage: [seq,t,idx,flagWarn] = rbaIrs(m,'opt1',val_opt1,'opt2',val_opt2,...)
%
%   Input parameters:
%       - m: Integer that determines the order of GF and thus the length of
%       the sequence, i.e. 2^m-1.
%
%   Optional Input parameters:
%       - Amplitude: By default, the sequence only takes the values 0 and 1.
%       Use 'Amplitude' if you want to change 1 for another value.
%       - fs: sampling frequency. This determines the returned time vector.
%       By default, it is set to 44100 Hz.
%       - ZeroPadding: duration (in seconds) of the silence inserted after
%       the sequence. By default it is set to 0.
%
%   Output parameters:
%       - seq: The IRS sequence.
%       - t: The corresponding time vector. If 'fs' is not given, it
%       assumes 44100 Hz.
%       - idx: It is a vector specifying the non-zero coefficients of the
%       used primitive polynomial. For example, if the primitive polynomial
%       is 1 + x + x^3 = 1*x^0 + 1*x^1 + 0*x^2 + 1*x^3, then 'idx' is [1 1
%       0] (Note that the coefficient of the biggest order, i.e. x^m, is not
%       included as it is always 1).
%       - flagWarn: Flag used by the GUI_SignalGen. It is 0 if everything is
%       ok. It is 2 if the typed polynomial is not primitive.
%
%       For a more general and powerful irs generating function see also
%       IRS.
%
%   Author: Toni Torras, Date: 7-1-2009.
%   Modified by Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde
%   Date: 27-9-2012

zeroPadIdx = find(strcmpi(varargin,'zeropadding'));
idxin = ones(1,nargin-1);
idxin(zeroPadIdx:zeroPadIdx+1) = 0;
[seqMLS,t,idx,flagWarn] = mls2(m,varargin{logical(idxin)});
if flagWarn == 0
% Stan - Embrechts - Archambeau, version 1 ==> INCORRECT!!!
%     seq = zeros(1,2*(2^m-1));
%     seq(1:2:end) = seqMLS;
%     seq(2:2:end) = -seqMLS;
% Stan - Embrechts - Archambeau, version 2
    seq = (-1).^(0:2*(2^m-1)-1).*[seqMLS seqMLS];
% A. Farina version
%     seq = [seqMLS -seqMLS];
 idxfs = find(strcmpi(varargin,'fs'));
 if isempty(idxfs)
    fs = 44100;
 else
    fs = varargin{idxfs+1};
 end
    if ~isempty(zeroPadIdx)
        seq = [seq zeros(1,fs*varargin{zeroPadIdx+1})];
    end
    if nargout > 1
        varargout{1} = (0:1:(length(seq)-1))/fs;
        varargout{2} = idx;
        varargout{3} = 0;
    end
else
    seq = seqMLS;
    if nargout > 1
        varargout{1} = t;
        varargout{2} = idx;
        varargout{3} = flagWarn;
    end
end

end