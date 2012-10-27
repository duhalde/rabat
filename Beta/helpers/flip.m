function out = flip(in)

s = size(in);
idx = find(s == max(s));
if length(idx) > 1
	idx = idx(1);
end
out = flipdim(in, idx);