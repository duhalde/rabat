%function filterBank(BandsPerOctave,class,fs)

%% Octave filter bank, with implementation help from mathworks

BandsPerOctave = 1;
N = 6;      % Filter order
F0 = 1000;  % Center reference frequency (Hz)
fs = 44100; % Standard sampling frequency (Hz)
f = fdesign.octave(BandsPerOctave,'Class 1','N,F0',N,F0,fs);

%% Octave filter implementation

F1 = validfrequencies(f) % get valid frequencies from filter
% note these are (1000).*((2^(1/3)).^[-10:7]) and not exactly 125, 1250...
nrCenterFrequencies = length(F1);

for i = 1:nrCenterFrequencies
    f.F0 = F1(i);
    Hd(i) = design(f,'butter');
end

%% one-third octave filter implementation

f.BandsPerOctave = 3;   % change to 3 bands per octave
f.FilterOrder = 8;      % filter is set to 8th order (From ANSI S1.11:2004)
F3rd = validfrequencies(f); % find valid centerfrequencies
nr3rdCenterFrequencies = length(F3rd);
for i = 1:nr3rdCenterFrequencies
    f.F0 = F3rd(i);
    Hd3(i) = design(f,'butter');
end

%% visualize filters

% hfvt = fvtool(Hd,'FrequencyScale','log','color','white');
% axis([0.01 24 -90 5])
% title('Octave-Band Filter Bank')
% 
% hfvt = fvtool(Hd3,'FrequencyScale','log','color','white');
% axis([0.01 24 -90 5])
% title('1/3-Octave-Band Filter Bank')


%% filter a room response

[rir,fs] = wavread('room.wav');

rir = rir(:,1);

rir_bands = zeros(length(rir),1);

figure(2)

hold all
% filter rir with 1/3rd octave
for i = 1:nrCenterFrequencies
    rir_band = filter(Hd(i),rir);
    decay_curve = rbtDecayCurve(rir_band);
    t = 0:1/fs:length(decay_curve)/fs-1/fs;
    plot(t,decay_curve);
    str{i}=[num2str(F0(i)) ' Hz'];
    legend(str)
end
grid on
axis([0 0.5 -65 0])



