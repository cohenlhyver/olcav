function varargout = showPreviousZones(varargin)
    global ZONES ;
    if ~isempty(ZONES)
        cnames = {'left-right', 'dorsoventral'} ;
        rnames = fieldnames(ZONES) ;
        data = num2cell(...
               cell2mat(...
               cellfun(@(x) (str2num(ZONES.(char(x)).coordinates)),...
                       rnames,...
                       'UniformOutput', false))) ;

        f = figure('Name', 'PREVIOUS ZONES',...
                   'Menubar', 'none',...
                   'Units', 'normalized',...
                   'Position', [0.3, 0.5, 0.19, 0.2],...
                   'Color', [60, 60, 60]/255) ;
        
        tab_zones = uitable('Parent', f,...
                            'Units', 'normalized',...
                            'Position', [0.1, 0.3, 0.8, 0.6],...
                            'Data', data,...
                            'ColumnName', cnames,...
                            'RowName', rnames,...
                            'BackgroundColor', [1, 1, 1 ;...
                                                0.8, 0.8, 0.8]) ;
        if ~isempty(varargin)
            h1 = uicontrol('Style'          , 'text',...
                           'Units'          , 'normalized',...
                           'Position'       , [0.05, 0.1, 0.40, 0.1],...
                           'String'         , 'Choose index of zone:',...
                           'FontSize'       , 8,...
                           'FontWeight'     , 'bold',...
                           'ForegroundColor', 'white',...
                           'BackgroundColor', [60, 60, 60]/255) ;
    
            h2 = uicontrol('Style'          , 'edit',...
                           'Units'          , 'normalized',...
                           'Position'       , [0.5, 0.1, 0.2, 0.1],...
                           'String'         , '1',...
                           'BackgroundColor', 'white') ;
            
            h3 = uicontrol('Style'   , 'pushbutton',...
                           'Units'   , 'normalized',...
                           'Position', [0.75, 0.1, 0.2, 0.1],...
                           'String'  , 'Choose',...
                           'Callback', {@saveClose, h2}) ;
        end

    else
        warndlg('No previous zone detected: first zone explored',...
                'FIRST ZONE') ;
    end

function saveClose(src, evt, h2)
    setappdata(0, 'zone_name_note', ['zone', get(h2, 'String')]) ;
    close ;