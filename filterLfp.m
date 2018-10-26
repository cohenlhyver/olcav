function data = filterLfp(data, filter_spec, filter_type)
    global NB_COND SAMPLE_FREQ ;

    Fc   = filter_spec{1} ;
    n    = filter_spec{2} ;
    hilo = filter_spec{3} ;

    switch filter_type
    case 'butter'
        [b, a] = butter(n, Fc/(SAMPLE_FREQ/2), hilo) ;
        Hd = dfilt.df2(b, a) ;
        %filter(Hd, data) ;
        data = arrayfun(@(x) (filter(Hd, data(x, :))), 1:NB_COND, 'UniformOutput', false) ;
    case 'cheby2'
        [b, a] = cheby2(n, 20, Fc/(SAMPLE_FREQ/2), hilo) ;
        %filtfilt(b, a, data) ;
        data = arrayfun(@(x) (filtfilt(b, a, data(x, :))), 1:NB_COND, 'UniformOutput', false) ;
    case 'fir1'
        [b a] = fir1(n, Fc/(SAMPLE_FREQ/2), hilo) ;
        %filtfilt(b, a, data) ;
        data = arrayfun(@(x) (filtfilt(b, a, data(x, :))), 1:NB_COND, 'UniformOutput', false) ;
    end
