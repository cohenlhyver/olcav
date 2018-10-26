%% Online LFP & CSD analysis & visualization tool
% ----------------------------------------------------------------
% Main program
%
% Benjamin Cohen-Lhyver (@Collège de France - UMR 7152, LPPA) - May 2013
% contact: cohen.lhyver@gmail.com

function OLCAV
    clc ;

    waitfor(welcome) ;
    if isappdata(0, 'quit')
        rmappdata(0, 'quit') ;
        waitfor(CLOSE) ;
        return ;
    end
    INIT_DEFAULT ;
    answer = questdlg('What version of OLCAV do you want to use?',...
                      'OLCAV VERSION',...
                      'Online', 'Offline', 'None, I quit',...
                      'Online') ;
    global PRG_MODE ;
    switch answer
    case 'Online'
        PRG_MODE = 'On' ;
    case 'Offline'
        PRG_MODE = 'Off' ;
    otherwise
        waitfor(CLOSE) ;
        return ;
    end
    switch PRG_MODE
    case 'On'
        waitfor(controlPanel) ;
        waitfor(recSitesInterface) ;
        createLogFile ;
        createConfigFile ;
    case 'Off'
        %loadConfigFile ;
        nlxFilesProcess ;
        %generatePlots ;
        %waitfor(recSitesInterfaceOFF) ;
    end
	%waitfor(controlPanel) ;
	% if isappdata(0, 'quit')
 %        rmappdata(0, 'quit') ;
 %        waitfor(CLOSE) ;
 %        return ;
 %    end
    % switch PRG_MODE
    % case 'On'
    %     waitfor(recSitesInterface) ;
    % case 'Off'
    %     waitfor(defineZoneFeatures) ;
    %     nlxFilesProcess ;
    %     waitfor(recSitesInterfaceOFF) ;
    % end
	waitfor(CLOSE) ;

% ------------------- %
% --- END OF FILE --- %
% ------------------- %