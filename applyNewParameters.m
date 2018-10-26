function applyNewParameters
	global SET NB_ZONES ;

	param = getappdata(0, 'parameters') ;
	param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
	znames = getappdata(0, 'znames') ;
	for iZone = 1:NB_ZONES
		zone = getappdata(0, znames{iZone}) ;
		for iDepth = 1:length(zone.depths)
			% DEFINE DATA_FOLDER
			[data, spikes] = nlxRecProc(data_folder) ;
			lfp = reshape(cell2mat(filterLfp(data, {param.lp_lfp, 4, 'low'}, 'cheby2')), size(data, 2), size(data, 1))' ;
			zone.subzones{iDepth}.lfp_raw = data ; 
			zone.subzones{iDepth}.lfp = lfp ;
			zone.subzones{iDepth}.parameters = param ;
			zone.subzones{iDepth}.spikes_raw = spikes.raw ;
			zone.subzones{iDepth}.spikes_mean = spikes.mean ;
			zone.subzones{iDepth}.spikes_raster = spikes.raster ;
			zone.subzones{iDepth}.spikes_tuning = spikes.tuning ;
			zone.subzones{iDepth}.lfp_mean = mean(zone.subzones{iDepth}.lfp) ;
			zone.subzones{iDepth}.latencies = cat(2, zone.subzones{iDepth}.latencies, lfpLatencies(lfp)) ;
			if iDepth == 3
				zone.csd = csdAnalysis(zone) ;
			elseif iDepth > 3
				[zone.csd, zone.avrec] = csdAnalysis(zone) ;
			end
		end
		if iDepth > 1, zone.mean_lfp = meanLfp(zone) ; end
		setappdata(0, znames{iZone}, zone) ;
	end
	