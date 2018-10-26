function mean_lfp = meanLfp(zone)
    nb_depths = length(zone.depths) ;
    min_length = size(zone.subzones{1}.lfp(1, :), 2) ;
    for iDepth = 2:nb_depths
        s = size(zone.subzones{iDepth}.lfp(1, :), 2) ;
        if s < min_length, min_length = s ; end
    end
    mean_lfp = zone.subzones{1}.lfp(:, 1:min_length) ;
    for iDepth = 2:nb_depths
        mean_lfp = mean_lfp + zone.subzones{iDepth}.lfp(:, 1:min_length) / 2 ;
    end
end