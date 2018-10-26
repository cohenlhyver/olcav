function plot_compareCsd
	
	[fname, pname] = uigetfile('C:\', 'Choose a directory to be processed') ;
	tmp = load(fullfile(pname, fname)) ;
	zone1 = tmp.zone ;
	[fname, pname] = uigetfile('C:\', 'Choose a directory to be processed') ;
	tmp = load(fullfile(pname, fname)) ;
	zone2 = tmp.zone ;

	pos1 = find(zone1.depths >= zone1.depths(1)+200, 1, 'first') ;
	pos2 = find(zone2.depths >= zone2.depths(1)+200, 1, 'first') ;

	d1 = zone1.depths(pos1 : end-(pos1-1)) ;
	d2 = zone2.depths(pos2 : end-(pos2-1)) ;
	depths = [d1 ; d2] ;
	tmp = unique(depths) ;
	h = histc(depths, tmp) ;
	idx = find(h > 1) ;

	depths = tmp(idx) ;

	idx1 = [] ;
	idx2 = [] ;
	for iDepth = 1:length(idx)
		idx1 = [idx1, find(tmp(idx(iDepth)) == d1)] ;
		idx2 = [idx2, find(tmp(idx(iDepth)) == d2)] ;
	end

	step = 0.001 ;

	for iCond = 1:7
		figure ;
		norm1 = cell2mat(arrayfun(@(x) norm(zone1.csd{iCond}(idx1(x), :)), 1:length(idx1), 'UniformOutput', false)) ;
		csd1 = bsxfun(@rdivide, zone1.csd{iCond}(idx1, :), norm1') ;
		norm2 = cell2mat(arrayfun(@(x) norm(zone2.csd{iCond}(idx2(x), :)), 1:length(idx2), 'UniformOutput', false)) ;
		csd2 = bsxfun(@rdivide, zone2.csd{iCond}(idx2, :), norm2') ;
		csd_cond = bsxfun(@minus, csd1, csd2) ;
		csd_cond = csd_cond .^2 ;
		csd_cond = bsxfun(@minus, csd_cond, [0 :step: step*(length(idx)-1)]') ;
		plot(csd_cond') ;
		set(gca, 'XTick', )
	end