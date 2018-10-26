function varargout = welcome(varargin)
% WELCOME MATLAB code for welcome.fig
%      WELCOME, by itself, creates a new WELCOME or raises the existing
%      singleton*.
%
%      H = WELCOME returns the handle to a new WELCOME or the handle to
%      the existing singleton*.
%
%      WELCOME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WELCOME.M with the given input arguments.
%
%      WELCOME('Property','Value',...) creates a new WELCOME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before welcome_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to welcome_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help welcome

% Last Modified by GUIDE v2.5 22-May-2013 12:41:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @welcome_OpeningFcn, ...
                   'gui_OutputFcn',  @welcome_OutputFcn, ...
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


% --- Executes just before welcome is made visible.
function welcome_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject ;
    guidata(hObject, handles) ;

% --- Outputs from this function are returned to the command line.
function varargout = welcome_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output ;

% --- Executes on button press in pb_go.
function pb_go_Callback(hObject, eventdata, handles)
    delete(gcf) ;
    
% --- Executes on button press in pb_cancel.
function pb_cancel_Callback(hObject, eventdata, handles)
    setappdata(0, 'quit', true) ;
    delete(gcf) ;


% --- Executes when user attempts to close welcome.
function welcome_CloseRequestFcn(hObject, eventdata, handles)
    delete(hObject) ;
