function [seq,varargout] = rbtMls(m,varargin)
% rbtMls computes a Maximum-Length Sequence in GF(2^m), where GF stands for
% Galois Field. It also returns the corresponding time vector.
%
%   Usage: [seq,t,idx,flagWarn] = rbtMls(m,'opt1',val_opt1,'opt2',val_opt2,...)
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
    error('Wrong input number of arguments!!!')
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