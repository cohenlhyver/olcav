function plotCsdMean(zone, varargin)

    global NB_COND...
           NB_STIM...
           UNITS...
           SAMPLE_FREQ ;

    pP = getappdata(0, 'pP') ;

    p = inputParser ;
      p.addOptional('Constant', zone.constants.csd) ;
      p.addOptional('timeBeforeOnset', pP.ticks(1)) ;
      p.addOptional('timeAfterOffset', pP.ticks(3)) ;
      p.addOptional('Depths', [zone.depths(1), zone.depths(end)]) ;
      p.addOptional('Visible', 'on') ;
      p.addOptional('Save', false) ;
      p.addOptional('Inversion', false) ;
      p.addOptional('Output', '') ;
    p.parse(varargin{:}) ;
    p = p.Results ;

    % p.Depths = [350, 1500] ;
    ticks = [p.timeBeforeOnset, pP.ticks(2), p.timeAfterOffset] ;

    bound = round(0.001*SAMPLE_FREQ*ticks) ;

    idx = [pP.bound(1)-bound(1), pP.bound(1)+pP.bound(2)+bound(3)] ;
    if idx(1) == 0, idx(1) = 1 ; end

    timetab = linspace(-bound(1),...
                       sum(bound) - bound(1),...
                       length(idx(1):idx(2))) ;

    if strcmp(zone.output(end-1:end), 'P1')
      zone.depths = 0 :100: 1800 ;
    end

    d_min = find(zone.depths >= zone.depths(1)+300, 1, 'first') ;
    d_max = find(zone.depths <= zone.depths(end)-300, 1, 'last') ;

    if p.Depths(1) == zone.depths(1), p.Depths(1) = zone.depths(d_min) ; end
    if p.Depths(end) == zone.depths(end), p.Depths(end) = zone.depths(d_max) ; end

    depths = zone.depths(find(zone.depths == p.Depths(1)):...
                         find(zone.depths == p.Depths(end))) ;
    depths_idx = [find(zone.depths == p.Depths(1)):...
                  find(zone.depths == p.Depths(end))] ; 
    depths_idx = depths_idx-depths_idx(1) + 1 ;

    if strcmp(zone.output, 'C:\NR2\p2')
        depths_idx = 1:4 ;
        depths = [875, 1075, 1275, 1475] ;
    end

    depth_step = zone.depths(2)-zone.depths(1) ;
    % depths(1) = 300 ;
    % if depth_step == 100
    %     depths_idx = depths_idx - 5 ;
    % elseif depth_step == 50
    %     depths_idx = depths_idx - 6 ;
    % else
    %     depths_idx = depths_idx - 2 ;
    % end
    % depths = zone.depths ;
    if isempty(p.Output)
        tmpf = strfind(zone.output, '\') ;
    else
        output = p.Output ;
    end

    %timeZone = [0.5*bound(1), bound(1)+2*bound(2)] ;
    %csdBound = mean(std(zone.csd_mean(:, timeZone(1):timeZone(2)), 0, 2)) ;
    % pos = find(zone.depths >= zone.depths(1)+200, 1, 'first') ;
    %d = depths(end-(pos-1) :-1: pos) ;
    d = depths(end :-1: 1) ;
    figure('Visible', p.Visible) ; hold on ;

    for iDepth = 1:length(depths)
    %for iDepth = 1:size(zone.csd_mean, 1)
        step = p.Constant * (iDepth-1) ;
    	%tmp = zone.csd_mean(iDepth, bound(1)+1:end) >= 0 ;
        if p.Inversion
    	    tmp = -zone.csd_mean(depths_idx(iDepth), idx(1):idx(2)) >= 0 ;
            source = -zone.csd_mean(depths_idx(iDepth), idx(1):idx(2)) ;
        else
            tmp = zone.csd_mean(depths_idx(iDepth), idx(1):idx(2)) >= 0 ;
            source = zone.csd_mean(depths_idx(iDepth), idx(1):idx(2)) ;
        end
        sink = source ; 
        source(tmp) = NaN ;
        sink(~tmp)  = NaN ;
        %if std(zone.csd_mean(iDepth, bound(1)+1:end)) > 1*csdBound 
        %if any(dephts2remove == iDepth)
            %sink = zeros(size(zone.csd_mean(1, :))) ;
            %plot(timetab, sink-step, 'g', 'LineWidth', 1) ;
            %plot(timetab, source-step, 'c', 'LineWidth', 1) ;
        %else
            plot(timetab, sink-step, 'r', 'LineWidth', 1.6) ;
            plot(timetab, source-step, 'b', 'LineWidth', 1.6) ;
            %tmp = m(iDepth, bound(1):sum(bound)+bound(1)) >= 0 ;
        %end
        %if iDepth ~= 1 & iDepth ~= size(zone.csd_mean, 1)
        line(get(gca, 'XLim'), [-step, -step],...
             'Color'         , 'k',...
             'LineStyle'     , '--',...
             'LineWidth'     , 0.5) ;
        %end
    end
    if sum(ticks) > 500
        tstep = 50 ;
    elseif sum(ticks) <= 500
        tstep = 20 ;
    end
    set(gca, 'XLim'      , [-bound(1), idx(2)-pP.bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-pP.bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -p.Constant*(length(d)-1 :-1: 0),...
             'YTickLabel', d,...
             'YLim'      , ([min(zone.csd_mean(end, :))-1.1*step, max(zone.csd_mean(1, :))]+1.5*p.Constant),... % 1.1
             'FontSize'  , 8) ;
    xlabel(['time (ms)'], 'FontSize', 12) ;
    ylabel(['Depth (microns)'], 'FontSize', 12) ;
    line([0 0], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 0.5) ;
    line([bound(2), bound(2)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 0.5) ;
    title(['\fontsize{14} \bf Mean of Current Source Density',...
           '\newline \fontsize{12} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;

    hold off ;
    if p.Save
          if ~isempty(output)
            saveas(gca, [output, '/CSD/csd_mean.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\CSD\csd_mean.tiff'], 'tiffn') ;
          end
    end
    if ~p.Visible, close all ; end


    % --- Imagesc
    figure('Visible', p.Visible) ; 
    %norms = cell2mat(arrayfun(@(x) norm(zone.csd_mean(x, idx(1):idx(2))), depths_idx(1):depths_idx(2), 'UniformOutput', false))' ;
    %imagesc(bsxfun(@rdivide, zone.csd_mean(depths_idx, idx(1):idx(2))', norms)) ;
    if p.Inversion
        colormap(flipud(colormap)) ;
        imagesc(-zone.csd_mean(depths_idx, idx(1):idx(2))) ;
    else
        imagesc(zone.csd_mean(depths_idx, idx(1):idx(2))) ;
    end
    m = max(max(abs(zone.csd_mean))) ;
    caxis([-m, m]) ;
    %imagesc(zone.csd_mean) ; 
    set(gca, 'XLim'      , [0, sum(bound)],...
             'XTick'     , [0 :round(0.001*tstep*SAMPLE_FREQ): sum(bound)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)],...
             'XMinorTick', 'on',...
             'YTick'     , 1:length(d),...
             'YTickLabel', d(end :-1: 1),...
             'FontSize', 8) ;
    line([bound(1), bound(1)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 2) ;
    line([bound(1)+bound(2), bound(1)+bound(2)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 2) ;

    c = colorbar ;
    % if p.Inversion
    %     set(get(c, 'Title') , 'String' , 'source') ;
    %     set(get(c, 'XLabel'), 'String' , 'sink') ;
    % else
    %     set(get(c, 'Title') , 'String' , 'sink') ;
    %     set(get(c, 'YLabel'), 'String' , 'source') ;
    % end
    % set(get(c, 'Title') , 'FontWeight', 'bold') ;
    % set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

    xlabel('time (ms)', 'FontSize', 12) ;
    ylabel('depths (mi)', 'FontSize', 12) ;
    title(['\fontsize{18} \bf Mean of CSD',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
   if p.Save
          if ~isempty(output)
            saveas(gca, [output, '/CSD/csd_mean_img.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\CSD\csd_mean_img.tiff'], 'tiffn') ;
          end
    end
    if ~p.Visible, close all ; end
    disp('Plots generated') ;