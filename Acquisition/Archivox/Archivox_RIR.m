%Philip Robinson - Archivox Acoustic Design + Consulting
%Graduate Program in Architectural Acoustics
%Rensselaer Polytechnic Institute
%2010
%Version 1.0

function varargout = Archivox_RIR(varargin)
% ARCHIVOX_RIR M-file for Archivox_RIR.fig
%      ARCHIVOX_RIR, by itself, creates a new ARCHIVOX_RIR or raises the existing
%      singleton*.
%
%      H = ARCHIVOX_RIR returns the handle to a new ARCHIVOX_RIR or the handle to
%      the existing singleton*.
%
%      ARCHIVOX_RIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARCHIVOX_RIR.M with the given input arguments.
%
%      ARCHIVOX_RIR('Property','Value',...) creates a new ARCHIVOX_RIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Archivox_RIR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Archivox_RIR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Archivox_RIR

% Last Modified by GUIDE v2.5 17-Jun-2011 16:33:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Archivox_RIR_OpeningFcn, ...
                   'gui_OutputFcn',  @Archivox_RIR_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Archivox_RIR is made visible.
function Archivox_RIR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Archivox_RIR (see VARARGIN)
InitializePsychSound
clear global
global current_angle;
global fs;
global nbits;
global sig_len;
global fs1;
global fs2;
global avg;
global dev;
global devices;
global in_ch
global out_ch

current_angle = 1;
fs = str2double(get(handles.fs, 'String'));
nbits = str2double(get(handles.nbits, 'String'));
sig_len = str2double(get(handles.sig_len, 'String'));
fs1 = str2double(get(handles.fs1, 'String'));
fs2 = fs/2;
set(handles.fs2, 'String', num2str(fs2));

avg = str2double(get(handles.avg, 'String'));

devices = PsychPortAudio('GetDevices' );
dev_string = cell(size(devices, 2),1);
for idx = 1:size(devices, 2)
    dev_string{idx,1} = devices(1,idx).DeviceName; 
end
set(handles.dev_ID,'String',dev_string)


%dev = get(handles.dev_ID, 'Value')-1;
dev = [];
set(handles.max_in,'String',devices(1,dev+1).NrInputChannels)
set(handles.max_out,'String',devices(1,dev+1).NrOutputChannels)

in_ch = str2double(get(handles.in_ch, 'String'));
out_ch = str2double(get(handles.out_ch, 'String'));
% Choose default command line output for Archivox_RIR
handles.output = hObject;

% backgroundImage = importdata('logo.png');
% axes(handles.axes1);
% image(backgroundImage);
% axis off

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Archivox_RIR_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function fs_Callback(hObject, eventdata, handles)
global fs
fs = str2double(get(handles.fs, 'String'));
fs2 = fs/2;
set(handles.fs2, 'String', num2str(fs2));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fs_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nbits_Callback(hObject, eventdata, handles)
global nbits
nbits = str2double(get(handles.nbits, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nbits_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sig_len_Callback(hObject, eventdata, handles)

global sig_len
sig_len = str2double(get(handles.sig_len, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sig_len_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fs1_Callback(hObject, eventdata, handles)

global fs1
fs1= str2double(get(handles.fs1, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fs1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fs2_Callback(hObject, eventdata, handles)
global fs2
fs2 = str2double(get(handles.fs2, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fs2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function avg_Callback(hObject, eventdata, handles)
global avg
avg = str2double(get(handles.avg, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function avg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in dev_ID.
function dev_ID_Callback(hObject, eventdata, handles)
global dev
global devices
dev = get(hObject, 'Value')-1;
set(handles.max_in,'String',devices(1,dev+1).NrInputChannels)
set(handles.max_out,'String',devices(1,dev+1).NrOutputChannels)    
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dev_ID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on key press with focus on dev_ID and none of its controls.
function dev_ID_KeyPressFcn(hObject, eventdata, handles)

function out_ch_Callback(hObject, eventdata, handles)
global out_ch
if get(handles.latency_correction,'Value') ==1
out_ch = str2double(get(handles. out_ch, 'String'))+1;
else
out_ch = str2double(get(handles. out_ch, 'String'));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function out_ch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function in_ch_Callback(hObject, eventdata, handles)
global in_ch
if get(handles.latency_correction,'Value') ==1
 in_ch = str2double(get(handles. in_ch, 'String'))+1;
else
  in_ch = str2double(get(handles. in_ch, 'String'));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function in_ch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
global fs;
global sig_len;
global fs1;
global fs2;
global avg;
global dev;
global in_ch
global out_ch
global pahandle
global current_angle
global Polar_IR
global IR



T = sig_len;
% Create the swept sine tone
w1 = 2*pi*fs1;
w2 = 2*pi*fs2;
K = T*w1/log(w2/w1);
L = T/log(w2/w1);
t = linspace(0,T-1/fs,fs*T);
sweep = sin(K*(exp(t/L) - 1));
ramp_down = 1:-.004:0;
sweep(end-250:end) = sweep(end-250:end).*ramp_down;
output_sweep = sweep;

position = 1;
while position<avg+2
output_sweep = cat(2,output_sweep,sweep);
position = position+1;
end
multi_sweep = output_sweep;
 for idx = 1:out_ch-1
multi_sweep = cat(1,multi_sweep,output_sweep);
 end
multi_sweep = multi_sweep.*.04;

pahandle = PsychPortAudio('Open', dev, 3,0,fs,[out_ch, in_ch]);
PsychPortAudio('FillBuffer', pahandle, multi_sweep);
PsychPortAudio('GetAudioData', pahandle ,ceil(size(multi_sweep,2)/fs)); 
PsychPortAudio('Start', pahandle);
WaitSecs(size(output_sweep,2)/fs);
PsychPortAudio('Stop', pahandle);
[signal] = PsychPortAudio('GetAudioData', pahandle ,[],[],[]);
PsychPortAudio('Close');
signal = signal';
%signal_avg = signal;
%figure;plot(signal)

%  %-------Average-----------------------------------
  
%  %len = fs*T;
% signal_array = zeros(len,avg+2,in_ch);
% pos = 1;
% for idx = 1:len:length(signal)-len
%     signal_array(:,pos,:) = signal(idx:idx+len-1,:);
%     pos = pos +1;
% end
% signal_avg = zeros(len,in_ch);
% for idx = 1:in_ch
% signal_avg(:,idx) = mean(signal_array(:,2:avg+1,idx),2);
% end

% %----------Deconvolve--------------------------------
%double_IR = zeros(length(signal_avg)+size(sweep,2)-1,1);
%IR = zeros(len,in_ch);
len = length(sweep);
IR = zeros(len,in_ch);
for idx = 1:in_ch
Y=fft(signal(:,idx),(length(signal)+size(sweep,2)-1));   
 H=fft(sweep',(length(signal)+size(sweep,2)-1));   
 G=Y./(H);   
 multi_IR(:,idx)=ifft(G,'symmetric');
 for idx_a = len:len:length(signal)-1.5.*len
 IR(:,idx) = IR(:,idx)+multi_IR(idx_a:idx_a+len-1,idx);  
 end
 %figure;plot(multi_IR);
end
ms = fs/1000;
if get(handles.latency_correction,'Value') ==1
 [null,latency] = max(IR(ms:end,in_ch));
 latency = latency+ms;
 IR = IR(latency+5:(T*fs)-latency-5,:);
end

 %if get(handles.polar_check,'Value') ==0
  IR = IR./(1.1.*max(max(abs(IR))));
% end

if get(handles.polar_check,'Value') ==1 
    Polar_IR{1,current_angle} = IR(:,1);
    res = str2double(get(handles.res,'String'));
    set(handles.cur_ang,'String',(current_angle*res)-res);
end

axes(handles.axes1);
len = size(IR,1);
delta_t = 1/fs;
time_vct = 0:delta_t:(len-1)*delta_t;
time_vct = time_vct';

if get(handles.polar_check,'Value') ==0
plot(time_vct,IR);
else
plot(time_vct,Polar_IR{:,current_angle});  
end

circle = str2double(get(handles.cur_ang,'String'));
if circle==360
    set(handles.go,'Enable','Inactive')
    set(handles.go,'ForegroundColor',[.8 .8 .8])
    set(handles.cur_ang,'String', 0)
    current_angle = 0;
end
if get(handles.polar_check,'Value') ==1 
  current_angle = current_angle+1;
  end
guidata(hObject, handles);


% --- Executes on button press in polar_check.
function polar_check_Callback(hObject, eventdata, handles)

global in_ch
global out_ch

if get(hObject,'Value') == 1;
set(handles.in_ch,'String',1);
in_ch = 1;
set(handles.out_ch,'String',1);
out_ch = 1;
set(handles.in_ch,'Enable','Inactive');
set(handles.out_ch,'Enable','Inactive');
set(handles.in_ch,'ForegroundColor',[.8 .8 .8]);
set(handles.out_ch,'ForegroundColor',[.8 .8 .8]);
else
set(handles.in_ch,'Enable','On');
set(handles.out_ch,'Enable','On');
set(handles.in_ch,'ForegroundColor',[0 0 0]);
set(handles.out_ch,'ForegroundColor',[0 0 0]);
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of polar_check

function res_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function res_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
global current_angle
current_angle = current_angle-1;
res = str2double(get(handles.res,'String'));
set(handles.cur_ang,'String',(current_angle*res)-res);
% --- Executes on button press in save.

function save_Callback(hObject, eventdata, handles)
global IR
global Polar_IR
global fs
global nbits

if get(handles.polar_check,'Value')==1
    for idx = 1:(size(Polar_IR,2))
     len(idx) = size(Polar_IR{1,idx},1);
    end
    max_len = max(len);
    Polar = zeros(max_len,size(Polar_IR,2));
    for idx = 1:(size(Polar_IR,2))
    Polar(1:len(idx),idx) = Polar_IR{1,idx};
    end    
    Polar = Polar./(1.2*max(max(Polar)));

[filename, pathname] = uiputfile('Polar_IR.wav', 'Save as:');
filename = strcat(pathname,filename); 
wavwrite(Polar,fs,nbits,filename) ;
 set(handles.go,'Enable','On')
 set(handles.go,'ForegroundColor',[0 0 0])
 
 clear Polar_IR 
else
    [filename, pathname] = uiputfile('IR.wav', 'Save as:');
     wavwrite(IR,fs,nbits,strcat(pathname,filename)) ;
     clear IR
end

% --- Executes on button press in latency_correction.
function latency_correction_Callback(hObject, eventdata, handles)
global in_ch
global out_ch
if get(handles.latency_correction,'Value') ==1
    in_ch = str2double(get(handles. in_ch, 'String'))+1;
    out_ch = str2double(get(handles. out_ch, 'String'))+1;
else
    in_ch = str2double(get(handles. in_ch, 'String'));
    out_ch = str2double(get(handles. out_ch, 'String'));
end
