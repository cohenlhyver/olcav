function plotLfpByCond(zone, varargin)

    global NB_COND...
           NB_STIM...
           UNITS...
           SAMPLE_FREQ ;

    pP = getappdata(0, 'pP') ;

    p = inputParser ;
      p.addOptional('Constant', zone.constants.lfpbycond) ;
      p.addOptional('timeFlags', pP.ticks([1, 3])) ;
      p.addOptional('timeBeforeOnset', pP.ticks(1)) ;
      p.addOptional('timeAfterOffset', pP.ticks(3)) ;
      p.addOptional('Depths', [zone.depths(1), zone.depths(end)]) ;
      p.addOptional('Visible', 'on') ;
      p.addOptional('Save', false) ;
      p.addOptional('Output', '') ;
    p.parse(varargin{:}) ;
    p = p.Results ;

    ticks = [p.timeBeforeOnset, pP.ticks(2), p.timeAfterOffset] ;

    bound = round(0.001*SAMPLE_FREQ*ticks) ;

    idx = [pP.bound(1)-bound(1), pP.bound(1)+pP.bound(2)+bound(3)] ;
    if idx(1) == 0, idx(1) = 1 ; end
    
    timetab = linspace(-bound(1),...
                       sum(bound) - bound(1),...
                       length(idx(1):idx(2))) ;

    depths = zone.depths(find(zone.depths == p.Depths(1)):...
                         find(zone.depths == p.Depths(end))) ;
    depths_idx = [find(zone.depths == p.Depths(1)):...
                  find(zone.depths == p.Depths(end))]  ;
    
    if isempty(p.Output)
        tmpf = strfind(zone.output, '\') ;
    else
        output = p.Output ;
    end

    conditions = getappdata(0, 'conditions') ;
    fconditions = getappdata(0, 'fconditions') ;

    h1 = figure('Visible', p.Visible) ; 
    h2 = figure('Visible', p.Visible) ; 
    h3 = figure('Visible', p.Visible) ;
    h4 = figure('Visible', p.Visible) ;
    h5 = figure('Visible', p.Visible) ;
    h6 = figure('Visible', p.Visible) ;
    h7 = figure('Visible', p.Visible) ;

    if NB_COND == 8, h8 = figure ; end

    tmp = 0 ;
    for iDepth = 1:length(depths)
    	tmp = tmp + 1 ;
    	step = p.Constant * tmp ;
    	figure(h1) ;
    	hold on ;
    	plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(1, idx(1):idx(2))-step,...
                    'LineWidth', 1.5,...
                    'Color', 'blue') ;
    	line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--') ;
    	hold off ;
    	figure(h2) ;
    	hold on ;
    	plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(2, idx(1):idx(2))-step,...
                    'LineWidth', 1.5,...
                    'Color', 'blue') ;
    	line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--') ;
    	hold off ;
    	figure(h3) ;
    	hold on ;
    	plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(3, idx(1):idx(2))-step,...
                    'LineWidth', 1.5,...
                    'Color', 'blue') ;
    	line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--') ;
    	hold off ;
    	figure(h4) ;
    	hold on ;
    	plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(4, idx(1):idx(2))-step,...
                    'LineWidth', 1.5,...
                    'Color', 'blue') ;
    	line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--') ;
    	hold off ;
    	figure(h5) ;
    	hold on ;
    	plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(5, idx(1):idx(2))-step,...
                    'LineWidth', 1.5,...
                    'Color', 'blue') ;
    	line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--') ;
    	hold off ;
    	figure(h6) ;
    	hold on ;
    	plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(6, idx(1):idx(2))-step,...
                    'LineWidth', 1.5,...
                    'Color', 'blue') ;
    	line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--') ;
    	hold off ;
    	figure(h7) ;
    	hold on ;
    	plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(7, idx(1):idx(2))-step,...
                    'LineWidth', 1.5,...
                    'Color', 'blue') ;
    	line(get(gca, 'XLim'), [-step -step],...
             'Color', 'k',...
             'LineStyle', '--') ;
    	hold off ;
    	if NB_COND == 8
    		figure(h8) ;
    		hold on ;
    		plot(timetab, zone.subzones{depths_idx(iDepth)}.lfp(8, idx(1):idx(2))-step,...
                        'LineWidth', 1.5,...
                    'Color', 'blue') ;
    		line(get(gca, 'XLim'), [-step -step],...
    	         'Color', 'k',...
    	         'LineStyle', '--') ;
    		hold off ;
    	end
    end

    if sum(ticks) > 500
        tstep = 50 ;
    elseif sum(ticks) <= 500
        tstep = 20 ;
    end

    % --- Condition 1 --- %
    figure(h1)
    step = step/iDepth ;
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths) :-1: 1),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'FontSize', 8) ;

    xlabel('time (ms)', 'FontSize', 12) ;
    ylabel('Depth (microns)', 'FontSize', 12) ;
    hold off ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    stim_name = conditions{1} ;
    % if strfind(zone.name, 'NR')
    %     stim_name = 'O1' ;
    % else
    %     stim_name = 'O.5 kHz' ;
    % end
    title(['\fontsize{18} \bf LFP (', stim_name, ')',...
           '\newline \fontsize{14} \sl ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
    if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{1}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{1}, '.tiff'], 'tiffn') ;
          end
        
    end
    disp('condition 1') ;

    % --- Condition 2 --- %

    figure(h2)
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths) :-1: 1),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'FontSize', 8) ;

    xlabel(['time (ms)'], 'FontSize', 12) ;
    ylabel(['Depth (microns)'], 'FontSize', 12) ;
    hold off ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    stim_name = conditions{2} ;
    title(['\fontsize{18} \bf LFP (', stim_name, ')',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
    if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{2}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{2}, '.tiff'], 'tiffn') ;
          end
        
    end
    disp('condition 2') ;

    % --- Condition 3 --- %
    figure(h3)
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths) :-1: 1),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'FontSize', 8) ;

    xlabel(['time (ms)'], 'FontSize', 12) ;
    ylabel(['Depth (microns)'], 'FontSize', 12) ;
    hold off ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    stim_name = conditions{3} ;
    title(['\fontsize{18} \bf LFP (', stim_name,')',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
    if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{3}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{3}, '.tiff'], 'tiffn') ;
          end
        
    end
    disp('condition 3') ;

    % --- Condition 4 --- %
    figure(h4)
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths) :-1: 1),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'FontSize', 8) ;

    xlabel(['time (ms)'], 'FontSize', 12) ;
    ylabel(['Depth (microns)'], 'FontSize', 12) ;
    hold off ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    stim_name = conditions{4} ;
    title(['\fontsize{18} \bf LFP (', stim_name, ')',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
    if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{4}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{4}, '.tiff'], 'tiffn') ;
          end
        
    end
    disp('condition 4') ;

    % --- Condition 5 --- %
    figure(h5)
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths) :-1: 1),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'FontSize', 8) ;

    xlabel(['time (ms)'], 'FontSize', 12) ;
    ylabel(['Depth (microns)'], 'FontSize', 12) ;
    hold off ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    stim_name = conditions{5} ;
    title(['\fontsize{18} \bf LFP (', stim_name, ')',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
   if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{5}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{5}, '.tiff'], 'tiffn') ;
          end
        
    end
    disp('condition 5') ;

    % --- Condition 6 --- %
    figure(h6)
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths) :-1: 1),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'FontSize', 8) ;

    xlabel(['time (ms)'], 'FontSize', 12) ;
    ylabel(['Depth (microns)'], 'FontSize', 12) ;
    hold off ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    stim_name = conditions{6} ;
    title(['\fontsize{18} \bf LFP (', stim_name, ')',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
   if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{6}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{6}, '.tiff'], 'tiffn') ;
          end
        
    end
    disp('condition 6') ;

    % --- Condition 7 --- %
    figure(h7)
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths) :-1: 1),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'FontSize', 8) ;

    xlabel(['time (ms)'], 'FontSize', 12) ;
    ylabel(['Depth (microns)'], 'FontSize', 12) ;
    hold off ;
    line([0 0], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    line([bound(2) bound(2)], get(gca, 'YLim'),...
          'Color', 'k',...
          'LineWidth', 2) ;
    stim_name = conditions{7} ;
    title(['\fontsize{18} \bf LFP (', stim_name, ')',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
    if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{7}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{7}, '.tiff'], 'tiffn') ;
          end
        
    end
    disp('condition 7') ;

    % --- Condition 8 --- %
    if NB_COND == 8
    	figure(h8)
    	set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
                 'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
                 'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
    	         'YTick'     , -step*(length(depths) :-1: 1),...
    	         'YTickLabel', depths(end :-1: 1),...
    	         'YLim'      , -step*([length(depths)+2, -2]),...
    	         'FontSize', 8) ;

    	xlabel(['time (ms)'], 'FontSize', 12) ;
    	ylabel(['Depth (microns)'], 'FontSize', 12) ;
    	hold off ;
    	line([0 0], get(gca, 'YLim'),...
    	      'Color', 'k',...
          'LineWidth', 2) ;
    	line([bound(2) bound(2)], get(gca, 'YLim'),...
    	      'Color', 'k',...
          'LineWidth', 2) ;
        stim_name = conditions{8} ;
        title(['\fontsize{18} \bf LFP(', stim_name, ')',...
               '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
               'HorizontalAlignment', 'center') ;
        if p.Save
         if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp', fconditions{iCond}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp', fconditions{1}, '.tiff'], 'tiffn') ;
          end
        
    end
        disp('condition 8') ;
    end
    
    disp('Plot -- LFPs by condition -- have been successfully generated')
    
    if ~p.Visible, close all ; end

end