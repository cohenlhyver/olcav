function varargout = CLOSE(varargin)
% CLOSE M-file for CLOSE.fig
%      CLOSE, by itself, creates a new CLOSE or raises the existing
%      singleton*.
%
%      H = CLOSE returns the handle to a new CLOSE or the handle to
%      the existing singleton*.
%
%      CLOSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLOSE.M with the given input arguments.
%
%      CLOSE('Property','Value',...) creates a new CLOSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CLOSE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CLOSE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CLOSE

% Last Modified by GUIDE v2.5 26-Mar-2013 16:11:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CLOSE_OpeningFcn, ...
                   'gui_OutputFcn',  @CLOSE_OutputFcn, ...
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


% --- Executes just before CLOSE is made visible.
function CLOSE_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.output = hObject ;
	guidata(hObject, handles) ;

% --- Outputs from this function are returned to the command line.
function varargout = CLOSE_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles.output ;


% --- Executes on button press in pb_bye.
function pb_bye_Callback(hObject, eventdata, handles)
	delete(handles.figure1) ;
