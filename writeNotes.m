function varargout = writeNotes(varargin)
% WRITENOTES M-file for writeNotes.fig
%      WRITENOTES, by itself, creates a new WRITENOTES or raises the existing
%      singleton*.
%
%      H = WRITENOTES returns the handle to a new WRITENOTES or the handle to
%      the existing singleton*.
%
%      WRITENOTES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WRITENOTES.M with the given input arguments.
%
%      WRITENOTES('Property','Value',...) creates a new WRITENOTES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before writeNotes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to writeNotes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help writeNotes

% Last Modified by GUIDE v2.5 23-Apr-2013 16:58:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @writeNotes_OpeningFcn, ...
                   'gui_OutputFcn',  @writeNotes_OutputFcn, ...
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


% --- Executes just before writeNotes is made visible.
function writeNotes_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.output = hObject ;
	global ZONES ;
	if isempty(ZONES)
		set(handles.cb_z, 'Enable', 'off') ;
	else
			set(handles.lb_zone, 'String', fieldnames(ZONES)) ;
	end
	guidata(hObject, handles) ;

function varargout = writeNotes_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles.output ;

% --- Load previous notes
function pb_load_Callback(hObject, eventdata, handles)
	global ZONES ; 
	idx   = get(handles.lb_zone, 'Value') ;
    z = get(handles.lb_zone, 'String') ;
	depth = get(handles.lb_depth, 'Value') ;
    d = get(handles.lb_depth, 'String') ;
	notes = getappdata(0, 'notes') ;
	if get(handles.cb_d, 'Value')
		if isfield(notes, [z{idx}, '.depth', d{depth}])
			set(handles.ed, 'String', notes.([z{idx}, '.depth', d{depth}])) ;
			set(handles.tx_info, 'Visible', 'off') ;
			set(handles.pan_info, 'Visible', 'off') ;
		else
			set(handles.tx_info, 'Visible', 'on') ;
			set(handles.pan_info, 'Visible', 'on') ;
		end
    elseif get(handles.cb_z, 'Value')
		if isfield(notes, [z{idx}, '.notes'])
			set(handles.ed, 'String', notes.(z{idx}).notes) ;
			set(handles.tx_info, 'Visible', 'off') ;
			set(handles.pan_info, 'Visible', 'off') ;
		else
			set(handles.tx_info, 'Visible', 'on') ;
			set(handles.pan_info, 'Visible', 'on') ;
		end
	else
		set(handles.ed, 'String', notes.notes) ;
	end
	guidata(hObject, handles) ;

% --- Executes on button press in cb_z.
function cb_z_Callback(hObject, eventdata, handles)
	if get(hObject, 'Value')
		set(handles.lb_zone, 'Enable', 'on') ;
		set(handles.cb_d, 'Enable', 'on') ;
	else
		set(handles.lb_zone, 'Enable', 'off') ;
		set(handles.cb_d, 'Enable', 'off') ;
		set(handles.lb_depth, 'Enable', 'off') ;
	end
	guidata(hObject, handles) ;

% --- Executes on button press in cb_d.
function cb_d_Callback(hObject, eventdata, handles)
	global ZONES ;
	if get(hObject, 'Value')
		set(handles.lb_depth, 'Enable', 'on') ;
		set(handles.lb_depth, 'String', num2cell(ZONES.(['zone', num2str(get(handles.lb_zone, 'Value'))]).depths)) ;
	else
		set(handles.lb_depth, 'Enable', 'off') ;
		set(handles.lb_depth, 'String', '') ;
	end
	guidata(hObject, handles) ;

% --- Executes on button press in pb_save.
function pb_save_Callback(hObject, eventdata, handles)
	global ZONES ;
	txt = get(handles.ed, 'String') ;
	notes = getappdata(0, 'notes') ;
	if get(handles.cb_z, 'Value')
		z = get(handles.lb_zone, 'String') ;
		zone = 	z{get(handles.lb_zone, 'Value')} ;
		if get(handles.cb_d, 'Value')
            d = get(handles.lb_depth, 'String') ;
            depth = d{get(handles.lb_depth, 'Value')} ;
			notes.(zone).(['depth', depth]) = txt ;
		else
			notes.(zone).notes = txt ;
		end
	else
		notes.notes = txt ;
	end
	setappdata(0, 'notes', notes) ;
	close(gcf) ;

% --- Zone
function lb_zone_Callback(hObject, eventdata, handles)
	guidata(hObject, handles) ;
function lb_zone_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white') ;
	end

% --- Depth
function lb_depth_Callback(hObject, eventdata, handles)
	guidata(hObject, handles) ;
function lb_depth_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white') ;
	end
