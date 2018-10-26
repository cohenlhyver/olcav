function varargout = profileName(varargin)
% PROFILENAME M-file for profileName.fig
%      PROFILENAME, by itself, creates a new PROFILENAME or raises the existing
%      singleton*.
%
%      H = PROFILENAME returns the handle to a new PROFILENAME or the handle to
%      the existing singleton*.
%
%      PROFILENAME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROFILENAME.M with the given input arguments.
%
%      PROFILENAME('Property','Value',...) creates a new PROFILENAME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before profileName_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to profileName_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help profileName

% Last Modified by GUIDE v2.5 05-Apr-2013 13:51:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @profileName_OpeningFcn, ...
                   'gui_OutputFcn',  @profileName_OutputFcn, ...
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


% --- Executes just before profileName is made visible.
function profileName_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.output = hObject ;
	guidata(hObject, handles) ;

% --- Outputs from this function are returned to the command line.
function varargout = profileName_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles.output ;

% --- Executes on button press in pb_quit.
function pb_quit_Callback(hObject, eventdata, handles)
	if ~isempty(get(handles.ed_name, 'String'))
		setappdata(0, 'profile_name', get(handles.ed_name, 'String')) ;
		close ;
	else
		return
	end

function ed_name_Callback(hObject, eventdata, handles)
	guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function ed_name_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    	set(hObject,'BackgroundColor','white');
	end
