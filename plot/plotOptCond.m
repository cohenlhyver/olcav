function plotOptCond(zone, varargin)

    global NB_COND NB_STIM UNITS SAMPLE_FREQ ;


    p = inputParser ;
      p.addOptional('TypeOfExperiment', 'Aud') ;
      p.addOptional('Visible', 'On') ;
      p.addOptional('Save', false) ;
      p.addOptional('output', '') ;
    p.parse(varargin{:}) ;
    p = p.Results ;

    if strcmp(p.TypeOfExperiment, 'Vis'),
        nrow = 5 ;
        ncol = 8 ;
        lim = [1:32] ;
    else
        nrow = 1 ;
        ncol = 6 ;
        lim = [1:6] ;
    end
    
    conditions = getappdata(0, 'conditions') ;

    pP = getappdata(0, 'pP') ;
    bound = pP.bound ;
    timetab = pP.timetab ;
    ticks = pP.ticks ;
    depths = zone.depths ;
    tmpf=strfind(zone.output, '\') ;
    f = figure('Visible', 'off') ;

    nb_depths = length(zone.depths) ;
    h = subplot(1, 6, 1:6, 'XLim'      , [0, NB_COND+3],...
                         'XTick'     , 1:NB_COND+3,...
                         'XTickLabel', {conditions{1:NB_COND}, '', 'mean+std', ''},...
                         'YLim'      , [zone.depths(1)-100, zone.depths(end)+100],...
                         'YTick'     , zone.depths,...
                         'YTickLabel', zone.depths,...
                         'YDir'      , 'Reverse',...
                         'FontSize'  , 8,...
                         'Parent'    , f) ;
                         %'Position'  , [0.08, 0.06, 0.86, 0.90],...
    [a, b] = max(zone.spikes_all) ;
    [c, d] = min(zone.spikes_all) ;
    % setappdata(0, 'ab', [a, b]) ;
    % setappdata(0, 'cd', [c, d]) ;
    nb_spikes = [] ;
    % h2 = subplot(1, 6, 5, 'Parent', f) ;
    % h3 = subplot(1, 6, 6, 'Parent', f) ;
    hold on ;
    for iDepth = 1:nb_depths
        dp = zone.depths(iDepth) ;
      % line([b(iDepth) d(iDepth)], [zone.depths(iDepth) zone.depths(iDepth)],...
      %      'Color', 'k') ;
      handles_plot(iDepth) = plot(h, b(iDepth), dp,...
                                  'r.',...
                                  'MarkerSize', (a(iDepth)*40/max(a))+10,...
                                  'Tag', num2str(iDepth)) ;
      handles_plot2(iDepth) = plot(h, d(iDepth), dp,...
                                  'c.',...
                                  'MarkerSize', (c(iDepth)*40/max(a))+10,...
                                  'Tag', num2str(iDepth)) ;
      idx = 1:NB_COND ;
      idx(idx == b(iDepth)) = [] ;
      idx(idx == d(iDepth)) = [] ;
      for iCond = idx
          plot(h, iCond, dp,...
               'Marker', '.',...
               'MarkerSize', (zone.spikes_all(iCond, iDepth)*40/max(a))+10,...
               'Color', [180 180 180]/255) ;
      end
      plot(h, NB_COND+2, dp,...
           'k.',...
           'MarkerSize', (mean(zone.spikes_all(:, iDepth))*40/max(a))+10) ;
      nb_spikes = [nb_spikes, size(zone.subzones{iDepth}.spikes_raw, 1)] ;
    end

    for iDepth = 1:nb_depths
      if a(iDepth) == c(iDepth)
          text(b(iDepth), zone.depths(iDepth)+nb_depths,...
               ['\fontsize{8} \color[rgb]{0 0.2 0.6} \bf', num2str(a(iDepth)), ' / ', num2str(nb_spikes(iDepth))]) ;
               % ['\fontsize{8} \color[rgb]{0 0.2 0.6} \bf min & max = ', num2str(a(iDepth)), ' -- ', num2str(nb_spikes(iDepth))]) ;
      else
          text(b(iDepth)+0.1, zone.depths(iDepth)+nb_depths+30,...
               ['\fontsize{10} \color[rgb]{1 0.2 0.2} \bf', num2str(a(iDepth))]) ;
          text(d(iDepth)+0.1, zone.depths(iDepth)+nb_depths+30,...
               ['\fontsize{10} \color[rgb]{0 0.2 0.6} \bf', num2str(c(iDepth))]) ;
      end
      m = mean(zone.spikes_all(:, iDepth)) ;
      m = num2str(round(m*100)/100) ;
      s = std(zone.spikes_all(:, iDepth)) ;
      s = num2str(round(s*100)/100) ;
      text(NB_COND+2+0.1, zone.depths(iDepth)+nb_depths+30,...
               ['\fontsize{8} \color[rgb]{0 0 0}', m, '+', s]) ;
      % text(b(iDepth), zone.depths(iDepth)+nb_depths,...
      %          ['\fontsize{8} \color[rgb]{0 0.2 0.6}', num2str(nb_spikes(iDepth))], 'Parent', h2) ;
    end
    yl = get(h, 'YLim') ;
    % text(-1.25, yl(1)-50,...
    %            ['\fontsize{8} \color[rgb]{0 0 0} \bf to cortex']) ;
    % text(-1.25, yl(2)+50,...
    %            ['\fontsize{8} \color[rgb]{0 0 0} \bf to white matter']) ;
    xlabel('Condition', 'FontSize', 12) ;
    ylabel('Depth', 'FontSize', 12) ;
    % title('Optimal Condition (based on spikes)') ;
    title(['\fontsize{11} \bf Optimal Condition (based on spikes)',...
           '\newline \fontsize{10} \it               ', zone.name, '(', zone.output(end-1:end), ')'],...
           'HorizontalAlignment', 'center') ;
    grid on ; 
    hold off ;

     if strcmp(p.TypeOfExperiment, 'Vis')

        angle = [270 :45: 360, 45 :45: 225] ;
        y1 = [0, 0.08] ;
        x = [0, pi/4, 1, pi/4, 0, -pi/4, -1, -pi/4] ;
        y = [-1, -pi/4, 0, pi/4, 1, pi/4, 0, -pi/4] ;
        x2 = [-1, 1 ;...
              -pi/4, pi/4 ;...
              0, 0 ;...
              -pi/4, pi/4 ;...
              -1, 1 ;...
              -pi/4, pi/4 ;...
              0, 0 ;...
              -pi/4, pi/4] ;

        y2 = [0, 0 ;...
              -pi/4, pi/4 ;...
              -1, 1 ;...
              pi/4, -pi/4 ;...
              0, 0 ;...
              -pi/4, pi/4 ;...
              -1, 1 ;...
              pi/4, -pi/4] ;

        for iAngle = [2:numel(angle), 1]

            h(iAngle) = subplot(5, 8, 32+iAngle, 'Parent', f) ;
            set(h(iAngle), 'Position', [0.165+(iAngle-1)*0.07, y1(mod(iAngle, 2)+1), 0.07, 0.2]) ;
            a = angle(iAngle)*pi/180 ;
            
            polar([a, a], [0, 0.85]) ;
            tmp = get(h(iAngle), 'Children') ;
            set(tmp, 'LineWidth', 2, 'Color', 'k') ; % 'Marker', 'v', 'MarkerSize', 7, 'MarkerFaceColor', 'k') ;
            arrow([0, 0], [x(iAngle), y(iAngle)], 5) ;
            line(x2(iAngle, :), y2(iAngle, :), 'Color', 'k', 'LineWidth', 1.5) ; %, 'LineStyle', '--') ;
            % line(x2(iAngle, :), y2(iAngle, :)+0.05, 'Color', 'k', 'LineWidth', 1.5) ;%, 'LineStyle', '--') ;
            % line(x2(iAngle, :), y2(iAngle, :)-0.05, 'Color', 'k', 'LineWidth', 1.5) ; %, 'LineStyle', '--') ;
        end
    end
     if p.Save
          if ~isempty(output)
            saveas(gca, [output, '/opt_cond.tiff'], 'tiffn') ;
          else
            saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\opt_cond.tiff'], 'tiffn') ;
          end
        
    end
    if ~p.Visible
        close all ;
    end
    disp('Plots generated') ;