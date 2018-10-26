function latencies = lfpLatencies(data)
    global SAMPLE_FREQ SET ;
   
    param = getappdata(0, 'parameters') ;
    if isfield(param, 'set0')
        if ischar(param.(SET).lp_lfp)
            param = structfun(@(x) (str2double(x)), param.(SET), 'UniformOutput', false) ;
        else
            param = param.(SET) ;
        end
    end
    st = 10*1000/SAMPLE_FREQ ;
    l = round(0.001*SAMPLE_FREQ*0.25*param.lstim) ;
    timetab1 = round(0.001*SAMPLE_FREQ*(param.bline-0.5*param.lstim :st: param.bline+param.lstim)) ;
    timetab2 = round(0.001*SAMPLE_FREQ*(param.bline+param.lstim :st: param.bline+param.lstim+param.after)-4*l-1) ;
    n = size(data, 1) ;
    latencies.resp = zeros(n, 2) ;
    latencies.bline = zeros(n, 2) ;
    bl = 1:round(0.001*SAMPLE_FREQ*param.bline) ;
    m = mean(data(:, bl), 2) ;
    s = std(data(:, bl), 0, 2) ;
    thr1 = m + 2*s ;
    thr2 = m + s ;
    for iCond = 1:n
        % --- threshold for detection
        flag = false ;
        for iWin = timetab1
            if all(data(iCond, iWin:iWin+l) > thr1(iCond)) ;
                flag = true ;
                break ;
            end
        end
        latencies.resp(iCond, :) = [iWin, round(1000*(iWin/SAMPLE_FREQ))-param.bline] ;
        % --- threshold for detection
        flag = false ;
        for iWin = timetab2
            if all(data(iCond, iWin:iWin+4*l) < thr2(iCond))
                flag = true ;
                break ;
            end
        end
        latencies.bline(iCond, :) = [iWin, round(1000*(iWin/SAMPLE_FREQ))-param.bline] ;
    end