function nlxFilesProcess
	global NEUR_FOLDER OUTPUT COORDINATES ;

    param = getappdata(0, 'parameters') ;
    if length(fieldnames(param)) > 1
    	parameters = chooseSetOfParameters ;
    else
    	param = param.set0 ;
    end
    createZone ;
	h = waitbar(0, 'Analyzing data') ;
	d = dir(NEUR_FOLDER) ;
	d =  {d(3:end).name} ;
	neur_folders = d(cell2mat(cellfun(@(x) (isdir(fullfile(NEUR_FOLDER, x))), d, 'UniformOutput', false))) ;
	for iDepth = 1:length(neur_folder)
		data_folder = fullfile(NEUR_FOLDER, neur_folders{iDepth}) ;
		depthFileProcess ;
		waitbar(iDepth / length(neur_folder)) ;
	end

    % --------------------------------- %
    % --- CREATE A NEW ZONE (BEGIN) --- %
    % --------------------------------- %
	function createZone
        % --- Create new zone & CSD folders
        zone_name = 'zone1' ;
        zone_folder = fullfile(OUTPUT, [zone_name, '(', COORDINATES, ')']) ;

        % --- Update zone structure
        zone             = getappdata(0, 'zone_struct') ;
        zone.output      = zone_folder ;
        zone.coordinates = COORDINATES ;
        zone.name        = zone_name ;
        zone.subzones = [] ;
        %zone.hemisphere  = char(82 - 6*get(handles.rb_left, 'Value')) ;
        % --- Update zones structure
        ZONES.(zone_name).depths      = [] ;
        ZONES.(zone_name).name        = zone_name ;
        ZONES.(zone_name).coordinates = COORDINATES ;
        ZONES.(zone_name).depths      = depth ;
        %zone.handle                   = addPoint(zone_name) ; % placed here because last coordinates are needed
        %ZONES.(zone_name).handle      = zone.handle ;
        setappdata(0, zone_name, zone) ;
	    end
    % ------------------------------- %
    % --- CREATE A NEW ZONE (END) --- %
    % ------------------------------- %

	    
    % ------------------------------- %
    % --- ADD A NEW DEPTH (BEGIN) --- %
    % ------------------------------- %
    function depthFileProcess

        zone = getappdata(0, znames{1}) ;
        % --- Creating new depth folder & subfolder
        depth_folder = fullfile(zone.output, depth) ;
        data_folder = last_folder ;
        mkdir(depth_folder) ;

        depth = str2double(depth) ;
        zone.depths = cat(1, zone.depths, depth) ;
        
        % --- Retrieve sample frequency, needed for later calculations
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
                hdr = Nlx2MatSpike(fullfile(data_folder, 'CSC1.ncs'), [0 0 0 0 0], 1, 1, []) ;
            elseif isunix
                hdr = Nlx2MatSpike_v3(fullfile(data_folder, 'CSC1.ncs'), [0 0 0 0 0], 1, 1, []) ;
            end
            SAMPLE_FREQ = char(hdr(13)) ;
            SAMPLE_FREQ = str2double(SAMPLE_FREQ(20:end)) ;
            HICUT       = char(hdr(29)) ;
            HICUT       = str2double(HICUT(11:end)) ;
            GAIN        = char(hdr(30)) ;
            GAIN        = str2double(GAIN(10:end)) ;
        end
        % --- Retrieve Neuralynx recordings
        [data, spikes] = nlxRecProc(data_folder) ;
        zone.subzones = cat(2, zone.subzones, {getappdata(0, 'subzone_struct')}) ;
        if ~isempty(data)
            lfp = reshape(cell2mat(filterLfp(data, {parameters.lp_lfp, 4, 'low'}, 'cheby2')), size(data, 2), size(data, 1))' ;
            zone.subzones{end}.lfp = lfp ;
            zone.subzones{end}.lfp_mean = mean(zone.subzones{end}.lfp) ;
            zone.subzones{end}.latencies = cat(2, zone.subzones{end}.latencies, lfpLatencies(lfp)) ;
            % --- Mean of all LFP
            if length(zone.depths) > 1, zone.mean_lfp = meanLfp(zone) ; end
            % --- CSD analysis, if number of explored depths is greater than 3
            if zone.depths(end)-zone.depths(1) >= 400, [zone.csd, zone.csd_mean, zone.avrec] = csdAnalysis(zone) ; end
        else
            zone.subzones{end}.lfp = [] ;
            zone.subzones{end}.lfp_mean = [] ;
            zone.subzones{end}.latencies = cat(2, zone.subzones{end}.latencies, []) ;
            zone.mean_lfp = [] ;
            zone.csd = [] ;
            zone.csd_mean = [] ;
            zone.avrec = [] ;
        end

        % --- Updating zone/subzone structure
        zone.subzones{end}.lfp_raw       = data ;
        zone.subzones{end}.depth         = depth ;
        zone.subzones{end}.parameters    = parameters ;
        zone.subzones{end}.output        = depth_folder ; 
        if ~isempty(spikes)
            zone.subzones{end}.spikes_raw    = spikes.raw ;
            zone.subzones{end}.spikes_mean   = spikes.mean ;
            zone.subzones{end}.spikes_raster = spikes.raster ;
            zone.subzones{end}.spikes_tuning = spikes.tuning ;
            % if length(zone.depths) > 1
            %     zone.mean_spikes = (zone.mean_spikes + spikes.tuning) / 2 ;
            % else
            %     zone.mean_spikes = spikes.tuning ;
            % end
        else
            zone.subzones{end}.spikes_raw = [] ;
            zone.subzones{end}.spikes_mean = [] ;
            zone.subzones{end}.spikes_raster = [] ;
            zone.subzones{end}.spikes_tuning = [] ;
        end

        % --- Change the ButtonDownFunction of the new depth
        %set(zone.handle, 'ButtonDownFcn', {@depthsDisplay, zone.name}) ;

        setappdata(0, zone.name, zone) ;
        % --- Update zones structure
        ZONES.(zone.name).depths = zone.depths ;

    end
    % ----------------------------- %
    % --- ADD A NEW DEPTH (END) --- %
    % ----------------------------- %