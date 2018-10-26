function varargout = controlPanel(varargin)
% CONTROLPANEL M-file for controlPanel.fig
%      CONTROLPANEL, by itself, creates a new CONTROLPANEL or raises the existing
%      singleton*.
%
%      H = CONTROLPANEL returns the handle to a new CONTROLPANEL or the handle to
%      the existing singleton*.
%
%      CONTROLPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLPANEL.M with the given input arguments.
%
%      CONTROLPANEL('Property','Value',...) creates a new CONTROLPANEL or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before controlPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to controlPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help controlPanel

% Last Modified by GUIDE v2.5 15-May-2013 12:52:41

% ----------------------- %
% --- SUMMARY (BEGIN) --- %
% ----------------------- %
% 1.  Initialization            (44  - 61)
% 2.  Opening function & Output (63  - 113)
% 3.  ...
% 4.  Local Field Potential
% 5.  Peristimulus Time Histogram
% 6.  Raster plot of spikes
% 7.  Current Source Density
% 8.  Comparisons
% 9.  Miscallaneous
% 10. Close
% --------------------- %
% --- SUMMARY (END) --- %
% --------------------- %

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @controlPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @controlPanel_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Opening function
function controlPanel_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject ;
    global PRG_MODE ;
    if strcmp(PRG_MODE, 'Off') ; 
        name = 'Control Panel -- OLCAV - The Online LFP & CSD Analyzer and Visualizer tool -- OFFLINE VERSION' ;
    else
        name = 'Control Panel -- OLCAV - The Online LFP & CSD Analyzer and Visualizer tool' ;
    end
    set(hObject, 'Name', name,...
                 'Units', 'normalized') ;
    pos_current = get(hObject, 'Position') ;
    pos_new = [0.15, 0.25, pos_current(3), pos_current(4)] ;
    set(hObject, 'Position', pos_new) ;

    olca_path = getappdata(0, 'olca_path') ;
    models = dir(fullfile(olca_path, 'images')) ;
    models = models(3:end) ;
    img_format = {'.jpg', '.bmp', '.gif', '.png'} ;
    for iImg = 1:size(models, 1)
        if ~any(strcmp(img_format, lower(models(iImg).name(end-3:end))))
            models(iImg) = [] ;
        end
    end
    models = arrayfun(@(x) (x.name), models, 'UniformOutput', false) ;
    set(handles.lb_brains, 'String', cat(1, models, 'import image')) ;
    set(handles.ax_brain,  'XTick', [], 'YTick', []) ;
    set(handles.cb_img1, 'Value', 1) ;

    % --- Set tooltips
    setInfos(hObject) ;

    msg_text = {'Images of different animal models brain are proposed.',...
                'You can also upload an image of yours (cortical maps obtained by optical imaging for instance).',...
                'If so, be CAREFUL about the shape of your image!',...
                '-> The brain image has to be centered and has to take the whole image.',...
                'See the present images in the ''Olca\images'' folder'} ;
    set(handles.tx_about, 'String', msg_text) ;

    guidata(hObject, handles) ;

% --- Outputs from this function are returned to the command line.
function varargout = controlPanel_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output ;

% ------------------- %
% --- GUI (BEGIN) --- %
% ------------------- %

% ------------------------- %
% --- PARAMETERS (BEGIN)--- %
% ------------------------- %

% --- Low-pass threshold for lfp
function ed_lp_lfp_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_lp_lfp, 'String')))
        warndlg('Low-pass threshold must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;    
function ed_lp_lfp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- High-pass threshold for lfp
function ed_hp_lfp_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_hp_lfp, 'String')))
        warndlg('High-pass threshold for LFP must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_hp_lfp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Low-pass threshold for spikes
function ed_lp_sp_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_lp_sp, 'String')))
        warndlg('Low-pass threshold for spikes must be a NUMBER', 'WRONG INPUT') ;
        set(handles.ed_lp_sp, 'String', '') ;
        return
    end
function ed_lp_sp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- High-pass threshold for spikes
function ed_hp_sp_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_hp_sp, 'String')))
        warndlg('High-pass threshold for spikes must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_hp_sp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Spike threshold
function ed_sp_thr_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_sp_thr, 'String')))
        warndlg('Spike threshold must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_sp_thr_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Baseline length
function ed_bline_Callback(hObject, eventdata, handles)
    bline = get(handles.ed_bline, 'String') ;
    % if length(strfind(bline, '%')) & strfind(bline, '%') ~= length(bline)
    %     warndlg('Wrong syntax for relative length of baseline', 'WRONG INPUT') ;
    %     return
    % end
    if isnan(str2double(get(handles.ed_bline, 'String')))
        warndlg('Baseline must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_bline_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Average CSD
function cb_avrec_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;

% --- Number of conditions
function ed_nb_cond_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_nb_cond, 'String')))
        warndlg('Number of conditions must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_nb_cond_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Number of trials
function ed_nb_trials_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_nb_trials, 'String')))
        warndlg('Number of trials must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_nb_trials_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Left-right axis
function ed_lr_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_lr, 'String')))
        warndlg('Measurments must be NUMBERS', 'WRONG INPUT') ;
        set(handles.ed_lr, 'String', '') ;
        return
    end
    guidata(hObject, handles) ;
function ed_lr_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Dorsoventral axis
function ed_dv_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_dv, 'String')))
        warndlg('Measurments must be NUMBERS', 'WRONG INPUT') ;
        set(handles.ed_dv, 'String', '') ;
        return
    end
    guidata(hObject, handles) ;
function ed_dv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Antero-posterior position 0
function ed_ap_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_ap, 'String')))
        warndlg('Antero-posterior position must be a NUMBER', 'WRONG INPUT') ;
        set(handles.ed_ap, 'String', '') ;
        return
    end
    if str2double(get(handles.ed_ap, 'String')) > str2double(get(handles.ed_dv, 'String'))
        warndlg('Antero-posterior 0 position is superior to dorsoventral limit', 'WRONG INPUT') ;
        return ;
    end
    guidata(hObject, handles) ;
function ed_ap_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Maximum depth
function ed_max_depth_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_max_depth, 'String')))
        warndlg('Max depth must be a NUMBER', 'WRONG INPUT') ;
        set(handles.ed_max_depth, 'String', '') ;
        return
    end
    guidata(hObject, handles) ;
function ed_max_depth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Minimum depth
function ed_min_depth_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_min_depth, 'String')))
        warndlg('Min depth must be a NUMBER', 'WRONG INPUT') ;
        set(handles.min_depth, 'String', '') ;
        return
    end
    guidata(hObject, handles) ;
function ed_min_depth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Stimulus duration
function ed_lstim_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_lstim, 'String')))
        warndlg('Stimulus duration must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_lstim_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Length of post-stimulus time
function ed_after_Callback(hObject, eventdata, handles)
    if isnan(str2double(get(handles.ed_after, 'String')))
        warndlg('Stimulus duration must be a NUMBER', 'WRONG INPUT') ;
        return
    end
    guidata(hObject, handles) ;
function ed_after_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Enable antero-posterior field
function cb_ap_Callback(hObject, eventdata, handles)
    if get(handles.cb_ap, 'Value')
        set(handles.ed_ap, 'Enable', 'on') ;
    else
        set(handles.ed_ap, 'Enable', 'off') ;
    end
    guidata(hObject, handles) ;

% ----------------------- %
% --- PARAMETERS (END)--- %
% ----------------------- %

% ---------------------- %
% --- FOLDERS (BEGIN)--- %
% ---------------------- %

% --- Results folder
function pb_results_folder_Callback(hObject, eventdata, handles)
    if ispc 
        start_path = 'C:\' ;
    elseif isunix
        start_path = '~/' ;
    end
    dialog_title   = 'Select the location where a new results folder will be created' ;
    results_folder = uigetdir(start_path, dialog_title) ;
    if ~results_folder == 0
        if exist(results_folder) ~= 7
            warndlg('Please select valid Results folder', 'WRONG FOLDER') ;
            return ;
        end 
        set(handles.tx_results_folder, 'String', results_folder) ;
    end
    guidata(hObject, handles) ;

% --- Neuralynx folder
function pb_neur_folder_Callback(hObject, eventdata, handles)
    if ispc
        start_path = 'C:\' ;
    elseif isunix
        start_path = '~/' ;
    end
    dialog_title = 'Select Neuralynx folder' ;
    neur_folder  = uigetdir(start_path, dialog_title) ;
    if ~neur_folder == 0
        if exist(neur_folder) ~= 7
            warndlg('Please select valid Neuralynx folder', 'WRONG FOLDER') ;
            return ;
        end
        set(handles.tx_neur_folder, 'String', neur_folder) ;
    end
    guidata(hObject, handles) ;

% -------------------- %
% --- FOLDERS (END)--- %
% -------------------- %

% --------------------- %
% --- IMAGES (BEGIN)--- %
% --------------------- %

% --- Put an image
function populateAxe(handle, brain_path)
    brain_image = imread(brain_path) ;
    image(brain_image, 'Parent', handle) ;
    image_info = imfinfo(brain_path) ;
    if strcmp(image_info.FormatSignature, 'BM')
        colormap(gca, gray(256)) ;
    end
    axis image
    hold on ; 
    yaxis = size(brain_image, 1) ;
    xaxis = size(brain_image, 2) ;
    plot(gca, repmat(xaxis/2, yaxis, 1), 1:yaxis, 'r--', 'linewidth', 1.5) ;
    set(gca, 'XTick', [], 'YTick', []) ;
    hold off ;

% --- Listbox of brain images
function lb_brains_Callback(hObject, eventdata, handles)
    olca_path = getappdata(0, 'olca_path') ;
    img_path = fullfile(olca_path, 'images') ;
    models = dir(img_path) ;
    model  = get(hObject, 'Value') ;
    if model < length(get(hObject, 'String'))
        brain_path = fullfile(img_path, models(model+2).name) ;
        populateAxe(handles.ax_brain, brain_path) ;
    else
        start_path = img_path ;
        dialog_title   = 'Select brain image you want to load' ;
        [brain_file, brain_folder, cancel] = uigetfile('*.*', dialog_title, start_path) ;
        brain_path = fullfile(brain_folder, brain_file) ;
        if exist(brain_path, 'file') == 2
            if isempty(strfind(brain_path, img_path))
                user_response = modaldlg('Title' , 'Copy file',...
                                         'String', 'Copy selected image to Olca''s images folder?') ;
                switch user_response
                case 'No'
                    % takes no action
                case 'Yes'
                    copyfile(brain_path, img_path) ;
                end
            end
            populateAxe(handles.ax_brain, brain_path) ;
        end
    end
    if get(handles.cb_img1, 'Value') && isempty(get(handles.tx_img1, 'String'))
        set(handles.tx_img1, 'String', brain_path) ;
    elseif get(handles.cb_img2, 'Value') && isempty(get(handles.tx_img2, 'String'))
        set(handles.tx_img2, 'String', brain_path) ;
    elseif get(handles.cb_img3, 'Value') && isempty(get(handles.tx_img3, 'String'))
        set(handles.tx_img3, 'String', brain_path) ;
    end
    guidata(hObject, handles) ;
function lb_brains_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% ------------------- %
% --- IMAGES (END)--- %
% ------------------- %

% ---------------------------- %
% --- MISCALLANEOUS (BEGIN)--- %
% ---------------------------- %

% --- Set default values
function pb_profile_Callback(hObject, eventdata, handles)
    flag = false ;
    while flag == false
        user_response = inputdlg('Choose a name for your profile',...
                                 'New user profile',...
                                 1, {''}) ;
        if isempty(user_response), return ; end
        profile_path = fullfile(getappdata(0, 'olca_path'), 'profiles') ;
        d = dir(profile_path) ;
        if any(strcmp({d.name}, [cell2mat(user_response), '_OlcavProf.mat']))
            flag = false ;
            waitfor(warndlg('Username already taken, please choose another',...
                            'Invalid username')) ;
        else
            setappdata(0, 'user_name', cell2mat(user_response)) ;
            flag = true ;
        end
    end
    guidata(hObject, handles) ;

% --- Executes on button press in cb_clear.
function cb_clear_Callback(hObject, eventdata, handles)
    if get(handles.cb_clear, 'Value')
        getParameters(hObject) ;
        setToEmpty(hObject) ;
        set(handles.cb_clear, 'String', 'RESTORE PREVIOUS VALUES') ;
    else
        retrieveParameters(hObject) ;
        set(handles.cb_clear, 'String', 'Clear all fields') ;
    end
    guidata(hObject, handles) ;

% --- Rotate image
function pb_rot_p_Callback(hObject, eventdata, handles)
    rotate90(hObject, true) ;
    guidata(hObject, handles) ;

% --- Stimuli kind
function pb_kind_Callback(hObject, eventdata, handles)
    if isempty(get(handles.ed_nb_cond, 'String'))
        warndlg('Please fill first the number of different stimuli you will use',...
                'FIELD MISSING') ;
        return ;
    else
        stimuliFeatures(str2double(get(handles.ed_nb_cond, 'String'))) ;
    end
    guidata(hObject, handles) ;

% --- Executes on button press in pb_paradigm.
function pb_paradigm_Callback(hObject, eventdata, handles)
    if isempty(get(handles.ed_nb_cond, 'String'))
        warndlg('Please fill first the number of different stimuli you will use',...
                'FIELD MISSING') ;
        return ;
    else
        paradigmFeatures(str2double(get(handles.ed_nb_cond, 'String'))) ;
    end
    guidata(hObject, handles) ;

% --- Executes on button press in pb_resize.
function pb_resize_Callback(hObject, eventdata, handles)

function infos = setInfos(hObject)
    handles = guidata(hObject) ;
    % --- Tooltips
    infos_CP.tx_lp_lfp         = '<html>Low-passthreshold, used in LFP analysis' ;
    infos_CP.tx_hp_lfp         = '<html>High-pass threshold, used in LFP analysis' ;
    infos_CP.tx_lp_sp          = '<html>Low-pass threshold, used in spikes analysis' ;
    infos_CP.tx_hp_sp          = '<html>High-pass threshold, used in spikes analysis' ;
    infos_CP.tx_sp_thr         = '<html>Spike threshold, used in Spikes analysis' ;
    infos_CP.tx_nb_cond        = '<html>Number of different stimuli used during the experiment' ;
    infos_CP.tx_nb_trials      = '<html>Number of repetitions of each protocol design' ;
    infos_CP.cb_ap             = '<html>Antero-posterior position 0:<br><font color="blue">reference line defined between the ears of the model' ;
    infos_CP.cb_inter          = '<html>Interhemispheric fissure:<br><font color="blue">distance between fissure and left side of the cut zone' ;
    infos_CP.pb_neur_folder    = '<html>Select the folder where Neuralynx data will be stored' ;
    infos_CP.pb_results_folder = ['<html><font color="red">Optional input<br><font color="black">Select a path where an ''olcav'' results folder will be created.',...
                                  '<br>If no folder is selected, a new ''olcav'' folder will be created in the home directory'] ;
    infos_CP.cb_avrec = ['<html><font color="blue">Note:<br>',...
                         '<font color="black">Averaged rectified CSD (AVREC) waveform provides a measure <br>',...
                         'of the temporal pattern of the overall strength of transmembrane current flow'] ;
    infos_CP.tx_bline = ['<html><font color="blue">Note:<br>',...
                         '<font color="black">You can whether indicate a time or a percentage of stimulus duration <br>',...
                         'If you indicate a relative time, please write the ''%'' after time'] ;
    infos_CP.tx_after = ['<html><font color="blue">Note:<br>',...
                         '<font color="black">You can whether indicate a time or a percentage of stimulus duration <br>',...
                         'If you indicate a relative time, please write the ''%'' after time'] ;

    for iName = fieldnames(infos_CP)'
        set(handles.(char(iName)), 'tooltipString', infos_CP.(char(iName))) ;
    end
    guidata(hObject, handles) ;

% --- Load previous user profile
function pb_load_prof_Callback(hObject, eventdata, handles)
    profiles_path = fullfile(getappdata(0, 'olca_path'), 'profiles') ;
    dialog_title   = 'Select a profile' ;
    [profile_file, profile_folder, cancel] = uigetfile('*.mat*', dialog_title, profiles_path) ;
    if ~cancel, return ; end
    profile_path = fullfile(profile_folder, profile_file) ;
    content = load(profile_path) ;
    content = content.content ;
    for iContent = fieldnames(content.parameters)'
        set(handles.(['ed_', char(iContent)]), 'String', content.parameters.(char(iContent))) ;
    end
    set(handles.tx_neur_folder,    'String', content.folders.neuralynx) ;
    set(handles.tx_results_folder, 'String', content.folders.output) ;
    set(handles.ed_min_depth,      'String', num2str(content.limits.min)) ;
    set(handles.ed_max_depth,      'String', num2str(content.limits.max)) ;
    set(handles.ed_lr,             'String', content.dimensions.lr) ;
    set(handles.ed_dv,             'String', content.dimensions.dv) ;
    set(handles.ed_ap,             'String', content.dimensions.ap) ;
    switch content.units.time
    case 'msec'
        set(handles.rb_msec, 'Value', 1) ;
    case 'sec'
        set(handles.rb_sec, 'Value', 1) ;
    case 'misec'
        set(handles.rb_misec, 'Value', 1) ;
    end
    switch content.units.dim
    case 'mi'
        set(handles.rb_mi, 'Value', 1) ;
    case 'mm'
        set(handles.rb_mm, 'Value', 1) ;
    case 'cm'
        set(handles.rb_cm, 'Value', 1) ;
    end
    guidata(hObject, handles) ;
    
% -------------------------- %
% --- MISCALLANEOUS (END)--- %
% -------------------------- %

function ed_isi1_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
function ed_isi1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end


% --- Executes on button press in cb_random.
function cb_random_Callback(hObject, eventdata, handles)
    if get(handles.cb_random, 'Value')
        set(handles.ed_isi2, 'Visible', 'on',...
                             'String', 'min',...
                             'FontWeight', 'normal',...
                             'FontSize', 9,...
                             'ForegroundColor', [100, 100, 100]/255) ;
        set(handles.ed_isi1, 'String', 'max',...
                             'FontWeight', 'normal',...
                             'FontSize', 9,...
                             'ForegroundColor', [100, 100, 100]/255) ;
    else
        set(handles.ed_isi2, 'Visible', 'off') ;
        set(handles.ed_isi1, 'String', '') ;
    end
    guidata(hObject, handles) ;

function ed_isi2_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
function ed_isi2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end

% --------------------- %
% --- CLOSE (BEGIN) --- %
% --------------------- % 
% --- Close button
function pb_close_Callback(hObject, eventdata, handles)
    user_response = modaldlg('Title', 'QUIT',...
                             'String', 'Confirm Close?') ;
    switch user_response
    case{'No'}
        % take no action
    case 'Yes'
        setappdata(0, 'quit', true) ;
        delete(handles.controlPanel) ;
    end

% --- Cross or alt-f4 close
function controlPanel_CloseRequestFcn(hObject, eventdata, handles)
    user_response = modaldlg('Title', 'quit',...
                             'String', 'Confirm Close?') ;
    switch user_response
    case{'No'}
        % take no action
    case 'Yes'
        setappdata(0, 'quit', true) ;
        delete(handles.controlPanel)
    end

% --- Go button
function go_Callback(hObject, eventdata, handles)
    checkParameters(hObject) ;    
    delete(handles.controlPanel) ;

% ------------------- %
% --- CLOSE (END) --- %
% ------------------- % 

% ----------------- %
% --- GUI (END) --- %
% ----------------- %

function pb_stim_name_Callback(hObject, eventdata, handles)    

function cb_inter_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.ed_inter, 'Enable', 'on') ;
    else
        set(handles.ed_inter, 'Enable', 'off') ;
    end
    guidata(hObject, handles) ;

function ed_inter_Callback(hObject, eventdata, handles)
    guidata(hObject, handles) ;
function ed_inter_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white') ;
    end


% --- Executes on button press in cb_img1.
function cb_img1_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.tx_img1, 'Visible', 'on') ;
    else
        set(handles.tx_img1, 'Visible', 'off') ;
    end
    guidata(hObject, handles) ;

% --- Executes on button press in cb_img2.
function cb_img2_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.tx_img2, 'Visible', 'on') ;
    else
        set(handles.tx_img2, 'Visible', 'off') ;
    end
    guidata(hObject, handles) ;

% --- Executes on button press in cb_img3.
function cb_img3_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.tx_img3, 'Visible', 'on') ;
    else
        set(handles.tx_img3, 'Visible', 'off') ;
    end
    guidata(hObject, handles) ;


% --- Executes on button press in pb_clear1.
function pb_clear1_Callback(hObject, eventdata, handles)
    set(handles.tx_img1, 'String', '') ;
    guidata(hObject, handles) ;

% --- Executes on button press in pb_clear2.
function pb_clear2_Callback(hObject, eventdata, handles)
    set(handles.tx_img2, 'String', '') ;
    guidata(hObject, handles) ;

% --- Executes on button press in pb_clear3.
function pb_clear3_Callback(hObject, eventdata, handles)
    set(handles.tx_img3, 'String', '') ;
    guidata(hObject, handles) ;
