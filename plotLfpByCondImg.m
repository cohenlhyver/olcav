function plotLfpByCondImg(zone, varargin)

	global NB_COND...
           NB_STIM...
           UNITS...
           SAMPLE_FREQ ;

    pP = getappdata(0, 'pP') ;

    p = inputParser ;
    % p.addOptional('Constant', 2) ;
      p.addOptional('timeFlags', pP.ticks([1, 3])) ;
      p.addOptional('timeBeforeOnset', pP.ticks(1)) ;
      p.addOptional('timeAfterOffset', pP.ticks(3)) ;
      p.addOptional('Depths', [zone.depths(1), zone.depths(end)]) ;
      p.addOptional('Visible', 'on') ;
      p.addOptional('Save', false) ;
      p.addOptional('Output', '') ;
    p.parse(varargin{:}) ;
    p = p.Results ;

    if isempty(p.Output)
        tmpf = strfind(zone.output, '\') ;
    else
        output = p.Output ;
    end

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
                  find(zone.depths == p.Depths(end))] ;

	conditions = getappdata(0, 'conditions') ;
	fconditions = getappdata(0, 'fconditions') ; 
	tmpf = strfind(zone.output, '\') ;

	nb_depths = length(depths) ;
	
	tmp = zeros(nb_depths, length(zone.subzones{1}.lfp_mean(idx(1):idx(2)))) ;
	% tmp_max = zeros(1, NB_COND) ;
	% tmp_min = zeros(1, NB_COND) ;
	% for iCond = 1:NB_COND
	% 	for iDepth = 1:nb_depths
	% 		tmp(iDepth, :) = zone.subzones{depths_idx(iDepth)}.lfp(iCond, idx(1):idx(2)) ;
	% 	end
	% 	tmp_max(iCond) = max(max(tmp')) ;
	% 	tmp_min(iCond) = min(min(tmp')) ;
	% end
	% cmax = max(tmp_max) ;
	% cmin = min(tmp_min) ;
	if sum(ticks) > 500
        tstep = 50 ;
    elseif sum(ticks) <= 500
        tstep = 20 ;
    end
	for iCond = 1:NB_COND
		tmp = zeros(nb_depths, length(zone.subzones{1}.lfp_mean(idx(1):idx(2)))) ;
		for iDepth = 1:nb_depths
			tmp(iDepth, :) = zone.subzones{depths_idx(iDepth)}.lfp(iCond, idx(1):idx(2)) ;
		end
		figure('Visible', p.Visible) ;
		% norms = cell2mat(arrayfun(@(x) norm(tmp(x, :)), 1:size(tmp, 1), 'UniformOutput', false))' ;
  		% imagesc(bsxfun(@rdivide, tmp, norms)) ;
		imagesc(tmp) ;
		set(gca, 'XLim'      , [0, sum(bound)],...
             	 'XTick'     , [0 :round(0.001*tstep*SAMPLE_FREQ): sum(bound)],...
             	 'XTickLabel', [-ticks(1) :tstep: sum(ticks)],...
				 'XMinorTick', 'on',...
		         'YTick'     , 1:nb_depths,...
		         'YTickLabel', depths,...
		         'FontSize', 8) ;
		line([bound(1), bound(1)], get(gca, 'YLim'),...
		     'Color', 'k',...
		     'LineWidth', 2) ;
		line([bound(1)+bound(2) bound(1)+bound(2)], get(gca, 'YLim'),...
		     'Color', 'k',...
		     'LineWidth', 2) ;

		c = colorbar ;

		set(get(c, 'Title'), 'String', 'positive') ;
		set(get(c, 'Title'), 'FontWeight', 'bold')
		set(get(c, 'XLabel'), 'String', 'negative') ;
		set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

		%caxis([cmin, cmax])

		xlabel('time (ms)', 'FontSize', 12) ;
		ylabel('depths (mi)', 'FontSize', 12) ;
		title(['\fontsize{18} \bf LFP (', conditions{iCond},')'...
		       '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
		       'HorizontalAlignment', 'center') ;

		if p.Save
	         if ~isempty(output)
	            saveas(gca, [output, '/LFP/lfp', fconditions{iCond}, '_img.tiff'], 'tiffn') ;
	          else
	            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp' fconditions{iCond}, '_img.tiff'], 'tiffn') ;
	          end
	        
	    end
	end
	
	disp('Plots generated') ;
	if ~p.Visible, close all ; end

end