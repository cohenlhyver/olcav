function checkZone(hObject)
    handles = guidata(hObject) ;

    global NEUR_FOLDER DIMENSIONS OUTPUT SET COORDINATES NEW_COORD ZONES NB_ZONES NB_COND ;
    
    znames = getappdata(0, 'znames') ;

    % --- Retrieve set of parameters
    parameters = getappdata(0, 'parameters') ;
    parameters = parameters.(SET) ;
    parameters = structfun(@(x) (str2double(x)), parameters, 'UniformOutput', false) ;
    % --- Move last Neuralynx files to the output file
    if isappdata(0, 'last_folder')
        last_folder = getappdata(0, 'last_folder') ;
    else
        folders = dir(NEUR_FOLDER) ;
        last_folder = fullfile(NEUR_FOLDER, folders(end-1).name) ;
        setappdata(0, 'last_folder', last_folder) ;
    end
    depth = get(handles.ed_next_depth, 'String') ;
    %h = waitbar(0, 'Creating new zone structure -- 0 % completed', 'Name', 'Analyzing data') ;
    % --- Create a new zone
    if NEW_COORD
        createZone ;
        NEW_COORD = false ;
    else
        zone = getappdata(0, ['zone', num2str(NB_ZONES)]) ;
        %rmappdata(0, zone.name) ;
    end
    % --- Add a new depth
    flag_hdr = [] ;
    d = dir(last_folder) ;
    nCSC = length(strmatch('CSC', {d.name})) ;
    %wbar_limit = nCSC + 3 ;
    for iCSC = 1:nCSC
        %step = (iCSC + 2) / wbar_limit ;
        % waitbar(step, h,...
        %         ['Computing ***DATA*** of site ' num2str(iCSC), ' on ', num2str(nCSC), ' -- ', num2str(round(100*step)), ' % completed']) ;
        if iCSC > 1, flag_hdr = 1 ; end
        addDepth
        pos = find(zone.depths >= zone.depths(1)+400, 1, 'last') ;
        %low = find(zone.depths <= zone.depths(iDepth)-200, 1, 'last') ;
        if ~isempty(pos)
            % waitbar(step, h,...
            %         ['Computing ***CSD*** of site ' num2str(iCSC), ' on ', num2str(nCSC), ' -- ', num2str(round(100*step)), ' % completed']) ;
            pause(0.5) ;
            beg = find(zone.depths <= zone.depths(pos)-400, 1, 'last') ;
            mid = floor(pos/2) + 1 ;
            data4csd.subzones = zone.subzones([beg, mid, pos]) ;
            [csd, csd_mean] = csdAnalysis(data4csd) ;
            if ~isempty(zone.csd)
                for iCond = 1:NB_COND
                    zone.csd{iCond} = cat(1, zone.csd{iCond}, csd{iCond}) ;
                    %zone.avrec = cat(1, zone.avrec{iCond}, avrec{iCond}) ;
                end
            else
                zone.csd = csd ;
            end
            zone.csd_mean = cat(1, zone.csd_mean, csd_mean) ;
            zone.avrec = cellfun(@(x) (mean(abs(x))), zone.csd, 'UniformOutput', false) ;
        end
        depth = num2str(depth + 50) ;
    end
    % --- Rearrange subzones 
    nb_depths = length(zone.depths) ;
    if length(zone.depths) > 1 
        % step = (nCSC + 2) / wbar_limit ;
        % waitbar(step, h,...
                % ['End of process ', num2str(round(100*step)), ' % completed']) ;
        [zone.depths, idx] = sort(zone.depths) ;
        tmp1 = cell(nb_depths, 1) ;
        tmp2 = zeros(NB_COND, nb_depths) ;
        for iDepth = 1:nb_depths
            tmp1{iDepth} = zone.subzones{idx(iDepth)} ;
            tmp2(:, iDepth) = zone.spikes_all(:, idx(iDepth)) ;
        end
        zone.subzones = tmp1 ;
        zone.spikes_all = tmp2 ;
        clear tmp1 tmp2 ;
    end
    zone.latencies = [zone.latencies ;...
                      round(mean(zone.subzones{end}.latencies.resp(:, 2))),...
                      round(mean(zone.subzones{end}.latencies.bline(:, 2)))] ;

    % waitbar(99, h,...
    %         ['Saving data & log file -- ','99% completed']) ;
    % --- Change color of previous points/crosses on brain image
    if NB_ZONES > 1
        for iZone = 1:NB_ZONES-1
            set(ZONES.(znames{iZone}).handle, 'Color', 'r') ;
        end
    end
    olcav_log.zones = ZONES ;
    setappdata(0, zone.name, zone) ;
    save(fullfile(OUTPUT, 'olcavLog'), 'olcav_log') ;
    % --- Display last results automatically
    % waitbar(100, h,...
    %         'Everything seems ok ***Enjoy your results***') ;
    % pause(1) ;
    % delete(h) ;
    if handles.disp_last == true, displayResults(znames{NB_ZONES}, length(zone.depths)) ; end
    guidata(hObject, handles) ;

    % --------------------------------- %
    % --- CREATE A NEW ZONE (BEGIN) --- %
    % --------------------------------- %
    function createZone
        NB_ZONES = NB_ZONES + 1 ;
        % --- Create new zone & CSD folders
        zone_name = znames{NB_ZONES} ;
        zone_folder = fullfile(OUTPUT, [zone_name, '(', COORDINATES, ')']) ;
        %mkdir(fullfile(zone_folder, 'CSD')) ;

        % --- Update zone structure
        zone             = getappdata(0, 'zone_struct') ;
        zone.output      = zone_folder ;
        zone.coordinates = COORDINATES ;
        zone.name        = zone_name ;
        zone.subzones = [] ;
        zone.spikes_all = zeros(NB_COND, 1) ;
        %zone.hemisphere  = char(82 - 6*get(handles.rb_left, 'Value')) ;
        % idx = find(COORDINATES{3} == 'A') ;
        % if isempty(idx), idx = find(COORDINATES{3} == 'P') ; end
        %zone.position = COORDINATES{3}(idx:end) ;
        zone.position = COORDINATES ;
        zone.csd = [] ;
        zone.csd_mean = [] ;
        zone.avrec = [] ;
        % --- Update zones structure
        ZONES.(zone_name).depths      = [] ;
        ZONES.(zone_name).name        = zone_name ;
        ZONES.(zone_name).coordinates = COORDINATES ;
        ZONES.(zone_name).depths      = depth ;
        zone.handle                   = addPoint(zone_name) ; % placed here because last coordinates are needed
        ZONES.(zone_name).handle      = zone.handle ;
        setappdata(0, zone_name, zone) ;
    end
    % ------------------------------- %
    % --- CREATE A NEW ZONE (END) --- %
    % ------------------------------- %
    
    % ------------------------------- %
    % --- ADD A NEW DEPTH (BEGIN) --- %
    % ------------------------------- %
    function addDepth
       
        if isempty(flag_hdr), zone = getappdata(0, znames{NB_ZONES}) ; end
        % --- Creating new depth folder & subfolder
        depth_folder = fullfile(zone.output, depth) ;
        data_folder = last_folder ;
        mkdir(depth_folder) ;

        depth = str2double(depth) ;
        zone.depths = cat(1, zone.depths, depth) ;
        
        % --- Retrieve sample frequency, needed for later calculations
        if isempty(flag_hdr)
            global SAMPLE_FREQ HICUT GAIN ;
            d = dir(data_folder) ;
            if any(strcmp({d.name}, 'CSC1.ncs'))
                if ispc
                    hdr = Nlx2MatCSC(fullfile(data_folder, 'CSC1.ncs'), [0 0 0 0 0], 1, 1, []) ;
                elseif isunix
                    hdr = Nlx2MatCSC_v3(fullfile(data_folder, 'CSC1.ncs'), [0 0 0 0 0], 1, 1, []) ;
                end
                SAMPLE_FREQ = char(hdr(13)) ;
                SAMPLE_FREQ = str2double(SAMPLE_FREQ(20:end)) ;
                HICUT       = char(hdr(end-2)) ;
                HICUT       = str2double(HICUT(11:end)) ;
                GAIN        = char(hdr(end-1)) ;
                if isempty(GAIN), GAIN = char(hdr(end-2)) ; end
                GAIN        = str2double(GAIN(10:end)) ;
            elseif any(strcmp({d.name}, 'SE1.nse'))
                if ispc
                    hdr = Nlx2MatSpike(fullfile(data_folder, 'SE1.nse'), [0 0 0 0 0], 1, 1, []) ;
                elseif isunix
                    hdr = Nlx2MatSpike_v3(fullfile(data_folder, 'SE1.nse'), [0 0 0 0 0], 1, 1, []) ;
                end
                SAMPLE_FREQ = char(hdr(13)) ;
                SAMPLE_FREQ = str2double(SAMPLE_FREQ(20:end)) ;
                HICUT       = char(hdr(29)) ;
                HICUT       = str2double(HICUT(11:end)) ;
                GAIN        = char(hdr(30)) ;
                GAIN        = str2double(GAIN(10:end)) ;
            end
        end
        % --- Retrieve Neuralynx recordings
        [data, spikes] = nlxRecProc(data_folder, iCSC) ;
        zone.subzones = cat(1, zone.subzones, {getappdata(0, 'subzone_struct')}) ;
        if ~isempty(data)
            lfp = reshape(cell2mat(filterLfp(data, {parameters.lp_lfp, 4, 'low'}, 'cheby2')), size(data, 2), size(data, 1))' ;
            zone.subzones{end}.lfp = lfp ;
            %zone.subzones{end}.lfp_mean = mean(zone.subzones{end}.lfp) ;
            zone.subzones{end}.latencies = cat(2, zone.subzones{end}.latencies, lfpLatencies(lfp)) ;
            % --- Mean of all LFP
            if length(zone.depths) > 1
                zone.mean_lfp = meanLfp(zone)
            elseif length(zone.depths) == 1
                zone.mean_lfp = mean(zone.subzones{1}.lfp) ;
            end
            % --- CSD analysis, if number of explored depths is greater than 3
            %if zone.depths(end)-zone.depths(1) >= 400, [zone.csd, zone.csd_mean, zone.avrec] = csdAnalysis(zone) ; end
        else
            zone.subzones{end}.lfp = [] ;
            %zone.subzones{end}.lfp_mean = [] ;
            zone.subzones{end}.latencies = cat(2, zone.subzones{end}.latencies, []) ;
            zone.mean_lfp = [] ;
            zone.csd = [] ;
            zone.csd_mean = [] ;
            zone.avrec = [] ;
        end

        % --- Updating zone/subzone structure
        %zone.subzones{end}.lfp_raw    = data ;
        zone.subzones{end}.depth      = depth ;
        zone.subzones{end}.parameters = parameters ;
        zone.subzones{end}.output     = depth_folder ; 
        if ~isempty(spikes.raster)
            zone.subzones{end}.spikes_raw    = spikes.raw ;
            zone.subzones{end}.spikes_mean   = spikes.mean ;
            zone.subzones{end}.spikes_raster = spikes.raster ;
            zone.subzones{end}.spikes_tuning = spikes.tuning ;
            zone.subzones{end}.spikes_spontaneous = spikes.spontaneous ;
            tmp = cellfun(@(x) (length(x)), spikes.raster) ;
            setappdata(0, 'z1', zone) ;
            zone.spikes_all = cat(2, zone.spikes_all, sum(tmp, 2)) ;
            zone.subzones{end}.removed_trials = spikes.pb_trials ;
        else
            zone.subzones{end}.spikes_raw = [] ;
            zone.subzones{end}.spikes_mean = [] ;
            zone.subzones{end}.spikes_raster = [] ;
            zone.subzones{end}.spikes_tuning = [] ;
            zone.subzones{end}.spikes_spontaneous = [] ;
            zone.spikes_all = cat(2, zone.spikes_all, zeros(NB_COND, 1)) ;
            zone.subzones{end}.removed_trials = [] ;
        end
        if size(zone.spikes_all, 2) > length(zone.depths)
            zone.spikes_all = zone.spikes_all(:, 2:end) ;
        end

        % --- Change the ButtonDownFunction of the new depth
        set(zone.handle, 'ButtonDownFcn', {@depthsDisplay, zone.name}) ;

        %setappdata(0, zone.name, zone) ;
        % --- Update zones structure
        ZONES.(zone.name).depths = zone.depths ;

    end
    % ----------------------------- %
    % --- ADD A NEW DEPTH (END) --- %
    % ----------------------------- %
    
    % ------------------------------- %
    % --- ADD A NEW POINT (BEGIN) --- %
    % ------------------------------- %
    function handle = addPoint(zone_name)
        % dim = DIMENSIONS ;
        % lim = [get(handles.ax_brain, 'XLim'), get(handles.ax_brain, 'YLim')] ;
        % lim = [dim.lr/lim(2),...
        %        dim.dv/lim(4)] ;
        % coord = str2num(COORDINATES) ;
        % if strcmp(zone.hemisphere, 'R')
        %     coord(1) = dim.inter - coord(1) ;
        % else
        %     coord(1) = dim.inter + coord(1) ;
        % end
        % if strcmp(zone.position(1), 'P')
        %     coord(2) = dim.ap - coord(2);
        % else
        %     coord(2) = dim.ap + coord(2) ;
        % end
        % coordinates = coord./lim ;
        % --- Adding the new point on brain image
        % circle(handles.ax_brain) ;
        comma = find(COORDINATES == ',') ;
        c = [str2num(COORDINATES(2:comma-1)), str2num(COORDINATES(comma+2:end))] ;
        if COORDINATES(1) == 'L', c(1) = -c(1) ; end
        if COORDINATES(2) == 'A', c(2) = -c(2) ; end
        r  = 0.25 ;
        d  = r*2 ;
        px = c(1)-r ;
        py = c(2)-r ;
        h  = rectangle('Parent'   , handles.ax_brain,...
                       'Position' , [px py d d],...
                       'Curvature', [1, 1],...
                       'LineStyle', '--',...
                       'EdgeColor', 'b',...
                       'FaceColor', 'r') ;
        daspect([1, 1, 1]) ;
        hold on ; 
        handle = plot(handles.ax_brain,...
                      c(1), c(2),...
                      'bx',...
                      'LineWidth', 2,...
                      'MarkerSize', 10,...
                      'ButtonDownFcn', {@depthsDisplay, zone_name}) ;
        hold off ;
        guidata(hObject, handles) ;
    end
    % ----------------------------- %
    % --- ADD A NEW POINT (END) --- %
    % ----------------------------- %
    
    % --------------------------------------- %
    % --- DISPLAY EXPLORED DEPTHS (BEGIN) --- %
    % --------------------------------------- %
    function depthsDisplay(hObject, evt, zone_name)
        handles = guidata(hObject) ;

        depths = ZONES.(zone_name).depths ;
        set(handles.tx_depths, 'String', COORDINATES) ;

        x_lim  = get(handles.ax_depths, 'XLim') ;
        y_lim  = get(handles.ax_depths, 'YLim') ;
        set(handles.ax_depths, 'FontSize'  , 8,...
                               'XTick'     , [],...
                               'YTick'     , y_lim(1) :y_lim/20: y_lim(2),...
                               'YTickLabel', 0 :2000/20: 2000,...
                               'YGrid'     , 'on',...
                               'YMinorGrid', 'on') ;

        handle_plot = plot(handles.ax_depths,...
                           x_lim(2)/2, depths,...
                           'r.',...
                           'MarkerSize', 25,...
                           'LineWidth', 2) ;
        [a, b] = sort(zone.depths) ;
        idx = 1 ;
        for iHandle = handle_plot'
            set(iHandle, 'ButtonDownFcn', {@displayData, zone.name, b(idx)}) ;
            idx = idx + 1 ;
        end
        set(handles.ax_depths,...
                'Color'     , [0.678, 0.922, 1.0],...
                'XTick'     , [],...
                'YDir'      , 'reverse',...
                'YLim'      , [handles.limits(1), handles.limits(2)],...
                'YTick'     , handles.limits(1) :100: handles.limits(2),...
                'YTickLabel', handles.limits(1) :100: handles.limits(2),...
                'YMinorGrid', 'on') ;

        % % --- Add distance information
        % dim = DIMENSIONS ;
        % lim = [get(handles.ax_brain, 'XLim'), get(handles.ax_brain, 'YLim')] ;
        % lim = [dim.lr/lim(2), dim.dv/lim(4)] ;
        % idx = str2num(zone_name(5:end)) ;
        % if NB_ZONES >= 2
        %     coord = [] ;
        %     for iZone = 1:NB_ZONES
        %         coord = [coord ; str2num(ZONES.(['zone', num2str(iZone)]).coordinates)] ;
        %         coord(iZone, 2) = coord(iZone, 2) + dim.ap ;
        %         coord(iZone, :) = coord(iZone, :) ./ lim ;
        %     end
        %     tmp = coord(idx, :) ;
        %     coord(idx, :) = coord(1, :) ;
        %     coord(1, :) = tmp ;
        %     for iCoord = 2:size(coord, 1)
        %         pt_dist = sqrt(sum(bsxfun(@minus, coord(1, 1), coord(iCoord, 2)).^2)) ;
        %         line([coord(1, 1), coord(iCoord, 1)],...
        %              [coord(1, 2), coord(iCoord, 2)],...
        %              'Color', 'k',...
        %              'LineStyle', '--',...
        %              'Parent', handles.ax_brain,...
        %              'ButtonDownFcn', {@displayDistance, pt_dist}) ;
        %     end
        % end

        guidata(hObject, handles) ;
    end


    % ------------------------------------- %
    % --- DISPLAY EXPLORED DEPTHS (END) --- %
    % ------------------------------------- %

    function displayData(src, evt, zone_name, idx)
        clear global IDX ;
        displayResults(zone_name, idx) ;
    end

    % function circle(handle)
    %     r  = 0.25 ;
    %     d  = r*2 ;
    %     px = COORDINATES(1)-r ;
    %     py = COORDINATES(2)-r ;
    %     h  = rectangle('Parent'   , handle,...
    %                    'Position' , [px py d d],...
    %                    'Curvature', [1, 1],...
    %                    'LineStyle', '--',...
    %                    'EdgeColor', 'b',...
    %                    'FaceColor', 'r') ;
    %     daspect([1, 1, 1]) ;
    % end

    function displayDistance(src, evt, d)  
        handles_u = uicontrol('Parent'  , handles.pan_brain,...
                              'Units'   , 'normalized',...
                              'Position', [0.70, 0.1, 0.10, 0.04],...
                              'Style'   , 'text',...
                              'String'  , d) ;
    end

end
