function editParameters(hObject)

    handles = guidata(hObject) ;

    if get(handles.cb_edit, 'Value')
        set(handles.cb_edit, 'String', 'CONFIRM') ;
        changeProperty(hObject, eventdata, handles.pan_parameters, 'Enable', 'on') ;
    else
        changeProperty(hObject, eventdata, handles.pan_parameters, 'Enable', 'off') ;
        parameters_new = getParameters(hObject, eventadata) ;
        names_new = fieldnames(parameters_new) ;
        differences = cell(0) ;
        for iName = names_new'
            if ~strcmp(parameters_new.(char(iName)), parameters_default.(char(iName)))
                differences = cat(1, differences, char(iName)) ;
            end
        end
        if ~isempty(differences)
            user_response = modaldlg('Title', 'NEW',...
                                     'String', 'Some parameters have changed. Save new ones?')
            switch user_response
            case {'No'}
                % takes no action
            case 'Yes'
                setappdata(0, 'parameters_user', parameters_user) ;
            end
        end
    end

    guidata(hObject, handles) ;