function varargout = displayResults(varargin)
% DISPLAYRESULTS MATLAB code for displayResults.fig
%      DISPLAYRESULTS, by itself, creates a new DISPLAYRESULTS or raises the existing
%      singleton*.
%
%      H = DISPLAYRESULTS returns the handle to a new DISPLAYRESULTS or the handle to
%      the existing singleton*.
%
%      DISPLAYRESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAYRESULTS.M with the given input arguments.
%
%      DISPLAYRESULTS('Property','Value',...) creates a new DISPLAYRESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before displayResults_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to displayResults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help displayResults

% Last Modified by GUIDE v2.5 28-May-2013 15:30:51

% ----------------------- %
% --- SUMMARY (BEGIN) --- %
% ----------------------- %
% 1.  Initialization            (44  - 61)
% 2.  Opening function & Output (63  - 113)
% 3.  ...
% 4.  Local Field Potential
% 5.  Peristimulus Time Histogram
% 6.  Raster plot of spikes
% 7.  Current Source Density
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
                   'gui_OpeningFcn', @displayResults_OpeningFcn, ...
                   'gui_OutputFcn',  @displayResults_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1}) ;
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Opening function
function displayResults_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject ;
    global NB_COND CONDITIONS NB_ZONES UNITS IDX SLSTEP SLSTEP_MIN SLSTEP_MAX AXLIM COORDINATES ;
    IDX = NB_COND + 1 ;
    SLSTEP = 1 ;
    SLSTEP_MIN = 1 ;
    SLSTEP_MAX = 1 ;
    set(hObject, 'Units', 'normalized',...
                 'Position', [0.001, 0.04, 0.999, 0.92]) ;

    zone_name = varargin{1} ;
    idx       = varargin{2} ;

    zone = getappdata(0, zone_name) ;
    coordinates = str2num(zone.coordinates) ;
    name = [zone_name,...
            ' -- ', 'coordinates: ', COORDINATES,...
            '-- ','depth: ', num2str(zone.depths(idx)),...
            'mm'] ;

    set(hObject, 'Name', name) ;
    handles.idx = idx ;
    handles.name = zone_name ;
    handles.zone = zone ;
    handles.speed = 2 ;
    guidata(hObject, handles) ;
    if isempty(zone.subzones{idx}.lfp)
        set(handles.rb_lfp, 'Enable', 'off') ;
        set(handles.sl_lfp , 'Enable', 'off') ;
        set(handles.pb_play, 'Enable', 'off') ;
        set(handles.pb_stop, 'Enable', 'off') ;
        set(handles.rb_lfp_all, 'Enable', 'off') ;
        set(get(handles.pan_speed, 'Children'), 'Enable', 'off') ;
        set(handles.rb_raster, 'Value', 1) ;
        rasterDisplay(hObject) ;
        handles = guidata(hObject) ;
    else
        lfpDisplay(hObject) ;
        handles = guidata(hObject) ;
    end
    if isempty(zone.csd), set(handles.rb_csd, 'Enable', 'off') ; end
    if isempty(zone.subzones{idx}.spikes_raw)
        set(handles.rb_spikes, 'Enable', 'off') ;
        set(handles.rb_raster, 'Enable', 'off') ;
        set(handles.rb_psth  , 'Enable', 'off') ;
     end
    guidata(hObject, handles) ;
    l = length(zone.depths) ;
    if ~isempty(zone.csd), set(handles.rb_csd, 'Enable', 'on') ; end
    if l == 1
        set(handles.sl_lfp , 'Enable', 'off') ;
        set(handles.pb_play, 'Enable', 'off') ;
        set(handles.pb_stop, 'Enable', 'off') ;
        set(get(handles.pan_speed, 'Children'), 'Enable', 'off') ;
        set(handles.rb_lfp_all, 'Enable', 'off') ;
        set(handles.rb_pref  , 'Enable', 'off') ;
    else
        set(handles.sl_lfp, 'Min', 1,...
                            'Max', l,...
                            'SliderStep', [1/(l-1), 1],...
                            'Value', handles.idx) ;
    end
    set(handles.sl_csd_scale, 'Min', 1,...
                              'Max', 10000,...
                              'SliderStep', [1/1000, 1],...
                              'Value', 1) ;
    set(handles.pb_next     , 'Visible', 'off') ;
    set(handles.pb_prev     , 'Visible', 'off') ;
    set(handles.sl_csd_scale, 'Visible', 'off') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'off') ; end
    set(handles.cb_img, 'Enable', 'off') ;
    guidata(hObject, handles) ;

% --- Outputs from this function are returned to the command line.
function varargout = displayResults_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output ;
  
% ------------------- %
% --- GUI (BEGIN) --- %
% ------------------- %

% --- Display LFP
function rb_lfp_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.pb_visible, 'Enable', 'on') ;
        lfpDisplay(hObject) ;
        handles = guidata(hObject) ;
    end
    guidata(hObject, handles) ;

% --- Display CSD
function rb_csd_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.pb_visible, 'Enable', 'off') ;
        csdDisplay(hObject) ;
        handles = guidata(hObject) ;
    else
        set(handles.pb_visible, 'Enable', 'on') ;
        set(handles.cb_img, 'Enable', 'off') ;
    end
    guidata(hObject, handles) ;

% --- Display PSTH
function rb_psth_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.pb_visible, 'Enable', 'off') ;
        psthDisplay(hObject) ;
        handles = guidata(hObject) ;
    end
    guidata(hObject, handles) ;

% --- Display spikes
function rb_spikes_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.pb_visible, 'Enable', 'off') ;
        spikesDisplay(hObject) ;
        handles = guidata(hObject) ;
    end
    guidata(hObject, handles) ;

% --- Display raster plot
function rb_raster_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.pb_visible, 'Enable', 'off') ;
        rasterDisplay(hObject) ;
        handles = guidata(hObject) ;
    end
    guidata(hObject, handles) ;

% --- Creation of ax_plot axe
function ax_plot_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in rb_pref.
function rb_pref_Callback(hObject, eventdata, handles)
    optimalCondition(hObject) ;
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;

% ------------------------------------- %
% --- LOCAL FIELD POTENTIAL (BEGIN) --- %
% ------------------------------------- %

function lfpDisplay(hObject, eventdata)
    global NB_COND SAMPLE_FREQ SET SLSTEP_MIN SLSTEP_MAX AXLIM ;
    handles = guidata(hObject) ;
    set(handles.pb_next     , 'Visible', 'off') ;
    set(handles.pb_prev     , 'Visible', 'off') ;
    set(handles.sl_csd_scale, 'Visible', 'off') ;
    set(handles.sl_lfp, 'Visible', 'on') ;
    set(handles.pb_play, 'Visible', 'on') ;
    set(handles.pb_stop, 'Visible', 'on') ;
    set(handles.sl_min, 'Visible', 'on') ;
    set(handles.sl_max, 'Visible', 'on') ;
    set(handles.cb_img, 'Enable', 'off') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'off') ; end
    set(handles.sl_lfp, 'Enable', 'on') ;
    set(handles.pb_play, 'Enable', 'on') ;
    set(handles.rb_pref, 'Value', 0) ;
    set(handles.rb_lfp, 'Value', 1) ;

    idx = str2double(get(gco, 'Tag')) ;
    if ~isnan(idx), handles.idx = idx ; end
    
    zone = handles.zone ;
    point = zone.subzones{handles.idx} ;
    if isempty(point.lfp), return ; end 
    param = point.parameters ;
    %param = getappdata(0, 'parameters') ;
    if ischar(param.lp_lfp)
        param = structfun(@(x) (str2double(x)), param, 'UniformOutput', false) ;
    end
    bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                     param.lstim,...
                                     param.after]) ;
    
    timetab = linspace(-bound(1),...
                        sum(bound) - bound(1),...
                        size(point.lfp(1, :), 2)) ;

    ticks = round(bound/SAMPLE_FREQ*1000) ;

    h = subplot(1, 1, 1, 'Parent'  , handles.pan_axe) ;
    set(h, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
           'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
           'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
           'XMinorTick', 'on',...
           'Position'  , [0.06, 0.1, 0.92, 0.86],...
           'FontSize'  , 8) ;
    xlabel(h, 'time (ms)') ;
    ylabel(h, 'amplitude (mV)') ;
    set(handles.tx_title, 'String', 'LFP evolution') ;
    set(handles.tx_title2, 'String', ['Depth: ', num2str(zone.depths(handles.idx))]) ;
    AXLIM = [-bound(1), sum(bound)-bound(1)] ;
    hold all ;
    for iCond = 1:NB_COND, plot(h, timetab, point.lfp(iCond, :), 'Tag', num2str(iCond)) ; end
    legend_txt = genvarname(repmat({'Stimulus '}, 1, NB_COND+2)) ;
    legend_txt(1) = [] ;
    legend_txt{end} = 'Mean of all conditions' ;
    lfp_mean = mean(point.lfp) ;
    plot(h, timetab, lfp_mean,...
            'r',...
            'LineStyle', '--',...
            'LineWidth', 2.2,...
            'Tag', 'mean') ;

    line([0 0], get(gca, 'YLim'),...
          'Color', 'k', 'Parent', h) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k', 'Parent', h) ;
    line(get(gca, 'XLim'), [0 0], 'Color', 'k',...
                                  'LineStyle', '--',...
                                  'LineWidth', 0.1) ;
    hold off ;

    legend(gca, legend_txt, 'FontSize', 7) ;

    handles.lfp = h ; 
    guidata(hObject, handles) ;

    hcmenu = uicontextmenu ;
    item1 = uimenu(hcmenu, 'Label', 'remove selected condition',...
                           'Callback', @removeSingleData) ;
    item2 = uimenu(hcmenu, 'Label', 'keep only selected condition',...
                           'Callback', @removeAllExceptOne) ;
    item3 = uimenu(hcmenu, 'Label', 'Show lfp evolution for selected condition',...
                           'Callback', @showAllLfp) ;

    hlines = findall(h, 'Type', 'line') ;
    for iLine = hlines'
        set(iLine, 'uicontextmenu', hcmenu) ;
    end

    % --- Display raw data
    % h = subplot(1, 1, 1, 'Parent', handles.pan_raw) ;
    % plot(h, timetab, point.lfp_raw') ;
    % set(h, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
    %        'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
    %        'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
    %        'FontSize', 7) ;
    % --- Set features of LFPs
    set(handles.tx_rl, 'String', mean(point.latencies.resp(:, 2))) ;
    set(handles.tx_bl, 'String', mean(point.latencies.bline(:, 2))) ;
    [peak, t] = max(lfp_mean, [], 2) ;
    set(handles.tx_ma, 'String', peak) ;
    set(handles.tx_ml, 'String', round(t/SAMPLE_FREQ*1000)-param.bline) ;

    data = arrayfun(@(x) (point.latencies.(char(x))(:, 2)'), fieldnames(point.latencies), 'UniformOutput', false) ;
    [peak, t] = max(point.lfp, [], 2) ;
    data = cat(1, data, {peak'}) ;
    data = cat(1, data, {(t'/SAMPLE_FREQ*1000)-param.bline}) ;
    data = num2cell(cell2mat(data)) ;
    set(handles.tb_feat, 'Data', data) ;
    % --- Display latencies
    latencyDisplay(hObject) ;
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;

function showAllLfp(hObject, eventdata)
    handles = guidata(hObject) ;
    global SET SAMPLE_FREQ SLSTEP IDX ;
    set(handles.tx_title, 'String', get(gco, 'DisplayName')) ;
    set(handles.sl_csd_scale, 'Visible', 'on') ;
    set(handles.pb_play, 'Visible', 'off') ;
    set(handles.pb_stop, 'Visible', 'off') ;
    zone = handles.zone ;
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    stim = str2double(get(gco, 'Tag')) ;
    if ~isnan(stim),
        stim = stim ;
    else
        stim = IDX ;
    end
    nb_depths = length(zone.depths) ;
    % c = floor(nb_depths/10) + 1 ;
    % r = ceil(nb_depths/c) ;
    % stim = get(gco, 'DisplayName') ;
    % stim = str2double(stim(end)) ;
    bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                     param.lstim,...
                                     param.after]) ;

    ticks = round(bound/SAMPLE_FREQ*1000) ;
    timetab = linspace(-bound(1),...
                        sum(bound) - bound(1),...
                        size(zone.subzones{1}.lfp(stim, :), 2)) ;

    h = subplot(1, 1, 1, 'Parent', handles.pan_axe) ;
    set(h, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
           'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
           'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
           'XMinorTick', 'on',...
           'Position'  , [0.1, 0.1, 0.88, 0.86],...
           'FontSize'  , 8) ;
    xlabel(h, 'time (ms)') ;
    ylabel(h, 'amplitude (mV)') ;
    set(handles.tx_title, 'String', 'LFP evolution') ;
    hold on ;
    for iDepth = 1:length(zone.depths)
        step = (1 + SLSTEP*1e-3) * iDepth ;
        lfp_mean = mean(zone.subzones{iDepth}.lfp) ;
        plot(h, timetab, lfp_mean - step,...
                'Tag', num2str(iDepth)) ;
        line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--',...
             'Parent', h) ;
    end
    step = step/iDepth ;
    set(gca, 'YTick', -step*(length(zone.depths) :-1: 1),...
             'YTickLabel', zone.depths(end :-1: 1)) ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'Parent', h) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'Parent', h) ;
    h = subplot(1, 1, 1, 'Parent', handles.pan_raw,...
                         'Title', ['Mean of all LFPs for condition ', num2str(stim)]',...
                         'XLim'      , [-bound(1), sum(bound)-bound(1)],...
                         'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
                         'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
                         'FontSize'  , 6) ;
    plot(h, timetab, zone.mean_lfp(stim, :)) ;
    line([0 0], get(h, 'YLim'),...
          'Color', 'k') ;
    line([bound(2) bound(2)], get(h, 'YLim'),...
          'Color', 'k') ;
    line(get(h, 'XLim'), [0 0], 'Color', 'k',...
                                'LineStyle', '--',...
                                'LineWidth', 0.1) ;

function lfpAllDisplay(hObject)
    global NB_COND SAMPLE_FREQ SET SLSTEP IDX ;
    handles = guidata(hObject) ;
    set(handles.pb_next     , 'Visible', 'on') ;
    set(handles.pb_prev     , 'Visible', 'on') ;
    set(handles.sl_csd_scale, 'Visible', 'on') ;
    set(handles.sl_lfp, 'Visible', 'off') ;
    set(handles.pb_play, 'Visible', 'off') ;
    set(handles.pb_stop, 'Visible', 'off') ;
    set(handles.sl_min, 'Visible', 'on') ;
    set(handles.sl_max, 'Visible', 'on') ;
    set(handles.cb_img, 'Enable', 'on') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'on') ; end
    set(handles.sl_lfp, 'Enable', 'on') ;
    set(handles.pb_play, 'Enable', 'on') ;

    zone = handles.zone ;
    
    param = getappdata(0, 'parameters') ;
    if isfield(param, 'set0') ;
        param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    end
    bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                     param.lstim,...
                                     param.after]) ;
    
    timetab = linspace(-bound(1),...
                        sum(bound) - bound(1),...
                        length(zone.subzones{1}.lfp(1, :))) ;

    ticks = round(bound/SAMPLE_FREQ*1000) ;

    h = subplot(1, 1, 1, 'Parent'    , handles.pan_axe,...
                         'XLim'      , [-bound(1), sum(bound)-bound(1)],...
                         'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
                         'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
                         'XMinorTick', 'on',...
                         'Position'  , [0.1, 0.1, 0.85, 0.8],...
                         'FontSize'  , 8) ;
    xlabel(h, 'time (ms)') ;
    ylabel(h, 'amplitude (mV)') ;
    set(handles.tx_title, 'String', 'LFP evolution') ;
    hold on ;

    if get(handles.cb_img, 'Value')
        if IDX == NB_COND + 1
            tmp = cell2mat(arrayfun(@(x) (mean(zone.subzones{x}.lfp)), 1:length(zone.depths), 'UniformOutput', false)') ;
        else
            tmp = cell2mat(arrayfun(@(x) (zone.subzones{x}.lfp(IDX, :)), 1:length(zone.depths), 'UniformOutput', false)') ;
        end
        imagesc(tmp, 'Parent', h) ;
    else
        for iDepth = 1:length(zone.depths)
            step = (1 + SLSTEP*1e-3) * iDepth ;
            if IDX == NB_COND + 1
                lfp_mean = mean(zone.subzones{iDepth}.lfp) ;
                handles_plot(iDepth) = plot(h, timetab, lfp_mean - step,...
                                    'Tag', num2str(iDepth)) ;
            else
                handles_plot(iDepth) = plot(h, timetab, zone.subzones{iDepth}.lfp(IDX, :) - step,...
                                    'Tag', num2str(iDepth)) ;
            end
            line(get(gca, 'XLim'), [-step -step],...
                 'Color', 'k',...
                 'LineStyle', '--',...
                 'Parent', h) ;
        end
    end
    if get(handles.cb_img, 'Value')
        set(gca, 'YTick', [1:length(zone.depths)],...
                 'YTickLabel', zone.depths(end :-1: 1)) ;
    else
        step = step/iDepth ;
        set(gca, 'YTick', -step*(length(zone.depths) :-1: 1),...
                 'YTickLabel', zone.depths(end :-1: 1)) ;
    end
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'Parent', h) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'Parent', h) ;
    title(['Condition ', num2str(IDX)],...
           'FontSize', 10,...
           'FontWeight', 'bold') ;
    if IDX == NB_COND+1
        title('Mean of all conditions',...
              'FontSize', 10,...
              'FontWeight', 'bold') ;
    end
    if ~get(handles.cb_img, 'Value')
        hcmenu = uicontextmenu ;
        item1 = uimenu(hcmenu, 'Label', 'Local Field Potentials (LFP)',...
                               'Callback', @lfpDisplay) ;
        item2 = uimenu(hcmenu, 'Label', 'Raster plot',...
                               'Callback', @rasterDisplay) ;
        item3 = uimenu(hcmenu, 'Label', 'Peri-Stimulus Time Histogram (PSTH)',...
                               'Callback', @psthDisplay) ;
        for iHandle = handles_plot
            set(iHandle, 'uicontextmenu', hcmenu) ;
        end
    end
    hold off ;
    guidata(hObject) ;

function lfpContinuousDisplay(hObject)
    global NB_COND SAMPLE_FREQ SET PLAY ;
    handles = guidata(hObject) ;
    zone = handles.zone ;
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    
    bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                     param.lstim,...
                                     param.after]) ;
    
    ticks = round(bound/SAMPLE_FREQ*1000) ;
    
    if get(handles.sl_lfp, 'Value') ~= 1
        set(handles.sl_lfp, 'Value', 1) ;
        vect = 1:length(zone.depths) ;
    else
        vect = 2:length(zone.depths) ;
    end
    pause(handles.speed) ;
    for iDepth = get(handles.sl_lfp, 'Value'):length(zone.depths)
        if PLAY
            h = subplot(1, 1, 1, 'Parent', handles.pan_axe) ;
            set(h, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
                   'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
                   'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
                   'XMinorTick', 'on',...
                   'Position'  , [0.06, 0.1, 0.92, 0.86],...
                   'FontSize'  , 8) ;
            xlabel('time (ms)') ;
            ylabel('amplitude (mV)') ;
            timetab = linspace(-bound(1),...
                               sum(bound) - bound(1),...
                               size(zone.subzones{iDepth}.lfp(1, :), 2)) ;
            hold all ;
            plot(h, timetab, zone.subzones{iDepth}.lfp') ;
            legend_txt = genvarname(repmat({'Stimulus '}, 1, NB_COND+1)) ;
            legend_txt(1) = [] ;
            lfp_mean = mean(zone.subzones{iDepth}.lfp) ;
            plot(h, timetab, lfp_mean,...
                    'LineStyle', 'none',...
                    'LineWidth', 2.2,...
                    'Tag', 'mean') ;

            line([0 0], get(gca, 'YLim'), 'Color', 'k',...
                                          'Parent', h) ;
            line([bound(2) bound(2)], get(gca, 'YLim'), 'Color', 'k',...
                                                        'Parent', h) ;
            line(get(gca, 'XLIm'), [0, 0], 'Color', 'k',...
                                           'LineStyle', '--',...
                                           'LineWidth', 1) ;

            legend(gca, legend_txt, 'FontSize', 7) ;
            hold off ;
            hcmenu = uicontextmenu ;
            item1 = uimenu(hcmenu, 'Label', 'remove selected data',...
                                   'Callback', @removeSingleData) ;
            item2 = uimenu(hcmenu, 'Label', 'remove all other data',...
                                   'Callback', @removeAllExceptOne) ;
            hlines = findall(h, 'Type', 'line') ;
            for iLine = hlines'
                set(iLine, 'uicontextmenu', hcmenu) ;
            end
            set(handles.tx_title, 'String', ['LFP -- depth: ', num2str(zone.depths(get(handles.sl_lfp, 'Value')))]) ;
            set(handles.tx_title2, 'String', ['Depth: ', num2str(zone.depths(handles.idx))]) ;
            % --- Display raw data
            % h2 = subplot(1, 1, 1, 'Parent', handles.pan_raw) ;
            % plot(h2, timetab, zone.subzones{iDepth}.lfp_raw') ;
            % set(h2, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
            %         'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
            %         'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
            %         'FontSize', 7) ;

            % --- Set features of LFPs
            set(handles.tx_rl, 'String', mean(zone.subzones{iDepth}.latencies.resp(:, 2))) ;
            set(handles.tx_bl, 'String', mean(zone.subzones{iDepth}.latencies.bline(:, 2))) ;
            [peak, t] = max(lfp_mean, [], 2) ;
            set(handles.tx_ma, 'String', peak) ;
            set(handles.tx_ml, 'String', round(t/SAMPLE_FREQ*1000)-param.bline) ;

            val = get(handles.sl_lfp, 'Value') ;
            if val < get(handles.sl_lfp, 'Max'), set(handles.sl_lfp, 'Value', val+1) ; end
            pause(handles.speed) ;
        else
            break ;
        end
    end
   
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;

% ----------------------------------- %
% --- LOCAL FIELD POTENTIAL (END) --- %
% ----------------------------------- %

% ------------------------------------------- %
% --- PERISTIMULUS TIME HISTOGRAM (BEGIN) --- %
% ------------------------------------------- %

function psthDisplay(hObject, eventdata)
    global NB_COND NB_TRIALS SAMPLE_FREQ SET ;
    handles = guidata(hObject) ;
    set(handles.pb_next, 'Visible', 'off') ;
    set(handles.pb_prev, 'Visible', 'off') ;
    set(handles.sl_csd_scale, 'Visible', 'off') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'off') ; end
    set(handles.sl_lfp, 'Enable', 'off') ;
    set(handles.pb_play, 'Enable', 'off') ;
    set(handles.rb_pref, 'Value', 0) ;
    set(handles.rb_psth, 'Value', 1) ;

    idx = str2double(get(gco, 'Tag')) ;
    if ~isnan(idx), handles.idx = idx ; end
    
    spikes = handles.zone.subzones{handles.idx}.spikes_raster ;
    if isempty(spikes), return ; end
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    
    timetab_psth = linspace(-20,...
                            param.lstim+20,...
                            param.lstim/10) ;
    cumul_best   = 0 ;
    cumul_all    = cell(NB_COND, 1) ;
    nrow = ceil(sqrt(NB_COND)) ;
    ncol = ceil(NB_COND/nrow) ;
    subplot(1, 1, 1, 'Parent', handles.pan_axe) ;
    for iCond = 1:NB_COND
        allstim_time = [] ;
        for iTrial = 1:NB_TRIALS
            pts_ms       = spikes{iCond, iTrial} / 1000 ;
            allstim_time = [allstim_time, squeeze(pts_ms)] ;
        end 
        pts_cumul        = hist(allstim_time, timetab_psth) ;
        if max(pts_cumul) > cumul_best, cumul_best = max(pts_cumul) ; end
        cumul_all{iCond} = pts_cumul ;

        subplot(nrow, ncol, iCond) ;
        hold on ;
        bar(timetab_psth, cumul_all{iCond}/NB_TRIALS/10) ;
        set(findobj(gca, 'Type', 'patch'), 'FaceColor', 'k', 'EdgeColor', 'k') ;
        plot(0, 0, '^g', 'MarkerSize', 5) ;
        plot(param.lstim, 0, '^r', 'MarkerSize', 5) ;
        xlim([-30, param.lstim+30]) ;
        ylim([0, (cumul_best/NB_TRIALS/10) + (cumul_best/NB_TRIALS/10/20)]) ;
        xlabel('time (ms)') ;
        ylabel('average spikes number by ms') ;
        title(['Condition ', num2str(iCond)]) ;
        hold off ;
    end
    set(handles.tx_title, 'String', 'PSTH of all CONDITIONS') ;
    set(handles.tx_title2, 'String', ['Depth: ', num2str(handles.zone.depths(handles.idx))]) ;
    % --- Tuning Curves
    spikes = handles.zone.subzones{handles.idx}.spikes_tuning ;
    spikes_mean = mean(spikes, 2) ;
    spikes_std  = std(spikes, 0, 2) ;
    h = subplot(1, 1, 1, 'Parent', handles.pan_raw) ;
    errorbar(1:NB_COND, spikes_mean, spikes_std) ;
    xlabel('Conditions') ;
    ylabel('Number of spikes') ;
    set(handles.pan_raw, 'Title', 'Tuning curve') ;

    guidata(hObject, handles) ;

% ----------------------------------------- %
% --- PERISTIMULUS TIME HISTOGRAM (END) --- %
% ----------------------------------------- %

% ---------------------- %
% --- SPIKES (BEGIN) --- %
% ---------------------- %
function spikesDisplay(hObject)
    handles = guidata(hObject) ;
    set(handles.pb_next, 'Visible', 'off') ;
    set(handles.pb_prev, 'Visible', 'off') ;
    set(handles.sl_csd_scale, 'Visible', 'off') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'off') ; end
    set(handles.sl_lfp, 'Enable', 'off') ;
    set(handles.pb_play, 'Enable', 'off') ;

    zone = handles.zone ;
    sraw = zone.subzones{handles.idx}.spikes_raw ;
    if isempty(sraw), return ; end
    smean = zone.subzones{handles.idx}.spikes_mean ;
    X = [min(sraw, [], 1), fliplr(max(sraw, [], 1))] ;
    Y = [1:size(sraw, 2), fliplr(1:size(sraw, 2))] ;
    h = subplot(1, 1, 1, 'Parent', handles.pan_axe) ;
    fill(Y, X, [190 255 250]/255, 'LineStyle', 'none') ;
    hold on ; 
    plot(smean, 'LineWidth', 2) ;
    hold off ;
    set(h, 'Units', 'normalized',...
           'Position'  , [0.06, 0.1, 0.92, 0.86],...
           'XLim', [0, size(sraw, 2)],...
           'XMinorTick', 'on',...
           'FontSize', 8) ;
    
    % --- Display raw data
    h = subplot(1, 1, 1, 'Parent', handles.pan_raw) ;
    plot(h, sraw') ;
    set(handles.pan_raw, 'Title', 'All spikes') ;
    set(handles.tx_title, 'Visible', 'on',...
                         'String', ['number of spikes detected: ', num2str(size(sraw, 1))]) ;
    set(handles.tx_title2, 'String', ['Depth: ', num2str(zone.depths(handles.idx))]) ;
    guidata(hObject, handles) ;

function rasterDisplay(hObject, eventdata)
    handles = guidata(hObject) ;
    global NB_COND NB_TRIALS SAMPLE_FREQ SET ;
    set(handles.pb_next     , 'Visible', 'off') ;
    set(handles.pb_prev     , 'Visible', 'off') ;
    set(handles.sl_csd_scale, 'Visible', 'off') ;
    set(handles.sl_lfp, 'Visible', 'off') ;
    set(handles.pb_play, 'Visible', 'off') ;
    set(handles.pb_stop, 'Visible', 'off') ;
    set(handles.sl_min, 'Visible', 'off') ;
    set(handles.sl_max, 'Visible', 'off') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'off') ; end
    set(handles.sl_lfp , 'Enable', 'off') ;
    set(handles.pb_play, 'Enable', 'off') ;
    set(handles.rb_pref, 'Value', 0) ;
    set(handles.rb_raster, 'Value', 1) ;


    idx = str2double(get(gco, 'Tag')) ;
    if ~isnan(idx), handles.idx = idx ; end
    
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    spikes = handles.zone.subzones{handles.idx}.spikes_raster ;
    if isempty(spikes), return ; end

    set(handles.tx_title, 'String', 'Spikes Raster plot') ;
    set(handles.tx_title2, 'String', ['Depth: ', num2str(handles.zone.depths(handles.idx))]) ;

    timetab_psth = linspace(-20,...
                            param.lstim+20,...
                            param.lstim/10) ;

    h = subplot(1, 1, 1, 'Parent', handles.pan_axe) ;
    h = [] ;
    set(handles.tx_title, 'String', 'Spikes Raster plot') ;
    nrow = ceil(sqrt(NB_COND)) ;
    ncol = ceil(NB_COND/nrow) ;
    for iCond = 1:NB_COND
        subplot(nrow, ncol, iCond) ;
        hold on ;
        rectangle('Position', [-20, 0, 20, NB_TRIALS],...
                  'FaceColor', [190 255 250]/255,...
                  'LineStyle', 'none') ;
        rectangle('Position', [param.lstim, 0, 20, NB_TRIALS],...
                  'FaceColor', [190 255 250]/255,...
                  'LineStyle', 'none') ;
        for iTrial = 1:NB_TRIALS
            points = spikes{iCond, iTrial} / 1000 ;
            ypos = ones(length(points), 1) * iTrial ;
            plot(points, ypos,...
                 '*b', 'MarkerSize', 2) ;
            set(gca, 'FontSize', 8) ;
        end
        %line([0 0], get(gca, 'YLim')) ;
        %line([param.lstim param.lstim], get(gca, 'YLim')) ;
        xlim([-30, param.lstim+30]) ;
        ylim([0, NB_TRIALS+1]) ;
        xlabel('time (ms)') ,
        ylabel('trial number') ;
        title(['Condition ', num2str(iCond)]) ;
        hold off
    end
    % --- Tuning Curves
    spikes = handles.zone.subzones{handles.idx}.spikes_tuning ;
    spikes_mean = mean(spikes, 2) ;
    spikes_std  = std(spikes, 0, 2) ;
    h = subplot(1, 1, 1, 'Parent', handles.pan_raw) ;
    errorbar(1:NB_COND, spikes_mean, spikes_std) ;
    xlabel('Conditions') ;
    ylabel('Number of spikes') ;
    set(handles.pan_raw, 'Title', 'Tuning curve') ;
    guidata(hObject, handles) ;

function optimalCondition(hObject)
    global NB_COND ;
    handles = guidata(hObject) ;
    %if isempty(handles.zone.subzones{handles.idx}.spikes_raw), return ; end
    set(handles.sl_lfp, 'Visible', 'off') ;
    set(handles.sl_max, 'Visible', 'off') ;
    set(handles.sl_min, 'Visible', 'off') ;
    set(handles.pb_play, 'Visible', 'off') ;
    set(handles.pb_stop, 'Visible', 'off') ;
    set(handles.sl_csd_scale, 'Visible', 'off') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'off') ; end
    zone = handles.zone ;
    nb_depths = length(zone.depths) ;
    h = subplot(1, 1, 1, 'Parent', handles.pan_axe,...
                         'XLim'      , [0, NB_COND+1],...
                         'XTick'     , 1:NB_COND,...
                         'XTickLabel', 1:NB_COND,...
                         'YLim'      , [zone.depths(1)-100, zone.depths(end)+100],...
                         'YTick'     , zone.depths,...
                         'YTickLabel', zone.depths,...
                         'YDir'      , 'Reverse',...
                         'FontSize'  , 8,...
                         'Position'  , [0.08, 0.06, 0.86, 0.90]) ;
    [a, b] = max(zone.spikes_all) ;
    [c, d] = min(zone.spikes_all) ;
    hold on ;
    nb_spikes = [] ;
    for iDepth = 1:nb_depths
        line([b(iDepth) d(iDepth)], [zone.depths(iDepth) zone.depths(iDepth)],...
             'Color', 'k') ;
        handles_plot(iDepth) = plot(h, b(iDepth), zone.depths(iDepth),...
                                    'r.',...
                                    'MarkerSize', (a(iDepth)*70/max(a))+10,...
                                    'Tag', num2str(iDepth)) ;
        handles_plot2(iDepth) = plot(h, d(iDepth), zone.depths(iDepth),...
                                    'c.',...
                                    'MarkerSize', (c(iDepth)*70/max(a))+10,...
                                    'Tag', num2str(iDepth)) ;
        nb_spikes = [nb_spikes, size(zone.subzones{iDepth}.spikes_raw, 1)] ;
    end
    for iDepth = 1:nb_depths
        if a(iDepth) == c(iDepth)
            text(b(iDepth), zone.depths(iDepth)+nb_depths,...
                 ['\fontsize{8} \color[rgb]{0 0.2 0.6} \bf min & max = ', num2str(a(iDepth))]) ;
        else
            percent_max = num2str(a(iDepth)/nb_spikes(iDepth)*100) ;
            percent_min = num2str(c(iDepth)/nb_spikes(iDepth)*100) ;
            idx_max = strfind(percent_max, '.') ;
            idx_min = strfind(percent_min, '.') ;
            if ~isempty(idx_max), percent_max = percent_max(1:idx_max+1) ; end
            if ~isempty(idx_min), percent_min = percent_min(1:idx_min+1) ; end
            if strcmp(percent_max, 'NaN') | strcmp(percent_max, 'Inf'), percent_max = '0' ; end
            if strcmp(percent_min, 'NaN') | strcmp(percent_min, 'Inf'), percent_min = '0' ; end
            text(b(iDepth), zone.depths(iDepth)+nb_depths,...
                 ['\fontsize{12} \color[rgb]{0 0.2 0.6} \bf', num2str(a(iDepth)), '\fontsize{8} -- ', percent_max, '%']) ;
            text(d(iDepth), zone.depths(iDepth)+nb_depths,...
                 ['\fontsize{10} \color[rgb]{1 0.2 0.2} \bf', num2str(c(iDepth)), '\fontsize{8} -- ', percent_min, '%']) ;
        end
    end

    set(handles.tx_title, 'String', 'Optimal Condition, based on count of spikes') ;
    xlabel('Condition') ;
    ylabel('Depth') ;
    grid on ; 
    hold off ;

    hcmenu = uicontextmenu ;
    item1 = uimenu(hcmenu, 'Label', 'Local Field Potentials (LFP)',...
                           'Callback', @lfpDisplay) ;
    item2 = uimenu(hcmenu, 'Label', 'Raster plot',...
                           'Callback', @rasterDisplay) ;
    item3 = uimenu(hcmenu, 'Label', 'Peri-Stimulus Time Histogram (PSTH)',...
                           'Callback', @psthDisplay) ;
    for iHandle = 1:length(handles_plot)
        set(handles_plot(iHandle), 'uicontextmenu', hcmenu) ;
        set(handles_plot2(iHandle), 'uicontextmenu', hcmenu) ;
    end

    h = subplot(1, 1, 1, 'Parent', handles.pan_raw,...
                         'Title', 'Number of spikes by depth') ;
    plot(h, nb_spikes, zone.depths) ;

    guidata(hObject, handles) ;

% -------------------- %
% --- SPIKES (END) --- %
% -------------------- %

% -------------------------------------- %
% --- CURRENT SOURCE DENSITY (BEGIN) --- %
% -------------------------------------- %

function csdDisplay(hObject)
    handles = guidata(hObject) ;
    global NB_COND SAMPLE_FREQ SET IDX UNITS SLSTEP AXLIM ;
    set(handles.cb_zoom     , 'Enable' , 'on') ;
    set(handles.pb_next     , 'Visible', 'on') ;
    set(handles.pb_prev     , 'Visible', 'on') ;
    set(handles.sl_csd_scale, 'Visible', 'on') ;
    set(handles.sl_lfp      , 'Visible', 'off') ;
    set(handles.pb_play     , 'Visible', 'off') ;
    set(handles.sl_min, 'Visible', 'on') ;
    set(handles.sl_max, 'Visible', 'on') ;
    set(handles.cb_img, 'Enable', 'on') ;
    for iText = 37:42,  set(handles.(['text', num2str(iText)]), 'Visible', 'on') ; end
    zone = handles.zone ;
    if isempty(zone.csd), return ; end
    param = getappdata(0, 'parameters') ;
    if isfield(param, 'set0')
        param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    end
    
    bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                     param.lstim,...
                                     param.after]) ;
    timetab = linspace(-bound(1),...
                        sum(bound) - bound(1),...
                        size(zone.csd{1}(1, :), 2)) ;
    ticks = round(bound/SAMPLE_FREQ*1000) ;
    h = subplot(1, 1, 1, 'Parent', handles.pan_axe,...
                         'Units', 'normalized',...
                         'Position', [0.1, 0.1, 0.85, 0.8],...
                         'Tag', 'csd') ;
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
            plot(timetab, sink-step, 'r', 'LineWidth', 3) ;
            plot(timetab, source-step, 'b', 'LineWidth', 3) ;
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
    AXLIM = [-bound(1), sum(bound)-bound(1)] ;
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
    if IDX == NB_COND+1, title('Mean of all conditions',...
                               'FontSize', 10,...
                               'FontWeight', 'bold') ; end
    set(handles.tx_title, 'String', 'Current Source Density') ;
    set(handles.tx_title2, 'String', ['Depth: ', num2str(zone.depths(handles.idx))]) ;
    % --- Avrec 
    if ~isempty(zone.avrec{1})
        subplot(1, 1, 1, 'Parent', handles.pan_raw) ;
        idx = IDX ;
        if idx == NB_COND+1
            plot(timetab, mean(zone.avrec{1}, 1)) ;
        else
            plot(timetab, zone.avrec{idx, :}) ;
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
        set(handles.pan_raw, 'Title', ['AVREC of condition ', num2str(idx)]) ;
        if idx == NB_COND+1, set(handles.pan_raw, 'Title', 'AVREC of all conditions') ; end
    end
    guidata(hObject, handles) ;

% ------------------------------------ %
% --- CURRENT SOURCE DENSITY (END) --- %
% ------------------------------------ %

% ----------------------------- %
% --- MISCELLANEOUS (BEGIN) --- %
% ----------------------------- %

function removeSingleData(hObject, eventdata)
    handles = guidata(hObject) ;

    if gco == findall(handles.pan_axe, 'Tag', 'mean')
        set(handles.cb_mean, 'String', 'Display Mean of ALL conditions',...
                             'Value', 0) ;
    end
    set(gco, 'LineStyle', 'none',...
             'Marker'   , 'none') ;

    guidata(hObject, handles) ;


function removeAllExceptOne(hObject, eventdata)
    handles = guidata(hObject) ;
    hlines = findall(handles.pan_axe, 'Type', 'line') ;
    for iLine = hlines'
        if iLine ~= gco
            set(iLine, 'LineStyle', 'none',...
                       'Marker'   , 'none') ;
        end
    end
    guidata(hObject, handles) ;

% --- Make all data visible
function pb_visible_Callback(hObject, eventdata, handles)
    for iLine = findall(handles.pan_axe, 'Type', 'line')' ;
        set(iLine, 'LineStyle', '-') ;
    end
    set(findall(handles.pan_axe, 'Tag', 'mean'), 'LineStyle', '--') ;
    set(handles.cb_mean, 'String', 'Display Mean of ALL conditions',...
                         'Value', 0) ;
    guidata(hObject, handles) ;
    
% --- Display mean of all CONDITIONS
function cb_mean_Callback(hObject, eventdata, handles)
    hline = findall(handles.pan_axe, 'Tag', 'mean') ;
    if get(handles.cb_mean, 'Value')
        set(handles.cb_mean, 'String', 'Remove Mean of ALL conditions') ;
        set(hline, 'LineStyle', '--') ;
    else
        set(handles.cb_mean, 'String', 'Display Mean of ALL conditions') ;
        set(hline, 'LineStyle', 'none') ;
    end
    guidata(hObject, handles) ;

% --------------------------- %
% --- MISCELLANEOUS (END) --- %
% --------------------------- %

function acrossZonesDisplay(hObject, eventdata, handles)
    zones       = getappdata(0, 'zones') ;
    CONDITIONS  = get(handles.lb_cond, 'Value') ;
    nb_depths   = str2num(get(handles.ed_depths_incr, 'String')) ;
    parameters  = handles.param ; 
    fnames      = fieldnames(zones) ;
    data        = cell(nb_depths, length(fnames)) ;
    data_length = [] ;

    for iZone = 1:length(fnames)
        zone_tmp = getappdata(0, fnames{iZone}) ;
        for iDepth = 1:nb_depths
            data{iDepth, iZone} = zone_tmp.subzones{iDepth}.data.lfp(CONDITIONS, :) ;
            data_length = [data_length, size(data{iDepth, iZone}, 2)] ;
        end
    end
    pos = find(data_length == min(data_length), 1, 'first') ;
    min_size = data_length(pos) ;
    for iData = 1:size(data, 1)
        data{iData} = data{iData}(:, 1:min_size) ;
    end

    timetab = linspace(0,...
                        bound(2) + bound(1),...
                        min_size) ;

    h = subplot(1, 1, 1, 'Parent', handles.pan_axe) ;
    index = 1 ;
    for iZone = 1:size(data, 2)
        for iDepth = 1:size(data, 1)
            subplot(size(data, 1), size(data, 2), index) ;
            plot(timetab, data{iDepth, iZone}) ;
            index = index + 1 ;
        end
    end
    guidata(hObject, handles) ;

function ed_depths_incr_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ed_depths_incr_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pb_incr_m.
function pb_incr_m_Callback(hObject, eventdata, handles)
    value = str2num(get(handles.ed_depths_incr, 'String')) ;
    if value >= 2
        set(handles.ed_depths_incr, 'String', num2str(value-1)) ;
    else
        warndlg('You have to compare 1 depth', 'TOO LOW') ;
        return ;
    end
    guidata(hObject, handles) ;

% --- Executes on button press in pb_incr_p.
function pb_incr_p_Callback(hObject, eventdata, handles)
    value = str2num(get(handles.ed_depths_incr, 'String')) ;
    set(handles.ed_depths_incr, 'String', num2str(value+1)) ;
    guidata(hObject, handles) ;


% --- Listbox of the different CONDITIONS
function lb_cond_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;

function lb_cond_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Compare all zones
function pb_compare_Callback(hObject, eventdata, handles)
    answer = modaldlg('Title', 'COMPARE',...
                             'String', 'Compare selected Data?') ;
    switch answer
    case {'No'}
        return ;
    case 'Yes'
        acrossZonesDisplay(hObject, eventdata, handles) ;
    end

% --- Executes during object creation, after setting all properties.
function ax_raw_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in cb_zoom.
function cb_zoom_Callback(hObject, eventdata, handles)
    if get(handles.cb_zoom, 'Value')
        zoom(handles.ax_plot, 'on') ;
    else
        zoom(handles.ax_plot, 'off') ;
    end


% --- Executes on button press in cb_lat.
function cb_lat_Callback(hObject, eventdata, handles)
    if get(handles.cb_lat, 'Value') ;
        set(handles.cb_lat, 'String', 'Remove average latency') ;
        latencyDisplay(hObject) ;
        handles = guidata(hObject) ;
    else
        set(handles.cb_lat, 'String', 'Display average latency') ;
        hlat = findall(get(handles.pan_axe, 'Children'), 'Tag', 'lat') ;
        set(hlat, 'Visible', 'off') ;
    end
    guidata(hObject, handles) ;

function latencyDisplay(hObject)
    global SAMPLE_FREQ UNITS SET ;
    handles = guidata(hObject) ;
    param = getappdata(0, 'parameters') ;
    if isfield(param, 'set0') 
        param = param.(SET) ;
    end
    lstim = str2double(param.lstim) ;
    hold(handles.lfp, 'on') ;
    latencies = handles.zone.subzones{handles.idx}.latencies.resp ;
    lat = mean(latencies(:, 1)) - round(0.001*SAMPLE_FREQ*100) ;
    handles.lat = line([lat lat], get(handles.lfp, 'YLim'),...
                       'Parent', handles.lfp,...
                       'Tag', 'lat') ;
    guidata(hObject, handles) ;


% --- Executes on button press in pb_choose.
function pb_choose_Callback(hObject, eventdata, handles)
    chooseSetOfParameters ;

% --- Executes on slider movement.
function sl_lfp_Callback(hObject, eventdata, handles)
    global UNITS ; 
    handles.idx = round(get(hObject, 'Value')) ;
    set(hObject, 'Value', handles.idx) ;
    name = get(handles.displayResults, 'name') ;
    tmp = strfind(name, 'h:') + 3 ;
    name = strrep(name, name(tmp:end), [num2str(handles.zone.depths(handles.idx)), UNITS.dim]) ;
    set(handles.displayResults, 'Name', name) ;
    lfpDisplay(hObject) ;
    guidata(hObject, handles) ;
function sl_lfp_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

% --- Executes on button press in cb_2.
function cb_2_Callback(hObject, eventdata, handles)
    handles.speed = 2 ;
    set(handles.cb_1     , 'Value', 0) ;
    set(handles.cb_05    , 'Value', 0) ;
    set(handles.cb_01    , 'Value', 0) ;
    set(handles.cb_custom, 'Value', 0) ;
    set(handles.ed_custom, 'Enable', 'off',...
                           'String', 'sec') ;
    guidata(hObject, handles) ;

% --- Executes on button press in cb_1.
function cb_1_Callback(hObject, eventdata, handles)
    handles.speed = 1 ;
    set(handles.cb_2     , 'Value', 0) ;
    set(handles.cb_05    , 'Value', 0) ;
    set(handles.cb_01    , 'Value', 0) ;
    set(handles.cb_custom, 'Value', 0) ;
    set(handles.ed_custom, 'Enable', 'off',...
                           'String', 'sec') ;
    guidata(hObject, handles) ;

% --- Executes on button press in cb_05.
function cb_05_Callback(hObject, eventdata, handles)
    handles.speed = 0.5 ;
    set(handles.cb_2     , 'Value', 0) ;
    set(handles.cb_1     , 'Value', 0) ;
    set(handles.cb_01    , 'Value', 0) ;
    set(handles.cb_custom, 'Value', 0) ;
    set(handles.ed_custom, 'Enable', 'off',...
                           'String', 'sec') ;
    guidata(hObject, handles) ;

% --- Executes on button press in cb_01.
function cb_01_Callback(hObject, eventdata, handles)
    handles.speed = 0.1 ;
    set(handles.cb_2     , 'Value', 0) ;
    set(handles.cb_1     , 'Value', 0) ;
    set(handles.cb_05    , 'Value', 0) ;
    set(handles.cb_custom, 'Value', 0) ;
    set(handles.ed_custom, 'Enable', 'off',...
                           'String', 'sec') ;
    guidata(hObject, handles) ;

% --- Executes on button press in cb_custom.
function cb_custom_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.cb_2     , 'Value', 0) ;
        set(handles.cb_1     , 'Value', 0) ;
        set(handles.cb_05    , 'Value', 0) ;
        set(handles.cb_01    , 'Value', 0) ;
        set(handles.ed_custom, 'Enable', 'on',...
                               'String', '') ;
    else
        set(handles.ed_custom, 'Enable', 'off',...
                               'String', 'sec') ;
    end
    guidata(hObject, handles) ; 

function ed_custom_Callback(hObject, eventdata, handles)
    handles.speed = str2double(get(handles.ed_custom, 'String')) ;
    guidata(hObject, handles)
function ed_custom_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Display the whole depth LFPs
function pb_play_Callback(hObject, eventdata, handles)
    set(handles.pb_stop, 'Enable', 'on') ;
    %set(handles.displayResults, 'Color', [60 60 60]/255) ;
    global PLAY ;
    PLAY = true ;
    lfpContinuousDisplay(hObject) ;
    guidata(hObject, handles) ;

% --- Executes on button press in pb_stop.
function pb_stop_Callback(hObject, eventdata, handles)
    global PLAY ;
    PLAY = false ;
    guidata(hObject, handles) ;

% --- Executes during object creation, after setting all properties.
function tx_rl_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tx_bl_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tx_ma_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tx_ml_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in pb_next.
function pb_next_Callback(hObject, eventdata, handles)
    global NB_COND IDX ;
    if IDX == NB_COND+1, IDX = 0 ; end
    IDX = IDX + 1 ;
    if get(handles.rb_lfp_all, 'Value')
        lfpAllDisplay(hObject) ;
    elseif get(handles.rb_csd, 'Value')
        csdDisplay(hObject) ;
    end
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;

% --- Executes on button press in pb_prev.
function pb_prev_Callback(hObject, eventdata, handles)
    global NB_COND IDX ;
    if IDX == 1, IDX = NB_COND+2 ; end
    IDX = IDX - 1 ;
    if get(handles.rb_lfp_all, 'Value')
        lfpAllDisplay(hObject) ;
    elseif get(handles.rb_csd, 'Value')
        csdDisplay(hObject) ;
    end
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;


% --- Executes on button press in rb_lfp_all.
function rb_lfp_all_Callback(hObject, eventdata, handles)
    lfpAllDisplay(hObject) ;
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;

% --- Executes on button press in cb_img.
function cb_img_Callback(hObject, eventdata, handles)
    if get(handles.rb_lfp_all, 'Value')
        lfpAllDisplay(hObject) ;
    elseif get(handles.rb_csd, 'Value')
        csdDisplay(hObject) ;
    end 
    guidata(hObject) ;

% ----------------------- %
% --- SLIDERS (BEGIN) --- %
% ----------------------- %

% Main slider 
function sl_csd_scale_Callback(hObject, eventdata, handles)
    global SLSTEP ;
    SLSTEP = get(hObject, 'Value') ;
    if get(handles.rb_lfp_all, 'Value')
        lfpAllDisplay(hObject) ;
    elseif get(handles.rb_csd, 'Value')
        csdDisplay(hObject) ;
    end
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;
function sl_csd_scale_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]) ;
    end

% --- Baseline cropping
function sl_min_Callback(hObject, eventdata, handles)
    global SLSTEP_MIN SLSTEP_MAX AXLIM ;
    SLSTEP_MIN = get(hObject, 'Value') ;
    ax = findall(get(handles.pan_axe, 'Children'), 'Type', 'axe') ;
    if get(handles.rb_lfp, 'Value') | get(handles.rb_lfp_all, 'Value') | get(handles.rb_csd, 'Value')
        if length(ax) > 1
            set(ax(2), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
            set(get(handles.pan_raw, 'Children'), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
        else
            set(ax(1), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
            set(get(handles.pan_raw, 'Children'), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
        end
    end
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;
function sl_min_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]) ;
    end

% --- After stimulus cropping
function sl_max_Callback(hObject, eventdata, handles)
    global SLSTEP_MAX SLSTEP_MIN AXLIM ;
    SLSTEP_MAX = get(hObject, 'Value') ;
    ax = findall(get(handles.pan_axe, 'Children'), 'Type', 'axe') ;
    if get(handles.rb_lfp, 'Value') | get(handles.rb_lfp_all, 'Value') | get(handles.rb_csd, 'Value')
        if length(ax) > 1
            set(ax(2), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
            set(get(handles.pan_raw, 'Children'), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
        else
            set(ax(1), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
            set(get(handles.pan_raw, 'Children'), 'XLim', AXLIM.*[SLSTEP_MIN SLSTEP_MAX]) ;
        end
    end
    handles = guidata(hObject) ;
    guidata(hObject, handles) ;
function sl_max_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]) ;
    end

% --------------------- %
% --- SLIDERS (END) --- %
% --------------------- %

% ----------------- %
% --- CLOSE (BEGIN) %
% ----------------- %

% --- Close button
function pb_close_Callback(hObject, eventdata, handles)
    answer = modaldlg('Title', 'QUIT',...
                             'String', 'Confirm Close?') ;
    switch answer
    case{'No'}
        % take no action
    case 'Yes'
        clear global IDX ;
        delete(handles.displayResults) ;
    end
    
% --- Cross or alt-f4 close
function displayResults_CloseRequestFcn(hObject, eventdata, handles)
    answer = modaldlg('Title', 'QUIT',...
                             'String', 'Confirm Close?') ;
    switch answer
    case{'No'}
        % take no action
    case 'Yes'
        clear global IDX ;
        delete(handles.displayResults)
    end

% --------------- %
% --- CLOSE (END) %
% --------------- %

% ----------------- %
% --- GUI (END) --- %
% ----------------- %
