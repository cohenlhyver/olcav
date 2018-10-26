function waveProcess(data)
	% --- needed:
	% length of baseline
	% --- Normalization
	data = (data - mean(data)) / std(data) ;
	bline = 3100 ;
	bline_mean = mean(data(1:bline)) ;
	bline_std = mean(data(1:bline)) ;
	threshold = bline_mean + (abs(bline_std)) ;
	flag = find(data >= threshold, 1, 'first') ;
	above = data ;
	above(1:flag) = data(1:flag) ;
	above(flag+1:end) = threshold ;

	X = [data, fliplr(above)] ;
	Y = [1:length(data), fliplr(1:length(above))] ;
	hold all ;
	fill(Y, X, 'r') ;
	alpha(0.20) ;
	clear X Y ;
	set(get(gca, 'Children'), 'Color', 'b') ;
