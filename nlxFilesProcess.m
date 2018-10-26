function nlxFilesProcess
	global NB_COND NB_TRIALS NB_ZONES ;

    loadConfigFile ;
    spec = getappdata(0, 'spec') ;
    NB_ZONES = length(spec) ;
    for iZone = 1:length(spec)
        spec_zone = spec(iZone) ;
        depths = spec_zone.depths ;
        %parameters.set0 = structfun(@(x) (str2double(x)), spec_zone.parameters, 'UniformOutput', false) ;
        %SET = 'set0' ;
        %setappdata(0, 'parameters', parameters) ;
        parameters = spec_zone.parameters ;
        setappdata(0, 'parameters', parameters) ;
        %parameters = parameters.set0 ;
        NB_COND = spec_zone.stim(1) ;
        NB_TRIALS = spec_zone.stim(2) ;
      
        d = dir(spec_zone.folder) ;
        d = {d(3:end).name} ;
        neur_folders = d(cell2mat(cellfun(@(x) (isdir(fullfile(spec_zone.folder, x))), d, 'UniformOutput', false))) ;
        wbar_limit = length(depths)+3 ;
        h = waitbar(0, ['Creating new zone structure -- 0 % completed'], 'Name', ['Analyzing data of zone ', num2str(iZone), ' on ', num2str(length(spec))]) ;

        zone_name = ['zone', num2str(iZone)] ;
        zone = getappdata(0, 'zone_struct') ;
        zone.output = spec_zone.folder ;
        zone.coordinates = spec_zone.coordinates ;
        zone.name = spec_zone.name ;
        zone.subzones = [] ;
        % zone.spikes_all = zeros(spec_zone.stim(1)) ;
        nb_depths = length(depths) ;
        [depths, positions] = sort(depths) ;
        
        for iDepth = 1:nb_depths
            step = (iDepth + 1) / wbar_limit ;
    	    waitbar(step, h,...
                    ['Processing file ' num2str(iDepth), ' on ', num2str(nb_depths), ' files -- ', num2str(round(100*step)), ' % completed']) ;
    		depthFileProcess ;
    	end
        % --- To fix the problem of csd9, zone2, depth18.
        % if any(zone.subzones{18}.lfp(1, :) > 100)
        %     zone.subzones{18}.lfp = zone.subzones{18}.lfp./160000 ;
        %     zone.subzones{18}.lfp_mean = zone.subzones{18}.lfp_mean/160000 ;
        % end
        % --- To fix the problem of csd9, zone2, depth18.
        % zone.spikes_all = zone.spikes_all(:, 2:end) ;
        step = (iDepth+2) / wbar_limit ;
        waitbar(step, h,...
                ['Now computing Current Source Densities -- ', num2str(round(100*step)), ' % completed']) ;
        zone.csd_mean = [] ;
        n_csd = 300 ;
        pos = find(zone.depths >= zone.depths(1)+n_csd, 1, 'first') ;

        for iDepth = pos:nb_depths-(pos-1)
            beg = find(zone.depths <= zone.depths(iDepth)-n_csd, 1, 'last') ;
            fin = find(zone.depths >= zone.depths(iDepth)+n_csd, 1, 'first') ;
            data4csd.subzones = zone.subzones([beg, iDepth, fin]) ;
            setappdata(0, 'zone_tmp', zone) ;
            [csd, csd_mean] = csdAnalysis(data4csd) ;
            if isempty(zone.csd)
                zone.csd = csd ;
            else
                for iCond = 1:NB_COND
                    zone.csd{iCond} = cat(1, zone.csd{iCond}, csd{iCond}) ;
                    %zone.avrec = cat(1, zone.avrec{iCond}, avrec{iCond}) ;
                end
            end
            zone.csd_mean = cat(1, zone.csd_mean, csd_mean) ;
            zone.avrec = cellfun(@(x) (mean(abs(x))), zone.csd, 'UniformOutput', false) ;
        end

        % for iDepth = 1:nb_depths
        %     zone.mean_lfp = [zone.mean_lfp ; zone.subzones{iDepth}.lfp_mean] ;
        % end

        waitbar(100, h, 'END OF PROCESSING -- 100 % completed') ;
        setappdata(0, ['zone', num2str(iZone)], zone) ;
        pause(1) ;
        delete(h) ;
        proc_folder = getappdata(0, 'proc_folder') ;
        mkdir(proc_folder, 'Olcav_offlineProcessings') ;
        save(fullfile(proc_folder, 'Olcav_offlineProcessings', ['zone', num2str(iZone)]), 'zone') ;
    end

	    
    % ------------------------------- %
    % --- ADD A NEW DEPTH (BEGIN) --- %
    % ------------------------------- %
    function depthFileProcess

        zone.depths = cat(1, zone.depths, depths(iDepth)) ;
        
        data_folder = fullfile(spec_zone.folder, neur_folders{positions(iDepth)}) ;

        % --- Retrieve sample frequency, needed for later calculations
        global SAMPLE_FREQ HICUT GAIN ;
        d = dir(data_folder) ;
        if any(strcmp({d.name}, 'CSC1.ncs'))
            dd = dir(fullfile(data_folder, 'CSC1.ncs')) ;
            if dd.bytes == 16384
                zone.depths = zone.depths(1:end-1) ;
                return ; 
            end
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
        % --- Retrieve Neuralynx recordings
        [msg, data, spikes] = evalc('nlxRecProc(data_folder)') ;
        if strcmp(data_folder, 'C:\NR1\p1\2012-06-19_15-16-19')
            data = data/1000000 ;
        end
        zone.subzones = cat(2, zone.subzones, {getappdata(0, 'subzone_struct')}) ;
        setappdata(0, 'data', data) ;
        setappdata(0, 'parameters', parameters) ;
        if ~isempty(data)
            lfp = reshape(cell2mat(filterLfp(data, {parameters.lp_lfp, 4, 'low'}, 'cheby2')), size(data, 2), size(data, 1))' ;
            zone.subzones{end}.lfp = lfp ;
            zone.subzones{end}.lfp_mean = mean(zone.subzones{end}.lfp) ;
            zone.subzones{end}.latencies = cat(2, zone.subzones{end}.latencies, lfpLatencies(lfp)) ;
            % --- Mean of all LFP
            %if length(zone.depths) > 1, zone.mean_lfp = meanLfp(zone) ; end
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
        zone.subzones{end}.depth         = depths(iDepth) ;
        zone.subzones{end}.parameters    = parameters ;
        %zone.subzones{end}.output        = depth_folder ; 
        if ~isempty(spikes)
            zone.subzones{end}.spikes_raw    = spikes.raw ;
            zone.subzones{end}.spikes_mean   = spikes.mean ;
            zone.subzones{end}.spikes_raster = spikes.raster ;
            zone.subzones{end}.spikes_tuning = spikes.tuning ;
            if isempty(spikes.raster)
                tmp = zeros(NB_COND, 1) ;
                zone.spikes_all = cat(2, zone.spikes_all, tmp) ;
            else
                tmp = cellfun(@(x) length(x), zone.subzones{end}.spikes_raster) ;
                zone.spikes_all = cat(2, zone.spikes_all, sum(tmp')'/NB_TRIALS) ;
            end
        else
            zone.subzones{end}.spikes_raw = [] ;
            zone.subzones{end}.spikes_mean = [] ;
            zone.subzones{end}.spikes_raster = [] ;
            zone.subzones{end}.spikes_tuning = [] ;
        end

        % --- Change the ButtonDownFunction of the new depth
        %set(zone.handle, 'ButtonDownFcn', {@depthsDisplay, zone.name}) ;

        %setappdata(0, zone.name, zone) ;
        % --- Update zones structure
        %ZONES.(zone.name).depths = zone.depths ;

    end
    % ----------------------------- %
    % --- ADD A NEW DEPTH (END) --- %
    % ----------------------------- %
end





    % % --------------------------------- %
    % % --- CREATE A NEW ZONE (BEGIN) --- %
    % % --------------------------------- %
    % function zone = createZone
    %     % --- Create new zone & CSD folders
    %     %zone_name = 'zone1' ;
    %     %zone_folder = fullfile(OUTPUT, [zone_name, '(', COORDINATES, ')']) ;
    %     zone_name = ['zone', num2str(iZone)] ;
    %     % --- Update zone structure
    %     zone             = getappdata(0, 'zone_struct') ;
    %     %zone.output      = zone_folder ;
    %     zone.output = spec_zone.folder ;
    %     %zone.coordinates = COORDINATES ;
    %     zone.coordinates = spec_zone.coordinates ;
    %     %zone.name        = zone_name ;
    %     zone.name = spec_zone.name ;
    %     zone.subzones = [] ;
    %     %zone.spikes_all = zeros(NB_COND, 1) ;
    %     zone.spikes_all = zeros(spec_zone.stim(1)) ;
    %     %zone.hemisphere  = char(82 - 6*get(handles.rb_left, 'Value')) ;
    %     % --- Update zones structure
    %     ZONES.(zone_name).depths      = [] ;
    %     %ZONES.(zone_name).name        = zone_name ;
    %     ZONES.(zone_name).name = spec_zone.name ;
    %     %ZONES.(zone_name).coordinates = COORDINATES ;
    %     ZONES.(zone_name).coordinates = spec_zone.coordinates ;
    %     ZONES.(zone_name).depths      = depths(1) ;
    %     %zone.handle                   = addPoint(zone_name) ; % placed here because last coordinates are needed
    %     %ZONES.(zone_name).handle      = zone.handle ;
    %     %setappdata(0, zone_name, zone) ;
    % end
    % % ------------------------------- %
    % % --- CREATE A NEW ZONE (END) --- %
    % % ------------------------------- %
