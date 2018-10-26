function generatePlots

	global SAMPLE_FREQ NB_ZONES NB_COND NB_TRIALS ;

	folder = fullfile(getappdata(0, 'proc_folder'), 'Olcav_offlineProcessings', 'plots') ;

	if exist(fullfile(folder, 'Olcav_offlineProcessings', 'plots')) == 0
		%mkdir(fullfile(folder, 'Olcav_offlineProcessings', 'plots')) ;
		mkdir(folder) ;
	end
	 
	%wbar_limit = length(zone.depths)*2 ;
	
	% h = waitbar(0, ['Generating plots', num2str(zone.depths(iDepth))],...
	% 				'Name', ['Generating figures for zone ', num2str(iZone), 'on ', num2str(NB_ZONES)]) ;
	%pause(1) ;
	for iZone = 1:NB_ZONES
		if NB_ZONES > 1
			zone_folder = fullfile(folder, ['zone', num2str(iZone)]) ;
			mkdir(zone_folder) ;
		else
			zone_folder = folder ;
		end

		zone = getappdata(0, ['zone', num2str(iZone)]) ;
		param = zone.subzones{1}.parameters ;
		nb_depths = length(zone.depths) ;

		% ------------------- %
		% --- LFP (begin) --- %
		% ------------------- %

		bound = round(0.001*SAMPLE_FREQ*[param.bline,...
	                                     param.lstim,...
	                                     param.after]) ;

	    ticks = round(bound/SAMPLE_FREQ*1000) ;
	    timetab = linspace(-bound(1),...
	                        sum(bound) - bound(1),...
	                        size(zone.subzones{1}.lfp(1, :), 2)) ;
		
		f = figure('Visible', 'off') ;
		hold on ;
		tmp = [] ;
		for iDepth = 1:nb_depths, tmp = [tmp ; zone.subzones{iDepth}.lfp_mean] ; end
		m1 = min(min(tmp')) ;
		m2 = max(max(tmp')) ;
		m = max([abs(m1), abs(m2)]) ;
		for iDepth = 1:nb_depths

			% wstep = (iDepth + 1) / wbar_limit ;
   %  		waitbar(wstep, h,...
   %                  ['Mean Local Field Potentials of depth ' num2str(zone.depths(iDepth))], '-- ', num2str(round(100*step)), ' % completed']) ;
			
			step = (iDepth-1) * m ;
			plot(timetab, zone.subzones{iDepth}.lfp_mean - step) ;
			line(get(gca, 'XLim'), [-step -step],...
	             'Color', 'k',...
	             'LineStyle', '--',...
	             'Parent', gca) ;
		end
		line([0, 0], get(gca, 'YLim'),...
			 'Color', 'r',...
			 'LineStyle', '-',...
			 'Parent', gca) ;
		line([bound(1), bound(1)], get(gca, 'YLim'),...
			 'Color', 'r',...
			 'LineStyle', '-',...
			 'Parent', gca) ;
		hold off ;
		tmp = get(gca, 'YLim') ;
		set(gca, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
	             'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
	             'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
	             'XMinorTick', 'on',...
	             'YLim'	     , [-round(step-2*min(zone.subzones{end}.lfp_mean)), round(2*max(zone.subzones{1}.lfp_mean))],...
	             'YTick'     , [-step :m: 0],...
	             'YTickLabel', zone.depths(end:-1:1),...
	             'FontSize'  , 8) ;

		xlabel(gca, 'time (ms)') ;
	    ylabel(gca, 'depths') ;
	    
	    title(gca, 'Mean LFP by depth') ;

		saveas(gca, fullfile(zone_folder, 'lfp_mean.tiff'), 'tiffn') ;
		close(gcf)

	    lfp_folder = fullfile(zone_folder, 'lfp_allcond') ;
    	mkdir(lfp_folder) ;
		
		for iDepth = 1:nb_depths
			f = figure('Visible', 'off') ;
			plot(gca, timetab, zone.subzones{iDepth}.lfp') ;
	    	line([0 0], get(gca, 'YLim'),...
		          'Color', 'k', 'Parent', gca) ;
		    line([bound(2) bound(2)], get(gca, 'YLim'),...
		          'Color', 'k', 'Parent', gca) ;
		    line(get(gca, 'XLim'), [0 0], 'Color', 'k',...
		                                  'LineStyle', '--',...
		                                  'LineWidth', 0.1) ;
		    hold off ;

			legend_txt = genvarname(repmat({'Stimulus '}, 1, NB_COND+1)) ;
	    	legend_txt(1) = [] ;
    		legend(gca, legend_txt, 'FontSize', 7) ;
    		set(gca, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
		             'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
		             'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
		             'XMinorTick', 'on',...
		             'FontSize'  , 8) ;
    		xlabel(gca, 'time (ms)') ;
	    	ylabel(gca, 'amplitude') ;
	    	title(gca, ['LFP of all conditions -- depth: ', num2str(zone.depths(iDepth))]) ;
    		saveas(gca, fullfile(lfp_folder, [num2str(zone.depths(iDepth)), '.tiff']), 'tiffn') ;
    		close(gcf)
    	end

    	% --- By conditions --- %
    	% for iCond = 1:NB_COND
	    % 	f = figure('Visible', 'off') ;
	    % 	hold on ; 
	    % 	for iDepth = 1:nb_depths
	    % 		step = (iDepth-1) * m ;
	    % 		plot(timetab, zone.subzones{iDepth}.lfp{iCond} - step) ;
	    % 		line(get(gca, 'XLim'), [-step -step],...
		   %           'Color', 'k',...
		   %           'LineStyle', '--',...
		   %           'Parent', gca) ;
	    % 	end

    	% --- As an image --- %
  %   	f = figure('Visible', 'off') ;
		% imagesc(zone.csd_mean) ;
		% line([bound(1), bound(1)], get(gca, 'YLim'),...
		% 	 'Color', 'r',...
		% 	 'LineStyle', '-',...
		% 	 'Parent', gca) ;
		% line([bound(1)+bound(1), bound(1)+bound(2)], get(gca, 'YLim'),...
		% 	 'Color', 'r',...
		% 	 'LineStyle', '-',...
		% 	 'Parent', gca) ;
		% set(gca, 'XLim'    , [-bound(1), sum(bound)-bound(1)],...
	 %             'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
	 %             'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
	 %             'XMinorTick', 'on',...
	 %             'YTick', [0:size(zone.csd_mean, 1)],...
	 %             'YTickLabel', zone.depths(2:end-2),...
	 %             'FontSize'  , 8) ;

		% xlabel(gca, 'time (ms)') ;
		% ylabel(gca, 'depths') ;
		% title(gca, 'Mean CSD by depth') ;

		% saveas(gca, fullfile(zone_folder, 'csd_mean_imagesc.tiff'), 'tiffn') ;
		% close(gcf) ;

		% ----------------- %
		% --- LFP (end) --- %
		% ----------------- %

		% ------------------- %
		% --- CSD (begin) --- %
		% ------------------- %
		
		csd_folder = fullfile(zone_folder, 'CSD') ;
		mkdir(csd_folder) ;
		nb = (nb_depths - size(zone.csd_mean, 1)) / 2 ;
		m1 = min(min(zone.csd_mean')) ;
		m2 = max(max(zone.csd_mean')) ;
		m = max([abs(m1), abs(m2)]) ;

		f = figure('Visible', 'off') ;
		hold on ; 
		for iDepth = 1:size(zone.csd_mean, 1)
			step = (iDepth-1)*m ;
			plot(timetab, zone.csd_mean(iDepth, :) - step) ;
			line(get(gca, 'XLim'), [-step -step],...
	             'Color', 'k',...
	             'LineStyle', '--',...
	             'Parent', gca) ;
		end
		line([0, 0], get(gca, 'YLim'),...
			 'Color', 'r',...
			 'LineStyle', '-',...
			 'Parent', gca) ;
		line([bound(1), bound(1)], get(gca, 'YLim'),...
			 'Color', 'r',...
			 'LineStyle', '-',...
			 'Parent', gca) ;
		hold off ;

		set(gca, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
	             'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
	             'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
	             'XMinorTick', 'on',...
	             'YLim'		 , [2*min(zone.csd_mean(end, :))-step, 2*max(zone.csd_mean(1, :))],...
	             'YTick'	 , [-step :m: 0],...
	             'YTickLabel', zone.depths(end-nb:-1:nb),...
	             'FontSize'  , 8) ;
		xlabel(gca, 'time (ms)') ;
	    ylabel(gca, 'depths') ;
	    title(gca, 'Mean CSD by depth') ;

		saveas(gca, fullfile(csd_folder, 'csd_mean.tiff'), 'tiffn') ;
		close(gcf) ;

		% --- By conditions --- %

		nrow = ceil(sqrt(NB_COND)) ;
		ncol = ceil(NB_COND/nrow) ;

		for iCond = 1:NB_COND
			f = figure('Visible', 'off') ;
			%subplot(nrow, ncol, iCond) ;
			imagesc(zone.csd{iCond}) ;
			
			line([bound(1), bound(1)], get(gca, 'YLim'),...
				 'Color', 'k',...
				 'LineStyle', '-',...
				 'Parent', gca) ;
			line([bound(1)+bound(1), bound(1)+bound(2)], get(gca, 'YLim'),...
				 'Color', 'k',...
				 'LineStyle', '-',...
				 'Parent', gca) ;
			set(gca, 'XLim'    , [0, sum(bound)],...
		             'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
		             'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
		             'XMinorTick', 'on',...
		             'YTick', [0 :2: size(zone.csd_mean, 1)],...
		             'YTickLabel', zone.depths(nb :2: end-nb),...
		             'FontSize'  , 8) ;
			c = colorbar ;
			set(get(c, 'Title'), 'String', 'sink') ;
			set(get(c, 'Title'), 'FontWeight', 'bold')
			set(get(c, 'XLabel'), 'String', 'source') ;
			set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

			xlabel(gca, 'time (ms)') ;
			ylabel(gca, 'depths') ;
			title(gca, ['CSD of condition ', num2str(iCond)]) ;
			saveas(gca, fullfile(csd_folder, ['csd_cond', num2str(iCond), '.tiff']), 'tiffn') ;
			close(gcf) ;
		end

		% --- As an image --- %

		f = figure('Visible', 'off') ;
		imagesc(zone.csd_mean) ;
		line([bound(1), bound(1)], get(gca, 'YLim'),...
			 'Color', 'k',...
			 'LineStyle', '-',...
			 'Parent', gca) ;
		line([bound(1)+bound(1), bound(1)+bound(2)], get(gca, 'YLim'),...
			 'Color', 'k',...
			 'LineStyle', '-',...
			 'Parent', gca) ;
		set(gca, 'XLim'    , [0, sum(bound)],...
	             'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
	             'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
	             'XMinorTick', 'on',...
	             'YTick', [0:size(zone.csd_mean, 1)],...
	             'YTickLabel', zone.depths(nb:end-nb),...
	             'FontSize'  , 8) ;

		c = colorbar ;
		set(get(c, 'Title'), 'String', 'sink') ;
		set(get(c, 'Title'), 'FontWeight', 'bold')
		set(get(c, 'XLabel'), 'String', 'source') ;
		set(get(c, 'XLabel'), 'FontWeight', 'bold') ;
			
		xlabel(gca, 'time (ms)') ;
		ylabel(gca, 'depths') ;
		title(gca, 'Mean CSD by depth') ;

		saveas(gca, fullfile(csd_folder, 'csd_mean_imagesc.tiff'), 'tiffn') ;
		close(gcf) ;

		% ----------------- %
		% --- CSD (end) --- %
		% ----------------- %
		% --------------------------------- %
		% --- Optimal Condition (begin) --- %
		% --------------------------------- %

		f = figure('Visible', 'off') ;
		[a, b] = max(zone.spikes_all) ;
	    [c, d] = min(zone.spikes_all) ;
	    hold on ;
	    nb_spikes = [] ;
	    
	    for iDepth = 1:nb_depths
	        line([b(iDepth) d(iDepth)], [zone.depths(iDepth) zone.depths(iDepth)],...
	             'Color', 'k') ;
	        plot(gca, b(iDepth), zone.depths(iDepth),...
	                  'r.',...
	                  'MarkerSize', (a(iDepth)*70/max(a))+10,...
	                  'Tag', num2str(iDepth)) ;
	        plot(gca, d(iDepth), zone.depths(iDepth),...
	                  'c.',...
	                  'MarkerSize', (c(iDepth)*70/max(a))+10,...
	                  'Tag', num2str(iDepth)) ;
	        nb_spikes = [nb_spikes, size(zone.subzones{iDepth}.spikes_raw, 1)] ;
	    end

	    for iDepth = 1:nb_depths
	        if a(iDepth) == c(iDepth)
	            text(b(iDepth), zone.depths(iDepth)+nb_depths,...
	                 ['\fontsize{8} \color[rgb]{0 0.2 0.6} \bf min & max = ', num2str(a(iDepth))]) ;
	        else
	            percent_max = num2str(a(iDepth)/nb_spikes(iDepth)*100) ;
	            percent_min = num2str(c(iDepth)/nb_spikes(iDepth)*100) ;
	            idx_max = strfind(percent_max, '.') ;
	            idx_min = strfind(percent_min, '.') ;
	            if ~isempty(idx_max), percent_max = percent_max(1:idx_max+1) ; end
	            if ~isempty(idx_min), percent_min = percent_min(1:idx_min+1) ; end
	            if strcmp(percent_max, 'NaN') | strcmp(percent_max, 'Inf'), percent_max = '0' ; end
	            if strcmp(percent_min, 'NaN') | strcmp(percent_min, 'Inf'), percent_min = '0' ; end
	            text(b(iDepth), zone.depths(iDepth)+nb_depths,...
	                 ['\fontsize{12} \color[rgb]{0 0.2 0.6} \bf', num2str(a(iDepth)), '\fontsize{8} -- ', percent_max, '%']) ;
	            text(d(iDepth), zone.depths(iDepth)+nb_depths,...
	                 ['\fontsize{10} \color[rgb]{1 0.2 0.2} \bf', num2str(c(iDepth)), '\fontsize{8} -- ', percent_min, '%']) ;
	        end
	    end

	    xlabel('condition') ;
	    ylabel('depths') ;
	    title('Optimal Condition, based on count of spikes') ;
	    grid on ; 
	    hold off ;

        set(gca, 'XLim'      , [0, NB_COND+1],...
                 'XTick'     , 1:NB_COND,...
                 'XTickLabel', 1:NB_COND,...
                 'YLim'      , [zone.depths(1)-100, zone.depths(end)+100],...
                 'YTick'     , zone.depths,...
                 'YTickLabel', zone.depths,...
                 'YDir'      , 'Reverse',...
                 'FontSize'  , 8) ;

		saveas(gca, fullfile(zone_folder, 'opt_cond.tiff'), 'tiffn') ;
		close(gcf)
		% ------------------------------- %
		% --- Optimal Condition (end) --- %
		% ------------------------------- %
		% ---------------------- %
		% --- Raster (begin) --- %
		% ---------------------- %

		% raster_folder = fullfile(zone_folder, 'rasters') ;
		% mkdir(raster_folder) ;
		% timetab = linspace(-20, param.lstim+20, param.lstim/10) ;
		
		% nrow = ceil(sqrt(NB_COND)) ;
		% ncol = ceil(NB_COND/nrow) ;
		
		% for iDepth = 1:nb_depths
		% 	f = figure('Visible', 'off') ;
		% 	spikes = zone.subzones{iDepth}.spikes_raster ;
		% 	if isempty(spikes), return ; end
		% 	for iCond = 1:NB_COND
		% 		subplot(nrow, ncol, iCond) ;
		% 		hold on ;
		% 		rectangle('Position', [-20, 0, 20, NB_TRIALS],...
  %               		  'FaceColor', [190 255 250]/255,...
  %                 		'LineStyle', 'none') ;
  %       		rectangle('Position', [param.lstim, 0, 20, NB_TRIALS],...
  %                 		  'FaceColor', [190 255 250]/255,...
  %                 		  'LineStyle', 'none') ;
  %       		for iTrial = 1:NB_TRIALS
	 %            	points = spikes{iCond, iTrial} / 1000 ;
	 %            	ypos = ones(length(points), 1) * iTrial ;
	 %            	plot(points, ypos,...
	 %                	 '*b', 'MarkerSize', 2) ;
	 %            	set(gca, 'FontSize', 8) ;
  %       		end
		%         xlim([-30, param.lstim+30]) ;
		%         ylim([0, NB_TRIALS+1]) ;
		%         xlabel('time (ms)') ,
		%         ylabel('trial number') ;
		%         title(['Condition ', num2str(iCond)]) ;
		%         hold off
  %   		end
  %   		saveas(gca, fullfile(raster_folder, [num2str(zone.depths(iDepth)), '.tiff']), 'tiffn') ;
  %   		close(gcf) ;
  %   	end

		% -------------------- %
		% --- Raster (end) --- %
		% -------------------- %

		% -------------------------------- %
		% --- Latencies Tables (begin) --- %
		% -------------------------------- %

	end

		% ------------------ %
		% --- Zip folder --- %
		% ------------------ %

	%waitbar(100, h, 'Zipping folder -- 100 % completed') ;
	%zip([folder, '.zip'], folder) ;
	% pause(0.5) ;
	% delete(h) ;
	%rmdir(folder, 's') ;