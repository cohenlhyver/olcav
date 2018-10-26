function plotCsdByCond(zone, varargin)

    global NB_COND...
           NB_STIM...
           UNITS...
           SAMPLE_FREQ ;

    pP = getappdata(0, 'pP') ;

    p = inputParser ;
      p.addOptional('Constant', zone.constants.csd) ;
      p.addOptional('timeFlags', pP.ticks([1, 3])) ;
      p.addOptional('timeBeforeOnset', pP.ticks(1)) ;
      p.addOptional('timeAfterOffset', pP.ticks(3)) ;
      p.addOptional('Depths', [zone.depths(1), zone.depths(end)]) ;
      p.addOptional('Visible', 'on') ;
      p.addOptional('Save', false) ;
      p.addOptional('Output', '') ;
    p.parse(varargin{:}) ;
    p = p.Results ;

    % p.Depths = [350, 1500] ;
    ticks = [p.timeBeforeOnset, pP.ticks(2), p.timeAfterOffset] ;

    bound = round(0.001*SAMPLE_FREQ*ticks) ;

    idx = [pP.bound(1)-bound(1), pP.bound(1)+pP.bound(2)+bound(3)] ;
    % idx = [1, pP.bound(1)+pP.bound(2)+bound(3)] 

    if idx(1) == 0, idx(1) = 1 ; end

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
    % depths_idx = depths_idx - 2 ;


    conditions = getappdata(0, 'conditions') ;
    fconditions = getappdata(0, 'fconditions') ; 

    if isempty(p.Output)
        tmpf = strfind(zone.output, '\') ;
    else
        output = p.Output ;
    end

    % timetab_csd = linspace(1,...
    %                        sum(bound),...
    %                        sum(bound)-bound(1)) ;
    % timeZone = [0.5*bound(1), bound(1)+2*bound(2)] ;
    % csdBound = mean(std(zone.csd_mean(:, timeZone(1):timeZone(2)), 0, 2)) ;
    % pos = find(zone.depths >= zone.depths(1)+200, 1, 'first') ;
    % d = depths(end-(pos-1) :-1: pos) ;
    d = depths(end :-1: 1) ;

    if sum(ticks) > 500
        tstep = 50 ;
    elseif sum(ticks) <= 500
        tstep = 20 ;
    end

    step = p.Constant * (1 : length(d)) ;
    % idx
    for iCond = 1:NB_COND
        figure('Visible', p.Visible) ;
        disp(['condition ', num2str(iCond)]) ;
        plot(bsxfun(@minus, zone.csd{iCond}(depths_idx, idx(1):idx(2))', step), 'b') ;
        
        % set(gca, 'XLim'      , [-bound(1), idx(2)-bound(1)],...
        %          'XTick'     , [-bound(1) :round(0.001*tstep*SAMPLE_FREQ): idx(2)-bound(1)],...
        %          'XTickLabel', [-ticks(1) :tstep: sum(ticks)-ticks(1)],...
        %          'YTick'     , -p.Constant*(length(d) :-1: 1),...
        %          'YTickLabel', d,...
        %          'YLim'      , [min(zone.csd{iCond}(depths_idx(end), idx(1):idx(2)))-0.00005-step(end), max(zone.csd{iCond}(depths_idx(1), idx(1):idx(2)))+0.00005],...
        %          'FontSize'  , 8) ;
        set(gca, 'XLim'      , [0, sum(bound)],...
                 'XTick'     , [0 :round(0.001*tstep*SAMPLE_FREQ): sum(bound)],...
                 'XTickLabel', [-ticks(1) :tstep: sum(ticks)],...
                 'YTick'     , -p.Constant*(length(d) :-1: 1),...
                 'YTickLabel', d,...
                 'YLim'      , [min(zone.csd{iCond}(depths_idx(end), idx(1):idx(2)))-1.1*step(end), max(zone.csd{iCond}(depths_idx(1), idx(1):idx(2)))+1.5*p.Constant],...
                 'FontSize'  , 8) ;
        line([bound(1), bound(1)], get(gca, 'YLim'),...
             'Color', 'k',...
             'LineWidth', 2) ;
        line([bound(1)+bound(2), bound(1)+bound(2)], get(gca, 'YLim'),...
             'Color', 'k',...
             'LineWidth', 2) ;
        line(get(gca, 'XLim'), [-step' -step'],...
              'Color', 'k',...
              'LineStyle', '--') ;
        xlabel(['time (ms)'], 'FontSize', 12) ;
        ylabel(['Depth (microns)'], 'FontSize', 12) ;
        title(['\fontsize{18} \bf CSD (', conditions{iCond}, ')',...
               '\newline \fontsize{14} \it ', zone.name, ' -- ', zone.output(end-1:end)],...
               'HorizontalAlignment', 'center') ;
        if p.Save
          if ~isempty(output)
            saveas(gca, [output, '/CSD/csd', fconditions{iCond}, '.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\CSD\csd' fconditions{iCond}, '.tiff'], 'tiffn') ;
          end
        end
    end
    
    disp('Plots generated') ;
    if ~p.Visible, close all ; end
end