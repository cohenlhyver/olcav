function documentation
    start_path = fullfile(getappdata(0, 'olca_path'), 'Documents') ;
    dialog_title   = 'What documentation would you like to consult?' ;
    [file, folder, cancel] = uigetfile('*.pdf*', dialog_title, start_path) ;
    if cancel ~= 0
        open(fullfile(folder, file)) ;
    end