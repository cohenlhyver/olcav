global NB_COND NB_STIM UNITS ;
% plot
zone = getappdata(0, 'zone1') ;
parameters = getappdata(0, 'parameters') ;
depths = zone.depths ;
global SAMPLE_FREQ NB_COND NB_STIM UNITS SET
%parameters = structfun(@(x) (str2double(x)), parameters.(SET), 'UniformOutput', false) ;
a = parameters.bline ; % 100
b = parameters.lstim ; % 100
c = parameters.after ; % 400
bound = round(0.001*SAMPLE_FREQ*[a,...
                                 b,...
                                 c]) ;
timetab = linspace(-bound(1),...
                    sum(bound) - bound(1),...
                    sum(bound)) ;
timetab_csd = linspace(1,...
                       sum(bound),...
                       sum(bound)-bound(1)) ;
ticks = round(bound/SAMPLE_FREQ*1000) ;
depthsStep = depths(2) - depths(1) ;

% --- CSD --- %
timeZone = [0.5*bound(1), bound(1)+2*bound(2)] ;
csdBound = mean(std(zone.csd_mean(:, timeZone(1):timeZone(2)), 0, 2)) ;
%dephts2remove = [28, 36, 42, 50] ;
pos = find(zone.depths >= zone.depths(1)+200, 1, 'first') ;
d = depths(end-(pos-1) :-1: pos) ;
%subplot(1, 2, 2) ;
val = 2*0.00002 ;
figure
hold on ;
%m = zone.csd_mean ;
%m = [zeros(1, size(m, 2)) ; m] ;
%m(1, :) = NaN ;
%m = [m ; m(1, :)] ;
for iDepth = 1:size(zone.csd_mean, 1)
    step = val * iDepth ;
    % csdMeanDepth = mean(zone.csd_mean(iDepth, :)) ;
    % csdBoundDepth = [csdMeanDepth - 3*csdBound ; csdMeanDepth + 3*csdBound] ;
    tmp = zone.csd_mean(iDepth, bound(1)+1:end) >= 0 ;
    %source = m(iDepth, bound(1):sum(bound)+bound(1)) ;
    source = zone.csd_mean(iDepth, bound(1)+1:end) ;
    %sink = m(iDepth, bound(1):sum(bound)+bound(1)) ;
    sink = source ; 
    source(tmp) = NaN ;
    sink(~tmp)  = NaN ;
    if std(zone.csd_mean(iDepth, bound(1)+1:end)) > 1.5*csdBound 
    %if any(dephts2remove == iDepth)
        %sink = zeros(size(zone.csd_mean(1, :))) ;
        plot(timetab_csd, sink-step, 'g', 'LineWidth', 2) ;
        plot(timetab_csd, source-step, 'c', 'LineWidth', 2) ;
    else
        plot(timetab_csd, sink-step, 'r', 'LineWidth', 2) ;
        plot(timetab_csd, source-step, 'b', 'LineWidth', 2) ;
        %tmp = m(iDepth, bound(1):sum(bound)+bound(1)) >= 0 ;
    end
    %if iDepth ~= 1 & iDepth ~= size(zone.csd_mean, 1)
    line(get(gca, 'XLim'), [-step, -step],...
         'Color'         , 'k',...
         'LineStyle'     , '--',...
         'LineWidth'     , 0.5) ;
    %end
end
set(gca, 'XLim'      , [0, sum(bound)-bound(1)],...
         'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
         'XTickLabel', [0 :50: sum(ticks)-ticks(1)],...
         'YTick'     , -val*(length(d)-1 :-1: 1),...
         'YTickLabel', d,...
         'YLim'      , -val*([length(d)+3, -2]),...
         'FontSize', 8) ;
xlabel(['time (', UNITS.time, ')']) ;
ylabel(['Depth (', UNITS.dim, ')']) ;
hold off ;
line([0, 0], get(gca, 'YLim'),...
     'Color', 'k',...
     'LineWidth', 0.5) ;
line([bound(2) bound(2)], get(gca, 'YLim'),...
     'Color', 'k',...
     'LineWidth', 0.5) ;

% --- LFP
%lfpBound = mean(std(zone.csd_mean, 0, 2)) ;
%bf = [1, length(depths)] ;
%subplot(1, 2, 1) ;
timeZone = [0.5*bound(1), bound(1)+3*bound(2)] ;
d = depths(end :-1: 1) ;
d = [d(1) + depthsStep ; d ; d(end) - depthsStep] ;
figure
hold on ;
%tmp = zeros(52, length(bound(1):sum(bound)+bound(1))) ;
tmp = 0 ;
for iDepth = 1:length(depths)
    tmp = tmp + 1 ;
    step = 1.5 * tmp ;
    t = zone.subzones{iDepth}.lfp_mean ;
    if std(t(timeZone(1):timeZone(2))) > 1
        plot(timetab, t - step, 'g') ;
    else
        plot(timetab, t - step) ;
    end
    line(get(gca, 'XLim'), [-step -step],...
         'Color', 'k',...
         'LineStyle', '--') ;
    %tmp(iDepth-4, :) = t ;
end
step = step/iDepth ;
set(gca, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
         'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
         'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
         'YTick'     , -step*(length(d)-2 :-1: 1),...
         'YTickLabel', d(2:end-1),...
         'YLim'      , -step*([length(d)+3, -2]),...
         'FontSize', 8) ;

xlabel(['time (', UNITS.time, ')']) ;
ylabel(['Depth (', UNITS.dim, ')']) ;
hold off ;
line([0 0], get(gca, 'YLim'),...
      'Color', 'k') ;
line([bound(2) bound(2)], get(gca, 'YLim'),...
      'Color', 'k') ;

% ---

figure ; 
imagesc(zone.csd_mean(:, bound(1)+1:end)) ; 
         %'XTickLabel', [-ticks(1)*2 :50: sum(ticks)-ticks(1)],...
set(gca, 'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
         'XTickLabel', [0 :50: sum(ticks)-ticks(1)],...
         'XMinorTick', 'on',...
         'YTick'     , 1:length(d),...
         'YTickLabel', d(end :-1: 1),...
         'FontSize', 8) ;
% line([bound(1), bound(1)], get(gca, 'YLim'),...
%      'Color', 'k',...
%      'LineWidth', 0.5) ;
%line([bound(2)+bound(1) bound(1)+bound(2)], get(gca, 'YLim'),...
line([bound(2) bound(2)], get(gca, 'YLim'),...
     'Color', 'k',...
     'LineWidth', 0.5) ;

c = colorbar ;
set(get(c, 'Title'), 'String', 'sink') ;
set(get(c, 'Title'), 'FontWeight', 'bold')
set(get(c, 'XLabel'), 'String', 'source') ;
set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

xlabel('time (ms)', 'FontSize', 14) ;
ylabel('depths (mi)', 'FontSize', 14) ;
title('Current Source Density across depths', 'FontSize', 20,...
                                              'FontWeight', 'bold') ;

% --- CSD
% NB_COND = 8 ;
% NB_STIM = 20 ;
depths = zone.depths ;
pos = find(zone.depths >= zone.depths(1)+200, 1, 'first') ;
d = depths(end-(pos-1) :-1: pos) ;

f=figure ; 
%subplot(1, 2, 2) ;
%imagesc(zone.csd_mean(:, bound(1):sum(bound)+bound(1))) ; 
imagesc(zone.csd_mean(:, bound(1)+1:end)) ; 
set(gca, 'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
         'XTickLabel', [0 :50: sum(ticks)],...
         'XMinorTick', 'on',...
         'YTick'     , 1:length(d),...
         'YTickLabel', d(end :-1: 1),...
         'FontSize', 8) ;
line([bound(2), bound(2)], get(gca, 'YLim'),...
     'Color', 'k',...
     'LineWidth', 0.5) ;
% line([bound(2)+bound(1) bound(1)+bound(2)], get(gca, 'YLim'),...
%      'Color', 'k',...
%      'LineWidth', 0.5) ;

c = colorbar ;
set(get(c, 'Title'), 'String', 'sink') ;
set(get(c, 'Title'), 'FontWeight', 'bold')
set(get(c, 'XLabel'), 'String', 'source') ;
set(get(c, 'XLabel'), 'FontWeight', 'bold') ;


xlabel('time (ms)', 'FontSize', 14) ;
ylabel('depths (mi)', 'FontSize', 14) ;
title('Mean Current Source Density across depths', 'FontSize', 20,...
                                              'FontWeight', 'bold') ;

% ---
subplot(1, 2, 1) ;
imagesc(tmp) ;
set(gca, 'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
         'XTickLabel', [-ticks(1)*2 :50: sum(ticks)-ticks(1)],...
         'XMinorTick', 'on',...
         'YTick'     , 1:25,...
         'YTickLabel', -400:100:2000,...
         'FontSize', 8) ;

xlabel(['time (', UNITS.time, ')']) ;
line([bound(1) bound(1)], get(gca, 'YLim'),...
      'Color', 'k') ;
line([bound(2)+bound(1) bound(2)+bound(1)], get(gca, 'YLim'),...
      'Color', 'k') ;

% --- Opt cond

figure ;
  nb_depths = length(zone.depths) ;
    h = subplot(1, 1, 1, 'XLim'      , [0, NB_COND+1],...
                         'XTick'     , 1:NB_COND,...
                         'XTickLabel', 1:NB_COND,...
                         'YLim'      , [zone.depths(1)-100, zone.depths(end)+100],...
                         'YTick'     , zone.depths,...
                         'YTickLabel', zone.depths,...
                         'YDir'      , 'Reverse',...
                         'FontSize'  , 8,...
                         'Position'  , [0.08, 0.06, 0.86, 0.90]) ;
    [a, b] = max(zone.spikes_all) ;
    [c, d] = min(zone.spikes_all) ;
    hold on ;
    nb_spikes = [] ;
    for iDepth = 1:nb_depths
        line([b(iDepth) d(iDepth)], [zone.depths(iDepth) zone.depths(iDepth)],...
             'Color', 'k') ;
        handles_plot(iDepth) = plot(h, b(iDepth), zone.depths(iDepth),...
                                    'r.',...
                                    'MarkerSize', (a(iDepth)*70/max(a))+10,...
                                    'Tag', num2str(iDepth)) ;
        handles_plot2(iDepth) = plot(h, d(iDepth), zone.depths(iDepth),...
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
    xlabel('Condition') ;
    ylabel('Depth') ;
    grid on ; 
    hold off ;


% --- AVREC

figure ;
hold on ;
plot(10^4*zone.avrec(:, 100:sum(bound))') ; 
plot(10^4*mean(zone.avrec(:, 100:sum(bound))), 'LineStyle', '--', 'LineWidth', 2, 'Color', 'r') ;
legend(gca, {'0.5 kHz', '1 kHz', '2 kHz', '4 kHz', '8 kHz', '16 kHz', '32 kHz', 'Mean of all stimuli'},...
            'FontSize', 12) ;
title('Averaged Rectified CSD', 'Fontsize', 20,...
                                'FontWeight', 'bold') ;
line([bound(2)+bound(1) bound(1)+bound(2)], get(gca, 'YLim'),...
     'Color', 'k',...
     'LineWidth', 0.5) ;
set(gca, 'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
         'XTickLabel', [-ticks(1)*2 :50: sum(ticks)-ticks(1)],...
         'FontSize', 8) ;
xlabel('time (ms)', 'FontSize', 14) ;
ylabel('Amplitude (mV)', 'FontSize', 14) ;



% --- CSD by condition
% NB_COND = 7 ;
% NB_STIM = 50 ;
depths = zone.depths ;
pos = find(zone.depths >= zone.depths(1)+200, 1, 'first') ;
conditions = {'0.5 kHz', '1 kHz', '2 kHz', '4 kHz', '8 kHz', '16 kHz', '32 kHz', '64 kHz'} ;
d = depths(end-(pos-1) :-1: pos) ;
for iCond = 1:NB_COND
    figure ; 
    imagesc(zone.csd{iCond}(:, bound(1):sum(bound))) ; 
    set(gca, 'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
             'XTickLabel', [0 :50: sum(ticks)],...
             'XMinorTick', 'on',...
             'YTick'     , 1:length(d),...
             'YTickLabel', d(end :-1: 1),...
             'FontSize', 8) ;
    % line([bound(1), bound(1)], get(gca, 'YLim'),...
    %      'Color', 'k',...
    %      'LineWidth', 0.5) ;
    line([bound(2) bound(1)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 0.5) ;

    c = colorbar ;
    set(get(c, 'Title'), 'String', 'sink') ;
    set(get(c, 'Title'), 'FontWeight', 'bold')
    set(get(c, 'XLabel'), 'String', 'source') ;
    set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

    xlabel('time (ms)', 'FontSize', 14) ;
    ylabel('depths (mi)', 'FontSize', 14) ;
    title(['Current Source Density across depths -- ', conditions{iCond}], 'FontSize', 20,...
                                                  'FontWeight', 'bold') ;
end


figure ; 
for iCond = 1:NB_COND
    subplot(3, 3, iCond) ;
    imagesc(zone.csd{iCond}(:, bound(1):sum(bound))) ;
    set(gca, 'XTick'     , [0 :round(50*SAMPLE_FREQ/1000): sum(bound)],...
             'XTickLabel', [0 :50: 250],...
             'XMinorTick', 'on',...
             'YTick'     , 1 :2: length(d),...
             'YTickLabel', d(end :-2 : 1),...
             'FontSize', 8) ;
    % line([bound(1), bound(1)], get(gca, 'YLim'),...
    %      'Color', 'k',...
    %      'LineWidth', 0.5) ;
    line([bound(2) bound(1)], get(gca, 'YLim'),...
         'Color', 'k',...
         'LineWidth', 0.5) ;

    c = colorbar ;
    set(get(c, 'Title'), 'String', 'sink') ;
    set(get(c, 'Title'), 'FontWeight', 'bold')
    set(get(c, 'XLabel'), 'String', 'source') ;
    set(get(c, 'XLabel'), 'FontWeight', 'bold') ;

    xlabel('time (ms)', 'FontSize', 10) ;
    ylabel('depths (mi)', 'FontSize', 10) ;
    title(conditions{iCond}, 'FontSize', 10, 'FontWeight', 'bold') ;
end

% ---

for iDepth = 1:length(depths)
    if mod(iDepth, 10) == 0
        figure
    end 
    subplot(10, 1, mod(iDepth-1, 10)+1) ;
    step = 1.5 * iDepth ;
    plot(timetab, zone.subzones{iDepth}.lfp' - step) ;
    line(get(gca, 'XLim'), [-step -step],...
         'Color', 'k',...
         'LineStyle', '--') ;
step = step/iDepth ;
set(gca, 'XLim'      , [-bound(1), sum(bound)-bound(1)],...
         'XTick'     , [-bound(1) :round(50*SAMPLE_FREQ/1000): sum(bound)-bound(1)],...
         'XTickLabel', [-ticks(1) :50: sum(ticks)-ticks(1)],...
         'FontSize', 8) ;
title([num2str(zone.depths(iDepth)), 'mi']) ;
xlabel(['time (', UNITS.time, ')']) ;
ylabel(['Depth (', UNITS.dim, ')']) ;
hold off ;
line([0 0], get(gca, 'YLim'),...
      'Color', 'k') ;
line([bound(2) bound(2)], get(gca, 'YLim'),...
      'Color', 'k') ;
end
