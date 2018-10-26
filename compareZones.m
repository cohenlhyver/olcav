function compareZones(hObject)
    handles = guidata(hObject) ;

    zones = getappdata(0, 'zones') ;
    
    if isempty(zones)
        warndlg('No data detected.', 'First zone') ;
        return ;
    end

    f = figure('Units', 'normalized', 'Position', [0.1, 0.3, 0.8, 0.5]) ;
    data = [] ;
    for iDepths = zones.depths
        data = [data, num2cell(iDepths{:})', false] ;
    end
    column_names = [] ;
    for iName = zones.names
        column_names = [column_names, iName, {'Select'}] ;
    end
    l = size(zones.names, 2) ;
    column_format = [repmat({'char', 'logical'}, 1, l)] ;
    column_editable = [false(1, l*2)] ;
    column_editable(2:2:l*2) = true ;

    handle_t = uitable('Units', 'normalized',...
                       'Position', [0.1 0.1 0.9 0.9],...
                       'Data', data,... 
                       'ColumnName', column_names,...
                       'ColumnFormat', column_format,...
                       'ColumnEditable', column_editable,...
                       'RowName', []) ;

    pb_compare = uicontrol('Parent', f,...
                         'Style', 'pushbutton',...
                         'String', 'Compare selected data',...
                         'Callback', {@compareData, f}) ;

    pb_cancel = uicontrol('Parent', f,...
                         'Style', 'pushbutton',...
                         'String', 'CANCEL',...
                         'Callback', {@closeWindow, f}) ;

    guidata(hObject, handles) ;

function compareData(hObject, eventdata, handle)
    user_response = modaldlg('Title', 'COMPARE',...
                             'String', 'Confirm chosen data?') ;
    switch user_response
    case {'No'}
        % take no action
    case 'Yes'
        figure_children = get(handle, 'Children') ;
        table = get(figure_children(strcmp(get(figure_children, 'Type'), 'uitable'))) ;
        content = table.Data ;
        names = table.ColumnName ;
        for iZone = 1 :2: length(content)
            zone = content(:, iZone:iZone+1) ;
            depths = zone(find(zone{2} == true)) ;
            if ~isempty(depths)
                data_compare.(char(names(iZone))) = depths ;
            end
        end
        if ~isempty(data_compare)
            setappdata(0, 'data_compare', data_compare) ;
        end
        delete(handle) ;
        displayVsResults ;
    end

function closeWindow(hObject, eventdata, handle)
     user_response = modaldlg('Title', 'CANCEL',...
                             'String', 'Quit?') ;
    switch user_response
    case {'No'}
        % take no action
    case 'Yes'
        delete(handle) ;
    end