%% nlxRecProc function
% ----------------------------------------------------------------
% Neurlaynx Recordings Processing function
% 
% Benjamin Cohen-Lhyver (@Collège de France - UMR 7152) - February 2013

function [data, spikes] = nlxRecProc2(folder)
    global NB_COND NB_TRIALS SAMPLE_FREQ SET HI_CUT GAIN ;

    parameters = getappdata(0, 'parameters') ;
    parameters = structfun(@(x) (str2double(x)), parameters.(SET), 'UniformOutput', false) ;

    % --- Neuralynx data processing 
    [time_stamps, ttl] = Nlx2MatEV(fullfile(folder, 'Events.nev'), [1 0 1 0 0], 0, 1) ;
    event              = find((ttl == 0), 1, 'last') + 1 ;
    %stim_time          = 0.001 * (time_stamps(event+1) - time_stamps(event)) ;
    stim_time          = parameters.lstim ;
    pre_stim_ms        = parameters.bline ;
    pre_stim           = 1000*pre_stim_ms ;
    post_stim_ms       = parameters.after ;
    post_stim          = 1000*post_stim_ms ;
    boundaries         = round(0.001*SAMPLE_FREQ*[pre_stim_ms, stim_time, post_stim_ms]) ;
    flags.events = event :2: 2*NB_COND*NB_TRIALS+1 ;
    flags.starts = time_stamps(flags.events) ;
    flags.stops  = time_stamps(flags.events+1) ;
    flags.index  = dec2bin(ttl(flags.events)) ;
    flags.index  = bin2dec(flags.index(:, end-4:end))' ;
    data = [] ;
    d = dir(folder) ;
    if any(strcmp({d.name}, 'CSC1.ncs'))
        data            = zeros(NB_COND, sum(boundaries)) ;
        [timestamps,...
         samples]       = Nlx2MatCSC(fullfile(folder, 'CSC1.ncs'), [1 0 0 0 1], 0, 1, []) ;
         %samples = reshape(samples, 1, numel(samples)) ;
        flags.twdows = [(flags.starts-pre_stim-1)', (flags.stops+post_stim+1)'] ;
        % --- faire la boucle for ici
        flags.blines = [arrayfun(@(x) (find(timestamps < x, 1, 'last')), flags.twdows(:, 1)),...
                        arrayfun(@(x) (find(timestamps >= x, 1, 'first')-1), flags.twdows(:, 2))] ;
        flags.stim   = [arrayfun(@(x) (find(timestamps < x, 1, 'last')), flags.starts)',...
                        arrayfun(@(x) (find(timestamps >= x, 1, 'first')-1), flags.stops)'] ;

        l            = 1:size(flags.stim, 1) ;
        samples_in   = arrayfun(@(x) (samples(:, flags.stim(x, 1):flags.stim(x, 2)))  , l, 'UniformOutput', false) ;
        samples_bef  = arrayfun(@(x) (samples(:, flags.blines(x, 1):flags.stim(x, 1))), l, 'UniformOutput', false) ;
        samples_aft  = arrayfun(@(x) (samples(:, flags.stim(x, 2):flags.blines(x, 2))), l, 'UniformOutput', false) ;
        
        stim         = cellfun(@(x) (reshape(x, numel(x), 1))     , samples_in,  'UniformOutput', false) ;
        stim_cut     = cellfun(@(x) (x(1:boundaries(2)))          , stim,        'UniformOutput', false) ;
        before       = cellfun(@(x) (reshape(x, numel(x), 1))     , samples_bef, 'UniformOutput', false) ;
        before_cut   = cellfun(@(x) (x((end-boundaries(1)+1):end)), before,      'UniformOutput', false) ;
        m            = cellfun(@(x) (mean(x)), before_cut, 'UniformOutput', false) ;
        after        = cellfun(@(x)  (reshape(x, numel(x), 1))     , samples_aft, 'UniformOutput', false) ;
        %not_av       = cellfun(@(x)  (length(x))                   , stim,        'UniformOutput', false) ;
        after_cut    = arrayfun(@(x) (after{x}(1:boundaries(3))'),...
                                l, 'UniformOutput', false) ;
        whole        = arrayfun(@(x) ([before_cut{x}', stim_cut{x}', after_cut{x}]-m{x}), l, 'UniformOutput', false) ;
        
        for iEvent = l
            data(flags.index(iEvent), :) = data(flags.index(iEvent), :) + whole{iEvent} ;
        end
        data = data / (NB_TRIALS*GAIN) ;
    end
    % --- Spikes processing
    spikes = [] ;
    if any(strcmp({d.name}, 'SE1.nse')) 
        [samples]  = Nlx2MatSpike(fullfile(folder, 'SE1.nse'), [0 0 0 0 1], 0, 1, []) ;
        if all(samples == 0)
            warndlg('No spikes have been detected', 'NO SPIKES') ;
            spikes.raw = [] ;
            spikes.tuning = [] ;
            spikes.mean = [] ;
            spikes.raster = [] ;
        else
            idx = flags.events(1) ;
            for iTrial = 1:NB_TRIALS
                for iCond = 1:NB_COND 
                    startstop = [time_stamps(idx)-20*1000, time_stamps(idx+1)+20*1000] ;
                    [timestamps] = Nlx2MatSpike(fullfile(folder, 'SE1.nse'), [1 0 0 0 0], 0, 4, startstop) ;
                    if timestamps(1) < startstop(1), timestamps = timestamps(2:end) ; end
                    iStim  = dec2bin(ttl(idx)) ;
                    iStim  = bin2dec(iStim(:, end-4:end))' ;
                    spikes.tuning(iStim, iTrial) = length(timestamps) ;
                    spikes.raster{iStim, iTrial} = timestamps - time_stamps(idx) ;
                    idx = idx + 2 ;
                end
            end

            samples = reshape(samples, size(samples, 1), size(samples, 3))' ;
            tmp = bsxfun(@minus, samples, mean(samples, 2)) ;
            tmp = bsxfun(@rdivide, tmp, std(samples, 0, 2)) ;
            spikes.raw = tmp ;
            spikes.mean = mean(tmp, 1) ;
        end
    end

% --------------------%
% --- END OF FILE --- %
% --------------------%