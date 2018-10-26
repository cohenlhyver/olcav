function varargout = recSitesInterfaceOFF(varargin)
%RECSITESINTERFACEOFF M-file for recSitesInterfaceOFF.fig
%      RECSITESINTERFACEOFF, by itself, creates a new RECSITESINTERFACEOFF or raises the existing
%      singleton*.
%
%      H = RECSITESINTERFACEOFF returns the handle to a new RECSITESINTERFACEOFF or the handle to
%      the existing singleton*.
%
%      RECSITESINTERFACEOFF('Property','Value',...) creates a new RECSITESINTERFACEOFF using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to recSitesInterfaceOFF_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      RECSITESINTERFACEOFF('CALLBACK') and RECSITESINTERFACEOFF('CALLBACK',hObject,...) call the
%      local function named CALLBACK in RECSITESINTERFACEOFF.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help recSitesInterfaceOFF

% Last Modified by GUIDE v2.5 08-Nov-2013 13:51:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @recSitesInterfaceOFF_OpeningFcn, ...
                   'gui_OutputFcn',  @recSitesInterfaceOFF_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before recSitesInterfaceOFF is made visible.
function recSitesInterfaceOFF_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.output = hObject ;
    global NB_COND NB_TRIALS OUTPUT IMGIDX COORDINATES ;
    spec = getappdata(0, 'spec') ;
    IMGIDX = 1 ;
    set(hObject, 'Name', 'Recording Sites Interface -- OLCAV - The Online LFP & CSD Analyzer and Visualizer tool -- OFFLINE VERSION',...
                 'Units', 'normalized',...
                 'Menubar', 'none') ;
    param = getappdata(0, 'parameters') ;
    if isfield(param, 'set0') 
        param = param.set0 ;
    end
        
    %depths = getappdata(0, 'depths') ;
    set(handles.tx_lp_lfp, 'String', num2str(spec(1).parameters.lp_lfp)) ;
    set(handles.tx_hp_lfp, 'String', num2str(spec(1).parameters.hp_lfp)) ;
    set(handles.tx_lp_sp, 'String', num2str(spec(1).parameters.lp_sp)) ;
    set(handles.tx_hp_sp, 'String', num2str(spec(1).parameters.hp_sp)) ;
    set(handles.tx_sp_thr, 'String', num2str(spec(1). parameters.sp_thr)) ;
    set(handles.tx_bline, 'String', num2str(spec(1).parameters.bline)) ;
    set(handles.tx_after, 'String', num2str(spec(1).parameters.after)) ;
    set(handles.tx_lstim, 'String', num2str(spec(1).parameters.lstim)) ;
    set(handles.tx_nb_cond, 'String', spec(1).stim(1)) ;
    set(handles.tx_nb_trials, 'String', spec(1).stim(2)) ;
    set(handles.tx_nb_depths, 'String', length(spec(1).depths)) ;
    exp_name = ['Experiment ID: '] ;
    if length(spec) == 1
        exp_name = [exp_name, spec.name] ;
    else
        exp_name = [exp_name, spec(1).name] ;
    end
    set(handles.tx_exp_name, 'String', exp_name)
    % for iZone = 1:length(spec)
    %     handle_name = ['tx_coord', num2str(iZone)] ;
    %     set(handles.(handle_name), 'String', spec(iZone).coordinates) ;
    % end
    brainDisplay(hObject, spec) ;
    % c = clock ;
    % h = num2str(c(4)) ;
    % m = num2str(c(5)) ;
    % if length(m) == 1, m = ['0', m] ; end
    % s = num2str(c(6)) ;
    % if strcmp(s(2), '.')
    %     s = ['0', s(1)] ;
    % else
    %     s = s(1:2) ;
    % end
    % set(handles.tx_op2, 'String', [h, ':', m, ':', s])
    % set(handles.tx_first2, 'String', '') ;
    % set(handles.tx_res2, 'String', OUTPUT) ;
    %   handles = guidata(hObject) ;
	guidata(hObject, handles) ;

% --- Outputs from this function are returned to the command line.
function varargout = recSitesInterfaceOFF_OutputFcn(hObject, eventdata, handles)
	varargout{1} = handles.output ;

% --- Documentation
function pb_doc_Callback(hObject, eventdata, handles)
    documentation ;

% --- Executes on button press in pb_notes.
function pb_notes_Callback(hObject, eventdata, handles)
    writeNotes ;
    guidata(hObject, handles) ;

% --- Display brain image
function brainDisplay(hObject, spec)
    handles = guidata(hObject) ;
    gca = handles.ax_brain ;
    %gcf = get(gca, 'Parent')
    grid on ;
    xticklabel = {'L6', 'L5', 'L4', 'L3', 'L2', 'L1', 'L0', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6'} ;
    xticklabel = [xticklabel, xticklabel(end-1 :-1: 1)] ;
    yticklabel = {'A5', 'A4', 'A3', 'A2', 'A1', 'A/P0', 'P1', 'P2', 'P3', 'P4', 'P5'} ;

    set(gca, 'GridLineStyle', '-',...
             'XminorGrid'   , 'on',...
             'XLim'         ,  [-6, 6],...
             'XTick'        , [-6:6],...
             'XTickLabel'   , xticklabel,...
             'YMinorGrid'   , 'on',...
             'YLim'         , [-5, 5],...
             'YTick'        , [-5:5],...
             'YTickLabel'   , yticklabel) ;

    line([0, 0], [-5, 5],...
         'Parent', gca,...
         'LineWidth', 1.5,...
         'Color', 'r') ;
    line([-6, 6], [0, 0],...
         'Parent', gca,...
         'LineWidth', 1.5,...
         'Color', 'g') ;
    text(-3.5, 4, ['\fontsize{30} \color{lightblue} \bf L'], 'Parent', gca) ;
    text(0, 4, ['\fontsize{30} \color{lightblue} \bf R'], 'Parent', gca) ;
    hold(gca, 'on') ; 
    for iZone = 1:length(spec)
        coord = spec(iZone).coordinates ;
        comma = find(coord == ',') ;
        c = [str2num(coord(2:comma-1)), str2num(coord(comma+2:end))] ;
        if coord(1) == 'L', c(1) = -c(1) ; end
        if coord(2) == 'A', c(2) = -c(2) ; end
        r  = 0.25 ;
        d  = r*2 ;
        px = c(1)-r ;
        py = c(2)-r ;
        h  = rectangle('Parent'   , gca,...
                       'Position' , [px py d d],...
                       'Curvature', [1, 1],...
                       'LineStyle', '--',...
                       'EdgeColor', 'b',...
                       'FaceColor', 'r') ;
        daspect([1, 1, 1]) ;
        handle = plot(gca,...
                      c(1), c(2),...
                      'bx',...
                      'LineWidth', 2,...
                      'MarkerSize', 10,...
                      'ButtonDownFcn', {@depthsDisplay, spec(iZone), iZone}) ;
        text(c(1)-2*r, c(2)+0.75, ['\fontsize{14} \color{red} \bf p', num2str(iZone)], 'Parent', gca) ;
    end
    hold(gca, 'off');
    % for iZone2 = iZone+1:4
    %     set(handles.(['ax_depths', num2str(iZone2)]), 'Visible', 'off') ;
    % end
    guidata(hObject, handles) ;


    guidata(hObject, handles) ;

% function handle = addPoint(hObject, zone_name)
%     handles = guidata(hObject) ;
%     global DIMENSIONS COORDINATES ;
%     dim = DIMENSIONS ;
%     lim = [get(handles.ax_brain, 'XLim'), get(handles.ax_brain, 'YLim')] ;
%     lim = [dim.lr/lim(2),...
%            dim.dv/lim(4)] ;
%     coord = str2num(COORDINATES) ;
%     coord(1) = coord(1) + dim.inter ;
%     coord(2) = coord(2) + dim.ap ;
%     coordinates = coord./lim ;
%     % --- Adding the new point on brain image
%     handle = plot(handles.ax_brain,...
%                   coordinates(1), coordinates(2),...
%                   'bx',...
%                   'LineWidth', 2,...
%                   'MarkerSize', 10,...
%                   'ButtonDownFcn', {@depthsDisplay, zone_name}) ;
%     circle(handles.ax_brain, coordinates, 25) ;

%     guidata(hObject, handles) ;

 function depthsDisplay(hObject, evt, spec, iZone)
    handles = guidata(hObject) ;
    spec = getappdata(0, 'spec') ;
    spec = spec(iZone) ;
    [spec.depths, depths_order] = sort(spec.depths) ;
    x_lim  = get(handles.ax_depths1, 'XLim') ;
    y_lim  = get(handles.ax_depths1, 'YLim') ;
    handle_name = 'ax_depths1' ;
    set(handles.ax_depths1, 'FontSize'  , 8,...
                           'XTick'     , [],...
                           'YTick'     , y_lim(1) :y_lim/20: y_lim(2),...
                           'YTickLabel', spec.depths(1)-100 :spec.depths(end)+100/20: spec.depths(end)+100,...
                           'YGrid'     , 'on',...
                           'YMinorGrid', 'on') ;
    handle_plot = plot(handles.(handle_name),...
                       x_lim(2)/10, spec.depths,...
                       'r.',...
                       'MarkerSize', 25,...
                       'LineWidth', 2) ;

    %hold(handles.(handle_name), 'on') ;
    digits_colors = cell(0) ;
    digits_colors{1} = '\color{black}' ;
    for iDepth = 2:length(spec.depths)-1
        if depths_order(iDepth) > depths_order(iDepth+1)
            digits_colors = [digits_colors, '\color{blue}'] ;
        else
            digits_colors = [digits_colors, '\color{green}'] ;
        end
    end
    digits_colors = [digits_colors, '\color{green}'] ;

    for iDepth = 1:length(spec.depths)
        text(3.6, spec.depths(iDepth),...
             ['\fontsize{12} ', digits_colors{iDepth}, ' \bf',num2str(depths_order(iDepth))],...
             'Parent', handles.ax_depths1)
    end
    %hold(handles.(handle_name), 'off') ;

    idx = 0 ;
    for iHandle = handle_plot'
        idx = idx + 1 ;
        set(iHandle, 'ButtonDownFcn', {@displayData, ['zone', num2str(iZone)], idx}) ;
    end
    set(handles.(handle_name),...
            'Color'     , [0.678, 0.922, 1.0],...
            'XTick'     , [],...
            'YDir'      , 'reverse',...
            'YLim'      , [spec.depths(1)-100, spec.depths(end)+100],...
            'YTick'     , spec.depths(1)-100 :100: spec.depths(end)+100,...
            'YTickLabel', spec.depths(1)-100 :100: spec.depths(end)+100,...
            'YMinorGrid', 'on') ;

    guidata(hObject, handles) ;

function circle(handle, coord, r)
    d  = r*2 ;
    px = coord(1)-r ;
    py = coord(2)-r ;
    h  = rectangle('Parent', handle,...
                   'Position', [px py d d],...
                   'Curvature',[1, 1],...
                   'LineStyle', '--',...
                   'EdgeColor', 'b') ;
    daspect([1, 1, 1]) ;

function displayData(src, evt, zone_name, idx)
    clear global IDX ;
    displayResults(zone_name, idx) ;

function lfpMeanDisplay(hObject, eventdata, handles)
    global NB_COND SAMPLE_FREQ NB_ZONES SET UNITS FROMTO ;
    zone = getappdata(0, 'zone1') ;
    param = getappdata(0, 'parameters') ;
    param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
    set(handles.tx_feat, 'Visible', 'off') ;
    if length(zone.depths) > 1
        set(handles.tx_last, 'Visible', 'off') ;
        bound = round(0.001*SAMPLE_FREQ*[param.bline,...
                                         param.lstim,...
                                         param.after]) ;
        
        timetab = linspace(-bound(1),...
                            sum(bound) - bound(1),...
                            size(zone.mean_lfp(1, :), 2)) ;
        ticks = round(bound/SAMPLE_FREQ*1000) ;
        stim_legend = cell(NB_COND, 1) ;
        h = subplot(1, 1, 1, 'Parent', handles.pan_last) ;
        set(h, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
               'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
               'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
               'Position', [0.08, 0.08, 0.80, 0.90],...
               'FontSize', 6) ;
        xlabel(h, 'time, (ms)', 'FontSize', 7) ;
        ylabel(h, 'Signal, (mV)', 'FontSize', 7) ;
        hold on ;
        plot(h, timetab, zone.mean_lfp') ;
        line([0, 0], get(h, 'YLim'), 'Color', 'k') ;
        line([bound(2), bound(2)], get(h, 'YLim'), 'Color', 'k') ;
        line(get(h, 'XLim'), [0, 0], 'Color', 'k',...
                                       'LineStyle', '--', 'LineWidth', 1) ;
        hold off ;
        if ~isappdata(0, 'stimuli_name')
            legend_txt = genvarname(repmat({'Stimulus '}, 1, NB_COND+1)) ;
            legend_txt(1) = [] ;
        else
            legend_txt = getappdata(0, 'stimuli_name') ;
        end
        legend(gca, legend_txt, 'FontSize', 7) ; 
    end

    % --- Latencies & amplitudes
    nb_depths = 1:length(zone.depths) ;
    lim = 1 :floor(nb_depths(end)/10)+1: nb_depths(end) ;
    % response
    lat = cell2mat(arrayfun(@(x) (zone.subzones{x}.latencies.resp(:, 2)),...
                            nb_depths, 'UniformOutput', false)) ; 
    lat_mean = mean(lat) ;
    lat_max  = max(lat) - lat_mean ; 
    lat_min  = lat_mean - min(lat) ;
    hlat_res = errorbar(handles.ax_lat,...
                        nb_depths, lat_mean, lat_min, lat_max,...
                        'Marker', 'x',...
                        'MarkerSize', 10,...
                        'MarkerEdgeColor', 'r') ;
    set(handles.ax_lat, 'XLim' , [0.5, nb_depths(end)+0.5],...
                        'XTick', lim,...
                        'XTickLabel', num2str(zone.depths(lim)),...
                        'YLim', [min(min(lat))-25, max(max(lat))+25]) ;
    ylabel(handles.ax_lat, 'Peak latency',...
                           'FontSize', 7) ;
    % baseline
    lat = cell2mat(arrayfun(@(x) (zone.subzones{x}.latencies.bline(:, 2)),...
                            nb_depths, 'UniformOutput', false)) ; 
    lat_mean = mean(lat) ; 
    lat_max  = max(lat) - lat_mean ; 
    lat_min  = lat_mean - min(lat) ; 
    hlat_bas = errorbar(handles.ax_lat_bas,...
                        nb_depths, lat_mean, lat_min, lat_max,...
                        'Marker', 'x',...
                        'MarkerSize', 10,...
                        'MarkerEdgeColor', 'r') ;
    set(handles.ax_lat_bas, 'XLim' , [0.5, nb_depths(end)+0.5],...
                            'XTick', lim,...
                            'XTickLabel', num2str(zone.depths(lim)),...
                            'YLim', [min(min(lat))-25, max(max(lat))+25]) ;
    % --- Amplitudes
    [amp, t] = arrayfun(@(x) (max(zone.subzones{x}.lfp, [], 2)),...
                        nb_depths, 'UniformOutput', false) ;
    amp = cell2mat(amp) ;
    amp_mean = mean(amp) ;
    amp_max  = max(amp) - amp_mean ; 
    amp_min  = amp_mean - min(amp) ;
    hamp = errorbar(handles.ax_amp,...
                    nb_depths, amp_mean, amp_min, amp_max,...
                    'Marker', 'x',...
                    'MarkerSize', 10,...
                    'MarkerEdgeColor', 'r') ;
    set(handles.ax_amp, 'XLim' , [0.5, nb_depths(end)+0.5],...
                        'XTick', lim,...
                        'XTickLabel', num2str(zone.depths(lim)),...
                        'YLim', [min(min(amp))-2, max(max(amp))+2]) ;
    ylabel(handles.ax_amp, 'Peak amplitude', 'FontSize', 7) ;
    t   = round(1000*cell2mat(t)/SAMPLE_FREQ) - param.bline ;
    t_mean = mean(t) ;
    t_max  = max(t) - t_mean ;
    t_min  = t_mean - min(t) ;
    ht = errorbar(handles.ax_amp_lat,...
                  nb_depths, t_mean, t_min, t_max,...
                  'Marker', 'x',...
                  'MarkerSize', 10,...
                  'MarkerEdgeColor', 'r') ;
    set(handles.ax_amp_lat, 'XLim' , [0.5, nb_depths(end)+0.5],...
                            'XTick', lim,...
                            'XTickLabel', num2str(zone.depths(lim)),...
                            'YLim', [min(min(t))-25, max(max(t))+25]) ;

    guidata(hObject, handles) ;


% --- Executes on button press in pb_new_param.
function pb_new_param_Callback(hObject, eventdata, handles)



% --------------------- %
% --- CLOSE (BEGIN) --- % 
% --------------------- %

% --- Close button
function pb_quit_Callback(hObject, eventdata, handles)
    user_response = modaldlg('Title', 'QUIT',...
                             'String', 'Confirm Close?') ;
    switch user_response
    case{'No'}
        % take no action
    case 'Yes'
        setappdata(0, 'QUIT', 1) ;
        delete(gcf) ;
    end

% --- Cross or alt-f4 close
function recSitesInterfaceOFF_CloseRequestFcn(hObject, eventdata, handles)
    user_response = modaldlg('Title', 'QUIT',...
                             'String', 'Confirm Close?') ;
    switch user_response
    case{'No'}
        % take no action
    case 'Yes'
        setappdata(0, 'QUIT', 1) ;
        hold(handles.ax_brain, 'off') ;
        delete(gcf)
    end
    
% ------------------- %
% --- CLOSE (END) --- % 
% ------------------- %
