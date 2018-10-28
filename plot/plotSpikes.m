function plotSpikes(zone, varargin)

    global NB_COND...
           NB_STIM...
           UNITS...
           SAMPLE_FREQ ;

    pP = getappdata(0, 'pP') ;

    p = inputParser ;
    % p.addOptional('Constant', 2*0.00005) ;
    p.addOptional('timeFlags', pP.ticks([1, 3])) ;
    p.addOptional('timeBeforeOnset', pP.ticks(1)) ;
    p.addOptional('timeAfterOffset', pP.ticks(3)) ;
    p.addOptional('Depths', [zone.depths(1), zone.depths(end)]) ;
    p.addOptional('Visible', 'on') ;
    p.addOptional('Save', false) ;
    p.addOptional('Specific', 'all') ;
    p.addOptional('Output', '') ;
    % p.addOptional('Inversion', false) ;
    p.parse(varargin{:}) ;
    p = p.Results ;

    depths = zone.depths(find(zone.depths == p.Depths(1)):...
                         find(zone.depths == p.Depths(end))) ;
    depths_idx = [find(zone.depths == p.Depths(1)):...
                  find(zone.depths == p.Depths(end))] ;


    timetab_psth = linspace(-20,...
                            pP.ticks(3)+pP.ticks(2),...
                            (pP.ticks(2)+pP.ticks(3))/10) ;

    if isempty(p.Output)
        tmpf = strfind(zone.output, '\') ;
    else
        output = p.Output ;
    end

    conditions = getappdata(0, 'conditions') ;

% if strcmpi(p.Specific, 'spikes') || strcmpi(p.Specific, 'all')
%     textprogressbar('Generating Spikes plots - ') ;
%     pause(0.5) ;
%     % --- Spikes display
%     for iDepth = 1:length(depths)
%         textprogressbar(100*(iDepth/length(depths))) ;
%         sraw = zone.subzones{iDepth}.spikes_raw ;
%         if ~isempty(sraw)
%             smean = zone.subzones{iDepth}.spikes_mean ;
%             X = [min(sraw, [], 1), fliplr(max(sraw, [], 1))] ;
%             Y = [1:size(sraw, 2), fliplr(1:size(sraw, 2))] ;
%             % h = subplot(1, 1, 1, 'Parent', handles.pan_axe) ;
%             figure('Visible', p.Visible) ;
%             % h = suplot(1, 1, 1) ;
%             fill(Y, X, [190 255 250]/255, 'LineStyle', 'none') ;
%             hold on ;
%             % --- Raw data
%             plot(sraw') ;
%             % --- Mean data
%             plot(smean, 'LineWidth', 2.8, 'LineStyle', '--') ;
%             tmp = get(gca, 'YLim') ;
%             text(24, tmp(2)-0.25, ['spikes count:', num2str(size(sraw, 1))]) ;
%             hold off ;
%             set(gca, 'XLim', [0, size(sraw, 2)],...
%                      'FontSize', 8) ;
%             xlabel('time (ms)', 'Fontsize', 12) ;
%             ylabel('Normalized voltage (microVolt)', 'Fontsize', 12)
%             title(['\fontsize{14} \bf All Spikes and Mean of Spikes',...
%                    '\newline \fontsize{12} \sl', zone.name, '(', zone.output(end-1:end), ')',...
%                    ' -- ',num2str(depths(iDepth)), ' mi'],...
%                    'HorizontalAlignment', 'center') ;
%             if p.Save
%                 saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\Spikes\SP\SP_', num2str(depths(iDepth)), 'mi.tiff'], 'tiffn') ;
%             end
%         end
%     end
%     textprogressbar('Spikes plots generated') ;
%     pause(0.5) ;
% end
    % --- Display raw data
    % title(['All spikes (', num2str(size(sraw, 1)), ')']) ;
    % set(handles.tx_title, 'Visible', 'on',...
    %                      'String', ['number of spikes detected: ', num2str(size(sraw, 1))]) ;
    % set(handles.tx_title2, 'String', ['Depth: ', num2str(zone.depths(handles.idx))]) ;

% --- Raster display
if strcmpi(p.Specific, 'raster') || strcmpi(p.Specific, 'all')
    textprogressbar('Generating Raster plots - ') ;
    for iDepth = 1:length(depths)
        textprogressbar(100*(iDepth/length(depths))) ;
        % idx = str2double(get(gco, 'Tag')) ;
        % if ~isnan(idx), handles.idx = idx ; end
        
        % param = getappdata(0, 'parameters') ;
        % param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
        spikes = zone.subzones{iDepth}.spikes_raster ;
        if ~isempty(spikes)
            if size(spikes, 2) ~= NB_STIM
                spikes = cat(2, spikes, cell(NB_COND, NB_STIM - size(spikes, 2))) ;
            end
            figure('Visible', p.Visible) ;

            % set(handles.tx_title, 'String', 'Spikes Raster plot') ;
            % set(handles.tx_title2, 'String', ['Depth: ', num2str(handles.zone.depths(handles.idx))]) ;

            % set(handles.tx_title, 'String', 'Spikes Raster plot') ;

            nrow = ceil(sqrt(NB_COND)) ;
            ncol = ceil(NB_COND/nrow) ;
            
            for iCond = 1:NB_COND
                s = cell2mat(arrayfun(@(x) spikes{x}, iCond:NB_COND:numel(spikes), 'UniformOutput', false))/1000 ;
                subplot(nrow, ncol, iCond) ;
                hold on ;
                % rectangle('Position', [-20, 0, 20, NB_STIM],...
                %           'FaceColor', [190 255 250]/255,...
                %           'LineStyle', 'none') ;
                % rectangle('Position', [pP.ticks(2), 0, 20, NB_STIM],...
                %           'FaceColor', [190 255 250]/255,...
                %           'LineStyle', 'none') ;
                for iStim = 1:NB_STIM
                    points = spikes{iCond, iStim} / 1000 ;
                    ypos = ones(length(points), 1) * iStim ;
                    plot(points, ypos,...
                         '*k', 'MarkerSize', 2) ;
                    set(gca, 'FontSize', 8) ;
                end
                % if ~isempty(s)
                %     line([mean(s), mean(s)], get(gca, 'YLim'), 'Color', 'red', 'LineWidth', 2) ;
                % end
                % line([median(s), median(s)], get(gca, 'YLim'), 'Color', 'red') ;
                xlim([-30, p.timeAfterOffset+p.timeBeforeOnset+10]) ;
                ylim([0, NB_STIM+1]) ;
                line([0 0], get(gca, 'YLim')) ;
                line([pP.ticks(2) pP.ticks(2)], get(gca, 'YLim')) ;
                xlabel('time (ms)', 'Fontsize', 8) ,
                ylabel('trial number', 'Fontsize', 8) ;
                title(num2str(conditions{iCond}), 'FontWeight', 'bold') ;
                % boxplot(s, 'Orientation', 'horizontal', 'Boxstyle', 'filled') ;
                hold off ;
            end
        else
            for iCond = 1:NB_COND
                nrow = ceil(sqrt(NB_COND)) ;
                ncol = ceil(NB_COND/nrow) ;
                subplot(nrow, ncol, iCond) ;
                xlim([-30, p.timeAfterOffset+p.timeBeforeOnset+10]) ;
                ylim([0, NB_STIM+1]) ;
                line([0 0], get(gca, 'YLim')) ;
                line([pP.ticks(2) pP.ticks(2)], get(gca, 'YLim')) ;
                xlabel('time (ms)', 'Fontsize', 8) ,
                ylabel('trial number', 'Fontsize', 8) ;
                title(num2str(conditions{iCond}), 'FontWeight', 'bold') ;
            end
        end
        ax = axes('Position', [0, 0, 1, 1], 'Visible', 'off') ;
        tx = text(0.5, 0.97,...
                  ['\fontsize{12} \bf Raster plots -- ', num2str(depths(iDepth)), 'mi -- ', zone.name, '(', zone.output(end-1:end), ')'],...
                  'HorizontalAlignment', 'center') ;
        if p.Save
            if ~isempty(output)
                saveas(gca, [output, '/Spikes/RA/RA_', num2str(depths(iDepth)), 'mi.tiff'], 'tiffn') ;
            else
                saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\Spikes\RA\RA_', num2str(depths(iDepth)), 'mi.tiff'], 'tiffn') ;
            end
            
        end
    end
    textprogressbar('Raster plots generated') ;
    pause(0.5) ;
end

% --- PSTH

if strcmpi(p.Specific, 'psth') || strcmpi(p.Specific, 'all')
    textprogressbar('Generating PSTH - ') ;
    timetab_psth = linspace(-20,...
                            pP.ticks(2)+pP.ticks(3)+20,...
                            (pP.ticks(2)+pP.ticks(3))/10) ;

    max_tmp = 0 ;
    for iDepth = 1:length(depths)
        spikes = zone.subzones{iDepth}.spikes_raster ;
        if ~isempty(spikes)
            if size(spikes, 2) ~= NB_STIM
                spikes = cat(2, spikes, cell(NB_COND, NB_STIM - size(spikes, 2))) ;
            end
            cumul_all = cell(NB_COND, 1) ;

            for iCond = 1:NB_COND
                allstim_time = [] ;
                for iStim = 1:NB_STIM
                    pts_ms = spikes{iCond, iStim} / 1000 ;
                    pts_ms = pts_ms(pts_ms > 0) ;
                    pts_ms = pts_ms(pts_ms < 1000) ;
                    allstim_time = [allstim_time, squeeze(pts_ms)] ;
                end
                pts_cumul = hist(allstim_time, timetab_psth) ;
                cumul_all{iCond} = pts_cumul ;
                if max(cumul_all{iCond}) > max_tmp
                    max_tmp = max(cumul_all{iCond}) ;
                end
            end
        end
    end
    
    for iDepth = 1:length(depths)
        textprogressbar(100*(iDepth/length(depths))) ;
        spikes = zone.subzones{iDepth}.spikes_raster ;
        if ~isempty(spikes)
            if size(spikes, 2) ~= NB_STIM
                spikes = cat(2, spikes, cell(NB_COND, NB_STIM - size(spikes, 2))) ;
            end
            figure('Visible', p.Visible) ;
            cumul_best   = 0 ;
            cumul_all    = cell(NB_COND, 1) ;
            nrow = ceil(sqrt(NB_COND)) ;
            ncol = ceil(NB_COND/nrow) ;
            % max_tmp = 0 ;

            for iCond = 1:NB_COND
                allstim_time = [] ;
                for iStim = 1:NB_STIM
                    pts_ms = spikes{iCond, iStim} / 1000 ;
                    pts_ms = pts_ms(pts_ms > 0) ;
                    pts_ms = pts_ms(pts_ms < 1000) ;
                    allstim_time = [allstim_time, squeeze(pts_ms)] ;
                end
                pts_cumul = hist(allstim_time, timetab_psth) ;
                if max(pts_cumul) > cumul_best, cumul_best = max(pts_cumul) ; end
                cumul_all{iCond} = pts_cumul ;
                % if max(cumul_all{iCond}) > max_tmp
                %     max_tmp = max(cumul_all{iCond}) ;
                % end
                subplot(nrow, ncol, iCond) ;
                % rectangle('Position', [-20, 0, 20, NB_STIM],...
                %           'FaceColor', [190 255 250]/255,...
                %           'LineStyle', 'none') ;
                % rectangle('Position', [pP.ticks(2)+pP.ticks(3), 0, 20, NB_STIM],...
                %           'FaceColor', [190 255 250]/255,...
                %           'LineStyle', 'none') ;
                hold on ;
                % line([100, 100], [0, 0.1],...
                %      'Color', 'b',...
                %      'LineWidth', 2) ;
                bar(timetab_psth, cumul_all{iCond}) ;
                set(findobj(gca, 'Type', 'patch'), 'FaceColor', 'k', 'EdgeColor', 'k') ;
                % plot(0, 0, '^g', 'MarkerSize', 5) ;
                % plot(pP.ticks(3), 0, '^r', 'MarkerSize', 5) ;
                xlim([-30, p.timeBeforeOnset+p.timeAfterOffset+10]) ;
                if cumul_best == 0
                    cumul_best = 1 ;
                end

                if max_tmp == 0
                    max_tmp = 1
                end
                % ylim([0, (cumul_best/(NB_STIM*10)) + (cumul_best/(NB_STIM*10*20))]) ;

                ylim([0, max_tmp+1]) ;
                line([0 0], get(gca, 'YLim')) ;
                line([pP.ticks(2) pP.ticks(2)], get(gca, 'YLim')) ;
                % line(get(gca, 'XLim'), [mean(cumul_all{iCond}), mean(cumul_all{iCond})], 'LineWidth', 2, 'LineStyle', '--') ;
                % cs = cumsum(cumul_all{1}) ;
                % tmp_cs = find(cs >= cs(end)/2, 1, 'first') ;
                % line([tmp_cs*10, tmp_cs*10], get(gca, 'YLim'), 'LineWidth', 2, 'LineStyle', '--', 'Color', 'r') ;
                xlabel('time (msec)') ;
                ylabel('average spikes number by sec', 'Fontsize', 8) ;
                title(num2str(conditions{iCond}), 'FontWeight', 'bold') ;
                hold off ;
            end
            % title('PSTH of all conditions') ;
        else
            for iCond = 1:NB_COND
                nrow = ceil(sqrt(NB_COND)) ;
                ncol = ceil(NB_COND/nrow) ;
                subplot(nrow, ncol, iCond) ;
                xlim([-30, p.timeAfterOffset+p.timeBeforeOnset+10]) ;
                ylim([0, NB_STIM+1]) ;
                line([0 0], get(gca, 'YLim')) ;
                line([pP.ticks(2) pP.ticks(2)], get(gca, 'YLim')) ;
                xlabel('time (ms)', 'Fontsize', 8) ,
                ylabel('trial number', 'Fontsize', 8) ;
                title(num2str(conditions{iCond}), 'FontWeight', 'bold') ;
            end
        end
        % title('PSTH of all conditions') ;
        ax = axes('Position', [0, 0, 1, 1], 'Visible', 'off') ;
        tx = text(0.5, 0.97,...
                  ['\fontsize{12} \bf PSTH -- ', num2str(depths(iDepth)), 'mi -- ', zone.name, '(', zone.output(end-1:end), ')'],...
                  'HorizontalAlignment', 'center') ;
        if p.Save
            if ~isempty(output)
                saveas(gca, [output, '/Spikes/PSTH/PSTH_', num2str(depths(iDepth)), 'mi.tiff'], 'tiffn') ;
            else
                saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\Spikes\PSTH\PSTH_', num2str(depths(iDepth)), 'mi.tiff'], 'tiffn') ;
            end
        end
        % set(handles.tx_title2, 'String', ['Depth: ', num2str(handles.zone.depths(handles.idx))]) ;
    end
    textprogressbar('PSTH generated') ;
    pause(0.5) ;
end

% --------------------- %
% --- Tuning Curves --- %
if strcmpi(p.Specific, 'tcurves') || strcmpi(p.Specific, 'all')
    textprogressbar('Generating Tuning Curves - ') ;
    max_tmp = 0 ;
    min_tmp = 0 ;
    for iDepth = 1:length(depths)
        spikes = zone.subzones{iDepth}.spikes_tuning ;
        max_tmp = max([max_tmp, max(mean(spikes, 2)+std(spikes, 0, 2))]) ;
        min_tmp = min([min_tmp, min(mean(spikes, 2)-std(spikes, 0, 2))]) ;
    end
    for iDepth = 1:length(depths)
        textprogressbar(100*(iDepth/length(depths))) ;
        spikes = zone.subzones{iDepth}.spikes_tuning ;
        if ~isempty(spikes)
            figure('Visible', p.Visible) ;
            spikes_mean = mean(spikes, 2) ;
            spikes_std  = std(spikes, 0, 2) ;
            errorbar(1:NB_COND, spikes_mean, spikes_std) ;
            set(gca, 'Xtick', 0:length(conditions)+1,...
                     'XTickLabel', {'', conditions{1:NB_COND}, ''},...
                     'YLim', [min_tmp-5, max_tmp+5],...
                     'FontSize', 12) ;
            xlabel('Conditions') ;
            ylabel('Spikes Count') ;
            title(['\fontsize{14} \bf Tuning Curves',...
                   '\newline \fontsize{12} \sl ', zone.name, '(', zone.output(end-1:end), ')',...
                   ' -- ',num2str(depths(iDepth)), ' mi'],...
                   'HorizontalAlignment', 'center') ;
            if p.Save
                if ~isempty(output)
                    saveas(gca, [output, '/Spikes/TC/TC_', num2str(depths(iDepth)), 'mi.tiff'], 'tiffn') ;
                else
                    saveas(gca, [zone.output(1:tmpf(2)), 'Figures', zone.output(tmpf(2):end), '\Spikes\TC\TC_', num2str(depths(iDepth)), 'mi.tiff'], 'tiffn') ;
                end
                
            end
        end
    end
    textprogressbar('Tuning Curves generated') ;
end
% --- Tuning Curves --- %
% --------------------- %
