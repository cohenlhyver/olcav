function writeLog(datatype)
	global OUTPUT ZONES NB_ZONES ;
	
	olcav_log = getappdata(0, 'olcav_log') ;
	if isempty(olcav_log)
		olcav_log.depths = [] ;
		olcav_log.coordinates = [] ;
		olcav_log.notes = [] ;
	end
	notes = getappdata(0, 'notes') ;
	if isempty(notes), notes = [] ; end 

	switch find(strcmp(datatype, types))
	case 1
		olcav_log.depths = ZONES
	case 2
		olcav_log.zones = ZONES
	case 3
		olcav_log.notes = notes ;
	case 4
		olcav_log.depths = ZONES
		olcav_log.coordinates = ZONES.(['zone', num2str(NB_ZONES)]).coordinates ;
		olcav_log.notes = notes ;
	otherwise
		error('') ;
		return ;
	end

	setappdata(0, 'olcav_log', olcav_log) ;
	
	save(fullfile(OUTPUT, 'olcavLog'), 'olcav_log') ;
