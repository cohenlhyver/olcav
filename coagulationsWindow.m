function varargout = coagulationsWindow(varargin)
% COAGULATIONSWINDOW M-file for coagulationsWindow.fig
%      COAGULATIONSWINDOW, by itself, creates a new COAGULATIONSWINDOW or raises the existing
%      singleton*.
%
%      H = COAGULATIONSWINDOW returns the handle to a new COAGULATIONSWINDOW or the handle to
%      the existing singleton*.
%
%      COAGULATIONSWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COAGULATIONSWINDOW.M with the given input arguments.
%
%      COAGULATIONSWINDOW('Property','Value',...) creates a new COAGULATIONSWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before coagulationsWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to coagulationsWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help coagulationsWindow

% Last Modified by GUIDE v2.5 21-Nov-2013 14:58:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @coagulationsWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @coagulationsWindow_OutputFcn, ...
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


% --- Executes just before coagulationsWindow is made visible.
function coagulationsWindow_OpeningFcn(hObject, eventdata, handles, varargin)
    global NB_ZONES ;
    zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;

    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = coagulationsWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.edit1, 'String')))
        warndlg('Coagulations must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function edit2_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.edit2, 'String')))
        warndlg('Coagulations must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function edit3_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.edit3, 'String')))
        warndlg('Coagulations must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit4_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.edit4, 'String')))
        warndlg('Coagulations must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in pb_close.
function pb_close_Callback(hObject, eventdata, handles)
    global NB_ZONES
    answer = modaldlg('Title', 'QUIT',...
                      'String', 'Confirm Close?') ;
    switch answer
    case{'No'}
        % take no action
    case 'Yes'
        zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
        zone.coagulations = [str2num(get(handles.edit1, 'String')),...
                             str2num(get(handles.edit2, 'String')),...
                             str2num(get(handles.edit3, 'String')),...
                             str2num(get(handles.edit4, 'String'))] ;
                             setappdata(0, ['zone', num2str(NB_ZONES)], zone) ;
        delete(handles.recSitesInterface) ;
    end
