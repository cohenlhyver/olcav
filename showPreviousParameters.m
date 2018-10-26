function parameters_set = chooseSetOfParameters

    
    parameters_all = getappdata(0, 'parameters_all') ;
    if length(fieldnames(parameters_all)) == 1
        warndlg('No previous set of parameters detected',...
                'FIRST SET') ;
    else
        data = cell(0) ;
        for iSet = fieldnames(parameters_all)' 
            parameters_tmp = cell(0) ;
            for iParam = fieldnames(parameters_all.(char(iSet)))'
                if ~strcmp(iParam, 'folders')
                    parameters_tmp = cat(1, parameters_tmp, str2num(parameters_all.(char(iSet)).(char(iParam)))) ;
                end
            end
            data = cat(2, data, parameters_tmp) ;
        end
        cnames = fieldnames(parameters_all)' ;
        rnames = fieldnames(parameters_all.(char(cnames{1})))' ;
        rnames = {rnames{1:end-1}} ;
        rnames = cat(2, rnames, 'Choose set') ;
        row_format = [repmat({'char', 'logical'}, 1, length(cnames))] ;
        row_editable = [false(1, length(rnames)-1), true] ;

        f = figure('Name', 'PREVIOUS SETS OF PARAMETERS',...
                   'Menubar', 'none',...
                   'Units', 'normalized',...
                   'Position', [0.3, 0.4, 0.25, 0.2]) ;
        
        tab_zones = uitable('Parent', f,...
                            'Units', 'normalized',...
                            'Position', [0.1, 0.1, 0.8, 0.8],...
                            'Data', data,...
                            'ColumnName', cnames,...
                            'RowName', rnames) ;
        parameters_set = get(tab_zones, 'Data') ;
end