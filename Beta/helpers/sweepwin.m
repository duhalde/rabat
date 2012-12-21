function win = sweepwin(N,flow,fup,f1,f2,type)
%
% Usage: win = sweepwin(N,flow,fup,f1,f2,type)
%
%   Input parameters:
%       N = Window length
%       flow = Lower frequency
%       fup = Higher frequency
%       f1 = First frequency of interest
%       f2 = Last frequency of interest
%       type = 'Lin' or 'Log'
%
%   Author: Toni Torras, Date: 27-4-2009, Last update: 27-4-2009

if strcmpi(type,'linsin')
    n1 = floor(N*(f1-flow)/(fup-flow));
    n2 = ceil(N*(f2-flow)/(fup-flow));
elseif strcmpi(type,'logsin')
    n1 = floor(N*log(f1/flow)/log(fup/flow));
    n2 = ceil(N*log(f2/flow)/log(fup/flow));
else
    error('Wrong input parameter. Type must be either ''linsin'' or ''logsin''');
end

win = ones(1,N);
n = 1:n1;
win(1,n) = (1 + cos(pi*(n-n1)/n1))/2;
n = n2:N;
win(1,n) = (1 + cos(pi*(n-n2)/(N-n2)))/2;
