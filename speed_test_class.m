clear all
clc

s = RABAT_SIGNAL;
rir = RABAT_SIGNAL; 
s.signal = rand(10000000,1);
rir.signal = rand(1000000,1);

tic;
conv_no_init = fconv(rir.signal(:), s.signal);
disp(['convolution without initializing took ' num2str(toc) ' s'])

conv_init_zeros = zeros(length(s.signal)+length(rir.signal)-1,1);
tic;
conv_init_zeros = fconv(rir.signal(:), s.signal);
disp(['convolution with zeros initializing took ' num2str(toc) ' s'])

conv_init_repmat = repmat(0,length(s.signal)+length(rir.signal)-1,1);
tic;
conv_init_repmat = fconv(rir.signal(:), s.signal);
disp(['convolution with repmat initializing took ' num2str(toc) ' s'])

%% now with standard type signals
signal = s.signal;
rir2 = rir.signal(:);

conv_init_zeros = zeros(length(signal)+length(rir2)-1,1);
tic;
conv_init_zeros = fconv(rir2(:), signal);
disp(['convolution with standard signals and zeros initializing took ' num2str(toc) ' s'])

