function [CC, LAGINDX] = crosscorr( u, v )
%CROSSCORR Computes the cross correlation between u and v.
% [CC, LAGINDX] = crosscorr( u, v ) computes the cross correlation between
% vectors u (length K) and y (length N) where both can be real/complex.
% The cross correlation is computed as:
%
%           N
%   C(w) = Sum  x(w+n) * y^*(n),   -(N-1) <= w <= K-1
%          n=1
%
% where ^* indicates complex conjugate (of the signal y in this case), and:
%
%   x = [0,...,0,  u(1),...,u(K), 0,...,0]^T
%        -------   -------------  -------
%          N-1           K        P-K-N+1
%
%   y = [v(1),...,v(N), 0,...,0 ]^T
%        -------------  -------
%              N          P-N
%
% and P=nextpow2(K+N-1). The output from the CROSSCORR function is thus
% given by:
%
%   CC(m) = C(m-N),   m=1,2,...,K+N-1
%   W(m)  = m-N,      m=1,2,...,K+N-1
% 
%
% Author:
%   - Torben Larsen, Aalborg University, Denmark. E-mail: tl@es.aau.dk
% Copyright:
%   - Torben's Corner
%     http://wiki.accelereyes.com/wiki/index.php?title=Torben%27s_Corner
%
% Reference:
%   - W.H. Press, S.A. Teukolsky, W.T. Wetterling, and B.P. Flannery:
%     "Numerical Recipes - The Art of Scientific Computing", Third Edition,
%     Cambridge University Press, 2007 (see §13.2 p. 648-649).
%
% The function CROSSCORR is fully Jacket supported.
K = length(u);
N = length(v);
LEN = 2^nextpow2(N+K-1);
 
VarType = class(u);
if strcmp(VarType,'gsingle') == 1
    x = gzeros(N+K-1,1,'single');
    x(N:N+K-1) = u;
    y = gzeros(N+K-1,1,'single');
    y(1:N) = v;
elseif strcmp(VarType,'gdouble') == 1
    x = gzeros(N+K-1,1,'double');
    x(N:N+K-1) = u;
    y = gzeros(N+K-1,1,'double');
    y(1:N) = v;
else
    x = zeros(N+K-1,1,class(u));
    x(N:N+K-1) = u;
    y = zeros(N+K-1,1,class(u));
    y(1:N) = v;
end
 
CCt = real(ifft( fft(x,LEN) .* conj(fft(y,LEN)) ));
CC = CCt(1:K+N-1);
LAGINDX = (-(N-1):1:K-1);
end