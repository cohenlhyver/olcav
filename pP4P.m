function varargout = pP4P(varargin)

	global SAMPLE_FREQ...
           NB_COND    ...
           NB_STIM    ...
           UNITS      ...
           SET ;

    SAMPLE_FREQ = 30303 ;

    [fname, pname] = uigetfile('C:\', 'Choose a data file ("zoneX" with X=number)') ;
    %d = dir(data_folder) ;
    %pos = find
    zone = load(fullfile(pname, fname)) ;
    zone = zone.zone ;

    tmpf = fullfile(pname, fname) ;
    tmp = find(tmpf == '/') ;
    spec = load(fullfile(tmpf(1:tmp(end-1)), 'spec.mat')) ;
    spec = spec.spec ;

    nzone = str2num(zone.output(end)) ;
    nzones = length(dir(fullfile(pname, '*.mat'))) ;
    if nzones > 1
        spec = spec(nzone) ;
    end
    NB_COND = spec.stim(1) ;
    NB_STIM = spec.stim(2) ;

    parameters = zone.subzones{1}.parameters ;

    p = inputParser ;
	p.addOptional('generatePlots', false) ;
	p.addOptional('timeBeforeOnset', parameters.bline) ;
	p.addOptional('timeAfterOffset', parameters.after) ;
	p.addOptional('Depths', 'all') ;
    p.addOptional('CsdDepths', 'all') ;
	p.addOptional('Save', true) ;
	p.addOptional('Visible', 'off') ;
    p.addOptional('LfpConstant', 2) ;
    p.addOptional('CsdConstant', 0.0001) ;
    p.addOptional('TypeOfExperiment', 'Aud') ;
	p.parse(varargin{:}) ;
	p = p.Results ;

    if ~p.generatePlots
        p.Save = false ;
    end

	% if nargin < 1
	% 	generate = true ;
	% else
	% 	generate = varargin{1} ;
	% end

	depths = zone.depths ;

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

	pP.bound = bound ;
	pP.timetab = timetab ;
	pP.ticks = ticks ;
	if strcmp(p.TypeOfExperiment, 'Vis')
		conditions  = {'O1', 'O2', 'O3', 'O4', 'O5', 'O6', 'O7', 'O8'} ;
		fconditions = {'O1', 'O2', 'O3', 'O4', 'O5', 'O6', 'O7', 'O8'} ;
	else
		conditions  = {'0.5 kHz', '1 kHz', '2 kHz', '4 kHz', '8 kHz', '16 kHz', '32 kHz', '64 kHz'} ;
		fconditions = {'05', '1', '2', '4', '8', '16', '32', '64'} ;
	end
	
	setappdata(0, 'conditions', conditions) ;
	setappdata(0, 'fconditions', fconditions) ;
	setappdata(0, 'pP', pP) ;

    tmp = strfind(zone.output, '\') ;
    folder = [zone.output(1:tmp(2)), 'Figures', zone.output(tmp(2):end)] ;
    mkdir(folder) ;
    mkdir([folder, '\LFP']) ;
    mkdir([folder, '\CSD']) ;
    mkdir([folder, '\Spikes']) ;
    mkdir([folder, '\Spikes\RA']) ;
    mkdir([folder, '\Spikes\SP']) ;
    mkdir([folder, '\Spikes\PSTH']) ;
    mkdir([folder, '\Spikes\TC']) ;
	
	if isstr(p.Depths) && strcmp(p.Depths, 'all')
        p.Depths = spec.depths ;
		% p.Depths = [zone.depths(1), zone.depths(end)] ;
	end

	if p.generatePlots
		plotLfpMean(zone, 'timeBeforeOnset', p.timeBeforeOnset,...
						  'timeAfterOffset', p.timeAfterOffset,...
						  'Visible'		   , p.Visible,...
						  'Save'		   , p.Save,...
						  'Depths'		   , p.Depths,...
                          'Constant'       , p.LfpConstant) ;
		plotLfpByCond(zone, 'timeBeforeOnset', p.timeBeforeOnset,...
						    'timeAfterOffset', p.timeAfterOffset,...
						    'Visible'        , p.Visible,...
						    'Save'           , p.Save,...
						    'Depths'         , p.Depths,...
                            'Constant'       , p.LfpConstant) ;
		plotLfpByCondImg(zone, 'timeBeforeOnset', p.timeBeforeOnset,...
						       'timeAfterOffset', p.timeAfterOffset,...
						       'Visible'        , p.Visible,...
						       'Save'           , p.Save,...
						       'Depths'         , p.Depths,...
                               'Constant'       , p.LfpConstant) ;
		plotCsdMean(zone, 'timeBeforeOnset', p.timeBeforeOnset,...
						  'timeAfterOffset', p.timeAfterOffset,...
						  'Visible'        , p.Visible,...
						  'Save'           , p.Save,...
						  'Depths'         , p.Depths,...
                          'Constant'       , p.CsdConstant) ;
		plotCsdByCond(zone, 'timeBeforeOnset', p.timeBeforeOnset,...
						    'timeAfterOffset', p.timeAfterOffset,...
						    'Visible'        , p.Visible,...
						    'Save'           , p.Save,...
						    'Depths'         , p.Depths,...
                            'Constant'       , p.CsdConstant) ;
		plotCsdByCondImg(zone, 'timeBeforeOnset', p.timeBeforeOnset,...
						       'timeAfterOffset', p.timeAfterOffset,...
						       'Visible'        , p.Visible,...
						       'Save'           , p.Save,...
						       'Depths'         , p.Depths,...
                               'Constant'       , p.CsdConstant) ;
        plotSpikes(zone, 'Visible', p.Visible,...
                         'Save', p.Save) ;
		plotOptCond(zone) ;
	end

	if nargout == 1, varargout{1} = zone ; end
end 