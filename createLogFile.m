function  createLogFile
	global NB_ZONES SET NB_COND NB_TRIALS NEUR_FOLDER ZONES ;

	f = fopen(fullfile(NEUR_FOLDER, 'exp_log.txt'), 'wt') ;

	last_folder = getappdata(0, 'last_folder') ;
	exp_end = last_folder(end-7:end) ;
	exp_end = [exp_end(1:2), 'h', exp_end(4:5)] ;
	%tmp = dir
	%opening_time =
	B = '2013-03-28' ;

	fprintf(f, '*** Online LFP and CSD Analysis & Visualization Tool ***\n\n') ;
	fprintf(f, '--------------------------------------------------------\n\n') ;
	fprintf(f, 'This is the log file of the experiment: %s \n\n', getappdata(0, 'exp_name')) ;
	fprintf(f, 'Beginning of the session: %s at %s\n', B, getappdata(0, 'opening_time')) ;
	fprintf(f, 'First experiment        : %s at %s\n', B, getappdata(0, 'first_experiment')) ;
	fprintf(f, 'End of the session      : %s at %s\n\n', B, exp_end) ;

	fprintf(f, '* Number of zones: %d\n\n', NB_ZONES) ;
	fprintf(f, '--- *** Features of the experiment *** ---\n\n') ;
	
	parameters = getappdata(0, 'parameters') ;
	parameters = parameters.(SET) ;
	
	fprintf(f, '|----------------------------------|\n') ;
	fprintf(f, '| number of conditions   : %4d    |\n', NB_COND) ;
	fprintf(f, '| number of repetitions  : %4d    |\n', NB_TRIALS) ;
	fprintf(f, '| duration of stimulation: %4s ms |\n', parameters.lstim) ;
	fprintf(f, '| baseline               : %4s ms |\n', parameters.bline) ;
	fprintf(f, '| time after stimulation : %4s ms |\n', parameters.after) ;
	fprintf(f, '|----------------------------------|\n\n') ;
	

	fprintf(f, '|-----------------------------------------|\n') ;
	fprintf(f, '| low-pass threshold (LFP)    : %5s Hz  |\n', parameters.lp_lfp) ;
	fprintf(f, '| high-pass threshold (LFP)   : %5s Hz  |\n', parameters.hp_lfp) ;
	fprintf(f, '| low-pass threshold (spikes) : %5s Hz  |\n', parameters.lp_sp) ;
	fprintf(f, '| high-pass threshold (spikes): %5s Hz  |\n', parameters.hp_sp) ;
	fprintf(f, '| standard threshold (spikes) : %5s std |\n', parameters.sp_thr) ;
	fprintf(f, '|-----------------------------------------|\n\n') ;
	

	fprintf(f, '--- *** Summary of explored depths *** ---\n\n') ;
	fprintf(f, ' ! Depths are displayed in the order they were explored !\n\n') ;
	
	for iZone = 1:NB_ZONES
		if iZone < 10
			fprintf(f, '*  zone 0%d  ', iZone) ;
		else
			fprintf(f, '*  zone %d  ', iZone) ;
		end
	end
	fprintf(f, '*\n') ;
	for iCoord = 1:NB_ZONES
		z = getappdata(0, ['zone', num2str(iCoord)]) ;
		fprintf(f, '* %9s ', z.position) ;
	end
	fprintf(f, '*\n\n') ;

	depths = zeros(length(ZONES.zone1.depths), NB_ZONES) ;
	depths(:, 1) = ZONES.zone1.depths ;
	for iZone = 2:NB_ZONES
		z = ZONES.(['zone', num2str(iZone)]) ;
		l = length(z.depths) - size(depths, 1) ;
		if l < 0
			z.depths = [z.depths ; NaN(abs(l), 1)] ;
		elseif l > 0
			depths = [depths ; NaN(l, NB_ZONES)] ;
		end
		depths(:, iZone) = z.depths ;
	end

	for iDepth = 1:size(depths, 1)
		for iZone = 1:size(depths, 2)
			if isnan(depths(iDepth, iZone))
				fprintf(f, '|           ') ;
			else
				fprintf(f, '| %5d mi  ', depths(iDepth, iZone)) ;
			end
		end
		fprintf(f, '|\n') ;
	end

	fprintf(f, '\n\n') ;
	
	fprintf(f, '*** ----------------------------------- ***\n') ;
	fprintf(f, '*** Detailed summary of explored depths ***\n') ;
	fprintf(f, '*** ------------------------------ ---- ***\n\n\n') ;
	
	A = 'A1L3' ;
	for iZone = 1:NB_ZONES
		fprintf(f, '* zone %d (%s)\n\n', iZone, A) ;
		z = getappdata(0, ['zone', num2str(iZone)]) ;
		for iDepth = 1:length(z.depths)
			fprintf(f, '| %5d mi | ', z.depths(iDepth)) ;
			if isempty(z.subzones{iDepth}.spikes_mean)
				fprintf(f, '! no spikes of interest !\n') ;
			else
				s = size(z.subzones{iDepth}.spikes_mean, 1) ;
				t = 'spikes' ;
				if s == 1, t = 'spike' ; end
				fprintf(f, '%d %s of interest\n', s, t) ;
			end
			fprintf(f, '           | ') ;
			fprintf(f, '%d spontaneous spike(s)\n', size(z.subzones{iDepth}.spikes_spontaneous, 1)) ;
			fprintf(f, '           | ') ;
			if isempty(z.subzones{iDepth}.removed_trials)
				fprintf(f, 'no trials have been removed\n') ;
			else
				fprintf(f, '%d removed trial(s)', size(z.subzones{iDepth}.removed_trials, 1)) ;
				fprintf(f, ' (') ;
				for iTrial = z.subzones{iDepth}.removed_trials, fprintf(f, '%d, ', iTrial) ; end
				fprintf(f, ')\n') ;
			end
			fprintf(f, ' ----------\n') ;
		end
		fprintf(f, '\n\n') ;
	end
	fclose(f) ;