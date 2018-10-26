% takes the zone''.subzones{''} as an input
function data = lfpFilter(subzone, varargin)


    sample_freq = subzone.parameters.sample_freq ;
    if ~isempty(varargin) 
        lp_lfp = varargin{1} ;
        hp_lfp = varargin{2} ;
    else
        lp_lfp = subzone.parameters.lp_lfp ;
        hp_lfp = subzone.parameters.hp_lfp ;
    end

    lfp = arrayfun(@(iCond) (hilofilter(iCond, lp_lfp, sample_freq, 'low')),...
                   subzone.data.lfp, 'UniformOutput', false) ;

    lfp = arrayfun(@(iCond) (hilofilter(iCond, hp_lfp, sample_freq, 'high')),...
                   lfp, 'UniformOutput', false) ;

    data = lfp ;