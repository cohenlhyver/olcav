function loadConfigFile
	flag = true ;
	while flag 
		data_folder = uigetdir('C:\', 'Choose a directory to be processed') ;
		if data_folder == 0
            return ;
        end
		d = dir(data_folder) ;
		%pos = find(strcmp({d.name}, 'Olcav_logs') == 1) ;
		pos = find(strcmp({d.name}, 'spec.mat') == 1) ;
		if ~isempty(pos)
			flag = false ;
		else
			waitfor(warndlg('No Olcav configuration folder found. Please try again or leave', '')) ;
		end
	end
	% config_folder = fullfile(data_folder, d(pos).name) ;
	% d = dir(config_folder) ;
	% depths_file = load(fullfile(config_folder, 'depths.mat')) ;
	% parameters = load(fullfile(config_folder, 'parameters.mat')) ;
	% coordinates = load(fullfile(config_folder, 'coordinates.mat')) ;
	% parameters = parameters.parameters ;
	setappdata(0, 'proc_folder', data_folder) ;
	spec = load(fullfile(data_folder, d(pos).name)) ;
	spec = spec.spec ;
	setappdata(0, 'spec', spec) ;
	% depths = depths_file.depths' ;
	% explored_points = length(fieldnames(depths)) ;
	% folders = cell(explored_points, 1) ;
	% for iPoint = 1:explored_points, folders{iPoint} = fullfile(data_folder, ['P', num2str(iPoint)]) ; end
	% setappdata(0, 'parameters', parameters) ;
	return