function output = compareParameters(hObject) 

	handles = guidata(hObject) ;
    output = false ;
	parameters_tmp = get(findall(handles.pan_parameters, 'Style', 'edit'), 'Tag')' ;
	parameters_user = getappdata(0, 'parameters_user') ;

	hedit = findall(handles.pan_parameters, 'Style', 'edit')' ;
	changed_values = cell(0) ;
	for iHandle = hedit
		name = char(get(iHandle, 'Tag')) ;
        name = name(4:end) ;
		parameter = parameters_user.(name) ;
		value = get(iHandle, 'String') ;
		if ~strcmp(value, parameter)
			changed_values = cat(1, changed_values,...
								  {name, str2num(parameter), str2num(value)}) ;
		end
		parameters_new.(name) = value ;
    end

    if ~isempty(changed_values)
   		setappdata(0, 'changed_values', changed_values) ;
    	user_response = compareParametersModalDlg('Title', 'CONTINUE') ;
    	switch user_response
    	case {'No'}
    		setParameters(hObject, 'user') ;
    	case 'Yes'
    		% if set_default == true
    		% 	setappdata(0, 'parameters_default', parameters_new) ;
    		% end
    		parameters_new.folders = parameters_user.folders ;
            parameters_all = getappdata(0, 'parameters_all') ;
            l = length(fieldnames(parameters_all)) ;
            parameters_all.(['set', num2str(l + 1)]) = parameters_new ;
            setappdata(0, 'parameters_all', parameters_all) ;
            output = true ;
    	end
    end

    guidata(hObject, handles) ;