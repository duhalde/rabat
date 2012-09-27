function [seq,varargout] = rbtIrs(m,varargin)
% rbtIrs computes a Inverse Repeated Sequence defined from the corresponding
% MLS sequence of period 2^m-1. It also returns the corresponding time vector.
%
%   Usage: [seq,t,idx,flagWarn] = rbtIrs(m,'opt1',val_opt1,'opt2',val_opt2,...)
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