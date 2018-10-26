function varargout = defineZoneFeatures(varargin)
% DEFINEZONEFEATURES M-file for defineZoneFeatures.fig
%      DEFINEZONEFEATURES, by itself, creates a new DEFINEZONEFEATURES or raises the existing
%      singleton*.
%
%      H = DEFINEZONEFEATURES returns the handle to a new DEFINEZONEFEATURES or the handle to
%      the existing singleton*.
%
%      DEFINEZONEFEATURES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFINEZONEFEATURES.M with the given input arguments.
%
%      DEFINEZONEFEATURES('Property','Value',...) creates a new DEFINEZONEFEATURES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before defineZoneFeatures_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to defineZoneFeatures_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help defineZoneFeatures

% Last Modified by GUIDE v2.5 23-May-2013 11:47:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @defineZoneFeatures_OpeningFcn, ...
                   'gui_OutputFcn',  @defineZoneFeatures_OutputFcn, ...
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


% --- Executes just before defineZoneFeatures is made visible.
function defineZoneFeatures_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject ;
    global UNITS ;
    set(handles.tx_units, 'String', UNITS.dim) ;
    set(handles.tb_zones, 'Data', {'' ; '' ; '' ; '' ; ''}) ;
    populateAxe(hObject) ;
    guidata(hObject, handles) ;

function varargout = defineZoneFeatures_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output ;

function ed_lr_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
% --- Executes during object creation, after setting all properties.
function ed_lr_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end

function ed_ap_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
function ed_ap_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end

% --- Executes on button press in pb_next.
function pb_next_Callback(hObject, eventdata, handles)
    global COORDINATES ;
    COORDINATES = [get(handles.ed_lr, 'String'), ',',...
                   get(handles.ed_ap, 'String')] ;
    while(isnan(str2double(COORDINATES(1)))), COORDINATES = COORDINATES(2:end) ; end
    z = getappdata(0, 'zone1') ;
    z.coordinates = COORDINATES ;
    setappdata(0, 'depths', cell2mat(get(handles.tb_zones, 'Data'))) ;
    delete(handles.defineZoneFeatures) ;

function populateAxe(hObject) 
    handles = guidata(hObject) ;
    global DIMENSIONS ; 
    brain_path = getappdata(0, 'images') ;
    brain_image = imread(brain_path{1}) ;
    image(brain_image, 'Parent', handles.ax_img) ;
    image_info = imfinfo(brain_path{1}) ;
    if strcmp(image_info.FormatSignature, 'BM')
        colormap(gca, gray(256)) ;
    end
    axis image

    hold on ; 
    yaxis = size(brain_image, 1) ;
    xaxis = size(brain_image, 2) ;
    ap = DIMENSIONS.ap * yaxis / DIMENSIONS.dv ;

    hap = plot(handles.ax_img,...
               1:xaxis, repmat(ap, xaxis, 1),...
               'r--',...
               'LineWidth', 1.5,...
               'Tag', 'ap') ;
    inter = DIMENSIONS.inter * xaxis / DIMENSIONS.lr ; 
    hint = plot(handles.ax_img,...
                repmat(inter, yaxis, 1), 1:yaxis,...
                'r--',...
                'LineWidth', 1.5,...
                'Tag', 'inter') ;
    %plot(gca, repmat(xaxis/2, yaxis, 1), 1:yaxis, 'r--', 'linewidth', 1.5) ;
    set(gca, 'XTick', [], 'YTick', []) ;
    hold off ;
    dcm_obj = datacursormode(gcf) ;
    set(dcm_obj, 'DisplayStyle', 'datatip',...
                 'Enable', 'on') ;
    set(dcm_obj, 'UpdateFcn', {@windowFormat, [xaxis, yaxis]}) ;

    handles.dcm_obj = dcm_obj ;
    guidata(hObject, handles) ;

function OUTPUT_DTIP = windowFormat(src, evt, xyaxis)
    global OUTPUT_DTIP DIMENSIONS ;
    persistent PROPORTIONS UNITS_DIM ;
    if isempty(PROPORTIONS)
        global UNITS ;
        UNITS_DIM = UNITS.dim ;
        PROPORTIONS = [xyaxis(1)/DIMENSIONS.lr,...
                       xyaxis(2)/DIMENSIONS.dv] ;
    end
    pos = get(evt, 'Position') ;
    %x   = num2str(pos(1)/PROPORTIONS(1), 4) ;
    x   = abs((pos(1)/PROPORTIONS(1)) - DIMENSIONS.inter) ;
    y   = abs((pos(2)/PROPORTIONS(2)) - DIMENSIONS.ap) ;
    if x < 0.01
        x = '0' ; 
    else
        x = num2str(x, 3) ;
    end
    if y < 0.01
        y = '0' ; 
    else
        y = num2str(y, 3) ;
    end
    Lx = num2str(round(str2double(x)/100)) ;
    Ax = num2str(round(str2double(y)/100)) ;
    OUTPUT_DTIP = {['left-right:            ', x, ' ', UNITS_DIM],...
                   ['anteroposterior: '      , y, ' ', UNITS_DIM],...
                   ['position:              ', 'A', Ax, 'L', Lx]} ;

% --- Executes on button press in cb_get_pos.
function cb_get_pos_Callback(hObject, eventdata, handles)
    if get(handles.cb_get_pos, 'Value')
        global OUTPUT_DTIP ;
        if isempty(OUTPUT_DTIP)
            warndlg('No position found on brain image', '') ;
            set(handles.ed_lr, 'String', '') ;
            set(handles.ed_ap, 'String', '') ;
            set(handles.cb_get_pos, 'Value', 0) ;
        else
            set(handles.ed_lr, 'String', OUTPUT_DTIP{1}(end-7:end-3)) ;
            if strcmp(OUTPUT_DTIP{2}(end-4:end-3), ' 0')
                set(handles.ed_ap, 'String', '0') ;
            elseif strcmp(OUTPUT_DTIP{2}(end-8), '-')
                set(handles.ed_ap, 'String', OUTPUT_DTIP{2}(end-8:end-3)) ;
            else
                set(handles.ed_ap, 'String', OUTPUT_DTIP{2}(end-7:end-3)) ;
            end
        end
    else
        set(handles.ed_lr, 'String', '') ;
        set(handles.ed_ap, 'String', '') ;
    end
    guidata(hObject, handles) ;


% --- Executes on button press in cb_new.
function cb_new_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(hObject, 'String', 'CONFIRM') ;
        set(handles.cb_get_pos, 'Enable', 'on') ;
        set(handles.ed_lr, 'Enable', 'on') ;
        set(handles.ed_ap, 'Enable', 'on') ;
        %if ~isnan(handles.cb_ed_lr, 'String') & ~isnan(handles.cb_ed_ap, 'String') 

    else
        set(hObject, 'String', 'New zone') ;
        set(handles.cb_get_pos, 'Enable', 'off') ;
        set(handles.ed_lr, 'Enable', 'off') ;
        set(handles.ed_ap, 'Enable', 'off') ;
    end
    guidata(hObject, handles) ;
        
function ed_vect1_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;

function ed_vect1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end


function ed_vect2_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
function ed_vect2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end
    
function ed_vect3_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
function ed_vect3_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end

% --- Executes on button press in pb_set.
function pb_set_Callback(hObject, eventdata, handles)
    vect = [str2double(get(handles.ed_vect1, 'String'))...
           :str2double(get(handles.ed_vect2, 'String')):...
           str2double(get(handles.ed_vect3, 'String'))] ;
    data = get(handles.tb_zones, 'Data') ;
    data = data(:, end) ;
    if strcmp(data(1), '')
        data = num2cell(vect') ;
    else
        data = [data ; num2cell(vect')] ;
    end 
    set(handles.tb_zones, 'Data', data) ;
    guidata(hObject, handles) ;
