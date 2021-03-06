function varargout = compareParametersModalDlg(varargin)
% COMPAREPARAMETERSMODALDLG M-file for compareParametersModalDlg.fig
%      COMPAREPARAMETERSMODALDLG by itself, creates a new COMPAREPARAMETERSMODALDLG or raises the
%      existing singleton*.
%
%      H = COMPAREPARAMETERSMODALDLG returns the handle to a new COMPAREPARAMETERSMODALDLG or the handle to
%      the existing singleton*.
%
%      COMPAREPARAMETERSMODALDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPAREPARAMETERSMODALDLG.M with the given input arguments.
%
%      COMPAREPARAMETERSMODALDLG('Property','Value',...) creates a new COMPAREPARAMETERSMODALDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before compareParametersModalDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to compareParametersModalDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help compareParametersModalDlg

% Last Modified by GUIDE v2.5 26-Mar-2013 15:29:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @compareParametersModalDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @compareParametersModalDlg_OutputFcn, ...
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

% --- Executes just before compareParametersModalDlg is made visible.
function compareParametersModalDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = 'Yes' ;
    guidata(hObject, handles) ;

    if(nargin > 3)
        for index = 1:2:(nargin-3),
            if nargin-3==index, break, end
            switch lower(varargin{index})
             case 'title'
              set(hObject, 'Name', varargin{index+1});
             case 'string'
              set(handles.text1, 'String', varargin{index+1});
            end
        end
    end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
    FigPos=get(0,'DefaultFigurePosition');
    OldUnits = get(hObject, 'Units');
    set(hObject, 'Units', 'pixels');
    OldPos = get(hObject,'Position');
    FigWidth = OldPos(3);
    FigHeight = OldPos(4);
    if isempty(gcbf)
        ScreenUnits=get(0,'Units');
        set(0,'Units','pixels');
        ScreenSize=get(0,'ScreenSize');
        set(0,'Units',ScreenUnits);

        FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
        FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
    else
        GCBFOldUnits = get(gcbf,'Units');
        set(gcbf,'Units','pixels');
        GCBFPos = get(gcbf,'Position');
        set(gcbf,'Units',GCBFOldUnits);
        FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                       (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject, 'Position', FigPos);
    set(hObject, 'Units', OldUnits);

    % Show a question icon from dialogicons.mat - variables questIconData
    % and questIconMap
    load dialogicons.mat

    IconData=questIconData;
    questIconMap(256,:) = get(handles.figure1, 'Color');
    IconCMap=questIconMap;

    Img=image(IconData, 'Parent', handles.axes1);
    set(handles.figure1, 'Colormap', IconCMap);

    set(handles.axes1, ...
        'Visible', 'off', ...
        'YDir'   , 'reverse'       , ...
        'XLim'   , get(Img,'XData'), ...
        'YLim'   , get(Img,'YData')  ...
        ) ;

    set(handles.figure1,'WindowStyle','modal') ;
    
    changed_values = getappdata(0, 'changed_values') ;
    cnames = {'User-defined values', 'Changed values'} ;
    rnames = {changed_values{:, 1}}' ;
    data = reshape({changed_values{:, 2:3}}, length(rnames), 2) ;
    set(handles.tb_values, 'Units', 'normalized',...
                           'Data', data,...
                           'ColumnName', cnames,...
                           'RowName', rnames) ;

    uiwait(handles.figure1) ;

% --- Outputs from this function are returned to the command line.
function varargout = compareParametersModalDlg_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output ;
    delete(handles.figure1) ;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    handles.output = get(hObject,'String') ;
    guidata(hObject, handles) ;
    uiresume(handles.figure1) ;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    handles.output = get(hObject,'String') ;
    guidata(hObject, handles) ;
    uiresume(handles.figure1) ;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'CurrentKey'),'escape')
        handles.output = 'No' ;
        guidata(hObject, handles) ;
        uiresume(handles.figure1) ;
    end
    if isequal(get(hObject,'CurrentKey'),'return')
        uiresume(handles.figure1) ;
    end    
