function varargout = SeizureAnnotation(varargin)
% SEIZUREANNOTATION MATLAB code for SeizureAnnotation.fig
%      SEIZUREANNOTATION, by itself, creates a new SEIZUREANNOTATION or raises the existing
%      singleton*.
%
%      H = SEIZUREANNOTATION returns the handle to a new SEIZUREANNOTATION or the handle to
%      the existing singleton*.
%
%      SEIZUREANNOTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEIZUREANNOTATION.M with the given input arguments.
%
%      SEIZUREANNOTATION('Property','Value',...) creates a new SEIZUREANNOTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SeizureAnnotation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SeizureAnnotation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SeizureAnnotation

% Last Modified by GUIDE v2.5 10-Sep-2018 14:38:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SeizureAnnotation_OpeningFcn, ...
    'gui_OutputFcn',  @SeizureAnnotation_OutputFcn, ...
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


% --- Executes just before SeizureAnnotation is made visible.
function SeizureAnnotation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SeizureAnnotation (see VARARGIN)

% Choose default command line output for SeizureAnnotation
handles.output = hObject;
handles.canvas.eventcolour = [0.7 0 0.2];
handles.canvas.selectcolour = [0 0.7 0.2];
% Update handles structure
settings.fs_rsmpl    = 2000; % the rate at which to downsample to
settings.current_vector = 1;
settings.analysis = 'SLE';
settings.data_loaded = false;
% = 2.5s  @ 2kHz

filterparameters.highpass = 150; % highpass filter cut off frequency
filterparameters.lowpass = 40; %low pass filter cut off frequency
handles.parameters.cons_SLE_offset     = 5; % in datapoints in coarse entropy trace the minimum number of data points under the threshold at which two SLE events are separated as being individual events;
handles.parameters.SLE_slw_width = 10000;
handles.parameters.SLE_slw_overlap =  handles.parameters.SLE_slw_width/2;
handles.parameters.LRD_slw_width = 1000;
handles.parameters.LRD_slw_overlap     = handles.parameters.LRD_slw_width/2;  % = 2.5s  @ 2kHz
handles.parameters.preseizure_duration = 10;
handles.filterparameters = filterparameters;
handles.settings = settings;
guidata(hObject, handles);

% UIWAIT makes SeizureAnnotation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SeizureAnnotation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loaddata.
function loaddata_Callback(hObject, eventdata, handles)
% hObject    handle to loaddata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


settings = handles.settings;

[file_name, file_path] = uigetfile({'*.axgd';'*.mat'},'Select file', '~/');
settings.file_path = [file_path file_name];
if endsWith(file_name,'.mat')
    file_struct = load(settings.file_path);
    fnames = fieldnames(file_struct);
    for i = 1:length(fnames)
        if isfield(file_struct.(fnames{i}),'values')
            data_vec{i} = file_struct.(fnames{i}).values;
            time_vec{i} = file_struct.(fnames{i}).interval:file_struct.(fnames{i}).interval:length(data_vec{i})*file_struct.(fnames{i}).interval;
        end
    end
    
elseif endsWith(file_name,'.axgd')
    [data_vec, time_vec, ~] = importaxo(settings.file_path);
end
%Define epoch of interest - if we want to analyse the entire file then
%epoch of interest is from index 1 to end. The epoch of interest must be
%contiguous.

% get sampling frequency of the raw data
if ~iscell(time_vec)
    temptime = time_vec;
    time_vec = cell(size(data_vec));
    for i = 1:size(data_vec,1)
        dt_raw{i}      = mean(diff(temptime));
        fs_raw{i}      = 1/dt_raw{i};
        time_vec{i} = temptime;
    end
else
    for i = 1:size(time_vec,1)

       dt_raw{i}      = mean(diff(time_vec{i}));
       fs_raw{i}      = 1/dt_raw{i};
    end
end
% resample to required rate
h = waitbar(0,'Downsampling data..');
data.tracenames = {};
for i = 1:length(data_vec)
    data.data_downsampled{i}  = resample(  data_vec{i}, ...
        settings.fs_rsmpl, round(fs_raw{i}))';
    data.tracenames{i} = ['Trace' num2str(i)];
    
end
handles.tracemenu.String = data.tracenames;
data.trace = data.data_downsampled{handles.settings.current_vector};
data.name = file_name;
data.seizure_times_all = cell(length(data_vec),1);
data.eventtimesfilenames = cell(length(data_vec),1);
clear data_vec;
waitbar(100);
close(h);

data.sf = settings.fs_rsmpl;
% calculate time course for resampled trace
for i = 1:length(time_vec)
    data.time_course_all{i} = time_vec{i}: 1/data.sf: time_vec{i}+(length(data.trace)-1)/data.sf;
end
data.time_course = data.time_course_all{handles.settings.current_vector};

settings.data_loaded = true;
handles.settings = settings;
clear time_vec;

[data.highpass, data.lowpass, data.theta] = filter_trace(data.trace, data.sf, handles.filterparameters);


handles.filterparamters.lowpass = 10;

[data.highpass, data.vlowpass, data.theta] = filter_trace(data.trace, data.sf, handles.filterparameters);
handles.filterparamters.lowpass = 40;
lowfreq.trace = data.vlowpass;
lowfreq.timecourse = data.time_course;
lowfreq.baseline = lowfreq.trace;
lowfreq.minusbaseline = lowfreq.trace - mean(lowfreq.baseline);
meantrace = mean(data.trace);
twostdtrace = 2*std(data.trace);
handles.canvas.height =  meantrace + twostdtrace;
[lowfreqpow.trace,lowfreqpow.time_course] = sigpoweroverwindow(lowfreq.minusbaseline,handles.parameters.SLE_min_length/2,data.sf);
meantrace = mean(lowfreqpow.trace);
twostdtrace = 2*std(lowfreqpow.trace);
handles.canvas.lowpowheight =  meantrace + twostdtrace;
handles.lowfreqpow = lowfreqpow;
handles.data = data;
cla;
cla reset;
axes(handles.axes1);
handles.canvas = plottraceandannotation(handles.data,handles.output.CurrentAxes,handles.canvas,1);
axes(handles.axes2);
handles.canvas = plottraceandannotation(lowfreqpow,handles.output.CurrentAxes,handles.canvas,2,handles.lowfreqpow.trace);
linkaxes([handles.axes1,handles.axes2],'x')


guidata(hObject, handles);





% --- Executes on button press in annotate.
function annotate_Callback(hObject, eventdata, handles)
% hObject    handle to annotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles.parameters,'med_threshold')
    helpdlg('First select threshold.');
else
    handles.lowfreqpow.seizureind = handles.lowfreqpow.trace>handles.parameters.med_threshold & (handles.lowfreqpow.time_course<handles.parameters.x_sel)';
    handles.lowfreqpow.seizuretimes = seizuretimesfromlogindices(handles.lowfreqpow.seizureind,handles.lowfreqpow.time_course);
    handles.lowfreqpow.seizure_times = combinenearby(handles.lowfreqpow.seizuretimes, handles.parameters.SLE_min_distapart, handles.parameters.SLE_min_length);
    
    handles.data.seizure_times = handles.lowfreqpow.seizure_times;
    handles.data.seizure_times = sort([handles.data.seizure_times handles.lowfreqpow.seizure_times],2);
    
    handles.data.seizure_times = combinenearby(handles.data.seizure_times, handles.parameters.SLE_min_distapart, handles.parameters.SLE_min_length);
    
    handles.data.selection = 1;
    axes(handles.axes1)
    cla;
    cla reset;
    hold on;
    handles.canvas = plottraceandannotation(handles.data,handles.output.CurrentAxes,handles.canvas,1);
    hold off;
    axes(handles.axes2)
    cla;
    cla reset;
    hold on;
    handles.canvas = plottraceandannotation(handles.lowfreqpow,handles.output.CurrentAxes,handles.canvas,2,handles.lowfreqpow.trace);
    hold off;
end
guidata(hObject, handles);

% --- Executes on button press in savedata.
function saveresults_Callback(hObject, eventdata, handles)
% hObject    handle to saveresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear name
clear trace
clear number

numseizures = length(handles.data.seizure_times(1,:));
for i = 1:numseizures
    name{i} = handles.data.name(not(ismember(handles.data.name,' ,.:;!axgd')));
    trace{i} = num2str(handles.settings.current_vector);
    number{i} = i;
end
StartTime = handles.data.seizure_times(1,:)';
EndTime = handles.data.seizure_times(2,:)';

name = name';
trace = trace';
channel = trace;

number = number';


t = table( channel,number,StartTime,EndTime );

filename = [name{1} '-ch' channel{1} 'eventtimes.csv'];
[file,path] = uiputfile(filename);
if isequal(file,0) || isequal(path,0)
   msgbox('User clicked Cancel.')
else
filename = fullfile(path,file);
writetable(t,filename);
handles.data.eventtimesfilenames{handles.settings.current_vector} = filename;
handles.furtheranalysis.enable = true;
end
guidata(hObject, handles);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2)
cla;
axes(handles.axes1)
cla;
handles = [];

guidata(hObject, handles);
delete(hObject);



% --- Executes on button press in Clean Data
function cleansig_Callback(hObject, eventdata, handles)
% hObject    handle to cleansig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data = cleansignal(handles.data, handles.filterparameters);
if strcmp(handles.settings.analysis, 'SLE')
    [handles.data.entropy, handles.data.entropy_time_course] = calculateShanEntropyOverTrace(handles.data.trace,handles.data.time_course, handles.parameters.SLE_slw_width, handles.parameters.SLE_slw_overlap, handles.data.sf);
elseif strcmp(handles.settings.analysis, 'LRD')
    [handles.data.entropy, handles.data.entropy_time_course] = calculateShanEntropyOverTrace(handles.data.trace,handles.data.time_course, handles.parameters.LRD_slw_width, handles.parameters.LRD_slw_overlap, handles.data.sf);
end
axes(handles.axes1)
cla;
cla reset;
handles.canvas = plottraceandannotation(handles.data,handles.output.CurrentAxes,handles.canvas);
axes(handles.axes2)
cla;
cla reset;
handles.canvas = plottraceandannotation(handles.lowfreqpow,handles.output.CurrentAxes,handles.canvas,handles.lowfreqpow.trace);

linkaxes([handles.axes1,handles.axes2],'x')
guidata(hObject, handles);


% --- Executes on button press in Select Threshold.
function selectThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to selectThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)#


[handles.parameters.x_sel,handles.parameters.med_threshold] = ginput(1);
line_obj1 = line([1 handles.parameters.x_sel], [1 1]*handles.parameters.med_threshold, 'Color', 'r');
line_obj2 = line([1 1]*handles.parameters.x_sel, [0 handles.parameters.med_threshold],get(gca, 'ylim'), 'Color', 'r');


guidata(hObject, handles);


% --- Executes on button press in Select.
function selectevent_Callback(hObject, eventdata, handles)
% hObject    handle to selectevent (see GCBO)
% eventdata  reserved - to be defined in a future verinput_args sion of MATLAB
% handles    structure with handles and user data (see GUIDATA)




[handles.x_annotate,handles.y_annotate] = ginput(1);
prevselect = handles.data.selection;
selected = false;
for i = 1:length(handles.data.seizure_times(1,:))
    if handles.x_annotate >= handles.data.seizure_times(1,i) && handles.x_annotate <= handles.data.seizure_times(2,i)
        handles.data.selection = i;
        selected = true;
    end
end
if selected
    hold( handles.axes1,'on');
     hold( handles.axes2,'on');
    handles.canvas = changeeventcolour(prevselect,handles.data.seizure_times,handles.canvas,handles.canvas.eventcolour,handles);
    handles.canvas = changeeventcolour(handles.data.selection,handles.data.seizure_times,handles.canvas,handles.canvas.selectcolour,handles);
    hold( handles.axes1,'on');
     hold( handles.axes2,'on');
end

guidata(hObject, handles);



% --- Executes on button press in alter.
function alterevent_Callback(hObject, eventdata, handles)
% hObject    handle to alterevent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x_extend,y_extend] = ginput(1);
if x_extend <  handles.data.seizure_times(1,handles.data.selection)
    handles.data.seizure_times(1,handles.data.selection) = x_extend;
elseif x_extend >  handles.data.seizure_times(2,handles.data.selection)
    handles.data.seizure_times(2,handles.data.selection) = x_extend;
elseif x_extend >  handles.data.seizure_times(1,handles.data.selection) && ...
        x_extend <  handles.data.seizure_times(2,handles.data.selection)
    if abs(x_extend-handles.data.seizure_times(1,handles.data.selection)) < abs(x_extend-handles.data.seizure_times(2,handles.data.selection))
        handles.data.seizure_times(1,handles.data.selection) = x_extend;
    else
        handles.data.seizure_times(2,handles.data.selection) = x_extend;
    end
end
handles.data.seizure_times = combinenearby(handles.data.seizure_times, handles.parameters.SLE_min_distapart, handles.parameters.SLE_min_length);
axes(handles.axes1)
cla;
cla reset;
hold on;
handles.canvas = plottraceandannotation(handles.data,handles.output.CurrentAxes,handles.canvas,1);
hold off;
axes(handles.axes2)
cla;
cla reset;
hold on;
handles.canvas = plottraceandannotation(handles.lowfreqpow,handles.output.CurrentAxes,handles.canvas,2,handles.lowfreqpow.trace);
hold off;
guidata(hObject, handles);



% --- Executes on button press in create new.
function createevent_Callback(hObject, eventdata, handles)
% hObject    handle to createevent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x_new,y_new] = ginput(1);

if strcmp(handles.settings.analysis, 'SLE')
    seizure_time = [x_new; x_new+10];
    handles.data.seizure_times = combinenearby(sort([handles.data.seizure_times seizure_time],2),handles.parameters.SLE_min_distapart, handles.parameters.SLE_min_length);
else
    seizure_time = [x_new; x_new+3];
    handles.data.lrd_times = combinenearby(sort([handles.data.lrd_times seizure_time],2),handles.parameters.LRD_min_distapart, handles.parameters.LRD_min_length);
end
axes(handles.axes1)
cla;
cla reset;
hold on;
handles.canvas = plottraceandannotation(handles.data,handles.output.CurrentAxes,handles.canvas,1);
hold off;
axes(handles.axes2)
cla;
cla reset;
hold on;
handles.canvas = plottraceandannotation(handles.lowfreqpow,handles.output.CurrentAxes,handles.canvas,2,handles.lowfreqpow.trace);
hold off;
guidata(hObject, handles);

% --- Executes on button press in delete.
function deleteevent_Callback(hObject, eventdata, handles)
% hObject    handle to deleteevent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.seizure_times(:,handles.data.selection) = [];
handles.data.selection = 1;
axes(handles.axes1)
cla;
cla reset;
hold on;
handles.canvas = plottraceandannotation(handles.data,handles.output.CurrentAxes,handles.canvas,1);
hold off;
axes(handles.axes2)
cla;
cla reset;
hold on;
handles.canvas = plottraceandannotation(handles.lowfreqpow,handles.output.CurrentAxes,handles.canvas,2,handles.lowfreqpow.trace);
hold off;
%handles.canvas = changeeventcolour(handles.data.selection,handles.data.seizure_times,handles.canvas,handles.canvas.selectcolour,handles);
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%handles.data = rmfield(handles, 'data');
%handles.lowfreqpow = rmfield(handles, 'lowfreqpow');

guidata(hObject, handles);
delete(hObject);


% --- Executes on button press in setview.
function setview_Callback(hObject, eventdata, handles)
% hObject    handle to setview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);



function eventwidth_Callback(hObject, eventdata, handles)
% hObject    handle to eventwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eventwidth as text
%        str2double(get(hObject,'String')) returns contents of eventwidth as a double
handles.parameters.SLE_slw_width = str2double(get(hObject,'String'));
handles.parameters.SLE_slw_overlap =  handles.parameters.SLE_slw_width/2;  % = 2.5s  @ 2kHz

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eventwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.parameters.SLE_slw_width = 10000;
handles.parameters.SLE_slw_overlap =  handles.parameters.SLE_slw_width/2;  % = 2.5s  @ 2kHz
disp(handles.parameters)
set(hObject, 'String', handles.parameters.SLE_slw_width);
guidata(hObject, handles);




% --- Executes when selected object is changed in selectparams.
function selectparams_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in selectparams
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.NewValue.String,'SLE params')
    handles.settings.analysis = 'SLE';
    [handles.data.entropy, handles.data.entropy_time_course] = calculateShanEntropyOverTrace(handles.data.trace,handles.data.time_course, handles.parameters.SLE_slw_width, handles.parameters.SLE_slw_overlap, handles.data.sf);
elseif strcmp(eventdata.NewValue.String,'LRD params')
    handles.settings.analysis = 'LRD';
    [handles.data.entropy, handles.data.entropy_time_course] = calculateShanEntropyOverTrace(handles.data.trace,handles.data.time_course, handles.parameters.LRD_slw_width, handles.parameters.LRD_slw_overlap, handles.data.sf);
end
axes(handles.axes1)
plottraceandannotation(handles.data)
axes(handles.axes2)
plotEntropy(handles.data)
guidata(hObject, handles);




function minsep_Callback(hObject, eventdata, handles)
% hObject    handle to minsep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minsep as text
%        str2double(get(hObject,'String')) returns contents of minsep as a double
handles.parameters.SLE_min_length = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minsep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minsep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.parameters.SLE_min_length = 10;%seconds
disp(handles)
set(hObject, 'String', handles.parameters.SLE_min_length )
guidata(hObject, handles);



function eventminlen_Callback(hObject, eventdata, handles)
% hObject    handle to eventminlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eventminlen as text
%        str2double(get(hObject,'String')) returns contents of eventminlen as a double
handles.parameters.SLE_min_distapart = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eventminlen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventminlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.parameters.SLE_min_distapart = 5;%seconds
disp(handles)
set(hObject, 'String', handles.parameters.SLE_min_distapart )
guidata(hObject, handles);


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.parameters.LRD_min_distapart = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.parameters.LRD_min_distapart = 1;%seconds
disp(handles)
set(hObject, 'String', handles.parameters.LRD_min_distapart )
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function uibuttongroup3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
disp(hObject)


% --- Executes on selection change in tracemenu.
function tracemenu_Callback(hObject, eventdata, handles)
% hObject    handle to tracemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tracemenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tracemenu
contents = cellstr(get(hObject,'String')) ;
tracestring = contents{get(hObject,'Value')};
data = handles.data;
if isfield(data, 'seizure_times')
    data.seizure_times_all{handles.settings.current_vector} = data.seizure_times;
end
handles.settings.current_vector  = str2num(tracestring(end));
data.trace = data.data_downsampled{handles.settings.current_vector};
data.time_course = data.time_course_all{handles.settings.current_vector};
data.seizure_times = data.seizure_times_all{handles.settings.current_vector};
[data.highpass, data.lowpass, data.theta] = filter_trace(data.trace, data.sf, handles.filterparameters);


handles.filterparamters.lowpass = 10;

[data.highpass, data.vlowpass, data.theta] = filter_trace(data.trace, data.sf, handles.filterparameters);
handles.filterparamters.lowpass = 40;
lowfreq.trace = data.vlowpass;
lowfreq.timecourse = data.time_course;
lowfreq.baseline = lowfreq.trace;
lowfreq.minusbaseline = lowfreq.trace - mean(lowfreq.baseline);
meantrace = mean(data.trace);
twostdtrace = 2*std(data.trace);
handles.canvas.height =  meantrace + twostdtrace;
[lowfreqpow.trace,lowfreqpow.time_course] = sigpoweroverwindow(lowfreq.minusbaseline,handles.parameters.SLE_min_length/2,data.sf);
meantrace = mean(lowfreqpow.trace);
twostdtrace = 2*std(lowfreqpow.trace);
handles.canvas.lowpowheight =  meantrace + twostdtrace;
handles.lowfreqpow = lowfreqpow;
handles.data = data;

axes(handles.axes1);
cla;
cla reset;
handles.canvas = plottraceandannotation(handles.data,handles.output.CurrentAxes,handles.canvas,1);
axes(handles.axes2);
cla;
cla reset;
handles.canvas = plottraceandannotation(handles.lowfreqpow,handles.output.CurrentAxes,handles.canvas,2,handles.lowfreqpow.trace);
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function tracemenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tracemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over eventwidth.
function eventwidth_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to eventwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in furtherAnalysis.
function furtherAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to furtherAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
app1(handles.data.eventtimesfilenames{handles.settings.current_vector},handles.settings.file_path);