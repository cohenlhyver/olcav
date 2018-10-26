%% csdAnalysis function
% ----------------------------------------------------------------
% Current Source Density analysis
%
% OLCA 1.0 -- Online LFP & CSD analysis
% Benjamin Cohen-Lhyver (@Collège de France - UMR 7152) - February 2013


function [csd, csd_mean] = csdAnalysis(zone)
	global NB_COND ;
	setappdata(0, 'd', zone) ;
	points_csd = cell(1, 3) ;
	points_csd{1} = zone.subzones{1}.lfp ;
	points_csd{2} = zone.subzones{2}.lfp ;
	points_csd{3} = zone.subzones{3}.lfp ;

	for iCond = 1:NB_COND, csd{iCond} = csdCalculation ; end
	
	points_csd = cell(1, 3) ;
	points_csd{1} = mean(zone.subzones{1}.lfp) ;
	points_csd{2} = mean(zone.subzones{2}.lfp) ;
	points_csd{3} = mean(zone.subzones{3}.lfp) ;
	iCond = 1 ;
	csd_mean = csdCalculation ;

		function csd_cond = csdCalculation
			csd_cond = (-1) * (points_csd{1}(iCond, :) - 2*points_csd{2}(iCond, :) + points_csd{3}(iCond, :)) / 300^2 ;
		end

end