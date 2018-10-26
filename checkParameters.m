function checkParameters(hObject)
	global NB_COND NB_TRIALS NEUR_FOLDER CONDITIONS DIMENSIONS UNITS OUTPUT SET ;
	handles = guidata(hObject) ;

	NB_COND       = str2double(get(handles.ed_nb_cond,   'String')) ; % number of stimuli
	NB_TRIALS     = str2double(get(handles.ed_nb_trials, 'String')) ; % number of trials
	% --- Neuralynx folder
	NEUR_FOLDER   = get(handles.tx_neur_folder, 'String') ;
	% --- Set of parameters
	SET 		  = 'set0' ;

	exp_name = get(handles.ed_name, 'String') ;

	% --- Dimensions
	%DIMENSIONS.lr = str2double(get(handles.ed_lr, 'String')) ; % left-rigth
	%DIMENSIONS.dv = str2double(get(handles.ed_dv, 'String')) ; % dorsoventral
	% if get(handles.cb_ap, 'Value')
	% 	DIMENSIONS.ap = str2double(get(handles.ed_ap, 'String')) ; % anteroposterior 0
	% else
	% 	DIMENSIONS.ap = 0 ;
	% end
	% if get(handles.cb_inter, 'Value')
	% 	DIMENSIONS.inter = str2double(get(handles.ed_inter, 'String')) ; % interhemispheric fissure
	% else
	% 	DIMENSIONS.inter = 0 ;
	% end
	% --- Units, time
	switch get(findall(get(handles.pan_units_time, 'Children'), 'Value', 1), 'Tag')
	case 'rb_msec'
		UNITS.time = 'msec' ;
	case 'rb_sec'
		UNITS.time = 'sec' ;
	case 'rb_misec'
		UNITS.time = 'misec' ;
	end
	% --- Units, dimensions
	switch get(findall(get(handles.pan_units_dim, 'Children'), 'Value', 1), 'Tag')
	case 'rb_mi'
		UNITS.dim = 'mi' ;
	case 'rb_mm'
		UNITS.dim = 'mm' ;
	case 'rb_cm'
		UNITS.dim = 'cm' ;
	end
	% --- Output folder
    OUTPUT = createFolder ; 
    % --- Stimulus names
    CONDITIONS = get(handles.tx_kind, 'String') ;
    if isempty(CONDITIONS)
        CONDITIONS = cell(0) ;
        for iCond = 1:NB_COND
            CONDITIONS = cat(2, CONDITIONS, {['Stimulus ', num2str(iCond)]}) ;
        end
    end

	% --- Analysis parameters
	parameters.lp_lfp = get(handles.ed_lp_lfp, 'String') ; % low-pass threshold for LFP
	parameters.lp_sp  = get(handles.ed_lp_sp,  'String') ; % low-pass threshold for spikes
	parameters.hp_lfp = get(handles.ed_hp_lfp, 'String') ; % high-pass threshold for LFP
	parameters.hp_sp  = get(handles.ed_hp_sp,  'String') ; % high-pass threshold for spikes
	parameters.sp_thr = get(handles.ed_sp_thr, 'String') ; % spike threshold (std)
	parameters.lstim  = get(handles.ed_lstim,  'String') ; % length of stimulus
	parameters.bline  = get(handles.ed_bline,  'String') ; % length of baseline
	parameters.after  = get(handles.ed_after,  'String') ; % length of post-stimulus

	avrec  = get(handles.cb_avrec, 'Value') ; % average rectified CSD

	% limits.min = str2double(get(handles.ed_min_depth, 'String')) ; % depth min display
	% limits.max = str2double(get(handles.ed_max_depth, 'String')) ; % depth max display

    tmp = getappdata(0, 'parameters') ;
    tmp.set0 = parameters ;
    images = cell(0) ;
    if get(handles.cb_img1, 'Value') && ~isempty(get(handles.tx_img1, 'String'))
        images = cat(1, images, get(handles.tx_img1, 'String')) ;
    end
    if get(handles.cb_img2, 'Value') && ~isempty(get(handles.tx_img2, 'String'))
        images = cat(1, images, get(handles.tx_img2, 'String')) ;
    end
    if get(handles.cb_img3, 'Value') && ~isempty(get(handles.tx_img3, 'String'))
        images = cat(1, images, get(handles.tx_img3, 'String')) ;
    end
   	setappdata(0, 'images', images) ;
	setappdata(0, 'parameters' , tmp) ;
	%setappdata(0, 'limits'	, limits) ;
	setappdata(0, 'exp_name', exp_name) ;
	if isappdata(0, 'user_name')
		createProfile ;
	end

	% --- Create new 'olcav' results folder
	function path_name = createFolder
		path_name = get(handles.tx_results_folder, 'String') ;
		if isempty(path_name)
			if ispc, path_name = 'C:\' ; end
			if isunix, path_name = '~/' ; end
		end
		dat = int2str(clock) ;
		path_name = fullfile(path_name, ['OlcavExp_', dat(15:16), '-', dat(10), '-', dat(3:4)]) ;
		idx = 0 ;
		while exist(path_name, 'dir') == 7
			idx = idx + 1 ;
			pos = find((path_name == '('), 1, 'last') ;
			if isempty(pos)
				path_name = [path_name, '(', num2str(idx), ')'] ;
			else
				path_name = [path_name(1:pos), num2str(idx), ')'] ;
			end
		end
		mkdir(path_name) ;
	end
	
	function createProfile
		content.parameters 			 = parameters ;
		content.parameters.nb_cond   = num2str(NB_COND) ;
		content.parameters.nb_trials = num2str(NB_TRIALS) ;
		content.units 				 = UNITS ;
		% content.dimensions 			 = DIMENSIONS ;
		% content.limits 				 = limits ;
		content.folders.output 		 = '' ;
		content.folders.neuralynx 	 = NEUR_FOLDER ;
		profile_path = fullfile(getappdata(0, 'olca_path'), 'profiles', [getappdata(0, 'user_name'), '_OlcavProf']) ;
		save(profile_path, 'content') ;
	end

end 

% ------------------- %
% --- END OF FILE --- %
% ------------------- %