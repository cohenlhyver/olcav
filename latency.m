function latencies = latency(point)
    global NB_COND SAMPLE_FREQ ;

    bline = str2double(point.parameters.bline) ;
    lstim = str2double(point.parameters.lstim) ;
    after = str2double(point.parameters.after) ;
    data = point.data.lfp ;
    timetab = round(0.001*SAMPLE_FREQ*(bline/2 :1/(0.001*SAMPLE_FREQ): (bline+lstim))+1) ;
    beg = round(0.001*SAMPLE_FREQ*(bline/2)) ;
    l = round(0.001*SAMPLE_FREQ*50) ;

    latencies = zeros(NB_COND, 2) ;

    for iCond = 1:NB_COND
        data(iCond, :) = (data(iCond, :) - mean(data(iCond, :))) / std(data(iCond, :)) ;
        threshold = mean(data(iCond, 1:round(0.001*SAMPLE_FREQ*bline)))...
                    + 3*std(data(iCond, 1:round(0.001*SAMPLE_FREQ*bline))) ;
        for iWin = timetab
            if all(data(iCond, iWin:iWin+l) > threshold), break ; end
        end
        latencies(iCond, :) = [iWin, round(1000*(iWin - lstim)/SAMPLE_FREQ)] ;
    end