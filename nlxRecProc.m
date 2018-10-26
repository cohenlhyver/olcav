%% nlxRecProc function
% ----------------------------------------------------------------
% Neurlaynx Recordings Processing function
% 
% Benjamin Cohen-Lhyver (@Collège de France - UMR 7152) - February 2013

function [data, spikes] = nlxRecProc(folder, varargin)
    global NB_COND NB_TRIALS SAMPLE_FREQ SET HI_CUT GAIN ;

    if ~isempty(varargin)
        iCSC = varargin{1} ;
    else
        iCSC = 1 ;
    end
    %parameters = getappdata(0, 'parameters') ;
    %spec = getappdata(0, 'spec') ;
    % parameters = spec.parameters ;
    % if ischar(parameters.(SET).lp_lfp)
    %     parameters = structfun(@(x) (str2double(x)), parameters.(SET), 'UniformOutput', false) ;
    % else
    %     parameters = parameters.(SET) ;
    % end
    parameters = getappdata(0, 'parameters') ;
    if isfield(parameters, 'set0'), parameters = parameters.set0 ; end
    if ischar(parameters.lp_lfp)
        parameters = structfun(@(x) (str2double(x)), parameters, 'UniformOutput', false) ;
    end
    % --- Neuralynx data processing
    if ispc
        [time_stamps, ttl] = Nlx2MatEV(fullfile(folder, 'Events.nev'), [1 0 1 0 0], 0, 1) ;
    elseif isunix
        [time_stamps, ttl] = Nlx2MatEV_v3(fullfile(folder, 'Events.nev'), [1 0 1 0 0], 0, 1) ;
    end
    tmp = time_stamps(1) ;
    time_stamps = time_stamps - time_stamps(1) ;
    event = find((ttl(1:10) == 0), 1, 'last') + 1 ;
    if ttl(event) == ttl(event+2),
        event = event+1 ;
    end
    boundaries = round(0.001*SAMPLE_FREQ*[parameters.bline, parameters.lstim, parameters.after]) ;
    flags.events = event :2: 2*NB_COND*NB_TRIALS+1 ;
    for iTtl = event:length(ttl)-1
        if ttl(iTtl) == ttl(event+1) && ttl(iTtl+1) == ttl(event+1)
            ttl = [ttl(1:iTtl), ttl(iTtl+2:end)] ;
        %elseif ttl(iTtl) ~= ttl(event+1) && ttl(iTtl+1) ~= ttl(event+1)
        elseif all(ttl(iTtl:iTtl+1) ~= ttl(event+1))
            ttl = [ttl(1:iTtl), ttl(event+1), ttl(iTtl+1:end)] ;
        end
    end
    flags.starts = time_stamps(flags.events) ;
    flags.stops  = time_stamps(flags.events+1) ;
    BOOL_STOP = false ;
    while ~BOOL_STOP
        if ispc
            flags.index = dec2bin(ttl(flags.events)) ;
            flags.index = bin2dec(flags.index(:, end-4:end))' ;
        elseif isunix
            flags.index = ttl(flags.events) - min(ttl(flags.events)) + 1 ;
        end
        pb = find(flags.index == 0, 1, 'first') ;
        if isempty(pb)
            BOOL_STOP = true ;
        else
            ttl = [ttl(1:(pb*2)-2), ttl(event+1), ttl((pb*2)-1:end)] ;
        end
    end
    data = [] ;
    d = dir(folder) ;

    % --- Spikes processing
    spikes = [] ;
    if any(strcmp({d.name}, 'SE1.nse')) 
        if ispc
            [time_stamps_spikes, samples] = Nlx2MatSpike(fullfile(folder, 'SE1.nse'), [1 0 0 0 1], 0, 1, []) ;
        elseif isunix
            [time_stamps_spikes, samples] = Nlx2MatSpike_v3(fullfile(folder, 'SE1.nse'), [0 0 0 0 1], 0, 1, []) ;
        end
        if all(samples == 0)
            global PRG_MODE ;
            if strcmp(PRG_MODE, 'On'), warndlg('No spikes have been detected', 'NO SPIKES') ; end
            spikes.raw         = [] ;
            spikes.tuning      = [] ;
            spikes.mean        = [] ;
            spikes.raster      = [] ;
            spikes.spontaneous = [] ;
            spikes.pb_trials   = [] ;
            pb_trials          = [] ;
        else
            time_stamps = time_stamps(event:end) ;
            time_stamps_spikes = time_stamps_spikes - tmp ;

            % starts = cell2mat(arrayfun(@(x) time_stamps(x) - 20000, 1 :2: NB_COND*NB_TRIALS*2, 'UniformOutput', false)) ;
            % stops  = cell2mat(arrayfun(@(x) time_stamps(x) + 20000, 2 :2: NB_COND*NB_TRIALS*2, 'UniformOutput', false)) ;

            % starts = flags.starts ;
            % stops = flags.stops ;

            aft = cell2mat(arrayfun(@(x) find(time_stamps_spikes >= x, 1, 'first'), flags.starts - (1000*1000*boundaries(1)/SAMPLE_FREQ), 'UniformOutput', false)) ;
            bef = cell2mat(arrayfun(@(x) find(time_stamps_spikes <= x, 1, 'last' ), flags.stops  + (1000*1000*boundaries(3)/SAMPLE_FREQ), 'UniformOutput', false)) ;
            
            % aft = cell2mat(arrayfun(@(x) find(time_stamps_spikes >= x, 1, 'first'), starts, 'UniformOutput', false)) ;
            % bef = cell2mat(arrayfun(@(x) find(time_stamps_spikes <= x, 1, 'last' ), stops, 'UniformOutput', false)) ;

            spikes.tuning = zeros(NB_COND, NB_TRIALS) ;
            spikes.raster = cell(NB_COND, NB_TRIALS) ;
            
            count = [] ;
            % for iStamp = 1:length(flags.index)
            %     iStim = flags.index(iStamp) ;
            %     iTrial = ceil(iStamp/NB_COND) ;
            %     tmp = bef(iStamp) - aft(iStamp) ;
            %     if tmp >= 0
            %         count = [count, aft(iStamp):bef(iStamp)] ;
            %         spikes.tuning(iStim, iTrial) = tmp + 1 ;
            %         spikes.raster{iStim, iTrial} = time_stamps_spikes(aft(iStamp):bef(iStamp)) - flags.starts(iStamp) ;
            %     end
            % end
            m1 = abs(length(flags.index)-length(bef)) ;
            m2 = abs(length(flags.index)-length(aft)) ;
            m = max([m1, m2])+1 ;
            for iStamp = m:length(flags.index)
                iStim = flags.index(iStamp) ;
                iTrial = ceil(iStamp/NB_COND) ;
                tmp = bef(iStamp-m+1) - aft(iStamp-m+1) ;
                if tmp >= 0
                    count = [count, aft(iStamp-m+1):bef(iStamp-m+1)] ;
                    spikes.tuning(iStim, iTrial) = tmp + 1 ;
                    spikes.raster{iStim, iTrial} = time_stamps_spikes(aft(iStamp-m+1):bef(iStamp-m+1)) - flags.starts(iStamp) ;
                end
            end
            % --- Checking for good trials
            s1 = sum(spikes.tuning) ;
            s2 = sum(s1) ;
            pb_trials1 = find(s1/s2 > 0.5) ;
            if ~isempty(pb_trials1)
                pb_trials = pb_trials1*NB_COND - (NB_COND - 1) ;
                for iTrial = 1:length(pb_trials)
                    % remove problematic trials from flags structure
                    flags.events(pb_trials(iTrial):(pb_trials(iTrial)+(NB_COND-1))) = [] ;
                    flags.starts(pb_trials(iTrial):(pb_trials(iTrial)+(NB_COND-1))) = [] ;
                    flags.stops(pb_trials(iTrial):(pb_trials(iTrial)+(NB_COND-1)))  = [] ;
                    flags.index(pb_trials(iTrial):(pb_trials(iTrial)+(NB_COND-1)))  = [] ;
                    % update spikes structure
                    spikes.raster(:, pb_trials1(iTrial)) = [] ;
                    spikes.tuning(:, pb_trials1(iTrial)) = zeros(NB_COND, 1) ;
                    pb_trials = pb_trials - NB_COND ;
                end
            else
                pb_trials = [] ;
            end
            samples = reshape(samples, size(samples, 1), size(samples, 3))' ;
            tmp = bsxfun(@minus, samples, mean(samples, 2)) ;
            tmp = bsxfun(@rdivide, tmp, std(samples, 0, 2)) ;
            sp = 1:size(samples, 1) ;
            sp(count) = [] ;
            spikes.spontaneous = samples(sp, :) ;
            spikes.raw = tmp(count, :) ;
            spikes.mean = mean(tmp(count, :), 1) ;
            spikes.pb_trials = pb_trials1 ;
        end
    end

    % --- LFP processing
    if any(strcmp({d.name}, 'CSC1.ncs'))
        data = zeros(NB_COND, sum(boundaries)) ;
        if ispc
            samples = Nlx2MatCSC(fullfile(folder, ['CSC', num2str(iCSC), '.ncs']), [0 0 0 0 1], 0, 1, []) ;
        elseif isunix
            samples = Nlx2MatCSC_v3(fullfile(folder, ['CSC', num2str(iCSC), '.ncs']), [0 0 0 0 1], 0, 1, []) ;
        end
        samples = samples(:)' ;
        % ---------
        % dif = samples(2:end) - samples(1:end-1) ;
        % val = 4570 ; % valeur du decalage
        % thresh = 2000 ; 
        % decalage = zeros(size(samples)) ;
        % for i = 1:5 
        %     decalage(find(dif > thresh+(i-1)*val)) = -i*val ;
        %     decalage(find(dif < -thresh-(i-1)*val)) = i*val ;
        % end
        % de = cumsum(decalage) ;
        % samples(2:end) = samples(2:end) + de(1:end-1) ;
        % ---------
        for iEvent = 1:(NB_COND*NB_TRIALS - NB_COND*length(pb_trials))
            bound = round(flags.starts(iEvent)/1e6*SAMPLE_FREQ) ;
            if (bound+sum(boundaries(2:3))) > size(samples, 2), return ; end
            data(flags.index(iEvent), :) = data(flags.index(iEvent), :)...
                                           + (samples(bound-boundaries(1):bound+sum(boundaries(2:3))-1)...
                                           - mean(samples(bound-boundaries(1):bound))) ;
        end

        data = data / (NB_TRIALS*GAIN) ;

    end

% --------------------%
% --- END OF FILE --- %
% --------------------%