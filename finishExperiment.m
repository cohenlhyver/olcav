function varargout = finishExperiment(varargin)
% FINISHEXPERIMENT M-file for finishExperiment.fig
%      FINISHEXPERIMENT, by itself, creates a new FINISHEXPERIMENT or raises the existing
%      singleton*.
%
%      H = FINISHEXPERIMENT returns the handle to a new FINISHEXPERIMENT or the handle to
%      the existing singleton*.
%
%      FINISHEXPERIMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINISHEXPERIMENT.M with the given input arguments.
%
%      FINISHEXPERIMENT('Property','Value',...) creates a new FINISHEXPERIMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before finishExperiment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to finishExperiment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help finishExperiment

% Last Modified by GUIDE v2.5 06-Jun-2013 18:30:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @finishExperiment_OpeningFcn, ...
                   'gui_OutputFcn',  @finishExperiment_OutputFcn, ...
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


% --- Executes just before finishExperiment is made visible.
function finishExperiment_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.output = hObject ;
    set(hObject, 'Name' , 'finishExperiment',...
                 'Units', 'normalized') ;
    initializeTable(hObject) ;
    %handles = guidata(hObject) ;

    set(handles.pb_cancel2, 'Enable', 'off') ;
    set(handles.pb_save, 'Enable', 'off') ;
    set(handles.tx_dir2, 'String', getappdata(0, 'last_folder')) ;
	guidata(hObject, handles) ;

% --- Outputs from this function are returned to the command line.
function varargout = finishExperiment_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles.output ;

% --- Executes on button press in cb_last.
function cb_last_Callback(hObject, eventdata, handles)
	if strcmp(get(handles.tx_dir, 'String'), 'directory to be processed')
		set(handles.tx_dir, 'Enable', 'off') ;
	end
	guidata(hObject, handles) ;

% --- Executes on button press in cb_choose.
function cb_choose_Callback(hObject, eventdata, handles)
	global NEUR_FOLDER ;
	set(handles.cb_last, 'Value', 0) ;
	flag = true ;
	while flag 
		data_folder = uigetdir(NEUR_FOLDER, 'Choose a directory to be processed') ;
		if data_folder == 0
            set(handles.cb_last, 'Value', 1) ;
            set(handles.cb_choose, 'Value', 0) ;
            return ;
        end
		d = dir(data_folder) ;
		if any(strcmp({d.name}, 'Events.nev'))
			flag = false ;
		else
			waitfor(warndlg('No Neuralynx files detected. Please choose a valid directory', '')) ;
		end
	end
	l = length(NEUR_FOLDER) ;
	set(handles.tx_dir, 'String', data_folder) ;
	guidata(hObject, handles) ;

% --- Executes on button press in pb_process.
function pb_process_Callback(hObject, eventdata, handles)
    s = str2double(get(handles.ed_set, 'String')) ;
    if isnan(s)
        set(handles.ed_set, 'String', '') ;
        return
    elseif s > size(get(handles.tb_param, 'Data'), 2) |...
           s < 0
        set(handles.ed_set, 'String', '') ;
        return
    end
	global SET NEUR_FOLDER ;
	if get(handles.cb_last, 'Value') == 0 & isempty(get(handles.tx_dir, 'String'))
		warndlg('Please select a directory to be processed', 'No file found') ;
		return ;
	elseif get(handles.cb_last, 'Value') == 0
		setappdata(0, 'last_folder', get(handles.tx_dir, 'String')) ;
	end
    SET = ['set', get(handles.ed_set, 'String')] ;
    setappdata(0, 'cancel', false) ;
    delete(handles.figure1) ;


% --- Executes on button press in pb_cancel2.
function pb_cancel_Callback(hObject, eventdata, handles)
	setappdata(0, 'cancel', true) ;
	delete(handles.figure1) ;

% --- Cross or alt-f4 close
function finishExperiment_CloseRequestFcn(hObject, eventdata, handles)
    user_response = modaldlg('Title', 'QUIT',...
                             'String', 'Confirm Close?') ;
    switch user_response
    case{'No'}
        % take no action
    case 'Yes'
        setappdata(0, 'cancel', true) ;
        delete(handles.figure1) ;
    end


% --- Executes on button press in pb_define.
function pb_define_Callback(hObject, eventdata, handles)
    set(handles.pb_cancel2, 'Enable', 'on') ;
    set(handles.pb_save, 'Enable', 'on') ;
    set(handles.pb_define, 'Enable', 'off') ;
    data = get(handles.tb_param, 'Data') ;
    cnames = get(handles.tb_param, 'ColumnName') ;
    ceditable = get(handles.tb_param, 'ColumnEditable') ;
    cwidth = get(handles.tb_param, 'ColumnWidth') ;
    set(handles.tb_param, 'Data', [data, data(:, 1)],...
                          'ColumnName', [cnames ; ['set', num2str(length(cnames))]],...
                          'ColumnEditable', [false(1, length(cnames)), true],...
                          'ColumnWidth', [cwidth, 50 50]) ;
    guidata(hObject, handles) ;

% --- Executes on button press in pb_cancel2.
function pb_cancel2_Callback(hObject, eventdata, handles)
    data = get(handles.tb_param, 'Data') ;
    cnames = get(handles.tb_param, 'ColumnName') ;
    ceditable = get(handles.tb_param, 'ColumnEditable') ;
    set(handles.tb_param, 'Data', data(:, 1:end-1),...
                          'ColumnName', cnames(1:end-1),...
                          'ColumnEditable', ceditable(1:end-1)) ;
    set(handles.pb_cancel2, 'Enable', 'off') ;
    set(handles.pb_save, 'Enable', 'off') ;

    set(handles.pb_define, 'Enable', 'on') ;
    guidata(hObject, handles) ;

% --- Executes on button press in pb_save.
function pb_save_Callback(hObject, eventdata, handles)
    data = cell2mat(get(handles.tb_param, 'Data')) ;
    for iSet = 1:size(data, 2)-1
        if all(data(:, iSet) == data(:, end))
            warndlg(['The parameters you have choosen are the same as set', num2str(iSet-1)],...
                    'SAME SETS') ;
            return
        end
    end
    set(handles.pb_cancel2, 'Enable', 'off') ;
    set(handles.pb_save, 'Enable', 'off') ;
    rnames = get(handles.tb_param, 'RowName') ;
    param = getappdata(0, 'parameters') ;
    data = get(handles.tb_param, 'Data') ;
    name = ['set', num2str(size(data, 2))-1] ;
    param.(name) = cell2struct(data(:, end), rnames) ;
    param.(name) = structfun(@(x) (num2str(x)), param.(name), 'UniformOutput', false) ;
    setappdata(0, 'parameters', param) ;
    set(handles.ed_set   , 'Enable', 'on') ;
    set(handles.pb_define, 'Enable', 'on') ;
    set(handles.cb_all   , 'Enable', 'on') ;
    set(handles.pb_remove, 'Enable', 'on') ;
    set(handles.ed_set2  , 'Enable', 'on') ;
    guidata(hObject, handles) ;


function ed_set_Callback(hObject, eventdata, handles)
    s = str2double(get(hObject, 'String')) ;
    if isnan(s)
        warndlg('Index of set of parameters must be NUMBER', 'WRONG INPUT') ;
        set(hObject, 'String', '') ;
        return
    elseif s > size(get(handles.tb_param, 'Data'), 2) |...
           s < 0
        warndlg('Wrong index', 'WRONG INPUT') ;
        set(hObject, 'String', '') ;
        return
    end
    guidata(hObject, handles) ;


% --- Executes on button press in pb_remove.
function pb_remove_Callback(hObject, eventdata, handles)
    s = str2double(get(handles.ed_set2, 'String')) ;
    if isnan(s)
        warndlg('Index of set of parameters must be NUMBER', 'WRONG INPUT') ;
        set(handles.ed_set2, 'String', '') ;
        return ;
    elseif s > size(get(handles.tb_param, 'Data'), 2) |...
           s <= 0
        warndlg('Wrong index', 'WRONG INPUT') ;
        set(handles.ed_set2, 'String', '') ;
        return
    end
    param = getappdata(0, 'parameters') ;
    s = get(handles.ed_set2, 'String') ;
    param = rmfield(param, ['set', s]) ;
    setappdata(0, 'parameters', param) ;
    initializeTable(hObject) ;
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;

function ed_set2_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
function ed_set2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end

function initializeTable(hObject) 
    handles = guidata(hObject) ;
    global SET ;
    set(handles.ed_set, 'String', SET(4:end)) ;
    param = getappdata(0, 'parameters') ;
    data = arrayfun(@(x) (str2double(struct2cell(param.(char(x))))), fieldnames(param), 'UniformOutput', false) ;
    data = num2cell(cell2mat(data')) ;
    l = length(fieldnames(param)) ;
    set(handles.tb_param, 'ColumnName', fieldnames(param),...
                          'RowName'   , fieldnames(param.set0),...
                          'Data'      , data,...
                          'ColumnEditable', false(1, l),...
                          'ColumnWidth', repmat(num2cell(50), 1, l)) ;
    if length(fieldnames(param)) == 1
        set(handles.ed_set   , 'String', '0',...
                               'Enable', 'off') ;
        set(handles.pb_remove, 'Enable', 'off') ;
        set(handles.ed_set2  , 'Enable', 'off') ;
        set(handles.cb_all   , 'Enable', 'off') ;
    else
        set(handles.cb_all   , 'Enable', 'on') ;
        set(handles.pb_remove, 'Enable', 'on') ;
        set(handles.ed_set2  , 'Enable', 'on') ;
    end
    guidata(hObject, handles) ;


% --- Executes on button press in cb_all.
function cb_all_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        user_response = modaldlg('Title' , 'CAUTION',...
                                 'String', 'This may take a few time. Please stop acquisition and wait. Continue?') ;
        switch user_response
        case 'No'
            set(hObject, 'Value', 0) ;
            return ;
        case 'Yes'
            setappdata(0, 'RELAUNCH', true) ;
            delete(handles.figure1) ;
        end
    end
    %guidata(hObject, handles) ;


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
