function hCrop = rbtCropIR(h,t)
%
%   Description:    
%
%   Usage: y = function_name(x,...)
%
%   Input parameters:
%       - x: 
%   Output parameters:
%       - y: 
%
%   Author: Oliver Lylloff, Mathias Immanuel Nielsen & David Duhalde 
%   Date: 9-11-2012, Last update: 9-11-2012
%   Acoustic Technology, DTU 2012


%function sampleStart = ita_start_IR(varargin)
%ITA_START_IR - Find the start of a impulse response
%  This function finds the start of an impulse response, in accordance to
%  standard ISO 3382 A.3.4.
%  The output is given in samples.
%
%  Syntax: sampleStart = ita_start_IR(audioObj, options)
%  options: 'threshold',30
%
%   See also ita_time_shift
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_start_IR">doc ita_start_IR</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  23-Set-2008

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'threshold', 20);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

if ischar(sArgs.threshold)
    sArgs.threshold = str2double(sArgs.threshold);
end
%% 
IRsquare = input.timeData.^2;

% assume the last 90% of the IR is noise, and calculate its noise level
NoiseLevel = mean(IRsquare(round(.9*end):end,:));

% get the maximum of the signal, that is the assumed IR peak
[max_val max_idx] = max(IRsquare,[],1);

% check if the SNR is enough to assume that the signal is an IR. If not,
% the signal is probably not an IR, so it starts at sample 1
if any(max_val < 100*NoiseLevel) % less than 20dB SNR
    ita_verbose_info('ITA_START_IR:NoiseLevelCheck: The SNR too bad or this is not an impulse response.',1);
    sampleStart = 1;
    return
end

% find the first sample that lies under the given threshold
sArgs.threshold = -abs(sArgs.threshold);
sampleStart = zeros(size(max_val));
for idx = 1:input.nChannels
    %% TODO - envelope mar/pdi - check!
    abs_dat = 10.*log10(IRsquare(1:max_idx(idx),idx)) - 10.*log10(max_val(idx));
    sampleStart(idx) = find(abs_dat > sArgs.threshold,1,'first');
end

end