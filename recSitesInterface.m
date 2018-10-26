function varargout = recSitesInterface(varargin)
% RECSITESINTERFACE2 M-file for recSitesInterface.fig
%      RECSITESINTERFACE2, by itself, creates a new RECSITESINTERFACE2 or raises the existing
%      singleton*.
%
%      H = RECSITESINTERFACE2 returns the handle to a new RECSITESINTERFACE2 or the handle to
%      the existing singleton*.
%
%      RECSITESINTERFACE2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECSITESINTERFACE2.M with the given input arguments.
%
%      RECSITESINTERFACE2('Property','Value',...) creates a new RECSITESINTERFACE2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before recSitesInterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to recSitesInterface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help recSitesInterface

% Last Modified by GUIDE v2.5 21-Nov-2013 15:03:39

% ----------------------- %
% --- SUMMARY (BEGIN) --- %
% ----------------------- %
% 1.  Initialization            (44  - 61)
% 2.  Opening function & Output (63  - 113)
% 3.  coordinates               (119 - 178)
% 4.  Depths
% 5.  Parameters
% 6.  End of trials
% 7.  Display
% 8.  Comparisons
% 9.  Miscallaneous
% 10. Close
% --------------------- %
% --- SUMMARY (END) --- %
% --------------------- %

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @recSitesInterface_OpeningFcn, ...
                   'gui_OutputFcn',  @recSitesInterface_OutputFcn, ...
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

% --- Opening function
function recSitesInterface_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject ;
    guidata(hObject, handles) ;
    global NEW_COORD OUTPUT IMGIDX NB_ZONES ZONES SLSTEP IDX NB_COND ;
    NEW_COORD = false ;
    IMGIDX = 1 ;
    NB_ZONES = 0 ;
    ZONES = [] ;
    SLSTEP = 1 ;
    IDX = NB_COND+1 ;
    set(hObject, 'Name', 'Recording Sites Interface -- OLCAV - The Online LFP & CSD Analyzer and Visualizer tool *** V2.0 ***',...
                 'Units', 'normalized',...
                 'Menubar', 'none') ;

    set(handles.cb_change_zone, 'Value', 0) ;
    
    handles.set = 'default' ;
    % --- Display brain image
    brainDisplay(hObject) ;
    handles = guidata(hObject) ;
    % --- Load min & max depth
    handles.limits = [0, 2000] ;
    set(handles.ax_depths, 'YLim'      , [0, 2000],...
                           'YTick'     , [0 :100: 2000],...
                           'YTickLabel', [0 :100: 2000]) ;
    % --- Set default value of depth incrementation
    handles.incr = 50 ;
    % --- Set default values
    set(handles.tx_prev_depth, 'Enable', 'off') ;
    %set(handles.cb_get_pos   , 'Enable', 'off') ;
    %set(handles.cb_ap        , 'Enable', 'off') ;
    % --- Automatic display
    handles.disp_last = false ;
    % --- Hide axes
    set(handles.ax_last    , 'Visible', 'off') ;
    set(handles.tx_mean_lfp, 'String' , 'No previous data to display') ;
    set(handles.tx_lfp_csd , 'String' , 'No previous data to display') ;
    set(handles.tx_opt     , 'String' , 'No previous data to display') ;
    set(handles.tx_feat    , 'String' , 'No previous data to display') ;
    set(handles.tx_avrec   , 'String' , 'No previous data to display') ;
    
    set(findall(get(handles.pan_feat, 'Children'), 'Type', 'axes'), 'Visible', 'off') ;
    c = clock ;
    h = num2str(c(4)) ;
    m = num2str(c(5)) ;
    if length(m) == 1, m = ['0', m] ; end
    s = num2str(c(6)) ;
    if strcmp(s(2), '.')
        s = ['0', s(1)] ;
    else
        s = s(1:2) ;
    end
    set(handles.tx_op2, 'String', [h, ':', m, ':', s]) ;
    setappdata(0, 'opening_time', [h, 'h', m]) ;
    set(handles.tx_first2, 'String', '') ;
    set(handles.tx_res2, 'String', OUTPUT) ;
    olca_path = getappdata(0, 'olca_path') ;
    brain_path = getappdata(0, 'brain_path') ;
    idx = strfind(brain_path, fullfile(olca_path, 'images')) + length(fullfile(olca_path, 'images')) ;
    set(handles.tx_img2, 'String', brain_path(idx:end)) ;
    set(handles.tx_olca2, 'String', olca_path) ;
    set(handles.rb_lfp, 'Value', 1,...
                        'Enable', 'off') ;
    set(handles.rb_csd, 'Enable', 'off') ;
    set(handles.rb_lfp_csd, 'Enable', 'off') ;
    set(handles.sl_step, 'Visible', 'off') ;

    set(handles.tb_opt, 'Data'   , {'', '', ''},...
                        'RowName', {''}) ;

    guidata(hObject, handles) ;

% --- Outputs
function varargout = recSitesInterface_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output ;

% ------------------- %
% --- GUI (BEGIN) --- %
% ------------------- %

% --------------------------- %
% --- COORDINATES (BEGIN) --- %
% --------------------------- %

% --- Change zone coordinates
function cb_change_zone_Callback(hObject, eventdata, handles)
    global COORDINATES NEW_COORD ;
    if get(handles.cb_change_zone, 'Value')
        set(handles.ed_next_lr    , 'Enable', 'on') ;
        set(handles.ed_next_dv    , 'Enable', 'on') ;
        set(handles.rb_left       , 'Enable', 'on') ;
        set(handles.rb_right      , 'Enable', 'on') ;
        % set(handles.cb_get_pos    , 'Enable', 'on') ;
        % set(handles.cb_ap         , 'Enable', 'on') ;
        set(handles.cb_change_zone, 'String', 'CONFIRM') ;
    else
        set(handles.ed_next_lr,     'Enable', 'off') ;
        set(handles.ed_next_dv,     'Enable', 'off') ;
        set(handles.rb_left,        'Enable', 'off') ;
        set(handles.rb_right,       'Enable', 'off') ;
        % set(handles.cb_get_pos,     'Enable', 'off',...
        %                             'Value' ,  0) ;
        % set(handles.cb_ap,          'Enable', 'off',...
        %                             'Value' ,  0) ;
        set(handles.cb_change_zone, 'String', 'New zone') ; 
        coord_new = [get(handles.ed_next_lr, 'String'), ',',...
                     get(handles.ed_next_dv, 'String')] ;
        if strcmp(COORDINATES, coord_new)
            NEW_COORD = false ;
        else
            NEW_COORD = true ;
            COORDINATES = coord_new ;
        end
    end
    guidata(hObject, handles) ;

% --- Hemisphere - left
function rb_left_Callback(hObject, eventdata, handles)
    set(handles.rb_right, 'Value', 1-get(handles.rb_left, 'Value')) ;
    guidata(hObject, handles) ;

% --- Hemisphere - right
function rb_right_Callback(hObject, eventdata, handles)
    set(handles.rb_left, 'Value', 1-get(handles.rb_right, 'Value')) ;
    guidata(hObject, handles) ;

% --- Next left-right zone coordinate
function ed_next_lr_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_next_lr, 'String')))
        warndlg('Left-right axis coordinate must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_next_lr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Next dorsoventral zone coordinate
function ed_next_dv_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_next_dv, 'String')))
        warndlg('Dorsoventral axis coordinate must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_next_dv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Next depth
function ed_next_depth_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_next_depth, 'String')))
        warndlg('Depth must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
    
function ed_next_depth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function tx_ap_CreateFcn(hObject, eventdata, handles)

% ------------------------- %
% --- COORDINATES (END) --- %
% ------------------------- %

% ----------------------------- %
% --- END OF TRIALS (BEGIN) --- %
% ----------------------------- %

% --- Finish set of trials
function pb_finish_Callback(hObject, eventdata, handles)
    global NB_ZONES NEUR_FOLDER SET FROMTO ZONES ;
    nb_zones = NB_ZONES ;
    if isempty(NB_ZONES) | NB_ZONES == 0, nb_zones = 1 ; end
    % --- Check fields
    if isempty(get(handles.ed_next_lr, 'String'))
        warndlg('Missing value of left-right axis coordinate!',...
                'Missing value') ;
        return
    elseif isempty(get(handles.ed_next_dv, 'String'))
        warndlg('Missing value of dorsoventral axis coordinate!',...
                'Missing value') ;
        return
    elseif isempty(get(handles.ed_next_depth, 'String'))
        warndlg('Missing value of next depth!',...
                'Missing value') ;
        return
    elseif ~get(handles.rb_left, 'Value') & ~get(handles.rb_right, 'Value')
        warndlg('Missing value of hemisphere!',...
                'Missing value') ;
        return
    elseif str2double(get(handles.ed_next_depth, 'String')) < 0
        answer = modaldlg('Title', 'Wrong depth',...
                                 'String', 'Depth is inferior to min depth. Change limits?') ;
         switch answer
         case 'No'
            return ;
        case 'Yes'
            %
        end
    elseif str2double(get(handles.ed_next_depth, 'String')) > 2000
         answer = modaldlg('Title', 'Wrong depth',...
                                  'String', 'Depth is superior to max depth. Change limits?') ;
         switch answer
         case 'No'
            return ;
        case 'Yes'
            %
        end
    end

    waitfor(finishExperiment) ;
    if getappdata(0, 'cancel') == true, return ; end
    % if getappdata(0, 'RELAUNCH') == true
    %     for iDepth = 1:
    %     recSitesInterface ; end

    pause(0.01) ;

    checkZone(hObject) ;

    % --- Enable 'End of experiment' pushbutton
    set(handles.pb_finish, 'Enable', 'on',...
                           'String', 'END OF RECORDING') ;
    % --- Update depths fields values
    depth = str2double(get(handles.ed_next_depth, 'String')) ;
    set(handles.tx_prev_depth2, 'String', num2str(depth)) ;
    set(handles.ed_next_depth, 'String', num2str(depth + handles.incr)) ;
    set(handles.tx_prev_depth, 'Enable', 'on') ;

    lfpDisplay(hObject, eventdata, handles) ;
    spikesDisplay(hObject, eventdata, handles) ;
    latAmpDisplay(hObject, eventdata, handles) ;
    set(handles.sl_step, 'Visible', 'on') ;
    if nb_zones == NB_ZONES
        lfpMeanDisplay(hObject, eventdata, handles) ;
    else
        h = subplot(1, 1, 1, 'Parent', handles.pan_mean_lfp) ;
        set(h, 'Visible', 'off') ;
        %set(handles.ax_last, 'Visible', 'off') ;
        set(handles.tx_mean_lfp, 'Visible', 'on',...
                             'String' , 'New zone') ;
        set(handles.tx_feat, 'Visible', 'on',...
                             'String' , 'New zone') ;
    end
    if isempty(get(handles.tx_first2, 'String'))
        c = clock ;
        h = num2str(c(4)) ;
        m = num2str(c(5)) ;
        if length(m) == 1, m = ['0', m] ; end
        s = num2str(c(6)) ;
        if strcmp(s(2), '.')
            s = ['0', s(1)] ;
        else
            s = s(1:2) ;
        end
        set(handles.tx_first2, 'String', [h, ':', m, ':', s]) ;
        setappdata(0, 'first_experiment', [h, 'h', m]) ;
    end
    zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
    if ~isempty(zone.csd_mean)
        set(handles.rb_csd, 'Enable', 'on') ;
        set(handles.rb_lfp_csd, 'Enable', 'on') ;
    end

    set(handles.sl_step, 'Min', 1,...
                          'Max', 10000,...
                          'SliderStep', [1/1000, 1],...
                          'Value', 1) ;
    if length(zone.depths) > 0, set(handles.rb_lfp, 'Enable', 'on') ; end
    % --- Spikes table
    data = get(handles.tb_opt, 'Data') ;
    if ~zone.spikes_all
        set(handles.tb_opt, 'Data', cell(size(zone.spikes_all, 1), 3),...
                            'RowName', {zone.depths}) ;
    else
        [sp_max, sp_max_pos] = max(zone.spikes_all) ;
        sp_tot = sum(zone.spikes_all) ;
        if sp_tot == 0
            sp_max = 0 ;
            percent_max = 0 ;
        else
            percent_max = round(sp_max./sp_tot*100) ;
        end
        set(handles.tb_opt, 'Data'   , num2cell([sp_max_pos', percent_max', sp_tot']),...
                            'RowName', {zone.depths}) ;
    end

    handles = guidata(hObject) ;
    guidata(hObject, handles) ;

% --------------------------- %
% --- END OF TRIALS (END) --- %
% --------------------------- %

% --- Display the coordinates of previous explored zones
function pb_prev_zones_Callback(hObject, eventdata, handles)
    showPreviousZones ;

% --- Creation of the axes containing the brain image
function ax_brain_CreateFcn(hObject, eventdata, handles)

% --- Creation of the axes containing the depths
function ax_depths_CreateFcn(hObject, eventdata, handles)

% --- Display results
function pb_display_Callback(hObject, eventdata, handles)

% ----------------------------- %
% --- MISCELLANEOUS (BEGIN) --- %
% ----------------------------- %

% --- Documentation
function pb_doc_Callback(hObject, eventdata, handles)
    documentation ;

% --------------------------- %
% --- MISCELLANEOUS (END) --- %
% --------------------------- %

% --- Enable datacursormode on brain image
function cb_cursor_Callback(hObject, eventdata, dcm_obj)
    handles = guidata(hObject) ;
    if strcmp(get(dcm_obj, 'Enable'), 'on')
        set(dcm_obj, 'Enable', 'off') ;
        delete(findall(handles.ax_brain, 'Type', 'hggroup', 'HandleVisibility', 'off')) ;
        set(handles.cb_cursor, 'String', 'Show coordinates') ;
    else
        set(dcm_obj, 'Enable', 'on') ;
        set(handles.cb_cursor, 'String', 'Hide coordinates') ;
    end
    guidata(hObject, handles) ;

% --- Display brain image
function brainDisplay(hObject)
    handles = guidata(hObject) ;
    h = handles.ax_brain ;
    %gcf = get(gca, 'Parent')
    grid on ;
    xticklabel = {'L6', 'L5', 'L4', 'L3', 'L2', 'L1', 'L0', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6'} ;
    xticklabel = [xticklabel, xticklabel(end-1 :-1: 1)] ;
    yticklabel = {'A5', 'A4', 'A3', 'A2', 'A1', 'A/P0', 'P1', 'P2', 'P3', 'P4', 'P5'} ;

    set(h, 'GridLineStyle', '-',...
             'XminorGrid'   , 'on',...
             'XLim'         ,  [-6, 6],...
             'XTick'        , [-6:6],...
             'XTickLabel'   , xticklabel,...
             'YMinorGrid'   , 'on',...
             'YLim'         , [-5, 5],...
             'YTick'        , [-5:5],...
             'YTickLabel'   , yticklabel) ;

    line([0, 0], [-5, 5],...
         'Parent', h,...
         'LineWidth', 1.5,...
         'Color', 'r') ;
    line([-6, 6], [0, 0],...
         'Parent', h,...
         'LineWidth', 1.5,...
         'Color', 'g') ;
    text(-3.5, 3, ['\fontsize{40} \color{lightblue} \bf L'], 'Parent', gca) ;
    text(0, 3, ['\fontsize{40} \color{lightblue} \bf R'], 'Parent', gca) ;
    set(h, 'ButtonDownFcn', {@getPosition, hObject}) ;

    guidata(hObject, handles) ;

function getPosition(hObject, src, evt)
    handles = guidata(hObject) ;
    if strcmp(get(handles.ed_next_dv, 'Enable'), 'off'), return, end 
    pos = get(hObject, 'CurrentPoint') ;
    pos = pos([1, 3]) ;
    x = [-6 :0.5: 6] ;
    y = [-5 :0.5: 5] ;
    tmp = x(find(x <= pos(1), 1, 'last')) ;
    if abs(pos(1) - tmp) >= 0.25
        pos(1) = x(find(x >= pos(1), 1, 'first')) ;
    else
        pos(1) = tmp ;
    end
    tmp = y(find(y <= pos(2), 1, 'last')) ;
    if abs(pos(2) - tmp) >= 0.25
        pos(2) = y(find(y >= pos(2), 1, 'first')) ;
    else
        pos(2) = tmp ;
    end
    pos_str = cell(1, 2) ;
    if pos(1) <= 0
        pos_str{1} = ['L', num2str(abs(pos(1)))] ;
    else
        pos_str{1} = ['R', num2str(abs(pos(1)))] ;
    end
    if pos(2) <= 0
        pos_str{2} = ['A', num2str(abs(pos(2)))] ;
    else
        pos_str{2} = ['P', num2str(abs(pos(2)))] ;
    end
    set(handles.cb_cursor, 'Value', 1) ;
    set(handles.ed_next_lr, 'String', pos_str{1}) ;
    set(handles.ed_next_dv, 'String', pos_str{2}) ;
    if pos(1) < 0
        set(handles.rb_left, 'Value', 1) ;
        set(handles.rb_right, 'Value', 0) ;
    else
        set(handles.rb_right, 'Value', 1) ;
        set(handles.rb_left, 'Value', 0) ;
    end
    
function circle(handle, coord, r)
    d  = r*2 ;
    px = coord(1)-r ;
    py = coord(2)-r ;
    h  = rectangle('Parent', handle,...
                   'Position', [px py d d],...
                   'Curvature',[1, 1],...
                   'LineStyle', '-',...
                   'EdgeColor', 'b',...
                   'LineWidth', 1.5) ;
    daspect([1, 1, 1]) ;
    

% --- +1 incrementation for next depth 
function pb_incr_p1_Callback(hObject, eventdata, handles)
    depth = str2num(get(handles.ed_next_depth, 'String')) ;
    set(handles.ed_next_depth, 'String', num2str(depth + 1)) ;
    guidata(hObject, handles) ;

% --- -1 incrementation for next depth
function pb_incr_m1_Callback(hObject, eventdata, handles)
    depth = str2num(get(handles.ed_next_depth, 'String')) ;
    set(handles.ed_next_depth, 'String', num2str(depth - 1)) ;
    guidata(hObject, handles) ;

% --- +5 incrementation for next depth
function pb_incr_p11_Callback(hObject, eventdata, handles)
    depth = str2num(get(handles.ed_next_depth, 'String')) ;
    set(handles.ed_next_depth, 'String', num2str(depth + 5)) ;
    guidata(hObject, handles) ;

% --- -5 incrementation for next depth
function pb_incr_m11_Callback(hObject, eventdata, handles)
    depth = str2num(get(handles.ed_next_depth, 'String')) ;
    set(handles.ed_next_depth, 'String', num2str(depth - 5)) ;
    guidata(hObject, handles) ;

% --- +1 incrementation of incrementator
function pb_incr_p2_Callback(hObject, eventdata, handles)
    handles.incr = handles.incr + 1 ;
    set(handles.ed_incr, 'String', num2str(handles.incr)) ;
    guidata(hObject, handles) ;

% --- -1 incrementation of incrementator
function pb_incr_m2_Callback(hObject, eventdata, handles)
    handles.incr = handles.incr - 1 ;
    set(handles.ed_incr, 'String', num2str(handles.incr)) ;
    guidata(hObject, handles) ;

% --- Incrementation value
function ed_incr_Callback(hObject, eventdata, handles)
    handles.incr = str2double(get(hObject, 'String')) ;
    guidata(hObject, handles) ;
function ed_incr_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Previous depth
function tx_prev_depth2_CreateFcn(hObject, eventdata, handles)

% --- Launch auto/man displayResults function
function cb_disp_last_Callback(hObject, eventdata, handles)
    if get(handles.cb_disp_last, 'Value')
        set(handles.cb_disp_last, 'String', 'Display last results MANUALLY') ;
        handles.disp_last = true ;
    else
        set(handles.cb_disp_last, 'String', 'Display last results AUTOMATICALLY') ;
        handles.disp_last = false ;
    end
    guidata(hObject, handles) ;

% ------------------------%
% --- Display (BEGIN) --- %
% ----------------------- %

function lfpMeanDisplay(hObject, eventdata, handles)
    global NB_COND SAMPLE_FREQ NB_ZONES SET ;
    zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
    if isempty(zone.mean_lfp), return ; end 
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    set(handles.tx_feat, 'Visible', 'off') ;
    %if length(zone.depths) >= 1
        set(handles.tx_mean_lfp, 'Visible', 'off') ;
        bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                         param.lstim,...
                                         param.after]) ;
        
        timetab = linspace(-bound(1),...
                            sum(bound) - bound(1),...
                            size(zone.mean_lfp(1, :), 2)) ;
        ticks = round(bound/SAMPLE_FREQ*1000) ;
        stim_legend = cell(NB_COND, 1) ;
        %h = subplot(1, 1, 1, 'Parent', handles.pan_mean_lfp) ;
        %h = subplot(1, 1, 1, 'Parent', handles.ax_lfp) ;
        cla(handles.ax_lfp) ;
        h = handles.ax_lfp  ;
        set(h, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
               'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
               'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
               'Position', [0.60, 0.60, 0.38, 0.38],...
               'FontSize', 6) ;
        xlabel(h, 'time, (ms)', 'FontSize', 7) ;
        ylabel(h, 'Signal, (mV)', 'FontSize', 7) ;
        hold (h, 'on') ;
        %plot(h, timetab, zone.mean_lfp') ;
        plot(h, zone.subzones{end}.lfp')
        line([0, 0], get(h, 'YLim'), 'Color', 'k', 'Parent', h) ;
        line([bound(2), bound(2)], get(h, 'YLim'), 'Color', 'k', 'Parent', h) ;
        line(get(h, 'XLim'), [0, 0], 'Color', 'k',...
                                       'LineStyle', '--', 'LineWidth', 1, 'Parent', h) ;
        hold(h, 'off') ;
    %end
    guidata(hObject, handles) ;

function latAmpDisplay(hObject, eventdata, handles)
    global SAMPLE_FREQ NB_ZONES SET ;
    zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;

    nb_depths = 1:length(zone.depths) ;
    lim = 1 :floor(nb_depths(end)/10)+1: nb_depths(end) ;
    
    set(handles.tx_feat, 'Visible', 'off') ;
    
    set(handles.tb_lat_amp, 'Data', zone.latencies, 'ColumnWidth', {30, 30}) 

    hold on ;
    plot(handles.ax_lat, zone.latencies(:, 1), '*b') ;
    plot(handles.ax_lat, zone.latencies(:, 2), '*r') ;
    hold off ;
    
    set(handles.ax_lat, 'XLim', [0.5, length(zone.depths)+0.5],...
                        'XTick', lim,...
                        'XTickLabel', num2str(zone.depths(lim)),...
                        'YLim', [min(zone.latencies(:))-25, max(zone.latencies(:))+25]) ;
    % --- Latencies & amplitudes
    % % response
    % lat = cell2mat(arrayfun(@(x) (zone.subzones{x}.latencies.resp(:, 2)),...
    %                         nb_depths, 'UniformOutput', false)) ; 
    % lat_mean = mean(lat) ;
    % lat_max  = max(lat) - lat_mean ; 
    % lat_min  = lat_mean - min(lat) ;
    % hlat_res = errorbar(handles.ax_lat,...
    %                     nb_depths, lat_mean, lat_min, lat_max,...
    %                     'Marker', 'x',...
    %                     'MarkerSize', 10,...
    %                     'MarkerEdgeColor', 'r') ;
    % set(handles.ax_lat, 'XLim' , [0.5, nb_depths(end)+0.5],...
    %                     'XTick', lim,...
    %                     'XTickLabel', num2str(zone.depths(lim)),...
    %                     'YLim', [min(min(lat))-25, max(max(lat))+25]) ;
    % ylabel(handles.ax_lat, 'Peak latency',...
    %                        'FontSize', 7) ;
    % % --- Baseline
    % lat = cell2mat(arrayfun(@(x) (zone.subzones{x}.latencies.bline(:, 2)),...
    %                         nb_depths, 'UniformOutput', false)) ; 
    % lat_mean = mean(lat) ; 
    % lat_max  = max(lat) - lat_mean ; 
    % lat_min  = lat_mean - min(lat) ; 
    % hold (handles.ax_lat, 'on') ;
    % %hlat_bas = errorbar(handles.ax_lat_bas,...
    % hlat_bas = errorbar(handles.ax_lat,...
    %                     nb_depths, lat_mean, lat_min, lat_max,...
    %                     'Marker', 'x',...
    %                     'MarkerSize', 10,...
    %                     'MarkerEdgeColor', 'r') ;
    % set(handles.ax_lat_bas, 'XLim' , [0.5, nb_depths(end)+0.5],...
    %                         'XTick', lim,...
    %                         'XTickLabel', num2str(zone.depths(lim)),...
    %                         'YLim', [min(min(lat))-25, max(max(lat))+25]) ;
    % hold (handles.ax_lat, 'off') ;
    % --- Amplitudes
    % [amp, t] = arrayfun(@(x) (max(zone.subzones{x}.lfp, [], 2)),...
    %                     nb_depths, 'UniformOutput', false) ;
    % amp = cell2mat(amp) ;
    % amp_mean = mean(amp) ;
    % amp_max  = max(amp) - amp_mean ; 
    % amp_min  = amp_mean - min(amp) ;
    % hamp = errorbar(handles.ax_amp,...
    %                 nb_depths, amp_mean, amp_min, amp_max,...
    %                 'Marker', 'x',...
    %                 'MarkerSize', 10,...
    %                 'MarkerEdgeColor', 'r') ;
    % set(handles.ax_amp, 'XLim' , [0.5, nb_depths(end)+0.5],...
    %                     'XTick', lim,...
    %                     'XTickLabel', num2str(zone.depths(lim)),...
    %                     'YLim', [min(min(amp))-2, max(max(amp))+2]) ;
    % ylabel(handles.ax_amp, 'Peak amplitude', 'FontSize', 7) ;
    % t   = round(1000*cell2mat(t)/SAMPLE_FREQ) - param.bline ;
    % t_mean = mean(t) ;
    % t_max  = max(t) - t_mean ;
    % t_min  = t_mean - min(t) ;
    % ht = errorbar(handles.ax_amp_lat,...
    %               nb_depths, t_mean, t_min, t_max,...
    %               'Marker', 'x',...
    %               'MarkerSize', 10,...
    %               'MarkerEdgeColor', 'r') ;
    % set(handles.ax_amp_lat, 'XLim' , [0.5, nb_depths(end)+0.5],...
    %                         'XTick', lim,...
    %                         'XTickLabel', num2str(zone.depths(lim)),...
    %                         'YLim', [min(min(t))-25, max(max(t))+25]) ;

    guidata(hObject, handles) ;

function lfpDisplay(hObject, eventdata, handles)
    global NB_COND SAMPLE_FREQ NB_ZONES SET UNITS SLSTEP ;
    handles = guidata(hObject) ;
    zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    set(handles.tx_feat, 'Visible', 'off') ;
    set(handles.sl_step, 'Enable', 'on') ;
    if length(zone.depths) >= 1
        set(handles.tx_lfp_csd, 'Visible', 'off') ;
        bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                         param.lstim,...
                                         param.after]) ;
        
        timetab = linspace(-bound(1),...
                            sum(bound) - bound(1),...
                            size(zone.mean_lfp(1, :), 2)) ;
        ticks = round(bound/SAMPLE_FREQ*1000) ;
        stim_legend = cell(NB_COND, 1) ;
        h = handles.ax_lfp_csd ;
        cla(h) ;
        %h = subplot(1, 1, 1, 'Parent'    , handles.pan_lfp_csd,...
        set(h, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
               'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
               'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
               'Position'  , [0.05, 0.1, 0.5, 0.85],...
               'FontSize'  , 6) ;
        xlabel(h, 'time, (ms)', 'FontSize', 7) ;
        ylabel(h, 'Signal, (mV)', 'FontSize', 7) ;
        hold (h, 'on') ;
        % if get(handles.cb_img, 'Value')
        %     tmp = cell2mat(arrayfun(@(x) (mean(zone.subzones{x}.lfp)), 1:length(zone.depths), 'UniformOutput', false)') ;
        %     imagesc(tmp, 'Parent', h) ;
        % else
            for iDepth = 1:length(zone.depths)
                step = (1 + SLSTEP*1e-3) * iDepth ;
                lfp_mean = mean(zone.subzones{iDepth}.lfp) ;
                handles_plot(iDepth) = plot(h, timetab, lfp_mean - step,...
                                        'Tag', num2str(iDepth)) ;
                line(get(h, 'XLim'), [-step -step],...
                     'Color', 'k',...
                     'LineStyle', '--',...
                     'Parent', h) ;
            end
        % end
        if get(handles.cb_img, 'Value')
            set(h, 'YTick', [1:length(zone.depths)],...
                     'YTickLabel', zone.depths(end :-1: 1)) ;
        else
            step = step/iDepth ;
            set(h, 'YTick', -step*(length(zone.depths) :-1: 1),...
                     'YTickLabel', zone.depths(end :-1: 1)) ;
        end
        line([0, 0], get(h, 'YLim'), 'Color', 'k', 'Parent', h) ;
        line([bound(2), bound(2)], get(h, 'YLim'), 'Color', 'k', 'Parent', h) ;
        line(get(h, 'XLim'), [0, 0], 'Color', 'k',...
                                     'LineStyle', '--', 'LineWidth', 1, 'Parent', h) ;
        hold (h, 'off') ;
    end
    guidata(hObject, handles) ;

function lfpCsdDisplay(hObject, eventdata, handles)
    global NB_COND SAMPLE_FREQ NB_ZONES SET UNITS SLSTEP ;
    handles = guidata(hObject) ;
    zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
    if isempty(zone.csd), return ; end 
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    set(handles.tx_feat, 'Visible', 'off') ;
    set(handles.sl_step, 'Enable', 'off') ; 

    bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                     param.lstim,...
                                     param.after]) ;
    timetab = linspace(-bound(1),...
                        sum(bound) - bound(1),...
                        size(zone.mean_lfp(1, :), 2)) ;
    ticks = round(bound/SAMPLE_FREQ*1000) ;

    [nb_depths_csd, dur] = size(zone.csd_mean) ;
    flag = (length(zone.depths) - nb_depths_csd) / 2 ;
    hold on ; 
    for iDepth = 1:length(zone.depths)
        step = (1 + SLSTEP*1e-3) * iDepth ;
        if iDepth > flag && iDepth < nb_depths_csd
            m = mean(zone.subzones{iDepth}.lfp) - step ;
            tmp = [m, 0.01+zeros(1, round(0.25*dur)), zone.csd_mean(iDepth, :)*max(m)] ;
            plot(tmp) ;
        else
            tmp = [mean(zone.subzones{iDepth}.lfp) - step, 0.01+zeros(1, round(0.25*dur)), zeros(1, dur)] ;
            plot(tmp) ;
        end
        line(get(gca, 'YLim'), [0 0],...
             'Color', 'k',...
             'LineStyle', '--') ;
    end
    guidata(hObject, handles) ;


function spikesDisplay(hObject, eventdata, handles)
    global NB_COND SAMPLE_FREQ NB_ZONES SET ;
    
    zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
    if isempty(zone.subzones{end}.spikes_raw), return ; end
    
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    
    plot(handles.ax_sp, zone.subzones{end}.spikes_raw') ;
    set(handles.ax_sp, 'XLim', [0, size(zone.subzones{end}.spikes_raw, 2)+1]) ;
    set(handles.tx_sp, 'String', [num2str(size(zone.subzones{end}.spikes_raw', 1)), ' spikes']) ;
    guidata(hObject, handles) ;

% ----------------------%
% --- Display (END) --- %
% --------------------- %

% --- Executes on button press in pb_notes.
function pb_notes_Callback(hObject, eventdata, handles)
    writeNotes ;
    guidata(hObject, handles) ;

%function = recomputeResults(src, evt, parameters)


% --- Executes on button press in pb_switch.
function pb_switch_Callback(hObject, eventdata, handles)
    global IMGIDX ;
    img_number = size(getappdata(0, 'images'), 1) ;
    if img_number > 1
        switch IMGIDX
        case 1
            IMGIDX = 2 ;
        case 2
            if img_number == 2
                IMGIDX = 1 ;
            else
                IMGIDX = 3 ;
            end
        case 3
            IMGIDX = 1 ;
        end
    end
    brainDisplay(hObject) ;
    guidata(hObject, handles) ;



% % --- Executes on button press in pb_lfp_csd.
% function pb_lfp_csd_Callback(hObject, eventdata, handles)
%     csdDisplay(hObject) ;

% % --- Executes on button press in pb_lfp.
% function pb_lfp_Callback(hObject, eventdata, handles)
%     lfpDisplay(hObject) ;

% -------------------------------------- %
% --- CURRENT SOURCE DENSITY (BEGIN) --- %
% -------------------------------------- %

function csdDisplay(hObject, eventdata, handles)
    handles = guidata(hObject) ;
    global NB_COND SAMPLE_FREQ SET IDX UNITS ;
    zone = getappdata(0, 'zone1') ;
    if isempty(zone.csd), return ; end
    set(handles.sl_step, 'Enable', 'on') ;
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    
    bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                     param.lstim,...
                                     param.after]) ;
    timetab = linspace(-bound(1),...
                        sum(bound) - bound(1),...
                        size(zone.csd{1}(1, :), 2)) ;
    ticks = round(bound/SAMPLE_FREQ*1000) ;
    h = subplot(1, 1, 1, 'Parent', handles.pan_lfp_csd,...
                         'Units', 'normalized',...
                         'Position', [0.1, 0.1, 0.85, 0.8],...
                         'Tag', 'csd') ;
    SLSTEP = 1 ;
    val = 0.00005 + SLSTEP*1e-8 ;
    if get(handles.cb_img, 'Value')
       if IDX == NB_COND + 1
            imagesc(zone.csd_mean) ;
        else
            imagesc(zone.csd{IDX}) ;
        end 
    else
        hold on ;
        for iDepth = 1:size(zone.csd{1}, 1)
            set(gca, 'Tag', 'csd') ;
            if IDX == NB_COND+1
                tmp = zone.csd_mean(iDepth, :) >= 0 ;
                source = zone.csd_mean(iDepth, :) ;
                sink = zone.csd_mean(iDepth, :) ;
            else
                tmp = zone.csd{IDX}(iDepth, :) >= 0 ;
                source = zone.csd{IDX}(iDepth, :) ;
                sink = zone.csd{IDX}(iDepth, :) ;
            end
            source(tmp) = NaN ;
            sink(~tmp)  = NaN ;
            step = val * iDepth ;
            plot(timetab, sink-step, 'b', 'LineWidth', 0.5) ;
            plot(timetab, source-step, 'r', 'LineWidth', 0.5) ;
            line(get(gca, 'XLim'), [-step, -step],...
                 'Color'         , 'k',...
                 'LineStyle'     , '--',...
                 'LineWidth'     , 0.5) ;
        end
    end
    set(gca, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
             'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
             'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
             'YTick'     , -val*(length(zone.depths)-2 :-1: 1),...
             'YTickLabel', zone.depths(end :-1: 3),...
             'FontSize', 8) ;
    %AXLIM = [-bound(1), sum(bound)-bound(1)] ;
    xlabel(['time (', UNITS.time, ')']) ;
    ylabel(['Depth (', UNITS.dim, ')']) ;
    hold off ;
    line([0, 0], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 0.5) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 0.5) ;
    title(['Condition ', num2str(IDX)],...
          'FontSize', 10,...
          'FontWeight', 'bold') ;
    if IDX == NB_COND+1
        title('Mean of all conditions',...
              'FontSize', 10,...
              'FontWeight', 'bold') ;
    end

    % --- AVREC
    if ~isempty(zone.avrec)
        set(handles.tx_avrec, 'Visible', 'off') ;
        subplot(1, 1, 1, 'Parent', handles.pan_avrec) ;
        hold all ;
        for iCond = 1:NB_COND
            plot(timetab, zone.avrec{iCond}) ;
        end
        set(gca, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
                 'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
                 'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
                 'FontSize'  , 6) ;
        line([0, 0], get(gca, 'YLim'),...
             'Color', 'k',...
             'LineWidth', 0.5) ;
        line([bound(2) bound(2)], get(gca, 'YLim'),...
             'Color', 'k',...
             'LineWidth', 0.5) ;
    end

    guidata(hObject, handles) ;

% ------------------------------------ %
% --- CURRENT SOURCE DENSITY (END) --- %
% ------------------------------------ %

function edit19_Callback(hObject, eventdata, handles)

function edit19_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit18_Callback(hObject, eventdata, handles)

function edit18_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Main slider
function sl_step_Callback(hObject, eventdata, handles)
    global SLSTEP ;
    SLSTEP = get(hObject, 'Value') ;
    if get(handles.rb_lfp, 'Value')
        lfpDisplay(hObject) ;
    elseif get(handles.rb_csd, 'Value')
        csdDisplay(hObject) ;
    end
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;
function sl_step_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


% --- LFP display
function rb_lfp_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        lfpDisplay(hObject) ;
    end
    guidata(hObject, handles) ;

% --- CSD display
function rb_csd_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value') 
        csdDisplay(hObject) ;
    end
    guidata(hObject, handles) ;

% --- LFP & CSD display
function rb_lfp_csd_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value') 
        lfpCsdDisplay(hObject) ;
    end
    guidata(hObject, handles) ;


% --- Executes on button press in cb_img.
function cb_img_Callback(hObject, eventdata, handles)
    if get(handles.rb_lfp, 'Value')
        lfpDisplay(hObject) ;
    elseif get(handles.rb_csd, 'Value')
        csdDisplay(hObject) ;
    end 
    guidata(hObject) ;


% --------------------- %
% --- CLOSE (BEGIN) --- % 
% --------------------- %

% --- Close button
function pb_quit_Callback(hObject, eventdata, handles)
    global OUTPUT DIMENSIONS ZONES ;
    answer = modaldlg('Title', 'QUIT',...
                      'String', 'Confirm Close?') ;
    switch answer
    case{'No'}
        % take no action
    case 'Yes'
        setappdata(0, 'QUIT', 1) ;
        hold(handles.ax_brain, 'off') ;
        olcav_log.zones = ZONES ;
        olcav_log.dim = DIMENSIONS ;
        notes = getappdata(0, 'notes') ;
        olcav_log.notes = notes ;
        save(fullfile(OUTPUT, 'olcavLog'), 'olcav_log') ;
        delete(handles.recSitesInterface) ;
    end

% --- Cross or alt-f4 close
function recSitesInterface_CloseRequestFcn(hObject, eventdata, handles)
    global OUTPUT DIMENSIONS ZONES ;
    answer = modaldlg('Title', 'QUIT',...
                             'String', 'Confirm Close?') ;
    switch answer
    case{'No'}
        % take no action
    case 'Yes'
        setappdata(0, 'QUIT', 1) ;
        hold(handles.ax_brain, 'off') ;
        olcav_log.zones = ZONES ;
        olcav_log.dim = DIMENSIONS ;
        notes = getappdata(0, 'notes') ;
        olcav_log.notes = notes ;
        save(fullfile(OUTPUT, 'olcavLog'), 'olcav_log') ;
        delete(handles.recSitesInterface)
    end
    
% ------------------- %
% --- CLOSE (END) --- % 
% ------------------- %

% ----------------- %
% --- GUI (END) --- %
% ----------------- %


% --- Executes on button press in pb_coag.
function pb_coag_Callback(hObject, eventdata, handles)
    coagulationsWindow ;