function [data_filtered, suppr_idx] = hiloFilter(data, cut_frequency, hilo)
    global SAMPLE_FREQ ; 
    tf_data = fft(data);

    cut_idx = round(cut_frequency / (SAMPLE_FREQ/length(data) + 1)) ;
    
    if strcmp(hilo, 'low') 
        suppr_idx = cut_idx:(length(tf_data) - cut_idx + 1) ;
    else
        suppr_idx = [(1:cut_idx), ((length(tf_data)-cut_idx+1):length(tf_data))] ;
    end
    tf_data(suppr_idx) = 0 ;
    
    data_filtered = real(ifft(tf_data)) ;

end