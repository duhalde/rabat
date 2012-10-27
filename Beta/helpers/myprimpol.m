function pol = myprimpol(m)
% MYPRIMPOL returns a primitive polynomial of order m in GF(2^m). GF stands
%   for Galois Field. Note that there are other primitive polynomials that
%   can be used.
%   Usage: pol = myprimpol(m)
%   Input parameters:
%       - m: order of the primitive polynomial. m must be and integer
%       number between 0 < m < 27.
%   Output parameters:
%       - pol: the corresponding primitive polynomial of order m.
%
%   For more powerful and general function related to primitive polynomials
%   see also GFPRIMDF, GFPRIMCK, ISPRIMITIVE.
%
%   Author: Toni Torras, Date: 1-7-2009, Last update: 1-7-2009
if  floor(m)~=m || m < 0 || m > 26
    error('Wrong value of m (integer number) ==> 0 < m < 27');
else
    switch m
        case 1
            pol = [1 1];
        case 2
            pol = [1 1 1];
        case 3
            pol = [1 1 0 1];
        case 4
            pol = [1 1 0 0 1];
        case 5
            pol = [1 0 1 0 0 1];
        case 6
            pol = [1 1 0 0 0 0 1];
        case 7
            pol = [1 0 0 1 0 0 0 1];
        case 8
            pol = [1 0 1 1 1 0 0 0 1];
        case 9
            pol = [1 0 0 0 1 0 0 0 0 1];
        case 10
            pol = [1 0 0 1 0 0 0 0 0 0 1];
        case 11
            pol = [1 0 1 0 0 0 0 0 0 0 0 1];
        case 12
            pol = [1 1 0 0 1 0 1 0 0 0 0 0 1];
        case 13
            pol = [1 1 0 1 1 0 0 0 0 0 0 0 0 1];
        case 14
            pol = [1 1 0 0 0 0 1 0 0 0 1 0 0 0 1];
        case 15
            pol = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 16
            pol = [1 1 0 1 0 0 0 0 0 0 0 0 1 0 0 0 1];
        case 17
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 18
            pol = [1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1];
        case 19
            pol = [1 1 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 20
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 21
            pol = [1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 22
            pol = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 23
            pol = [1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 24
            pol = [1 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 25
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 26
            pol = [1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
    end
end