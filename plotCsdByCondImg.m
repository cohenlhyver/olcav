function plotCsdByCondImg(zone, varargin)

	global NB_COND...
           NB_STIM...
           UNITS...
           SAMPLE_FREQ ;

    pP = getappdata(0, 'pP') ;

    p = inputParser ;
      p.addOptional('timeFlags', pP.ticks([1, 3])) ;
      p.addOptional('timeBeforeOnset', pP.ticks(1)) ;
      p.addOptional('timeAfterOffset', pP.ticks(3)) ;
      p.addOptional('Depths', [zone.depths(1), zone.depths(end)]) ;
      p.addOptional('Visible', 'on') ;
      p.addOptional('Save', false) ;
      p.addOptional('Output', '') ;
      p.addOptional('Inversion', false) ;
    p.parse(varargin{:}) ;
    p = p.Results ;

    % p.Depths = [350, 1500] ;

    ticks = [p.timeBeforeOnset, pP.ticks(2), p.timeAfterOffset] ;

    bound = round(0.001*SAMPLE_FREQ*ticks) ;

    idx = [pP.bound(1)-bound(1), pP.bound(1)+pP.bound(2)+bound(3)] ;
    if idx(1) == 0, idx(1) = 1 ; end

      if strcmp(zone.output(end-1:end), 'P1')
      zone.depths = 0 :100: 1800 ;
    end

    d_min = find(zone.depths >= zone.depths(1)+300, 1, 'first') ;
    d_max = find(zone.depths <= zone.depths(end)-300, 1, 'last') ;

    if p.Depths(1) == zone.depths(1), p.Depths(1) = zone.depths(d_min) ; end
    if p.Depths(2) == zone.depths(end), p.Depths(2) = zone.depths(d_max) ; end

    depths = zone.depths(find(zone.depths == p.Depths(1)):...
                         find(zone.depths == p.Depths(end))) ;

    depths_idx = [find(zone.depths == p.Depths(1)):...
                  find(zone.depths == p.Depths(end))] ;

    depth_step = zone.depths(2)-zone.depths(1) ;

    depths_idx = depths_idx-depths_idx(1) + 1 ;

    if strcmp(zone.output, 'C:\NR2\p2')
        depths_idx = 1:4 ;
        depths = [875, 1075, 1275, 1475] ;
    end

    timetab = linspace(-bound(1),...
                       sum(bound) - bound(1),...
                       length(idx(1):idx(2))) ;

    conditions = getappdata(0, 'conditions') ;
    fconditions = getappdata(0, 'fconditions') ;

    if isempty(p.Output)
        tmpf = strfind(zone.output, '\') ;
    else
        output = p.Output ;
    end

    pos = find(zone.depths >= zone.depths(1)+300, 1, 'first') ;
    % d = depths(end-(pos-1) :-1: pos) ;
    d = depths(end :-1: 1) ;
    if sum(ticks) > 500
        tstep = 50 ;
    elseif sum(ticks) <= 500
        tstep = 20 ;
    end
    for iCond = 1:NB_COND
        figure('Visible', p.Visible) ;
        disp(['condition ', num2str(iCond)]) ;
        %norms = cell2mat(arrayfun(@(x) norm(zone.csd{iCond}(x, idx(1):idx(2))), depths_idx(1):depths_idx(2), 'UniformOutput', false))' ;
        %imagesc(bsxfun(@rdivide, zone.csd{iCond}(depths_idx, idx(1):idx(2)), norms)) ;
        if p.Inversion
            imagesc(-zone.csd{iCond}(depths_idx, idx(1):idx(2))) ;
        else
            imagesc(zone.csd{iCond}(depths_idx, idx(1):idx(2))) ;
        end
        m = max(max(abs(zone.csd_mean))) ;
        caxis([-m, m]) ;
		set(gca, 'XLim'      , [0, sum(bound)],...
                 'XTick'     , [0 :round(0.001*tstep*SAMPLE_FREQ): sum(bound)],...
                 'XTickLabel', [-ticks(1) :tstep: sum(ticks)],...
				 'XMinorTick', 'on',...
		         'YTick'     , 1:length(d),...
		         'YTickLabel', d(end :-1: 1),...
		         'FontSize'  , 8) ;
		        
        line([bound(1), bound(1)], get(gca, 'YLim'),...
             'Color', 'k',...
             'LineWidth', 2) ;
        line([bound(1)+bound(2), bound(1)+bound(2)], get(gca, 'YLim'),...
             'Color', 'k',...
             'LineWidth', 2) ;
        c = colorbar ;
        if p.Inversion
	        set(get(c, 'Title') , 'String'    , 'source') ;
            set(get(c, 'XLabel'), 'String'    , 'sink') ;
        else
            set(get(c, 'Title') , 'String'    , 'sink') ;
            set(get(c, 'XLabel'), 'String'    , 'source') ;
        end
		set(get(c, 'Title') , 'FontWeight', 'bold') ;
		set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

		%caxis([-5.5e-5 3.5e-5]) ;

        xlabel(['time (ms)'], 'FontSize', 12) ;
        ylabel(['Depth (microns)'], 'FontSize', 12) ;
        title(['\fontsize{18} \bf CSD (', conditions{iCond}, ')',...
               '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
               'HorizontalAlignment', 'center') ;
        if p.Save
          if ~isempty(output)
            saveas(gca, [output, '/CSD/csd', fconditions{iCond}, '_img.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\CSD\csd', fconditions{iCond}, '_img.tiff'], 'tiffn') ;
          end
        end
        if ~p.Visible, close all ; en
    end
    
    disp('Plots generated')
end