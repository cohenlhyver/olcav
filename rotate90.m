
function rotate90(hObject, actualize)
    handles = guidata(hObject) ;
    img = findall(handles.ax_brain, 'Type', 'image') ;
    img_data = get(img, 'CData') ;
    img_rot(:, :, 1) = rot90(img_data(:, :, 1), 1) ;
    img_rot(:, :, 2) = rot90(img_data(:, :, 2), 1) ;
    img_rot(:, :, 3) = rot90(img_data(:, : ,3), 1) ;
    set(img, 'CData', img_rot) ;
    if actualize
	    axis image
	end
    rotation = getappdata(0, 'rotation') ;
    if rotation == 3
		setappdata(0, 'rotation', 1) ;
	else
		setappdata(0, 'rotation', rotation + 1) ;
	end
    guidata(hObject, handles) ;
