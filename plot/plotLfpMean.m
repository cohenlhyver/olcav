function plotLfpMean(zone, varargin)

    global NB_COND...
           NB_STIM...
           UNITS...
           SAMPLE_FREQ ;

    pP = getappdata(0, 'pP') ;

    p = inputParser ;
      p.addOptional('Constant', zone.constants.lfp) ;
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

    % p.Depths
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
    tmpf = strfind(zone.output, '\') ;
    figure('Visible', p.Visible) ; 
    hold on ;
    tmp = zeros(length(depths), length(idx(1):idx(2))) ;
    % length(depths)

    data = cell2mat(arrayfun(@(x) zone.subzones{x}.lfp_mean(idx(1):idx(2)), depths_idx(1):depths_idx(end), 'UniformOutput', false)') ;
    tmp = data ;
    l = length(depths_idx) ;

    steps = p.Constant*[0:l-1]' ;
    data = bsxfun(@minus, data, steps) ;
    
    plot(timetab, data, 'Color', 'blue', 'LineWidth', 1.5) ;

    % for iDepth = 1:length(depths)
    %     step = p.Constant * (iDepth-1) ;
    %     %if iDepth == 18
    %     %    plot(zeros(1, size(zone.csd_mean, 2))) ;
    %     %else 
    %     %tmp(iDepth, :) = zone.subzones{iDepth}.lfp_mean(idx(1):idx(2)) ;

    %     %tmp(iDepth, :) = zone.subzones{depths_idx(iDepth)}.lfp_mean(idx(1):idx(2)) ;
    % 	% plot(timetab, tmp(iDepth, :) - step, 'LineWidth', 1.5) ;

    %     %end
    % 	line(get(gca, 'XLim'), [-step -step],...
    %          'Color', 'k',...
    %          'LineStyle', '--') ;
        
    % end
    %%tmp(18, :) = zeros(1, size(zone.csd_mean, 2)) ;
    if sum(ticks) > 500
        tstep = 50 ;
    elseif sum(ticks) <= 500
        tstep = 20 ;
    end
    % step = step/(iDepth-1) ;
    step = steps(end)/(l-1) ;
    set(gca, 'XLim'      , [-bound(1), idx(2)-bound(1)],...
             'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ):idx(2)-bound(1)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
             'YTick'     , -step*(length(depths)-1 :-1: 0),...
             'YTickLabel', depths(end :-1: 1),...
             'YLim'      , -step*([length(depths)+2, -2]),...
             'XMinorTick', 'on',...
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
    title(['\fontsize{18} \bf Mean of Local Field Potentials',...
           '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
           'HorizontalAlignment', 'center') ;
    

    if p.Save
        if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp_mean.tiff'], 'tiffn') ;
        else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp_mean.tiff'], 'tiffn') ;
        end
    end

    if ~p.Visible, close all ; end


    % setappdata(0, 'lfpraw', tmp) ;
    % --- IMAGE
    figure('Visible', p.Visible) ;
    imagesc(tmp) ;
    % colormap(flipud(colormap)) ;
    m = max(max(abs(tmp))) ;
    caxis([-m, m]) ;
    set(gca, 'XLim'      , [0, sum(bound)],...
             'XTick'     , [0 :round(0.001*tstep*SAMPLE_FREQ): sum(bound)],...
             'XTickLabel', [-ticks(1) :tstep: sum(ticks)],...
             'XMinorTick', 'on',...
             'YTick'     , 1:length(depths),...
             'YTickLabel', depths,...
             'FontSize'  , 8) ;

    line([bound(1), bound(1)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 2) ;
    line([bound(1)+bound(2) bound(1)+bound(2)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 2) ;

    %caxis = [-5, 5] ;

    c = colorbar ;
    set(get(c, 'Title'), 'String', 'positive') ;
    set(get(c, 'Title'), 'FontWeight', 'bold')
    set(get(c, 'XLabel'), 'String', 'negative') ;
    set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

    xlabel('time (ms)', 'FontSize', 12) ;
    ylabel('depths (mi)', 'FontSize', 12) ;
    title(['\fontsize{18} \bf Mean of Local Field Potentials',...
           '\newline \fontsize{14} \it ', zone.name],...
           'HorizontalAlignment', 'center') ;

    if p.Save
        if ~isempty(output)
            saveas(gca, [output, '/LFP/lfp_mean_img.tiff'], 'tiffn') ;
        else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\LFP\lfp_mean_img.tiff'], 'tiffn') ;
        end
    end

    if ~p.Visible, close all ; end
    disp('Plots -- Mean of LFPs -- have been successfully generated')
