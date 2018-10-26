function createConfigFile
	global SET NB_COND NB_TRIALS NEUR_FOLDER ZONES ;

	spec = getappdata(0, 'spec_struct') ;

	for iZone = 1:length(spec)
		zone = getappdata(0, ['zone', num2str(iZone)]) ;
		spec(iZone).name = [getappdata(0, 'exp_name'), [' // p', num2str(iZone)]] ;
		spec.coordinates = zone.coordinates ;
		spec.depths = zone.depths ;
		spec.parameters = zone.subzones{1}.parameters ;
		spec.stim = [NB_COND, NB_TRIALS, 900, 100] ;
		spec.coagulations = zone.coagulations ;
		spec.folder = zone.output ;
	end
	tmp = find(NEUR_FOLDER == '\', 1, 'last') ;
	save(fullfile(NEUR_FOLDER(1:tmp-1), 'spec'), 'spec') ;