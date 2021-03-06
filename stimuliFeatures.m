function stimuliFeatures(nb_cond)

    f = figure('NumberTitle', 'off',...
               'Name'       , 'Stimuli properties',...
               'Menubar'    , 'none',...
               'Units'   , 'normalized',...
               'Position', [0.2, 0.3, 0.6, 0.1]) ;

    cnames = genvarnames(repmat({'Stimulus '}, 1, nb_cond+1)) ;
    cnames(1) = [] ;
    data = repmat({[]}, 1, nb_cond) ;
    rnames = {'Frequency (in Hz) of the stimulus'} ;
    column_editable = [true(1, nb_cond)] ;
    tab_zones = uitable('Parent'        , f,...
                        'Units'         , 'normalized',...
                        'FontWeight'    , 'demi',...
                        'Enable'        , 'on',...
                        'Position'      , [0, 0, 1, 1],...
                        'Data'          , cell(data),...
                        'ColumnName'    , cnames,...
                        'ColumnEditable', column_editable,...
                        'RowName'       , rnames,...
                        'ColumnWidth'   , 'auto') ;

    handles_u = uicontrol('Parent'  , f,...
                          'Units'   , 'normalized',...
                          'Position', [0.5, 0.2, 0.1, 0.2],...
                          'Style'   , 'pushbutton',...
                          'String'  , 'Save & Close',...
                          'Callback', {@getFeatures, get(tab_zones, 'Data')}) ;

    features = [] ;
%         for iFeat = 1:length(content)
%             features = [features, num2str(content{iFeat}), ' -- '] ;
%         end
    features = features(1:end-2) ;
    setappdata(0, 'stimuli_features', features) ;
    delete(get(handle, 'Parent')) ;

    function getFeatures(src, evt, content)
        if any(isempty(content))
            warndlg('Please fill all the fields', 'ERROR') ;
            return ;
        end
    end