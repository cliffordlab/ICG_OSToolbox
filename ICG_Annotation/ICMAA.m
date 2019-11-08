function varargout = ICMAA(varargin)
% ----------  Impedancce Cardiogram Manual Annotation Application ---------
% OVERVIEW:
%    ICMAA GUI file for "Open source toolbox for removal of noisy beats from ICG"
%    Configured to accept Ensemble averaged (EA) ECG and ICG signals to
%    facilitate in auto and manual annotation of EA ICG signals.

% INPUT:
%   EA ECG and ICG signal under neutral and stress conditions.

% OUTPUT:
%    Annotations of fiduical points for EA ECG signal and three Stage EA ICG signal.

% DEPENDENCIES & LIBRARIES:
%   Nil

% REFERENCE: 
%   Shafa-at Ali Sheikh et al. "An Open Sourc Toolbox for Automated Removal
%   of Noisy Beats for Accurate ICG Analysis" (** Details to be added**) 

%	REPO for code:       
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_Annotation
%
%   REPO for demo data:
%   1. Input data: 
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG
%   2. Sample output data:
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Sample_Annotations_by_ICMAA
%
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information

% This file has been updated on Nov 7, 2019 by Shafa-at Ali Sheikh.


%% Initializing variables
clc, clear
% signal related variables
global fs t time ecg icg                % Sampling Frequency % time vec for plot % time: signal duration % ecg sig % icg signal

% Variables for formating figure and objects on it
global color_set color_help color_help_txt;           % Backgr colour of main window and help line
global left w1 w2                                     % left allignment % w1 :width - load record sel data % w2 width -recordname; up/down pages, slider
global fontsize12 fontsize10 fontsize14               % fontsize of objects on figure
global seg_window  seg_time                           % seg_window under inspection;  = interval for xtick and plot

% variables for folder and data reading writing
global rec_folder ;                     %  for sel folder for reading data from computer
global folder_path_manual               %  for folder saving ICG ECG points
global file_path;                       % Path of file for reading data from computer
global Files;                           % 2 x 1 struct finding .mat files with fields :name, folder, date, bytes, isdir, datenum
global fullFileName
global record_num;                      % Number of records in folder
global record_list                      %
global record_name                      %
global record_cur                       % current record in data folder
global page_cur page_num                % current Page number and total number of pages for data

% R C, B X manual variables
global stop_Rpeak_mk;           % stop R peak marking variable
global Rpeak_txt_data;          % Data from '_Rpeaks.txt' is stored in this variable using dlmread
global Rpeak_indices;           % sample numbers of Rpeak_indices (column vector)
global stop_Cpoint_mk      Cpoint_indices    Cpoint_txt_data;
global stop_Bpoint_mk      Bpoint_indices    Bpoint_txt_data;
global stop_Xpoint_mk      Xpoint_indices    Xpoint_txt_data;

global icg_mag_B B_line Bpt_line Bpt_x_line x_final_Bpt_line Bpt_y_line  y_final_Bpt_line       % drag line variables for B point
global icg_mag_C C_line Cpt_line Cpt_x_line x_final_Cpt_line Cpt_y_line  y_final_Cpt_line        % drag line variables for C point
global icg_mag_X X_line Xpt_line Xpt_x_line x_final_Xpt_line Xpt_y_line  y_final_Xpt_line        % drag line variables for X point
global ecg_mag_R R_line Rpt_line Rpt_x_line x_final_Rpt_line Rpt_y_line  y_final_Rpt_line        % drag line variables for R peak

% higher derviatives of icg and plot variables
global icg_D1 icg_D2 id_grad  inflec_1 inflec_2    % first derivative; 2nd derivative, signs, startpt, endpt,
global qrs_pos
global timelim
global ECG_hide_mk                                             % ECG hide mark
global timer                            % timer to pause between marking points

% global variables for the shape of RC features, C shape and X shape
global RC_feature C_shape X_shape                   % To store type of RC feature, C peak shape , and X wave shape
global hRC_pop htimeaxes_pop hC_pop                 % pop up menues
global beatsFeature beatsCshape beatsXshape

% Misc variables

%%
clc
addpath(pwd);
% values for variables
color_set = [0.2 0.8 0.8]; color_help=[0 0 0]; color_help_txt = [1 1 0];

left=0.06;         % left allignment of navigation panel heading with plots; also used for navigation buttons allignment
w1=0.10;           % width of Sel Dataset, load, record list
w2=0.15;           % width of recordname; up/down pages, slider
fontsize12=12;
fontsize10=10;
fontsize14 = 14;
seg_window = 1.0;   % x lim of the plotwindow
seg_time = 0.2;     % minor xtick on time axes
page_cur = 1;       % initializing current page
record_cur=1;       % initilalizing current record

%% controls for Record sel panel
seldata_stx = left;            % Select Dataset  start x axis point
rec_stx = 3*left;              % Record, Record list, Record tag  start x axis point
load_stx = 5*left;             % Load record  start x axis point
recID_stx = 7*left;          % Record ID  start x axis point
nav_stx = 9.1*left;              % Navigation  start x axis point
time_stx = 11*left;            % Time axes start x axis point

%% controls for Points panel
widthButtons =0.045;
highButtons =0.035;            % used in heightof buttons as well panels
yPositionButtonsOnset=0.5825;
yPositionButtonsOffset=0.2425;
Rnew_st_x = 0.785;
Cnew_st_x = 0.835;
Bnew_st_x = 0.885;
Xnew_st_x = 0.935;



%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%   Main Figure, Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% creat MainFigure and controls on it
hMainFigure = figure('Name', 'ICG Manual Annotation Application', ...
    'NumberTitle', 'off', ...
    'Resize', 'on', ...
    'Units', 'pixel',...
    'HandleVisibility', 'callback',...
    'Position', [100 100 1024 568],...
    'color',[0 0 0]);

%% Record selection panel
record_sel_panel = uipanel('Parent', hMainFigure,...
    'Units', 'normalized',...
    'Position', [left-.02   0.74  0.74 0.18]);  % Panel for Record selection

tickECGpt = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [left-.02    0.9    0.74   0.04], ...
    'String', 'Record Selection, Loading and Navigation Panel',...
    'fontweight','bold',...
    'fontsize',13,...
    'Foreground', [1 1 0],...   % yellow colour
    'background',[0.2 0.6 0.8]);

%% Initialize selection of records folder and load record
hsel_record_folder = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [seldata_stx   0.76    w1    0.11], ...
    'TooltipString', ['Select folder containing', newline, ...
    'ECG & ICG records.'],...
    'fontsize',fontsize14,...
    'background',[0.2 0.8 0.6],....
    'Callback', @sel_folder);

set(hsel_record_folder, 'String', '<html> Select <br> Records Folder');    % for multi line button text


    function sel_folder(~, ~)       % for selecting Recordfolder
        path=uigetdir;                         % opens the window to select Recordwindow
        if path == 0
            % User clicked the Cancel button.
            return;
        end
        
        [~,rec_folder] = fileparts(path);
        addpath(genpath(path));
        file_path = [path filesep];
        Files = dir(fullfile(file_path,'*.mat'));      % Files - struct; finding .mat files
        record_num=length(Files);                      % Number of records in folder
        record_list=cell(record_num,1);                % cell
        if (record_num == 0)
            msgbox('Please select folder containing records.','Warning Window Name','warn');
            set(hB_loadrecord,'Enable', 'off');
        else
            set(hB_loadrecord,'Enable', 'on');
        end
        
        for kk=1:record_num
            record_list{kk}=num2str(kk);
        end
        
        set(hrecord_list,'String',record_list);
        set(tick_curr_record, 'String','--');
        set(tick_segment,'String','--');
        set(tick_segment1,'String','--');
        set(tick_total_pages,'String','--');
        set(tick_record_name,'String','--');
        
        % Setting axes and hide show ECG
        cla(hplotICG);
        cla(hplotECG);
        set(hplotECG,'Visible','on')
        set(hplotICG, 'Position',[0.04    0.07    0.74   0.335])
        set(hECG_show,'Enable','off')
        set(hECG_hide,'Enable','Off')
        set(hdisp_RC_feature,'Visible','Off')
        set(hdisp_C_Shape,'Visible','Off')
        set(hdisp_X_Shape,'Visible','Off')
        
        % Setting enable off for all buttons on selecting the Record folder
        set(hadd_notes,'Enable','off'); set(hBeatNumEdit_page,'Enable','off')
        
        set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off');
        set(hauto_Rpeak,'Enable','off');
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','off');
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off'),set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint,'Enable','off');
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','off');
        
        
    end


%-------------------- setting recording----------------------------------
tick_record0 = uicontrol(hMainFigure, ...     %text box for list
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [ rec_stx    0.845    w1*0.5    0.025], ...
    'String', 'Records',...
    'fontweight', 'bold',...
    'background',[0.2 0.6 0.8],....
    'fontsize',fontsize10);

tick_curr_record0 = uicontrol(hMainFigure, ...     %text box for list
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [ rec_stx+w1*0.5     0.82    w1*0.5    0.05], ...
    'String', 'Current Record ',...
    'fontweight', 'bold',...
    'background',[0.2 0.6 0.8],....
    'fontsize',fontsize10);

tick_curr_record = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [rec_stx+w1*0.5     0.76    w1*0.5    0.06], ...
    'String', '--',...
    'Foreground', [1 0 0],...
    'fontsize',fontsize14);

hrecord_list = uicontrol(hMainFigure, ...   % List box for records in folder
    'Style', 'listbox', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [rec_stx  0.76    w1*0.5   0.087], ...
    'String', record_list, ...
    'fontsize',9.5,...
    'Callback', @setting_record);

    function setting_record(hObject, ~)
        record_cur = round(get(hObject,'Value'));
        set(hrecord_list,'String',record_list);
    end

%% -------------------- Load record -----------------------------%

hB_loadrecord = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [load_stx  0.76    w1    0.11], ...
    'String', 'Load Record', ...
    'TooltipString', ['Load ECG & ICG record', newline, ...
    ' from "Records"'],...
    'fontsize',fontsize14,...
    'background',[0.2 0.8 0.6],....
    'Enable', 'on',...
    'Callback', @load);

%---------------------show Record information------------------------------
tickrecordshow = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [recID_stx  .81    w1+0.01    0.06], ...
    'String', 'Current Record ID',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);

tick_record_name = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can change text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [recID_stx  0.76  w1+0.01  0.06], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize14);

%% setting axes
hplotECG = axes(...
    'Parent', hMainFigure,...
    'HandleVisibility', 'callback', ...
    'Units', 'normalized', ...
    'Position', [0.04    0.45    0.74    0.23], ...
    'XLim', [0,seg_window], ...
    'YLim', [-3 3], ...
    'XTick', 0:seg_time:seg_window,...
    'XMinorGrid', 'on',...
    'YMinorGrid', 'on',...
    'YColor', 'y',...
    'XColor', 'y',...
    'XGrid', 'on',...
    'YGrid', 'on',...
    'GridColor', 'black',...
    'MinorGridColor', 'black',...
    'NextPlot', 'replacechildren');
ylabel(hplotECG,'ECG (mV)','Color','y');

hplotICG = axes(...
    'Parent', hMainFigure, ...
    'HandleVisibility', 'callback', ...
    'Units', 'normalized', ...
    'Position', [0.04    0.07    0.74   0.335], ...
    'XLim', [0,seg_window], ...
    'YLim', [-3 3], ...
    'XTick', 0:seg_time:seg_window,...
    'YColor', 'y',...
    'XColor', 'y',...
    'XGrid', 'on',...
    'YGrid', 'on',...
    'XMinorGrid', 'on',...
    'YMinorGrid', 'on',...
    'GridColor', 'black',...
    'MinorGridColor', 'black',...
    'NextPlot', 'replacechildren');

ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
xlabel(hplotICG,'Time (s)','Color','y');
%% Help line for marking of points

tick_help = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.15   0.69   0.5    0.03], ...
    'String', '', ...
    'fontsize',fontsize12,...
    'background',[0 0 0]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%            Functions              %%%%%%%%%%%%%%%%%%%%%%%%%%

%% Function Load
    function load(hObject, ~, ~)
        get(hObject)
        
        set(hBeatNumEdit_page,'Value',1);
        page_cur=1;
        
        [~, aa2] = find(Files(record_cur).name=='.');
        record_name = Files(record_cur).name(1:aa2-1);
        
        fs = 1000;
        FileName = Files(record_cur).name;
        fullFileName = fullfile(file_path, FileName);
        ecg_icg = importdata(FileName);
        
        %%       ecg_icg = ecg_icg./10000;   % for v4 version
        
        if size(ecg_icg,1) > size(ecg_icg,2)
            ecg = ecg_icg(:,1);
            icg = ecg_icg(:,2);
        else
            ecg = ecg_icg(1,:);
            icg = ecg_icg(2,:);
        end
        
        % finding higher derivatives for ICG
        icg_D1=gradient(icg);
        icg_D2=gradient(icg_D1);
        id_grad=sign(icg_D2);                       % sign of 2nd derivative of icg
        
% % %         icg_D1=diff(icg);
% % %         icg_D2=diff(icg_D1);
% % %         id_grad=sign(icg_D2);                       % sign of 2nd derivative of icg
        
        t = 1/fs:1/fs:length(ecg)/fs;
        time = length(ecg)/fs;
        seg_window = (length(ecg)/fs);
        page_num = ceil(time/seg_window);
        set(htimeaxes_pop, 'Enable', 'on');       
        set(htimeaxes_pop, 'Value', 1);
        timelim = 'Data Length';
        
        
        if page_num>1
            set(tick_segment, 'String',num2str(page_cur));
            set(tick_segment,'ForegroundColor',[1 0 0]);
            set(tick_segment1, 'String',num2str(page_cur));
            set(tick_segment1,'ForegroundColor',[1 0 0]);
            set(tick_total_pages, 'String',num2str(page_num));
            set(hBeatNumEdit_page,'Max',page_num);
            set(hBeatNumEdit_page,'SliderStep',[1/(page_num-1),1/(page_num-1) + 0.1]);
        else
            set(tick_segment, 'String',num2str(page_cur));
            set(tick_segment,'ForegroundColor',[1 0 0]);
            set(tick_segment1, 'String',num2str(page_cur));
            set(tick_segment1,'ForegroundColor',[1 0 0]);
            set(tick_total_pages, 'String',num2str(page_num));
            set(hBeatNumEdit_page,'Max',page_num+1);
            set(hBeatNumEdit_page,'SliderStep',[1/(page_num),1/(page_num-1) + 0.1]);
        end
        
        % setting strings of different field equal to -- on pressing "Select Records Folder"
              
        set(tick_curr_record, 'String',num2str(record_cur));
        set(tick_record_name, 'String',record_name);
        set(tick_record_name,'ForegroundColor',[1 0 0]);
        
        set(hRC_pop, 'Value', 1);set(hC_pop,'value',1);set(hX_pop,'value',1);
        set(hRC_pop, 'Enable', 'off');set(hC_pop,'Enable', 'off');set(hX_pop,'Enable', 'off');
        set(hdisp_RC_feature,'Visible','off'); set(hdisp_C_Shape,'Visible','Off');set(hdisp_X_Shape,'Visible','Off')
        ECG_hide_mk=0;


        
        % axes setting on loading the record
        set(hplotECG,'Visible','on');
        set(hplotICG, 'Position',[0.04    0.07    0.74   0.335]);
        set(hECG_hide,'Enable','on');set(hECG_show,'Enable','off');
        
        set(hdisp_data_ECG,'Visible','off');

       
        set(hadd_notes,'Enable','on');set(hBeatNumEdit_page,'Enable','on');
        set(hdel_Rpeak,'Enable','on');set(hadd_Rpeak,'Enable','on');set(hstop_Rpeak,'Enable','off')
        set(hauto_Rpeak,'Enable','on');
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','on');
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off'),set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint,'Enable','off')
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','on');
        
        
        set(hinflec_show,'Enable','off');
                
        set(hcomp_param,'Enable','off');
        set(tick_segment1,'String','--');        
        set(tick_RB_text,'String','--');
        set(tick_RC_text,'String','--');
        set(tick_BX_text,'String','--');
        set(tick_beat_len_text,'String','--');
        set(tick_Camp_text,'String','--');
        set(tick_Bamp_text,'String','--');
        set(tick_Xamp_text,'String','--');
        
        %5------------------ For creating text files for Rpeak, C, B , X point------------------------------------
        ann_folder = strcat(rec_folder, '_manual_annotation');
        cd(file_path)
        ann_folder_path = fullfile(file_path,ann_folder);
        
        if ~exist(ann_folder_path,'dir')    % Folder for saving annotation of ECG ICG Points
            mkdir(ann_folder);
        end
        
        
        folder_path_manual = char(strcat(file_path,ann_folder,'\'));
        
        
        Files_folder_manual = dir(fullfile(folder_path_manual,'*.txt'));
        
        
        %5------------------  creating text files for Rpeak, C, B Bavg Xpoint------------------------------------
        
        if exist(strcat(folder_path_manual,record_name,'_Rpeak','.txt'),'file')
            Rpeak_file = dir(strcat(folder_path_manual,record_name,'_Rpeak','.txt'));
            if Rpeak_file.bytes == 0
                delete(strcat(folder_path_manual,record_name,'_Rpeak','.txt'));
            else
                Rpeak_txt_data = dlmread(strcat(folder_path_manual,record_name,'_Rpeak.txt'));
                Rpeak_indices = Rpeak_txt_data(:,1);
            end
        else
            Rpeak_indices = [];
        end
        
        
        if exist(strcat(folder_path_manual,record_name,'_Cpoint','.txt'),'file')
            Cpoint_file = dir(strcat(folder_path_manual,record_name,'_Cpoint','.txt'));
            if Cpoint_file.bytes ==0
                delete ( strcat(folder_path_manual,record_name,'_Cpoint','.txt'))
            else
                Cpoint_txt_data = dlmread(strcat(folder_path_manual,record_name,'_Cpoint.txt'));
                Cpoint_indices = Cpoint_txt_data(:,1);
            end
        else
            Cpoint_indices = [];
        end
        
        if exist(strcat(folder_path_manual,record_name,'_Bpoint','.txt'),'file')
            Bpoint_file = dir(strcat(folder_path_manual,record_name,'_Bpoint','.txt'));
            if Bpoint_file.bytes == 0
                delete (strcat(folder_path_manual,record_name,'_Bpoint','.txt'))
            else
                Bpoint_txt_data = dlmread(strcat(folder_path_manual,record_name,'_Bpoint.txt'));
                Bpoint_indices = Bpoint_txt_data(:,1);
            end
        else
            Bpoint_indices = [];
        end
        
        if exist(strcat(folder_path_manual,record_name,'_Xpoint','.txt'),'file')
            Xpoint_file = dir(strcat(folder_path_manual,record_name,'_Xpoint','.txt'));
            if Xpoint_file.bytes == 0
                delete(strcat(folder_path_manual,record_name,'_Xpoint','.txt'))
            else
                Xpoint_txt_data = dlmread(strcat(folder_path_manual,record_name,'_Xpoint.txt'));
                Xpoint_indices = Xpoint_txt_data(:,1);
            end
        else
            Xpoint_indices = [];
        end
        
        if exist(strcat(folder_path_manual,record_name,'_Feature','.txt'),'file')
            fid = fopen(strcat(folder_path_manual,record_name,'_Feature.txt'));
            feature_data = fgetl(fid);
            fclose(fid);
            set(hdisp_RC_feature,'String',feature_data)
           
        else
            set(hdisp_RC_feature,'String','Select Feature')
        end
        
        
        if exist(strcat(folder_path_manual,record_name,'_CShape','.txt'),'file')
            fid = fopen(strcat(folder_path_manual,record_name,'_CShape.txt'));
            Cshape_data = fgetl(fid);
            fclose(fid);
            set(hdisp_C_Shape,'String',Cshape_data)      
        else
            set(hdisp_C_Shape,'String','Select C Shape')
        end
        
        if exist(strcat(folder_path_manual,record_name,'_XShape','.txt'),'file')
            fid = fopen(strcat(folder_path_manual,record_name,'_XShape.txt'));
            Xshape_data = fgetl(fid);
            fclose(fid);
            set(hdisp_X_Shape,'String',Xshape_data)       
        else
            set(hdisp_X_Shape,'String','Select X Shape')
        end
        %------------------ END creating text files for Rpeak, C, B, X and S/F point------------------------------------
        
        %-----------------------------Handling extra marked annotations-----------
        max_Bpoint = max(Bpoint_indices);
        if max_Bpoint > length(icg)
            question_ans_B = questdlg('B point annotations are more than size of ICG record. Do you want to delete incorrect B point annotation file?',...
                'Extra B points','Yes','No','Yes');
            if strcmp(question_ans_B,'Yes')
                delete (strcat(folder_path_manual,record_name,'_Bpoint.txt'))
                Bpoint_indices = [];
            end
        end
        
        max_Cpoint = max(Cpoint_indices);
        if max_Cpoint > length(icg)
            question_ans_C = questdlg('C point annotations are more than size of ICG record. Do you want to delete incorrect C point annotation file?',...
                'Extra C points','Yes','No','Yes');
            if strcmp(question_ans_C,'Yes')
                delete (strcat(folder_path_manual,record_name,'_Cpoint.txt'))
                Cpoint_indices = [];
            end
        end
        
        max_Xpoint = max(Xpoint_indices);
        if max_Xpoint > length(icg)
            question_ans_X = questdlg('X point annotations are more than size of ICG record. Do you want to delete incorrect X point annotation file?',...
                'Extra X points','Yes','No','Yes');
            if strcmp(question_ans_X,'Yes')
                delete (strcat(folder_path_manual,record_name,'_Xpoint.txt'))
                Xpoint_indices = [];
            end
        end
        max_Bpoint = max(Rpeak_indices);
        if max_Bpoint > length(ecg)
            question_ans_B = questdlg('R peak annotations are more than size of ECG record. Do you want to delete incorrect R peak annotation file?',...
                'Extra B points','Yes','No','Yes');
            if strcmp(question_ans_B,'Yes')
                delete (strcat(folder_path_manual,record_name,'_Rpeak.txt'))
                Rpeak_indices = [];
            end
        end
        
        
        
        %-------------------Plotting results -------------------------------------------------
        limitX1 = (page_cur-1)*seg_window;
        limitX2 = (page_cur)*seg_window;
        xlimit = [limitX1  limitX2];
        
        minamp_Ch1 = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1 =  max(ecg((round(xlimit(1)*fs)+1):end));
        
        pecg =  plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
        set(pecg,'Linewidth',1.5)
        
        picg = plot(hplotICG,t,icg,'b-',...
            t(Rpeak_indices),icg(Rpeak_indices),'r+',...
            t(Cpoint_indices),icg(Cpoint_indices),'ro',...
            t(Bpoint_indices),icg(Bpoint_indices),'bo',...
            t(Xpoint_indices),icg(Xpoint_indices),'ko');
        set(picg,'Linewidth',1.5)
        
        text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
        text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
        text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
        text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
        
        
        
        set(hplotECG,'XLim',xlimit);
        set(hplotECG,'YLim',[(minamp_Ch1-1*abs(minamp_Ch1))  (maxamp_Ch1+0.5*abs(maxamp_Ch1))]);
        set(hplotECG,'Xtick',limitX1:seg_time:limitX2);
        ylabel(hplotECG,'ECG (mV)','Color','y');
        set(hplotECG,'XGrid','on');
        
        minamp_Ch2 =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2 =  max(icg((round(xlimit(1)*fs)+1):end));
        
        limit_ch2_Y1 = (minamp_Ch2-0.5*abs(minamp_Ch2));
%         limit_ch2_Y2 = (maxamp_Ch2Ca+0.1*abs(maxamp_Ch2Ca));
         limit_ch2_Y2 = (maxamp_Ch2+0.1);
        
        
        set(hplotICG,'XLim',xlimit);
        set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
        
        set(hplotICG,'Xtick',limitX1:seg_time:limitX2);
        xlabel(hplotICG,'Time (s)','Color','y');
        ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
        set(hplotICG,'XGrid','on');
        if (strcmp(timelim,'RC Interval'))
            set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
            set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
        end
    end

%% navigation slider part
txt_BbB_nav = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [nav_stx    0.80    w1    0.07], ...
    'String', 'Beat by Beat Navigation',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);

hBeatNumEdit_page = uicontrol(hMainFigure, ...          % slider for "Record Navigation"
    'Style', 'slider', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [nav_stx   0.785  w1    0.025], ...
    'String', '--', ...
    'fontsize',fontsize12,...
    'foreground', [1 0 0],...
    'Min',1,'Max',10,'Value',1,...
    'Enable', 'off',...
    'Callback', @setting_page);

tick_segment = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [nav_stx  0.76  w1/2  0.03], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

tick_total_pages = uicontrol(hMainFigure, ...     % total page Number text box
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [nav_stx+0.05  0.76  w1/2  0.03], ...
    'String', '--',...
    'fontsize',fontsize10);

% this function helps in displaying the ECG and ICG on changing scroll bar up and down
    function setting_page(hObject, ~)
                
        page_cur = round(get(hObject,'Value'));
        set(tick_segment, 'String',num2str(page_cur));
        set(tick_segment,'ForegroundColor',[1 0 0]);
        set(tick_segment1, 'String',num2str(page_cur));
        set(tick_segment1,'ForegroundColor',[1 0 0]);
        set(tick_total_pages, 'String',num2str(page_num));
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch1S = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1S =  max(ecg((round(xlimit(1)*fs)+1):end));
        
        set(hplotECG,'XLim',xlimit);
        set(hplotECG,'YLim',[(minamp_Ch1S-1*abs(minamp_Ch1S))  (maxamp_Ch1S+0.5*abs(maxamp_Ch1S))]);
        set(hplotECG,'Xtick',limitX1 :seg_time:limitX2);
        ylabel(hplotECG,'ECG (mV)','Color','y');
        
        minamp_Ch2S =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2S =  max(icg((round(xlimit(1)*fs)+1):end));
        limit_ch2_Y1 = (minamp_Ch2S-0.5*abs(minamp_Ch2S));
 %      limit_ch2_Y2 = (maxamp_Ch2Ca+0.1*abs(maxamp_Ch2Ca));
        limit_ch2_Y2 = (maxamp_Ch2S+0.1);
        
        set(hplotICG,'XLim',xlimit);
        set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
        set(hplotICG,'Xtick',limitX1 :seg_time:limitX2);
        xlabel(hplotICG,'Time (s)','Color','y');
        ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
        set(hplotICG,'XGrid','on');
        if (strcmp(timelim,'RC Interval'))
            set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
            set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
        end
        
        % Camilo
        RC_feat = cellstr(get(hRC_pop,'String'));
        RC_feature = RC_feat{ beatsFeature( page_cur )};
        set(hdisp_RC_feature,'String',strcat('RC: ', RC_feature))
        set(hRC_pop, 'Value', 1)
        
        C_shp = cellstr(get(hC_pop,'String'));
        C_shape= C_shp{ beatsCshape( page_cur )};
        set(hdisp_C_Shape,'String',strcat('C: ', C_shape));
        set(hC_pop, 'Value', 1);
        
        X_shp = cellstr(get(hX_pop,'String'));
        X_shape= X_shp{ beatsXshape( page_cur )};
        set(hdisp_X_Shape,'String',strcat('X: ', X_shape))
        set(hX_pop, 'Value', 1);
       
        
        set(tick_RB_text,'String','--')
        set(tick_RC_text,'String','--')
        set(tick_BX_text,'String','--')
        set(tick_beat_len_text,'String','--');
        set(tick_Camp_text,'String','--')
        set(tick_Bamp_text,'String','--')
        set(tick_Xamp_text,'String','--')
        inflec_clear;                         % clearing inflection on changing page setting
       
    end

%% Time axes control - pop up menu
htimeaxes_pop = uicontrol(hMainFigure, ...          % popup menu for "Up/down pages"
    'Style', 'popupmenu', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [time_stx   0.82  w1   0], ...
    'String', {'Data Length','Beat Length','RC Interval'}, ...
    'HorizontalAlignment', 'center',...
    'fontsize',fontsize12,...
    'Tag', 'timelim',...
    'Enable', 'off',...
    'Value', 1,...
    'Callback', @time_con);

txt_timeaxes = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [time_stx   0.82    w1    0.05], ...
    'String', 'Time Axes Control',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);

    function time_con(hObject, ~)
        contents = cellstr(get(hObject,'String'));
        timelim = contents{get(hObject,'Value')};

        if (strcmp(timelim,'Data Length'))
            set(hdisp_RC_feature,'visible','off');
            set(hdisp_C_Shape,'visible','off');
            set(hdisp_X_Shape,'visible','off');
            set(hRC_pop,'Enable','off');
            set(hC_pop,'Enable', 'off');
            set(hX_pop,'Enable', 'off');
            set(hauto_Bpoint, 'Enable', 'off');
                                                % parameter panel initialized
            set(tick_segment1,'String','--');  
            set(tick_RB_text,'String','--');
            set(tick_RC_text,'String','--');
            set(tick_BX_text,'String','--');
            set(tick_beat_len_text,'String','--');
            set(tick_Camp_text,'String','--');
            set(tick_Bamp_text,'String','--');
            set(tick_Xamp_text,'String','--');
            set(hcomp_param,'Enable','off');
                     
            seg_window = (length(ecg)/fs);
            page_num = ceil(time/seg_window);
            page_cur = page_num;                       % for "data length" page_cur = page_num
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            
        elseif(strcmp(timelim,'Beat Length'))
            Rpeak_indices = sort(Rpeak_indices);
            if length(Rpeak_indices) <=1
                msgbox('Please annotate R peak for displaying ECG and ICG beat','Warning Window Name','warn')    
                set(htimeaxes_pop, 'value', 1)
            else
                seg_window = (length(ecg)/fs)/length(Rpeak_indices);          
                set(hcomp_param,'Enable','on');
                set(hdisp_RC_feature,'visible','on');
                set(hRC_pop,'Enable','on');
                RC_feat = cellstr(get(hRC_pop,'String'));
                RC_feature = RC_feat{ beatsFeature(1)};
                set(hdisp_RC_feature,'String',strcat('RC: ', RC_feature)) ;
            end
            
            if ECG_hide_mk                               % checking if ECG Hide is activated or not
                set(hdisp_C_Shape,'visible','on');
                set(hdisp_X_Shape,'visible','on');
                set(hdisp_RC_feature,'visible','on');
                set(hC_pop,'Enable','on');
                set(hX_pop,'Enable', 'on');
            else
                set(hdisp_C_Shape,'visible','off');
                set(hdisp_X_Shape,'visible','off');
                set(hdisp_RC_feature,'visible','off');
                set(hC_pop,'Enable','off');
                set(hX_pop,'Enable', 'off');
            end
            
            C_shp = cellstr(get(hC_pop,'String'));
            C_shape = C_shp{ beatsCshape(1)};
            set(hdisp_C_Shape,'String',strcat('C: ', C_shape));

            X_shp = cellstr(get(hX_pop,'String'));
            X_shape = X_shp{beatsXshape(1)};
            set(hdisp_X_Shape,'String',strcat('X: ', X_shape))
            
            page_num = ceil(time/seg_window);
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            set(hauto_Bpoint,'Enable','on');
        
        elseif (strcmp(timelim,'RC Interval'))
            Rpeak_indices = sort(Rpeak_indices);
            Cpoint_indices = sort(Cpoint_indices);
            if (length(Rpeak_indices) <=1) || (length(Cpoint_indices) <=1)
                msgbox('Please annotate R peak and C point for displaying RC interval','Warning Window Name','warn');
            else
                rr = diff(sort(Rpeak_indices./fs));
                mean_rr = mean(rr);
                seg_window = mean_rr/3.5;
            end
            
            set(hcomp_param,'Enable','on');           
            set(hRC_pop,'Enable','on');
            RC_feat = cellstr(get(hRC_pop,'String'));
            RC_feature = RC_feat{ beatsFeature(1)};
            set(hdisp_RC_feature,'String',strcat('RC: ', RC_feature)) ;
            
            C_shp = cellstr(get(hC_pop,'String'));
            C_shape = C_shp{ beatsCshape(1)};
            set(hdisp_C_Shape,'String',strcat('C: ', C_shape));
              
            set(hdisp_X_Shape,'visible','off');         % X shape, popoup menu and auto marker not required
            set(hX_pop,'Enable','off');
            set(hauto_Xpoint,'Enable','off')
            
            if ECG_hide_mk                               % checking if ECG Hide is activated or not
                set(hdisp_C_Shape,'visible','on');
                set(hdisp_RC_feature,'visible','on');
                set(hC_pop,'Enable','on');
            else
                set(hdisp_C_Shape,'visible','off');
                set(hdisp_RC_feature,'visible','off');  
                set(hC_pop,'Enable','off');
            end
                           
            page_num = length(Rpeak_indices);
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            
            set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off');set(hstop_Xpoint,'Enable','off');
            set(hauto_Xpoint,'Enable','off');
            set(hauto_Bpoint,'Enable','on');                  
        end
        set(hBeatNumEdit_page,'Value',page_cur);
        set(tick_segment, 'String',num2str(page_cur));
        set(tick_segment,'ForegroundColor',[1 0 0]);
        set(tick_segment1, 'String',num2str(page_cur));
        set(tick_segment1,'ForegroundColor',[1 0 0]);
        set(tick_total_pages, 'String',num2str(page_num));
        xlimit = [limitX1  limitX2];
        
        minamp_Ch1S = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1S =  max(ecg((round(xlimit(1)*fs)+1):end));
        set(hplotECG,'XLim',xlimit);
        set(hplotECG,'YLim',[(minamp_Ch1S-1*abs(minamp_Ch1S))  (maxamp_Ch1S+0.5*abs(maxamp_Ch1S))]);
        set(hplotECG,'Xtick',limitX1 :seg_time:limitX2);
        ylabel(hplotECG,'ECG (mV)','Color','y');
        
        minamp_Ch2S =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2S =  max(icg((round(xlimit(1)*fs)+1):end));
        limit_ch2_Y1 = (minamp_Ch2S-0.5*abs(minamp_Ch2S));
 %      limit_ch2_Y2 = (maxamp_Ch2Ca+0.1*abs(maxamp_Ch2Ca));
        limit_ch2_Y2 = (maxamp_Ch2S+0.1);
        
        set(hplotICG,'XLim',xlimit);
        set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
        set(hplotICG,'Xtick',limitX1 :seg_time:limitX2);
        xlabel(hplotICG,'Time (s)','Color','y');
        ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
        set(hplotICG,'XGrid','on');
        if (strcmp(timelim,'RC Interval'))
            set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
            set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
        end
        
        if page_num>1
            set(tick_segment, 'String',num2str(page_cur));
            set(tick_segment,'ForegroundColor',[1 0 0]);
            set(tick_segment1, 'String',num2str(page_cur));
            set(tick_segment1,'ForegroundColor',[1 0 0]);
            set(tick_total_pages, 'String',num2str(page_num));
            set(hBeatNumEdit_page,'Max',page_num);
            set(hBeatNumEdit_page,'SliderStep',[1/(page_num-1),1/(page_num-1) + 0.1]);
        else
            set(tick_segment, 'String',num2str(page_cur));
            set(tick_segment,'ForegroundColor',[1 0 0]);
            set(tick_segment1, 'String',num2str(page_cur));
            set(tick_segment1,'ForegroundColor',[1 0 0]);
            set(tick_total_pages, 'String',num2str(page_num));
            set(hBeatNumEdit_page,'Max',page_num+1);
            set(hBeatNumEdit_page,'SliderStep',[1/(page_num),1/(page_num-1) + 0.1]);
        end
        
        inflec_clear;                                   % clearing inflection on changing time settings
        
        % Camilo initialization of feature name reading from existing file
        % or initalizing to "Select Feature"
        
        if exist( strcat(folder_path_manual,record_name,'_Feature','.txt') , 'file')
            beatsFeature = dlmread( strcat(folder_path_manual,record_name,'_Feature','.txt') );
        else
            beatsFeature = ones(length(Rpeak_indices),1);               % Initializing to "Select Feature"    
        end
        
        if exist( strcat(folder_path_manual,record_name,'_CShape','.txt') , 'file')
            beatsCshape = dlmread( strcat(folder_path_manual,record_name,'_CShape','.txt') );
        else
            beatsCshape = 2.*ones(length(Rpeak_indices),1);               % Initializing to "Single Peak"    
        end
        
        if exist( strcat(folder_path_manual,record_name,'_XShape','.txt') , 'file')
            beatsXshape = dlmread( strcat(folder_path_manual,record_name,'_XShape','.txt') );
        else
            beatsXshape = ones(length(Rpeak_indices),1);               % Initializing to "Select X shape"    
        end
        
    end


%*************************************************************************************************************
%% BUTTON FUNCTIONALITIES FOR ADD, CORRECT, REMOVE points


Pts_panel = uipanel('Parent', hMainFigure,...
    'Units', 'normalized',...
    'Position', [0.781   yPositionButtonsOffset-5*highButtons 0.205 0.86]);  % Panel for ECG buttons

tickAnn_panel = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.781    0.9     0.205   0.04], ...
    'String', 'Current Beat Parameter Panel',...
    'fontweight','bold',...
    'fontsize',13,...
    'Foreground', [1 1 0],...   % yellow colour
    'background',[0.2 0.6 0.8]);


tickECG_panel = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.781    0.64     0.205   0.04], ...
    'String', 'ECG / ICG Fiducial Points Panel',...
    'fontweight','bold',...
    'fontsize',13,...
    'Foreground', [1 1 0],...   % yellow colour
    'background',[0.2 0.6 0.8]);

tickFSelpanel = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.781    0.26    0.205   0.04], ...
    'String', 'RC Feature Selection Panel',...
    'fontweight','bold',...
    'fontsize',13,...
    'Foreground', [1 1 0],...   % yellow colour
    'background',[0.2 0.6 0.8]);

tickECG_Rpeak = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x    0.59    widthButtons    highButtons], ...
    'String', 'R Peak',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);

hdel_Rpeak = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x   yPositionButtonsOnset-1.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Del', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['To delete R peak from', newline, ...
    'ECG plot'],...
    'Callback', @del_Rpeak);

set(hdel_Rpeak,'ForegroundColor',[1 0 0]);

    function del_Rpeak(~, ~)
        
        stop_Rpeak_mk = 0;
        
        set(hinflec_show,'Enable','off'); set(hinflec_clear,'Enable','Off')
        set(hauto_Rpeak,'Enable','off')
        set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','on')
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','off');
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off'),set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint,'Enable','off');
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','off');

        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch1Rd = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1Rd =  max(ecg((round(xlimit(1)*fs)+1):end));
        minamp_Ch2Rd =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2Rd =  max(icg((round(xlimit(1)*fs)+1):end));
        
        limit_ch1_Y1 = (minamp_Ch1Rd-1*abs(minamp_Ch1Rd));
        limit_ch1_Y2 = (maxamp_Ch1Rd+ 0.5*abs(maxamp_Ch1Rd));
        limit_ch2_Y1 = (minamp_Ch2Rd-0.5*abs(minamp_Ch2Rd));
        %limit_ch2_Y2 = (maxamp_Ch2Rd+0.1*abs(maxamp_Ch2Rd));
        limit_ch2_Y2 = (maxamp_Ch2Rd+0.1);
        
        while ~stop_Rpeak_mk
            
            
            set(tick_help,'String', 'Left click inside ECG plot to delelte an incorrect R peak','background',color_help,'Foreground',color_help_txt);
            [xt,yt] = ginput(1);
            
            pause(timer)
            if ~stop_Rpeak_mk
                
                set(tick_help,'String', '','background',[0 0 0]);
                
                
                
                if ~isempty(Rpeak_indices) &&...
                        (xt>=limitX1 && xt<=limitX2) && (yt>=limit_ch1_Y1  && yt<=limit_ch1_Y2)  % checking if click is in the figure
                    
                    [~, bb]=min(abs(Rpeak_indices-xt*fs));
                    selectedBeat = Rpeak_indices(bb);
                    cur_indx=find(Rpeak_txt_data(:,1)==selectedBeat,1);
                    
                    
                    Rpeak_txt_data(cur_indx,:)=[];
                    Rpeak_indices = Rpeak_txt_data(:,1);
                    
                    
                    pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                    set(pecg,'Linewidth',1.5)
                    picg = plot(hplotICG,...
                        t,icg,'b-',...
                        t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                        t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                        t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                        t(Xpoint_indices),icg(Xpoint_indices),'ko');
                    set(picg,'Linewidth',1.5)
                    text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                    text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                    text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B', 'color','blue')
                    text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
                   
                    
                    set(hplotECG,'XLim',xlimit);
                    set(hplotECG,'YLim',[limit_ch1_Y1  limit_ch1_Y2]);
                    set(hplotECG,'Xtick',(page_cur-1)*seg_window :seg_time:(page_cur)*seg_window);
                    ylabel(hplotECG,'ECG (mV)','Color','y');
                    set(hplotECG,'XGrid','on');
                    
                    set(hplotICG,'XLim',xlimit);
                    set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                    set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                    xlabel(hplotICG,'Time (s)','Color','y');
                    ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                    set(hplotICG,'XGrid','on');
                    if (strcmp(timelim,'RC Interval'))
                        set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                        set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    end
                    dlmwrite(strcat(folder_path_manual,record_name,'_Rpeak.txt'),Rpeak_txt_data,'precision','%1.0f');
                else
                    stop_Rpeak_mk = 1;
                    stop_Rpeak()
                end
            end
        end
        
    end

hadd_Rpeak = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x   yPositionButtonsOnset-2.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', '+', ...
    'fontsize',16,...
    'Enable','Off',...
    'TooltipString', ['To manually add R peaks', newline, ...
    'on ECG plot'],...
    'Callback', @add_Rpeak);
set(hadd_Rpeak,'ForegroundColor',[1 0 0]);

    function add_Rpeak(~, ~)
        stop_Rpeak_mk = 0;
        set(hdisp_data_ECG, 'string','ECG Amplitude')
        set(hdisp_data_ECG,'Visible','on');
        set(hinflec_show,'Enable','off')
        set(hauto_Rpeak,'Enable','off')
        set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','on')
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','off');
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off'),set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint,'Enable','off');
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','off');
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch1Ra = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1Ra =  max(ecg((round(xlimit(1)*fs)+1):end));
        minamp_Ch2Ra =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2Ra =  max(icg((round(xlimit(1)*fs)+1):end));
        
        limit_ch1_Y1 = (minamp_Ch1Ra-1*abs(minamp_Ch1Ra));
        limit_ch1_Y2 = (maxamp_Ch1Ra+0.5*abs(maxamp_Ch1Ra));
        limit_ch2_Y1 = (minamp_Ch2Ra-0.5*abs(minamp_Ch2Ra));
        %         limit_ch2_Y2 = (maxamp_Ch2Ra+0.1*abs(maxamp_Ch2Ra));
        limit_ch2_Y2 = (maxamp_Ch2Ra+0.1);
        
        
        set(tick_help,'String', 'Use mouse to drag line inside ECG plot and "Shift + Left click" to mark R peak','background',color_help,'Foreground',color_help_txt);
        R_line =  line(hplotECG, [mean(xlimit) mean(xlimit)], [limit_ch2_Y1 limit_ch2_Y2], ...
            'color' , 'red', ...
            'LineStyle', '-',...
            'linewidth', 1, ...
            'visible', 'on',...
            'ButtonDownFcn', @startDragFcn);
        
        set(hMainFigure,'WindowButtonUpFcn',@clickcallback)
        
        
        function startDragFcn(varargin)
            set(R_line,'LineStyle', '-.')
            set(hMainFigure, 'WindowButtonMotionFcn', @draggingFcn)
        end
        function draggingFcn(varargin)
            Rpt_line = get(hplotECG,'CurrentPoint');
            Rpt_x_line = Rpt_line(1,1);
            Rpt_y_line = Rpt_line(1,2);
            
            if (Rpt_x_line>=limitX1 && Rpt_x_line<=limitX2) && (Rpt_y_line>=limit_ch1_Y1  && Rpt_y_line<=limit_ch1_Y2)
                set(R_line, 'XData', Rpt_line(1)*[1 1]);   % dragging the line
                Rpt_x_line_index = round(Rpt_x_line*fs);
                if Rpt_x_line_index <= length(ecg)
                    ecg_mag_R= ecg(Rpt_x_line_index);
                else
                    set(hMainFigure, 'WindowButtonMotionFcn', '');
                    stop_Rpeak
                end
                set(hdisp_data_ECG, 'string', ['ECG amp:' num2str(ecg_mag_R)]); % update text for ECG amplitude
            else
                set(hMainFigure, 'WindowButtonMotionFcn', '');
                stop_Rpeak
            end
        end
        
        
        function clickcallback(obj,~)
            switch get(obj,'SelectionType')
                case 'normal'
                case 'extend'
                    zoom off
                    set(hMainFigure, 'WindowButtonMotionFcn', '');       % for stopping drag
                    x_final_Rpt_line = Rpt_x_line;
                    y_final_Rpt_line = Rpt_y_line;
                    delete(R_line)
                    plot_Rpoint
            end
        end
        function plot_Rpoint(~,~)
            
            xt = x_final_Rpt_line;
            if~stop_Rpeak_mk
                set(tick_help,'String', '','background',[0 0 0]);
                heartbeat_cur=[];
                heartbeat_cur(1,:)=[round(xt(1)*fs),0];        % Gives the sample number in x and y axes
                if ~isempty(Rpeak_indices)
                    [aa, bb]=min(abs(Rpeak_indices-xt*fs));
                    cur_indx=find(Rpeak_txt_data(:,1)==Rpeak_indices(bb),1);
                    Rpeak_txt_data(cur_indx+1:end+1,:)=Rpeak_txt_data(cur_indx:end,:);
                    Rpeak_txt_data(cur_indx,:)=heartbeat_cur;
                else
                    Rpeak_txt_data = heartbeat_cur;
                    
                end
                Rpeak_indices  = Rpeak_txt_data(:,1);       %updating Rpeak_indices
                pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                set(pecg,'Linewidth',1.5)
                
                picg = plot(hplotICG,t,icg,'b-',...
                    t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                    t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                    t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                    t(Xpoint_indices),icg(Xpoint_indices),'ko');
                set(picg,'Linewidth',1.5)
                text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
                text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
                
                set(hplotECG,'XLim',xlimit);
                set(hplotECG,'YLim',[limit_ch1_Y1  limit_ch1_Y2]);
                set(hplotECG,'Xtick',(page_cur-1)*seg_window :seg_time:(page_cur)*seg_window);
                ylabel(hplotECG,'ECG (mV)','Color','y');
                set(hplotECG,'XGrid','on');
                
                set(hplotICG,'XLim',xlimit);
                set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                xlabel(hplotICG,'Time (s)','Color','y');
                ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                set(hplotICG,'XGrid','on');
                if (strcmp(timelim,'RC Interval'))
                    set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                end
                dlmwrite(strcat(folder_path_manual,record_name,'_Rpeak.txt'),Rpeak_txt_data,'precision','%1.0f');
            end
            stop_Rpeak()
        end
    end

hstop_Rpeak = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x   yPositionButtonsOnset-3.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Stop', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['Stop manual annotation ', newline, ...
    'of R peak'],...
    'Callback', @stop_Rpeak);
set(hstop_Rpeak,'ForegroundColor',[1 0 0]);


    function stop_Rpeak(~, ~)
        
        stop_Rpeak_mk=1;
        delete(R_line);
        set(hdisp_data_ECG,'Visible','off');       
        set(tick_help,'String', '','background',[0 0 0]);
        
        set(hdel_Rpeak,'Enable','on');set(hadd_Rpeak,'Enable','on');set(hstop_Rpeak,'Enable','off');
        set(hdel_Cpoint,'Enable','on');set(hadd_Cpoint,'Enable','on');set(hstop_Cpoint,'Enable','off');
        set(hdel_Bpoint,'Enable','on');set(hadd_Bpoint,'Enable','on');set(hstop_Bpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','on');
        set(hauto_Rpeak,'Enable','on')
        set(hauto_Xpoint,'Enable','on');

        
        
        if (strcmp(timelim,'RC Interval'))
            set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off');set(hstop_Xpoint,'Enable','off');
        else
            set(hdel_Xpoint,'Enable','on');set(hadd_Xpoint,'Enable','on');set(hstop_Xpoint,'Enable','off')
        end
    end

hauto_Rpeak= uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x  yPositionButtonsOnset- 4.8*highButtons+0.03    widthButtons   highButtons], ...
    'String', 'Auto +', ...
    'fontsize',fontsize10,...
    'ForegroundColor',[1 0 0],...
    'Enable', 'off',...
    'TooltipString', ['To automatically add R peaks', newline, ...
    'on ECG plot'],...
    'Callback', @add_autoRpeak);


    function add_autoRpeak(~,~)
        % == managing inputs
        REF_PERIOD = 0.25;
        THRES = 0.6;
        fid_vec = [];
        SIGN_FORCE =[];
        
        
        
        [a b] = size(ecg);
        if(a>b); NB_SAMP=a; elseif(b>a); NB_SAMP=b; ecg=ecg'; end
        tm = 1/fs:1/fs:ceil(NB_SAMP/fs);
        
        % == constants
        MED_SMOOTH_NB_COEFF = round(fs/100);
        INT_NB_COEFF = round(7*fs/256); % length is 7 for fs=256Hz
        SEARCH_BACK = 1; % perform search back (FIXME: should be in function param)
        MAX_FORCE = []; % if you want to force the energy threshold value (FIXME: should be in function param)
        MIN_AMP = 0.1; % if the median of the filtered ECG is inferior to MINAMP then it is likely to be a flatline
        % note the importance of the units here for the ECG (mV)
        NB_SAMP = length(ecg); % number of input samples
        
        try
            % == Bandpass filtering for ECG signal
            % this sombrero hat has shown to give slightly better results than a
            % standard band-pass filter. Plot the frequency response to convince
            % yourself of what it does
            b1 = [-7.757327341237223e-05  -2.357742589814283e-04 -6.689305101192819e-04 -0.001770119249103 ...
                -0.004364327211358 -0.010013251577232 -0.021344241245400 -0.042182820580118 -0.077080889653194...
                -0.129740392318591 -0.200064921294891 -0.280328573340852 -0.352139052257134 -0.386867664739069 ...
                -0.351974030208595 -0.223363323458050 0 0.286427448595213 0.574058766243311 ...
                0.788100265785590 0.867325070584078 0.788100265785590 0.574058766243311 0.286427448595213 0 ...
                -0.223363323458050 -0.351974030208595 -0.386867664739069 -0.352139052257134...
                -0.280328573340852 -0.200064921294891 -0.129740392318591 -0.077080889653194 -0.042182820580118 ...
                -0.021344241245400 -0.010013251577232 -0.004364327211358 -0.001770119249103 -6.689305101192819e-04...
                -2.357742589814283e-04 -7.757327341237223e-05];
            
            b1 = resample(b1,fs,250);
            bpfecg = filtfilt(b1,1,ecg)';
            
            if (length(find(abs(bpfecg)>MIN_AMP))/NB_SAMP)>0.20
                % if 20% of the samples have an absolute amplitude which is higher
                % than MIN_AMP then we are good to go.
                
                % == P&T operations
                dffecg = diff(bpfecg');  % (4) differentiate (one datum shorter)
                sqrecg = dffecg.*dffecg; % (5) square ecg
                intecg = filter(ones(1,INT_NB_COEFF),1,sqrecg); % (6) integrate
                mdfint = medfilt1(intecg,MED_SMOOTH_NB_COEFF);  % (7) smooth
                delay  = ceil(INT_NB_COEFF/2);
                mdfint = circshift(mdfint,-delay); % remove filter delay for scanning back through ECG
                
                % look for some measure of signal quality with signal fid_vec? (FIXME)
                if isempty(fid_vec); mdfintFidel = mdfint; else mdfintFidel(fid_vec>2) = 0; end
                
                % == P&T threshold
                if NB_SAMP/fs>90; xs=sort(mdfintFidel(fs:fs*90)); else xs = sort(mdfintFidel(fs:end)); end;
                
                if isempty(MAX_FORCE)
                    if NB_SAMP/fs>10
                        ind_xs = ceil(98/100*length(xs));
                        en_thres = xs(ind_xs); % if more than ten seconds of ecg then 98% CI
                    else
                        ind_xs = ceil(99/100*length(xs));
                        en_thres = xs(ind_xs); % else 99% CI
                    end
                else
                    en_thres = MAX_FORCE;
                end
                
                % build an array of segments to look into
                poss_reg = mdfint>(THRES*en_thres);
                
                % in case empty because force threshold and crap in the signal
                if isempty(poss_reg); poss_reg(10) = 1; end
                
                % == P&T QRS detection & search back
                if SEARCH_BACK
                    indAboveThreshold = find(poss_reg); % ind of samples above threshold
                    RRv = diff(tm(indAboveThreshold));  % compute RRv
                    medRRv = median(RRv(RRv>0.01));
                    indMissedBeat = find(RRv>1.5*medRRv); % missed a peak?
                    % find interval onto which a beat might have been missed
                    indStart = indAboveThreshold(indMissedBeat);
                    indEnd = indAboveThreshold(indMissedBeat+1);
                    
                    for i=1:length(indStart)
                        % look for a peak on this interval by lowering the energy threshold
                        poss_reg(indStart(i):indEnd(i)) = mdfint(indStart(i):indEnd(i))>(0.5*THRES*en_thres);
                    end
                end
                
                % find indices into boudaries of each segment
                left  = find(diff([0 poss_reg'])==1);  % remember to zero pad at start
                right = find(diff([poss_reg' 0])==-1); % remember to zero pad at end
                
                % looking for max/min?
                if SIGN_FORCE
                    sign = SIGN_FORCE;
                else
                    nb_s = length(left<30*fs);
                    loc  = zeros(1,nb_s);
                    for j=1:nb_s
                        [~,loc(j)] = max(abs(bpfecg(left(j):right(j))));
                        loc(j) = loc(j)-1+left(j);
                    end
                    sign = mean(ecg(loc));  % FIXME: change to median?
                end
                
                % loop through all possibilities
                compt=1;
                NB_PEAKS = length(left);
                maxval = zeros(1,NB_PEAKS);
                maxloc = zeros(1,NB_PEAKS);
                for i=1:NB_PEAKS
                    if sign>0
                        % if sign is positive then look for positive peaks
                        [maxval(compt), maxloc(compt)] = max(ecg(left(i):right(i)));
                    else
                        % if sign is negative then look for negative peaks
                        [maxval(compt), maxloc(compt)] = min(ecg(left(i):right(i)));
                    end
                    maxloc(compt) = maxloc(compt)-1+left(i); % add offset of present location
                    
                    % refractory period - has proved to improve results
                    if compt>1
                        if maxloc(compt)-maxloc(compt-1)<fs*REF_PERIOD && abs(maxval(compt))<abs(maxval(compt-1))
                            maxloc(compt)=[]; maxval(compt)=[];
                        elseif maxloc(compt)-maxloc(compt-1)<fs*REF_PERIOD && abs(maxval(compt))>=abs(maxval(compt-1))
                            maxloc(compt-1)=[]; maxval(compt-1)=[];
                        else
                            compt=compt+1;
                        end
                    else
                        % if first peak then increment
                        compt=compt+1;
                    end
                end
                
                qrs_pos = maxloc; % datapoints QRS positions
                R_t = tm(maxloc); % timestamps QRS positions
                R_amp = maxval; % amplitude at QRS positions
                hrv = 60./diff(R_t); % heart rate
            else
                % this is a flat line
                qrs_pos = [];
                R_t = [];
                R_amp = [];
                hrv = [];
                sign = [];
                en_thres = [];
            end
        catch ME
            rethrow(ME);
            for enb=1:length(ME.stack); disp(ME.stack(enb)); end
            qrs_pos = [1 10 20]; sign = 1; en_thres = 0.5;
        end
        dumy= zeros(length(qrs_pos),1);     % dummy zeros column required for IMAA
        Rpeak_txt_data = [qrs_pos' dumy];
        
        dlmwrite(strcat(folder_path_manual,record_name,'_Rpeak.txt'),Rpeak_txt_data,'precision','%1.0f');
        Rpeak_indices = Rpeak_txt_data(:,1);
        stop_Rpeak_mk = 1;
        stop_Rpeak()
        
        pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
        set(pecg,'Linewidth',1.5)
        
        picg = plot(hplotICG,t,icg,'b-',...
            t(Rpeak_indices),icg(Rpeak_indices),'r+',...
            t(Cpoint_indices),icg(Cpoint_indices),'ro',...
            t(Bpoint_indices),icg(Bpoint_indices),'bo',...
            t(Xpoint_indices),icg(Xpoint_indices),'ko');
        set(picg,'Linewidth',1.5)
        text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
        text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
        text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
        text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
        
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','on');
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off'),set(hstop_Bpoint,'Enable','off');
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','on');

    end


%-------------------------    C point buttons and functions ------------------------------------
%% ICG  Fiducial Point C
tickECGQ = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x    0.59    widthButtons    highButtons], ...
    'String', 'C',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);

tickECGQ = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x    0.59    widthButtons    highButtons], ...
    'String', 'C',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);

hdel_Cpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x   yPositionButtonsOnset-1.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Del', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['To delete C point from', newline, ...
    'ICG plot'],...
    'Callback', @del_Cpoint);
set(hdel_Cpoint,'ForegroundColor',[1 0 0]);

    function del_Cpoint(~, ~)
        stop_Cpoint_mk = 0;
        
        set(hinflec_show,'Enable','off');set(hinflec_clear,'Enable','Off')
        set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off')
        set(hauto_Rpeak, 'Enable','off');
        set(hdel_Cpoint,'Enable','off'); set(hadd_Cpoint,'Enable','off');set(hstop_Cpoint,'Enable','on')
        set(hauto_Cpoint,'Enable','off');
        set(hdel_Bpoint,'Enable','off'); set(hadd_Bpoint,'Enable','off');set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint,'Enable','off');
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','off');


        
        
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch1Cd = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1Cd =  max(ecg((round(xlimit(1)*fs)+1):end));
        minamp_Ch2Cd =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2Cd =  max(icg((round(xlimit(1)*fs)+1):end));
        
        limit_ch1_Y1 = (minamp_Ch1Cd-1*abs(minamp_Ch1Cd));
        limit_ch1_Y2 = (maxamp_Ch1Cd+0.5*abs(maxamp_Ch1Cd));
        limit_ch2_Y1 = (minamp_Ch2Cd-0.5*abs(minamp_Ch2Cd));
%        limit_ch2_Y2 = (maxamp_Ch2Cd+0.1*abs(maxamp_Ch2Cd));
        limit_ch2_Y2 = (maxamp_Ch2Cd+0.1);

        
        while~stop_Cpoint_mk
            set(tick_help,'String', 'Left click inside ICG plot to delete an incorrect C peak','background',color_help);
            [xt,yt] = ginput(1);
            
            pause(timer)
            
            if~stop_Cpoint_mk
                set(tick_help,'String', '','background',[0 0 0]);
                
                
                if ~isempty(Cpoint_indices)  &&...
                        (xt>=limitX1 && xt<=limitX2) && (yt>=limit_ch2_Y1  && yt<=limit_ch2_Y2)
                    
                    [aa bb]=min(abs(Cpoint_indices-xt*fs));
                    selectedBeat = Cpoint_indices(bb);
                    cur_indx=find(Cpoint_txt_data(:,1)==selectedBeat,1);
                    
                    
                    Cpoint_txt_data(cur_indx,:)=[];
                    
                    Cpoint_indices = Cpoint_txt_data(:,1);
                    
                    pecg = plot(hplotECG,t,ecg,'b-',...
                        t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                    set(pecg,'Linewidth',1.5);
                    
                    picg = plot(hplotICG,t,icg,'b-',...
                        t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                        t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                        t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                        t(Xpoint_indices),icg(Xpoint_indices),'ko');
                    set(picg,'Linewidth',1.5);
                    text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red');
                    text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red');
                    text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue');
                    text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X');
                    
                    
                    set(hplotECG,'XLim',xlimit);
                    set(hplotECG,'YLim',[limit_ch1_Y1  limit_ch1_Y2]);
                    set(hplotECG,'Xtick',(page_cur-1)*seg_window :seg_time:(page_cur)*seg_window);
                    ylabel(hplotECG,'ECG (mV)','Color','y');
                    set(hplotECG,'XGrid','on');
                    
                    
                    set(hplotICG,'XLim',xlimit);
                    set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                    set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                    xlabel(hplotICG,'Time (s)','Color','y');
                    ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                    set(hplotICG,'XGrid','on');
                    if (strcmp(timelim,'RC Interval'))
                        set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                        set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    end
                    dlmwrite(strcat(folder_path_manual,record_name,'_Cpoint.txt'),Cpoint_txt_data,'precision','%1.0f');
                else
                    stop_Cpoint_mk=1;
                    stop_Cpoint()
                end
            end
        end
    end

hadd_Cpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x   yPositionButtonsOnset-2.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'o', ...
    'fontsize',16,...
    'Enable','Off',...
    'TooltipString', ['To manually add C points', newline, ...
    'on ICG plot'],...
    'Callback', @add_Cpoint);
set(hadd_Cpoint,'ForegroundColor',[1 0 0]);

    function add_Cpoint(~, ~)
        stop_Cpoint_mk = 0;
        set(hdisp_data_ICG, 'string','ICG Amplitude')
        set(hdisp_data_ICG,'Visible','on');
        
        set(hinflec_show,'Enable','off');set(hinflec_clear,'Enable','Off')
        set(hdel_Rpeak,'Enable','off'); set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off')
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off');set(hstop_Cpoint,'Enable','on')
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off');set(hstop_Bpoint,'Enable','off')
        set(hauto_Bpoint,'Enable','off')
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','off');
        set(hauto_Rpeak, 'Enable','off');
        set(hauto_Xpoint,'Enable','off');

        
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch1Ca = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1Ca =  max(ecg((round(xlimit(1)*fs)+1):end));
        minamp_Ch2Ca =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2Ca =  max(icg((round(xlimit(1)*fs)+1):end));
        limit_ch1_Y1 = minamp_Ch1Ca-1*abs(minamp_Ch1Ca);
        limit_ch1_Y2 = maxamp_Ch1Ca+0.5*abs(maxamp_Ch1Ca);
        limit_ch2_Y1 = (minamp_Ch2Ca-0.5*abs(minamp_Ch2Ca));
        limit_ch2_Y2 = (maxamp_Ch2Ca+0.1);
        
        
        set(tick_help,'String', 'Use mouse to drag line inside ICG plot and "Shift + Left click" on highest point in a beat to mark a C point','background',color_help,'Foreground',color_help_txt);
        C_line =  line(hplotICG, [mean(xlimit) mean(xlimit)], [limit_ch2_Y1 limit_ch2_Y2], ...
            'color' , 'red', ...
            'LineStyle', '-',...
            'linewidth', 1, ...
            'visible', 'on',...
            'ButtonDownFcn', @startDragFcn);
        
        set(hMainFigure,'WindowButtonUpFcn',@clickcallback)
        
        function startDragFcn(varargin)
            set(C_line,'LineStyle', '-.')
            set(hMainFigure, 'WindowButtonMotionFcn', @draggingFcn)
        end
        
        function draggingFcn(varargin)
            Cpt_line = get(hplotICG,'CurrentPoint');
            Cpt_x_line = Cpt_line(1,1);
            Cpt_y_line = Cpt_line(1,2);
            
            if (Cpt_x_line>=limitX1 && Cpt_x_line<=limitX2) && (Cpt_y_line>=limit_ch2_Y1  && Cpt_y_line<=limit_ch2_Y2)
                set(C_line, 'XData', Cpt_line(1)*[1 1]);   % dragging the line
                Cpt_x_line_index = round(Cpt_x_line*fs);
                if Cpt_x_line_index <= length(icg)
                    icg_mag_C= icg(Cpt_x_line_index);
                else
                    set(hMainFigure, 'WindowButtonMotionFcn', '');
                    stop_Cpoint
                end
                set(hdisp_data_ICG, 'string', ['ICG mag:' num2str(icg_mag_C)]); % update text for ICG amplitude
            else
                set(hMainFigure, 'WindowButtonMotionFcn', '');
                stop_Cpoint
            end
        end
        
        
        function clickcallback(obj,~)
            switch get(obj,'SelectionType')
                case 'normal'
                case 'extend'
                    set(hMainFigure, 'WindowButtonMotionFcn', '');
                    x_final_Cpt_line = Cpt_x_line;
                    y_final_Cpt_line = Cpt_y_line;
                    delete(C_line)
                    plot_Cpoint
            end
        end
        function plot_Cpoint(~,~)
            
            minamp_Ch1 = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
            maxamp_Ch1 =  max(ecg((round(xlimit(1)*fs)+1):end));
            limit_ch1_Y1 = minamp_Ch1-1*abs(minamp_Ch1);
            limit_ch1_Y2 = maxamp_Ch1+0.5*abs(maxamp_Ch1);
            
            xt = x_final_Cpt_line;
            yt = y_final_Cpt_line;
            if ~stop_Cpoint_mk
                set(tick_help,'String', '','background',[0 0 0]);
                
                heartbeat_cur=[];
                heartbeat_cur(1,:)=[round(xt(1)*fs),0];        % Gives the sample number in x and y axes
                
                
                if (xt>=limitX1 && xt<=limitX2) && (yt>=limit_ch2_Y1  && yt<=limit_ch2_Y2)
                    
                    if ~isempty(Cpoint_indices)
                        
                        [~, bb]=min(abs(Cpoint_indices-xt*fs));
                        cur_indx=find(Cpoint_txt_data(:,1)==Cpoint_indices(bb),1);
                        Cpoint_txt_data(cur_indx+1:end+1,:)=Cpoint_txt_data(cur_indx:end,:);
                        Cpoint_txt_data(cur_indx,:)=heartbeat_cur;
                    else
                        Cpoint_txt_data = heartbeat_cur;
                    end
                    
                    Cpoint_indices = Cpoint_txt_data(:,1);    %updating Cpoint_indices
                    
                    
                    pecg =  plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                    set(pecg,'Linewidth',1.5)

                        picg = plot(hplotICG,t,icg,'b-',...
                            t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                            t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                            t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                            t(Xpoint_indices),icg(Xpoint_indices),'ko');
                        set(picg,'Linewidth',1.5)
                        text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                        text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                        text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
                        text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
                    
                    
                    
                    set(hplotECG,'XLim',xlimit);
                    set(hplotECG,'YLim',[limit_ch1_Y1  limit_ch1_Y2]);
                    set(hplotECG,'Xtick',(page_cur-1)*seg_window :seg_time:(page_cur)*seg_window);
                    ylabel(hplotECG,'ECG (mV)','Color','y');
                    set(hplotECG,'XGrid','on');
                    
                    set(hplotICG,'XLim',xlimit);
                    set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                    set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                    xlabel(hplotICG,'Time (s)','Color','y');
                    ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                    set(hplotICG,'XGrid','on');
                    if (strcmp(timelim,'RC Interval'))
                        set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                        set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    end
                    dlmwrite(strcat(folder_path_manual,record_name,'_Cpoint.txt'),Cpoint_txt_data,'precision','%1.0f');
                else
                    stop_Cpoint_mk=1;
                    stop_Cpoint()
                end
            end
            stop_Cpoint()
        end
        
    end

hstop_Cpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x   yPositionButtonsOnset-3.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Stop', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['Stop manual annotation ', newline, ...
    'of C point'],...
    'Callback', @stop_Cpoint);

set(hstop_Cpoint,'ForegroundColor',[1 0 0]);


    function stop_Cpoint(~, ~)
        
        stop_Cpoint_mk=1;
        delete(C_line);
        set(hdisp_data_ICG,'Visible','off');       
        if ECG_hide_mk == 1
            set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');
            set(hstop_Rpeak,'Enable','off');set(hauto_Rpeak,'Enable','off');
        else
            set(hdel_Rpeak,'Enable','on');set(hadd_Rpeak,'Enable','on');
            set(hstop_Rpeak,'Enable','off'); set(hauto_Rpeak,'Enable','on');
        end
        set(tick_help,'String', '','background',[0 0 0]);
        set(hdel_Cpoint,'Enable','on');set(hadd_Cpoint,'Enable','on');set(hstop_Cpoint,'Enable','off')
        set(hdel_Bpoint,'Enable','on');set(hadd_Bpoint,'Enable','on');set(hstop_Bpoint,'Enable','off')
        set(hauto_Bpoint, 'Enable', 'on');
        set(hdisp_derivative_ICG, 'visible','off');set(hinflec_show,'Enable','on')
        set(hauto_Cpoint,'Enable','on');
        set(hauto_Xpoint,'Enable','on');

        if (strcmp(timelim,'RC Interval'))
            set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off');set(hstop_Xpoint,'Enable','off');
        else
            set(hdel_Xpoint,'Enable','on');set(hadd_Xpoint,'Enable','on');set(hstop_Xpoint,'Enable','off')
        end
        
        
    end
hauto_Cpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x   yPositionButtonsOnset-4.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Auto O', ...
    'TooltipString', ['To automatically add C points', newline, ...
    'on ICG plot'],...
    'fontsize',10,...
    'Enable','off',...
    'Callback', @add_autoCpoint);

set(hauto_Cpoint,'ForegroundColor',[1 0 0]);

    function add_autoCpoint(~,~)
        
        RR =  diff(sort(Rpeak_indices));                % sorted so that irregular manual addition can be adjsuted
        if isempty(RR)
            msgbox('Please annotate R peaks prior to automatic C point annotation.','Warning Window Name','warn');
        else
            RR_13 = ceil(mean(RR)/3);
            end_pt = Rpeak_indices + RR_13;                     % R locs plus (1/3)*(RR interval)
            for i =  1 : length(Rpeak_indices)
                data = icg(Rpeak_indices(i):end_pt(i));
                [~, Index] = max(data);
                Cpt(i,1) = Index + Rpeak_indices(i);     % Cpoint_indices
            end
            dumy= zeros(length(Cpt),1);     % dummy zeros column required for IMAA
            Cpoint_txt_data = [Cpt dumy];
            dlmwrite(strcat(folder_path_manual,record_name,'_Cpoint.txt'),Cpoint_txt_data,'precision','%1.0f');
            Cpoint_indices = Cpoint_txt_data(:,1);
            stop_Cpoint_mk = 1;
            %stop_Cpoint()
            
            pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
            set(pecg,'Linewidth',1.5)
            picg = plot(hplotICG,t,icg,'b-',...
                t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                t(Xpoint_indices),icg(Xpoint_indices),'ko');
            set(picg,'Linewidth',1.5)
            text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
            text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
            text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
            text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
        end
    end

%-------------------------  end  C point buttons and functions ------------------------------------
%-------------------------RC feature Pop up button----------------------

%yPositionButtonsOnset-11.15*highButtons+0.02

hdisp_RC_feature = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x-1.8*w1    0.57    0.12  highButtons], ...
    'String', 'Select RC Feature ',...
    'fontweight','bold',...
    'Visible', 'Off',...
    'fontsize',fontsize12);
set(hdisp_RC_feature,'backgroundcolor',get(hplotICG,'color'))     % transparent text box

hRC_pop = uicontrol(hMainFigure, ...          % popup menu for "RC features"
    'Style', 'popupmenu', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x   yPositionButtonsOnset-11.15*highButtons+0.02     2*widthButtons+0.005   highButtons], ...
    'String', {'Select RC feature','Notch','Valley','Plateau','Inflection','Mild inflection','Change in the gradient','Corner',...
    'Onset of the rise','Featureless','Invalid or noisy','Other - notes added'}, ...
    'HorizontalAlignment', 'center',...
    'fontsize',fontsize10,...
    'Tag', 'timelim',...
    'Enable','off',...
    'Callback', @RC_con);

    function RC_con(hObject, ~)
        contents = cellstr(get(hObject,'String'));
        RC_feat= contents{get(hObject,'Value')};
        if (contains(RC_feat,'Select'))
            RC_feature = 'Select RC feature';
        elseif (strcmp(RC_feat,'Inflection'))
            RC_feature = 'Inflection';
        elseif (strcmp(RC_feat,'Mild inflection'))
            RC_feature = 'Mild infection';
        elseif (strcmp(RC_feat,'Plateau'))
            RC_feature = 'Plateau';
        elseif (strcmp(RC_feat,'Notch'))
            RC_feature = 'Notch';
        elseif (strcmp(RC_feat,'Change in the gradient'))
            RC_feature = 'Change in the gradient';
        elseif (strcmp(RC_feat,'Valley'))
            RC_feature = 'Valley';
        elseif (strcmp(RC_feat,'Corner'))
            RC_feature = 'Corner';
        elseif (strcmp(RC_feat,'Featureless'))
            RC_feature = 'Featureless';
        elseif (strcmp(RC_feat,'Other - notes added'))
            RC_feature = 'Other - notes added';
        elseif (strcmp(RC_feat,'Invalid or Noisy'))
            RC_feature = 'Invalid or Noisy';
        elseif (strcmp(RC_feat,'Onset of the Rise'))
            RC_feature = 'Onset of the Rise';
        end
                % camilo
        beatsFeature( page_cur )  = get(hRC_pop, 'Value');
        filename = strcat(folder_path_manual,record_name,'_Feature','.txt');
        dlmwrite(filename, beatsFeature);
        set(hdisp_RC_feature,'String',strcat('RC: ', RC_feature)) 
    end

%-------------------------  B point buttons and functions ----------------


title_ICG_B = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x    0.59    widthButtons   highButtons], ...
    'String', 'B ',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);
hdel_Bpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x   yPositionButtonsOnset-1.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Del', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['To delete B point from', newline, ...
    'ICG plot'],...
    'Callback', @del_Bpoint);
set(hdel_Bpoint,'ForegroundColor',[0 0 1]);

    function del_Bpoint(~, ~)
        stop_Bpoint_mk = 0;
        
        set(hinflec_show,'Enable','off');set(hinflec_clear,'Enable','Off')
        set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off')
        set(hdel_Cpoint,'Enable','off'); set(hadd_Cpoint,'Enable','off');set(hstop_Cpoint,'Enable','off')
        set(hdel_Bpoint,'Enable','off'); set(hadd_Bpoint,'Enable','off');set(hstop_Bpoint,'Enable','on');
        set(hauto_Bpoint,'Enable','off')
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off');set(hstop_Xpoint,'Enable','off')
        set(hauto_Cpoint,'Enable','off');
        set(hauto_Rpeak, 'Enable','off');
        set(hauto_Xpoint,'Enable','off');

        
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        
        
        minamp_Ch1 = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1 =  max(ecg((round(xlimit(1)*fs)+1):end));
        minamp_Ch2 =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2 =  max(icg((round(xlimit(1)*fs)+1):end));
        
        limit_ch1_Y1 = (minamp_Ch1-1*abs(minamp_Ch1));
        limit_ch1_Y2 = (maxamp_Ch1+0.5*abs(maxamp_Ch1));
        limit_ch2_Y1 = (minamp_Ch2-0.5*abs(minamp_Ch2));
%        limit_ch2_Y2 = (maxamp_Ch2+0.1*abs(maxamp_Ch2));
      limit_ch2_Y2 = (maxamp_Ch2+0.1);
        
        while~stop_Bpoint_mk
            set(tick_help,'String', 'Left click inside ICG plot to delete an incorrect B point','background',color_help,'Foreground',color_help_txt);
            [xt,yt] = ginput(1);
            
            pause(timer)
            
            if~stop_Bpoint_mk
                set(tick_help,'String', '','background',[0 0 0]);
                
                
                if ~isempty(Bpoint_indices)  &&...
                        (xt>=limitX1 && xt<=limitX2) && (yt>=limit_ch2_Y1  && yt<=limit_ch2_Y2)
                    
                    [~, bb]=min(abs(Bpoint_indices-xt*fs));
                    selectedBeat = Bpoint_indices(bb);
                    cur_indx=find(Bpoint_txt_data(:,1)==selectedBeat,1);
                    
                    
                    Bpoint_txt_data(cur_indx,:)=[];
                    
                    Bpoint_indices = Bpoint_txt_data(:,1);
                    
                    pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                    set(pecg,'Linewidth',1.5)
                    
                    picg = plot(hplotICG,t,icg,'b-',...
                        t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                        t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                        t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                        t(Xpoint_indices),icg(Xpoint_indices),'ko');
                    set(picg,'Linewidth',1.5)
                    text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                    text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                    text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
                    text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
                    
                    
                    
                    set(hplotECG,'XLim',xlimit);
                    set(hplotECG,'YLim',[limit_ch1_Y1  limit_ch1_Y2]);
                    set(hplotECG,'Xtick',(page_cur-1)*seg_window :seg_time:(page_cur)*seg_window);
                    ylabel(hplotECG,'ECG (mV)','Color','y');
                    set(hplotECG,'XGrid','on');
                    
                    
                    set(hplotICG,'XLim',xlimit);
                    set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                    set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                    xlabel(hplotICG,'Time (s)','Color','y');
                    ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                    set(hplotICG,'XGrid','on');
                    if (strcmp(timelim,'RC Interval'))
                        set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                        set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    end
                    dlmwrite(strcat(folder_path_manual,record_name,'_Bpoint.txt'),Bpoint_txt_data,'precision','%1.0f');
                else
                    stop_Bpoint_mk=1;
                    stop_Bpoint()
                end
            end
        end
    end

hauto_Bpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x   yPositionButtonsOnset-4.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Auto O', ...
    'TooltipString', ['To automatically add B points', newline, ...
    'using max(3rd derivative) on ICG plot'],...
    'fontsize',10,...
    'Enable','off',...
    'Callback', @add_autoBpoint);

    function add_autoBpoint(~,~)
        Rpeak_indices_sorted= sort(Rpeak_indices);
        Cpoint_indices_sorted = sort(Cpoint_indices);
        if (length(Rpeak_indices_sorted) ~= length(Cpoint_indices_sorted)) || (length(Rpeak_indices_sorted) <=1) || (length(Cpoint_indices_sorted) <=1)
           errordlg('Number of R peaks are not equal to number of C points:  Please verify and annotate','RC Calculation Error','warn');
        else
            rg_4_B = [Rpeak_indices_sorted(page_cur)+35   Rpeak_indices_sorted(page_cur)+130];
            icg_3_der = icg_D2(rg_4_B(1):rg_4_B(2));
            [~, Index] = max(icg_3_der);
            xt = (rg_4_B(1) +Index)/1000;                     % just to go with code
%             if ~stop_Bpoint_mk
                heartbeat_cur=[];
                heartbeat_cur(1,:)=[round(xt(1)*fs),0];        % Gives the sample number in x and y axes
                if ~isempty(Bpoint_indices)
                    [~, bb]=min(abs(Bpoint_indices-xt*fs));
                    cur_indx=find(Bpoint_txt_data(:,1)==Bpoint_indices(bb),1);
                    Bpoint_txt_data(cur_indx+1:end+1,:)=Bpoint_txt_data(cur_indx:end,:);
                    Bpoint_txt_data(cur_indx,:)=heartbeat_cur;
                else
                    Bpoint_txt_data = heartbeat_cur;
                end
                Bpoint_indices = Bpoint_txt_data(:,1);                         %updating Bpoint_indices
                pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                set(pecg,'Linewidth',1.5);
                picg = plot(hplotICG,t,icg,'b-',...
                        t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                        t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                        t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                        t(Xpoint_indices),icg(Xpoint_indices),'ko');
                    set(picg,'Linewidth',1.5)
                    text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                    text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                    text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
                    text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
                
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch2 =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2 =  max(icg((round(xlimit(1)*fs)+1):end));
        limit_ch2_Y1 = (minamp_Ch2-0.5*abs(minamp_Ch2));
        %    limit_ch2_Y2 = (maxamp_Ch2+0.1*abs(maxamp_Ch2));
        limit_ch2_Y2 = (maxamp_Ch2+0.1);  
        
        set(hplotICG,'XLim',xlimit);
        set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
        set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
        xlabel(hplotICG,'Time (s)','Color','y');
        ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
        set(hplotICG,'XGrid','on');
        if (strcmp(timelim,'RC Interval'))
            set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
            set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
       end
       dlmwrite(strcat(folder_path_manual,record_name,'_Bpoint.txt'),Bpoint_txt_data,'precision','%1.0f');
        end
       
       % end
    end

set(hauto_Bpoint,'ForegroundColor',[0 0 1]);

hadd_Bpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x   yPositionButtonsOnset-2.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'o', ...
    'fontsize',16,...
    'Enable','Off',...
    'TooltipString', ['To manually add B points', newline, ...
    'on ICG plot'],...
    'Callback', @add_Bpoint);
set(hadd_Bpoint,'ForegroundColor',[0 0 1]);

    function add_Bpoint(~, ~)
        
        stop_Bpoint_mk = 0;
        set(hdisp_data_ICG, 'string','ICG Amplitude')
        set(hdisp_data_ICG,'Visible','on');

        set(hinflec_show,'Enable','on'); set(hinflec_clear,'Enable','off')
        set(hdel_Rpeak,'Enable','off'); set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off')
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off');set(hstop_Cpoint,'Enable','off')
        set(hdel_Bpoint,'Enable','off'); set(hadd_Bpoint,'Enable','off');set(hstop_Bpoint,'Enable','on')
        set(hauto_Bpoint,'Enable','off')
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','off');
        set(hauto_Rpeak, 'Enable','off');
        set(hauto_Xpoint,'Enable','off');
        
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch2 =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2 =  max(icg((round(xlimit(1)*fs)+1):end));
        limit_ch2_Y1 = (minamp_Ch2-0.5*abs(minamp_Ch2));
        %    limit_ch2_Y2 = (maxamp_Ch2+0.1*abs(maxamp_Ch2));
        limit_ch2_Y2 = (maxamp_Ch2+0.1);      
        
        set(tick_help,'String', 'Use mouse to drag line inside ICG plot and "Shift + Left click" to mark a B point','background',color_help,'Foreground',color_help_txt);
        B_line =  line(hplotICG, [mean(xlimit) mean(xlimit)], [limit_ch2_Y1 limit_ch2_Y2], ...
            'color' , 'blue', ...
            'LineStyle', '-',...
            'linewidth', 1, ...
            'visible', 'on',...
            'ButtonDownFcn', @startDragFcn);
        
        set(hMainFigure,'WindowButtonUpFcn',@clickcallback)
        
        
        function startDragFcn(varargin)
            set(B_line,'LineStyle', '-.')
            set(hMainFigure, 'WindowButtonMotionFcn', @draggingFcn)
        end
        function draggingFcn(varargin)
            Bpt_line = get(hplotICG,'CurrentPoint');
            Bpt_x_line = Bpt_line(1,1);
            Bpt_y_line = Bpt_line(1,2);
            
            if (Bpt_x_line>=limitX1 && Bpt_x_line<=limitX2) && (Bpt_y_line>=limit_ch2_Y1  && Bpt_y_line<=limit_ch2_Y2)
                set(B_line, 'XData', Bpt_line(1)*[1 1]);   % dragging the line
                Bpt_x_line_index = round(Bpt_x_line*fs);
                if (Bpt_x_line_index <= length(icg) ) && (Bpt_x_line_index >= 1 )
                    icg_mag_B= icg(Bpt_x_line_index);
                    icg_der_sign = id_grad(Bpt_x_line_index);
                else
                    icg_der_sign = 'NaN';
                    set(hMainFigure, 'WindowButtonMotionFcn', '');
                    stop_Bpoint
                    inflec_clear
                end
                
                set(hdisp_data_ICG, 'string', ['ICG amp:' num2str(icg_mag_B)]); % update text for ICG amplitude
                if (Bpt_x_line_index>=Rpeak_indices(page_cur)) && (Bpt_x_line_index<=Cpoint_indices(page_cur))
                    set(hdisp_derivative_ICG, 'string', ['Zero Crossing Sign:' num2str(icg_der_sign)])
                else
                    set(hdisp_derivative_ICG, 'string', ['Zero Crossing Sign:' 'NaN'])
                end
            else
                set(hMainFigure, 'WindowButtonMotionFcn', '');
                
                inflec_clear
                stop_Bpoint
            end
            
        end
        
        
        function clickcallback(obj,~)
            switch get(obj,'SelectionType')
                case 'normal'
                case 'extend'
                    set(hMainFigure, 'WindowButtonMotionFcn', '');       % for stopping drag
                    x_final_Bpt_line = Bpt_x_line;
                    y_final_Bpt_line = Bpt_y_line;
                    delete(B_line)
                    plot_Bpoint
            end
        end
        
        function plot_Bpoint(~,~)
            
            xt = x_final_Bpt_line;
            if ~stop_Bpoint_mk
                set(tick_help,'String', '','background',[0 0 0]);
                heartbeat_cur=[];
                heartbeat_cur(1,:)=[round(xt(1)*fs),0];        % Gives the sample number in x and y axes
                if ~isempty(Bpoint_indices)
                    [~, bb]=min(abs(Bpoint_indices-xt*fs));
                    cur_indx=find(Bpoint_txt_data(:,1)==Bpoint_indices(bb),1);
                    Bpoint_txt_data(cur_indx+1:end+1,:)=Bpoint_txt_data(cur_indx:end,:);
                    Bpoint_txt_data(cur_indx,:)=heartbeat_cur;
                else
                    Bpoint_txt_data = heartbeat_cur;
                end
                Bpoint_indices = Bpoint_txt_data(:,1);                         %updating Bpoint_indices
                pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                set(pecg,'Linewidth',1.5);

                picg = plot(hplotICG,t,icg,'b-',...
                        t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                        t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                        t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                        t(Xpoint_indices),icg(Xpoint_indices),'ko');
                set(picg,'Linewidth',1.5)
                text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
                text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
                                
                set(hplotICG,'XLim',xlimit);
                set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                xlabel(hplotICG,'Time (s)','Color','y');
                ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                set(hplotICG,'XGrid','on');
                if (strcmp(timelim,'RC Interval'))
                    set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                end
                dlmwrite(strcat(folder_path_manual,record_name,'_Bpoint.txt'),Bpoint_txt_data,'precision','%1.0f');
            end
            stop_Bpoint
            inflec_clear
        end
    end


hstop_Bpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x   yPositionButtonsOnset-3.8*highButtons+0.03   widthButtons    highButtons], ...
    'String', 'Stop', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['Stop manual annotation ', newline, ...
    'of B point'],...
    'Callback', @stop_Bpoint);
set(hstop_Bpoint,'ForegroundColor',[0 0 1]);


    function stop_Bpoint(~, ~)
        
        stop_Bpoint_mk=1;
        delete(B_line);
        set(hdisp_data_ICG,'Visible','off');       

        if ECG_hide_mk == 1
            set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');
            set(hstop_Rpeak,'Enable','off');set(hauto_Rpeak,'Enable','off');
        else
            set(hdel_Rpeak,'Enable','on');set(hadd_Rpeak,'Enable','on');set(hstop_Rpeak,'Enable','off')
            set(hauto_Rpeak,'Enable','on');
        end
        inflec_clear
        set(tick_help,'String', '','background',[0 0 0]);
    end

%-------------------------  X point buttons and functions ----------------
tickXpoint = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x    0.59    widthButtons    highButtons], ...
    'String', 'X ',...
    'fontweight','bold',...
    'fontsize',fontsize12,...
    'background',[0.2 0.6 0.8]);
hdel_Xpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x  yPositionButtonsOnset-1.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Del', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['To delete X point from', newline, ...
    'ICG plot'],...
    'Callback', @del_Xpoint);
set(hdel_Xpoint,'ForegroundColor',[0 0 0]);

    function del_Xpoint(~, ~)
        
        stop_Xpoint_mk = 0;
        
        set(hinflec_show,'Enable','off');set(hinflec_clear,'Enable','Off')
        set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off')
        set(hauto_Rpeak, 'Enable','off');
        set(hdel_Cpoint,'Enable','off'); set(hadd_Cpoint,'Enable','off');set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint, 'Enable','off');
        set(hdel_Bpoint,'Enable','off'); set(hadd_Bpoint,'Enable','off');set(hstop_Bpoint,'Enable','off')
        set(hauto_Bpoint,'Enable','off')
        set(hdel_Xpoint,'Enable','off'); set(hadd_Xpoint,'Enable','off');set(hstop_Xpoint,'Enable','on')
        set(hauto_Xpoint,'Enable','off');

        
        
        
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch1 = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1 =  max(ecg((round(xlimit(1)*fs)+1):end));
        minamp_Ch2 =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2 =  max(icg((round(xlimit(1)*fs)+1):end));
        
        limit_ch1_Y1 = (minamp_Ch1-1*abs(minamp_Ch1));
        limit_ch1_Y2 = (maxamp_Ch1+0.5*abs(maxamp_Ch1));
        limit_ch2_Y1 = (minamp_Ch2-0.5*abs(minamp_Ch2));
        %         limit_ch2_Y2 = (maxamp_Ch2+0.1*abs(maxamp_Ch2));
        limit_ch2_Y2 = (maxamp_Ch2+0.1);
        
        while~stop_Xpoint_mk
            set(tick_help,'String', 'Left click inside ICG plot to delete an incorrect X point','background',color_help,'Foreground',color_help_txt);
            [xt,yt] = ginput(1);
            
            pause(timer)
            
            if~stop_Xpoint_mk
                set(tick_help,'String', '','background',[0 0 0]);
                
                
                if ~isempty(Xpoint_indices)  &&...
                        (xt>=limitX1 && xt<=limitX2) && (yt>=limit_ch2_Y1  && yt<=limit_ch2_Y2)
                    
                    [~, bb]=min(abs(Xpoint_indices-xt*fs));
                    selectedBeat = Xpoint_indices(bb);
                    cur_indx=find(Xpoint_indices(:,1)==selectedBeat,1);
                    
                    
                    Xpoint_txt_data(cur_indx,:)=[];
                    
                    Xpoint_indices = Xpoint_txt_data(:,1);
                    
                    pecg = plot(hplotECG,t,ecg,'b-',...
                        t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                    set(pecg,'Linewidth',1.5);
                    
                    picg = plot(hplotICG,t,icg,'b-',...
                        t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                        t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                        t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                        t(Xpoint_indices),icg(Xpoint_indices),'ko');
                    set(picg,'Linewidth',1.5)
                    text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                    text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                    text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
                    text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
                    
                    set(hplotECG,'XLim',xlimit);
                    set(hplotECG,'YLim',[limit_ch1_Y1  limit_ch1_Y2]);
                    set(hplotECG,'Xtick',(page_cur-1)*seg_window :seg_time:(page_cur)*seg_window);
                    ylabel(hplotECG,'ECG (mV)','Color','y');
                    set(hplotECG,'XGrid','on');
                    
                    
                    set(hplotICG,'XLim',xlimit);
                    set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                    set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                    xlabel(hplotICG,'Time (s)','Color','y');
                    ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                    set(hplotICG,'XGrid','on');
                    if (strcmp(timelim,'RC Interval'))
                        set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                        set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    end
                    dlmwrite(strcat(folder_path_manual,record_name,'_Xpoint.txt'),Xpoint_txt_data,'precision','%1.0f');
                else
                    stop_Xpoint_mk=1;
                    stop_Xpoint()
                end
            end
        end
    end
hadd_Xpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x   yPositionButtonsOnset-2.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'o', ...
    'fontsize',16,...
    'Enable','Off',...
    'TooltipString', ['To manually add X points', newline, ...
    'on ICG plot'],...
    'Callback', @add_Xpoint);
set(hadd_Xpoint,'ForegroundColor',[0 0 0]);

    function add_Xpoint(~, ~)
        stop_Xpoint_mk = 0;
        set(hdisp_data_ICG, 'string','ICG Amplitude')
        set(hdisp_data_ICG,'Visible','on');
        
        set(hinflec_show,'Enable','off');set(hinflec_clear,'Enable','Off');
        set(hdel_Rpeak,'Enable','off'); set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off');
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off');set(hstop_Cpoint,'Enable','off');
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off');set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint,'Enable','off')
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off');set(hstop_Xpoint,'Enable','on');
        set(hauto_Cpoint,'Enable','off');
        set(hauto_Rpeak, 'Enable','off');
        set(hauto_Xpoint,'Enable','off');
        
        
        
        limitX1 = (page_cur-1)*seg_window;
        limitX2 = (page_cur)*seg_window;
        xlimit = [limitX1  limitX2];
        
        
        minamp_Ch1Ca = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
        maxamp_Ch1Ca =  max(ecg((round(xlimit(1)*fs)+1):end));
        minamp_Ch2Ca =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2Ca =  max(icg((round(xlimit(1)*fs)+1):end));
        limit_ch1_Y1 = minamp_Ch1Ca-1*abs(minamp_Ch1Ca);
        limit_ch1_Y2 = maxamp_Ch1Ca+0.5*abs(maxamp_Ch1Ca);
        
        limit_ch2_Y1 = (minamp_Ch2Ca-0.5*abs(minamp_Ch2Ca));
        %         limit_ch2_Y2 = (maxamp_Ch2Ca+0.1*abs(maxamp_Ch2Ca));
        limit_ch2_Y2 = (maxamp_Ch2Ca+0.1);
        
        
        set(tick_help,'String', 'Use mouse to drag line inside ICG plot and "Shift + Left click" in a beat to mark a X point','background',color_help,'Foreground',color_help_txt);
        X_line =  line(hplotICG, [mean(xlimit) mean(xlimit)], [limit_ch2_Y1 limit_ch2_Y2], ...
            'color' , 'black', ...
            'LineStyle', '-',...
            'linewidth', 1, ...
            'visible', 'on',...
            'ButtonDownFcn', @startDragFcn);
        
        set(hMainFigure,'WindowButtonUpFcn',@clickcallback)
        
        function startDragFcn(varargin)
            set(X_line,'LineStyle', '-.')
            set(hMainFigure, 'WindowButtonMotionFcn', @draggingFcn)
        end
        
        function draggingFcn(varargin)
            Xpt_line = get(hplotICG,'CurrentPoint');
            Xpt_x_line = Xpt_line(1,1);
            Xpt_y_line = Xpt_line(1,2);
            
            if (Xpt_x_line>=limitX1 && Xpt_x_line<=limitX2) && (Xpt_y_line>=limit_ch2_Y1  && Xpt_y_line<=limit_ch2_Y2)
                set(X_line, 'XData', Xpt_line(1)*[1 1]);   % dragging the line
                Xpt_x_line_index = round(Xpt_x_line*fs);
                if Xpt_x_line_index <= length(icg)
                    icg_mag_X= icg(Xpt_x_line_index);
                else
                    set(hMainFigure, 'WindowButtonMotionFcn', '');
                    stop_Xpoint
                end
                set(hdisp_data_ICG, 'string', ['ICG amp:' num2str(icg_mag_X)]); % update text for ICG amplitude
            else
                set(hMainFigure, 'WindowButtonMotionFcn', '');
                stop_Xpoint
            end
        end
        
        
        function clickcallback(obj,~)
            switch get(obj,'SelectionType')
                case 'normal'
                case 'extend'
                    set(hMainFigure, 'WindowButtonMotionFcn', '');
                    x_final_Xpt_line = Xpt_x_line;
                    y_final_Xpt_line = Xpt_y_line;
                    delete(X_line)
                    plot_Xpoint
            end
        end
        function plot_Xpoint(~,~)
            
            minamp_Ch1 = min(ecg((round(xlimit(1)*fs)+1):end));    % dealing in indices
            maxamp_Ch1 =  max(ecg((round(xlimit(1)*fs)+1):end));
            limit_ch1_Y1 = minamp_Ch1-1*abs(minamp_Ch1);
            limit_ch1_Y2 = maxamp_Ch1+0.5*abs(maxamp_Ch1);

            
            xt = x_final_Xpt_line;
            yt = y_final_Xpt_line;
            
            if ~stop_Xpoint_mk
                set(tick_help,'String', '','background',[0 0 0]);
                
                heartbeat_cur=[];
                heartbeat_cur(1,:)=[round(xt(1)*fs),0];        % Gives the sample number in x and y axes
                
                
                if (xt>=limitX1 && xt<=limitX2) && (yt>=limit_ch2_Y1  && yt<=limit_ch2_Y2)
                    
                    if ~isempty(Xpoint_indices)
                        
                        [~, bb]=min(abs(Xpoint_indices-xt*fs));
                        cur_indx=find(Xpoint_txt_data(:,1)==Xpoint_indices(bb),1);
                        Xpoint_txt_data(cur_indx+1:end+1,:)=Xpoint_txt_data(cur_indx:end,:);
                        Xpoint_txt_data(cur_indx,:)=heartbeat_cur;
                    else
                        Xpoint_txt_data = heartbeat_cur;
                    end
                    
                    Xpoint_indices = Xpoint_txt_data(:,1);    %updating Cpoint_indices
                    
                    
                    pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
                    set(pecg,'Linewidth',1.5);
                    picg = plot(hplotICG,t,icg,'b-',...
                            t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                            t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                            t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                            t(Xpoint_indices),icg(Xpoint_indices),'ko');
                    set(picg,'Linewidth',1.5)
                    text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
                    text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
                    text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
                    text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X') 
                    
                    set(hplotECG,'XLim',xlimit);
                    set(hplotECG,'YLim',[limit_ch1_Y1  limit_ch1_Y2]);
                    set(hplotECG,'Xtick',(page_cur-1)*seg_window :seg_time:(page_cur)*seg_window);
                    ylabel(hplotECG,'ECG (mV)','Color','y');
                    set(hplotECG,'XGrid','on');
                    
                    set(hplotICG,'XLim',xlimit);
                    set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
                    set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
                    xlabel(hplotICG,'Time (s)','Color','y');
                    ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
                    set(hplotICG,'XGrid','on');
                    if (strcmp(timelim,'RC Interval'))
                        set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                        set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
                    end
                    dlmwrite(strcat(folder_path_manual,record_name,'_Xpoint.txt'),Xpoint_txt_data,'precision','%1.0f');
                else
                    stop_Xpoint_mk=1;
                    stop_Xpoint()
                end
            end
            stop_Xpoint()
        end
        
    end

hstop_Xpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x   yPositionButtonsOnset-3.8*highButtons+0.03     widthButtons    highButtons], ...
    'String', 'Stop', ...
    'fontsize',10,...
    'Enable','Off',...
    'TooltipString', ['Stop manual annotation ', newline, ...
    'of X point'],...
    'Callback', @stop_Xpoint);
set(hstop_Xpoint,'ForegroundColor',[0 0 0]);


    function stop_Xpoint(~, ~)
        
        stop_Xpoint_mk=1;
        delete(X_line);
        set(hdisp_data_ICG,'Visible','off');       
        set(tick_help,'String', '','background',[0 0 0]);
        set(hdel_Cpoint,'Enable','on');set(hadd_Cpoint,'Enable','on');set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','on');
        set(hdel_Bpoint,'Enable','on');set(hadd_Bpoint,'Enable','on');set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint, 'Enable', 'on');
        set(hdel_Xpoint,'Enable','on');set(hadd_Xpoint,'Enable','on');set(hstop_Xpoint,'Enable','off')
                set(hauto_Xpoint,'Enable','on');

        set(hdisp_derivative_ICG, 'visible','off');set(hinflec_show,'Enable','on');
        if ECG_hide_mk == 1
            set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');
            set(hstop_Rpeak,'Enable','off');set(hauto_Rpeak,'Enable','off');
        else
            set(hdel_Rpeak,'Enable','on');set(hadd_Rpeak,'Enable','on');set(hstop_Rpeak,'Enable','off')
            set(hauto_Rpeak,'Enable','on');
        end
        
    end

hauto_Xpoint = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x   yPositionButtonsOnset-4.8*highButtons+0.03    widthButtons    highButtons], ...
    'String', 'Auto O', ...
    'TooltipString', ['To automatically add X points', newline, ...
    'in [C+150, C+350] on ICG plot'],...
    'fontsize',10,...
    'Enable','off',...
    'Callback', @add_autoXpoint);
set(hauto_Xpoint,'ForegroundColor',[0 0 0]);

    function add_autoXpoint(~,~)
        
        
        RR =  diff(sort(Rpeak_indices));
        CC = diff(sort(Cpoint_indices));
        Cpoint_indices_sorted = sort(Cpoint_indices);
        

     
    if isempty(CC)
            msgbox('Please annotate C points prior to automatic X point annotation.','Warning Window Name','warn');
        else
         if strcmp(timelim,'Beat Length')
            st_ptX = Cpoint_indices_sorted(page_cur)+0.15*fs ;  
            end_ptX = Cpoint_indices_sorted(page_cur)+0.35*fs;
            if end_ptX > length(icg)     % in case last end point is greater than icg signal
               end_ptX = length(icg);
            end 
            data = icg(st_ptX:end_ptX);
            [~, Index] = min(data);
            Xpt = Index + st_ptX;     % Xpoint_indices
            heartbeat_cur=[];
            heartbeat_cur(1,:)=[round(Xpt(1)),0];        % Gives the sample number in x and y axes
            if ~isempty(Xpoint_indices)
                 [~, bb]=min(abs(Xpoint_indices-Xpt*fs));
                 cur_indx=find(Xpoint_txt_data(:,1)==Xpoint_indices(bb),1);
                 Xpoint_txt_data(cur_indx+1:end+1,:)=Xpoint_txt_data(cur_indx:end,:);
                 Xpoint_txt_data(cur_indx,:)=heartbeat_cur;
            else
                 Xpoint_txt_data = heartbeat_cur;
            end
            elseif strcmp(timelim,'Data Length')
                st_pt = Cpoint_indices + 0.15*fs;
                end_pt = Cpoint_indices + 0.350*fs;                    
                for i =  1 : length(Cpoint_indices)
                    if end_pt(length(Cpoint_indices)) > length(icg)     % in case last end point is greater than icg signal
                        end_pt(length(Cpoint_indices)) = length(icg);
                    end                    
                    data = icg(st_pt(i):end_pt(i));
                    [~, Index] = min(data);
                    Xpt(i,1) = Index + st_pt(i);     % Xpoint_indices
                end
                dumy= zeros(length(Xpt),1);     % dummy zeros column required for IMAA
                Xpoint_txt_data = [Xpt dumy];
         end
                dlmwrite(strcat(folder_path_manual,record_name,'_Xpoint.txt'),Xpoint_txt_data,'precision','%1.0f');
                Xpoint_indices = Xpoint_txt_data(:,1);
                stop_Xpoint_mk = 1;
           
            pecg = plot(hplotECG,t,ecg,'b-',t(Rpeak_indices),ecg(Rpeak_indices),'r+');
            set(pecg,'Linewidth',1.5)
            picg = plot(hplotICG,t,icg,'b-',...
                t(Rpeak_indices),icg(Rpeak_indices),'r+',...
                t(Cpoint_indices),icg(Cpoint_indices),'ro',...
                t(Bpoint_indices),icg(Bpoint_indices),'bo',...
                t(Xpoint_indices),icg(Xpoint_indices),'ko');
            set(picg,'Linewidth',1.5)
            text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
            text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
            text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
            text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
     end
 end
%-------------------------  end  X point buttons and functions ------------------------------------
%% Inflection Visualization Panel


% Vis_panel = uipanel('Parent', hMainFigure,...
%     'Units', 'normalized',...
%     'Position', [0.781 yPositionButtonsOffset-5*highButtons   0.205 0.27]);  % Panel for Feature Visualization

tickFVpanel = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.781    0.16    0.205   0.04], ...
    'String', 'RC Inflection Visualization Panel',...
    'fontweight','bold',...
    'fontsize',13,...
    'Foreground', [1 1 0],...   % yellow colour
    'background',[0.2 0.6 0.8]);


%% Inflection visualization Push Button and fucntion

hinflec_show = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.785  yPositionButtonsOnset-14*highButtons+0.02     2*widthButtons+0.005     highButtons], ...
    'fontsize',fontsize10,...
    'background',[0.2 0.8 0.6],...
    'Enable','off',...
    'TooltipString', ['To show Zero crossing graph and sign', newline, ...
    'for identfication of Inflection point.'],...
    'Callback', @inflec_show);

set(hinflec_show, 'String', 'Show Inflection');    % for multi line button text

    function inflec_show(~,~)
        
        set(hdisp_derivative_ICG,'Visible','on')
        set(hdisp_derivative_ICG, 'string', ['Zero Crossing Sign:' 'NaN'])
        
        set(hinflec_clear,'Enable','on')
        set(hdel_Cpoint,'Enable','on');set(hadd_Cpoint,'Enable','on'),set(hstop_Cpoint,'Enable','off');
        set(hdel_Bpoint,'Enable','on');set(hadd_Bpoint,'Enable','on'),set(hstop_Bpoint,'Enable','off');
        set(hdel_Xpoint,'Enable','on');set(hadd_Xpoint,'Enable','on'),set(hstop_Xpoint,'Enable','off');
        
        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
        end
        
        minamp_Ch2Rd =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2Rd =  max(icg((round(xlimit(1)*fs)+1):end));
        limit_ch2_Y1 = (minamp_Ch2Rd-0.5*abs(minamp_Ch2Rd));
        %         limit_ch2_Y2 = (maxamp_Ch2Rd+0.1*abs(maxamp_Ch2Rd));
        limit_ch2_Y2 = (maxamp_Ch2Rd+0.1);
        
        % Setting for plotting inflection
        
        cur_window = round(fs*xlimit(1): fs*xlimit(2));
        inflec_1 = intersect(Rpeak_indices,cur_window);
        
        if length(inflec_1) < 1
            inflec_clear()
            msgbox('Please annotate R peak for Inflection visualization','Warning Window Name','warn');
            return
        end
        
        if length(inflec_1) > 1
            str = num2str(inflec_1./fs);
            index = listdlg('PromptString',...
                'Select R peak location /Beat for Inflection Analysis:',...
                'SelectionMode','single','ListString',str);
            if isempty(index)
                % user clicked the cancel button
                return;
            end
            switch index
                case 1
                    inflec_1 = inflec_1(1);
                case 2
                    inflec_1 = inflec_1(2);
                case 3
                    inflec_1 = inflec_1(3);
                case 4
                    inflec_1 = inflec_1(4);
                case 5
                    inflec_1 = inflec_1(5);
                case 6
                    inflec_1 = inflec_1(6);
                case 7
                    inflec_1 = inflec_1(7);
                case 8
                    inflec_1 = inflec_1(8);
                case 9
                    inflec_1 = inflec_1(9);
                otherwise
                    return;
            end
        end
        
        inflec_2 = intersect(Cpoint_indices,cur_window);
        
        if length(inflec_2) < 1
            inflec_clear()
            msgbox('Please annotate C point for Inflection Visualization','Warning Window Name','warn');
            return
        end
        
        icg_infl = icg(inflec_1:inflec_2);
        t_inflec = 1:length(icg_infl);
        id_grad=sign(icg_D2);                       % sign of 2nd derivative of icg
        mag = 0.7*limit_ch2_Y2;
        
        picg = plot(hplotICG,t,icg,'b-',...
            t(Rpeak_indices),icg(Rpeak_indices),'r+',...
            t(Cpoint_indices),icg(Cpoint_indices),'ro',...
            t(Bpoint_indices),icg(Bpoint_indices),'bo',...
            t(Xpoint_indices),icg(Xpoint_indices),'ko',...
            t(t_inflec+inflec_1-1),mag*id_grad(t_inflec+inflec_1-1),'green');
        set(picg, 'Linewidth',1.5);
        text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
        text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
        text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
        text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
        
        set(hplotICG,'XLim',xlimit);
        set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
        set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
        xlabel(hplotICG,'Time (s)','Color','y');
        ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
        set(hplotICG,'XGrid','on');
        if (strcmp(timelim,'RC Interval'))
            set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
            set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
        end
        add_Bpoint
        set(hinflec_show,'Enable','off')
        set(hinflec_clear,'Enable','on')
        
    end

hinflec_clear = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x  yPositionButtonsOnset-14*highButtons+0.02    2*widthButtons+0.005     highButtons], ...
    'fontsize',fontsize10,...
    'background',[0.2 0.8 0.6],...
    'Enable','Off',...
    'TooltipString', 'To clear zero crossing graph and sign',...
    'Callback', @inflec_clear);
set(hinflec_clear, 'String', 'Clear Inflection');

    function inflec_clear(~,~)
        
        set(tick_help,'String', '','background',[0 0 0]);
        set(hdisp_data_ICG, 'string','ICG Amplitude')
        set(hdisp_data_ICG, 'visible','off')       
        set(hdisp_derivative_ICG,'Visible','off')
        set(hinflec_show,'Enable','on');set(hinflec_clear,'Enable','off')
        set(hdel_Cpoint,'Enable','on');set(hadd_Cpoint,'Enable','on'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','on');
        set(hdel_Bpoint,'Enable','on');set(hadd_Bpoint,'Enable','on'),set(hstop_Bpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','on');
        
        
        if (strcmp(timelim,'Data Length'))
            set(hauto_Bpoint, 'Enable', 'off');
        else
            set(hauto_Bpoint, 'Enable', 'on');
        end


        if (strcmp(timelim,'RC Interval'))
            limitX1 = (Rpeak_indices(page_cur)/fs-0.05);
            limitX2 = (Rpeak_indices(page_cur)/fs) + seg_window;
            xlimit = [limitX1  limitX2];
            set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off');set(hstop_Xpoint,'Enable','off');
            set(hauto_Xpoint,'Enable','off')
        else
            limitX1 = (page_cur-1)*seg_window;
            limitX2 = (page_cur)*seg_window;
            xlimit = [limitX1  limitX2];
            set(hdel_Xpoint,'Enable','on');set(hadd_Xpoint,'Enable','on');set(hstop_Xpoint,'Enable','off')
        end
            
        
        
        minamp_Ch2Rd =  min(icg((round(xlimit(1)*fs)+1):end));
        maxamp_Ch2Rd =  max(icg((round(xlimit(1)*fs)+1):end));
        
        limit_ch2_Y1 = (minamp_Ch2Rd-0.5*abs(minamp_Ch2Rd));
        %         limit_ch2_Y2 = (maxamp_Ch2Rd+0.1*abs(maxamp_Ch2Rd));
        limit_ch2_Y2 = (maxamp_Ch2Rd+0.1);
        
        picg = plot(hplotICG,t,icg,'b-',...
            t(Rpeak_indices),icg(Rpeak_indices),'r+',...
            t(Cpoint_indices),icg(Cpoint_indices),'ro',...
            t(Bpoint_indices),icg(Bpoint_indices),'bo',...
            t(Xpoint_indices),icg(Xpoint_indices),'ko');
        set(picg,'Linewidth',1.5);
        
        text(hplotICG, t(Rpeak_indices),icg(Rpeak_indices +20),'R','color','red')
        text(hplotICG, t(Cpoint_indices),icg(Cpoint_indices+12),'C','color','red')
        text(hplotICG, t(Bpoint_indices),icg(Bpoint_indices-15),'B','color','blue')
        text(hplotICG, t(Xpoint_indices),icg(Xpoint_indices-25),'X')
        
        
        set(hplotICG,'XLim',xlimit);
        set(hplotICG,'YLim',[limit_ch2_Y1  limit_ch2_Y2]);
        set(hplotICG,'Xtick',(page_cur-1)*seg_window :seg_time:page_cur*seg_window);
        xlabel(hplotICG,'Time (s)','Color','y');
        ylabel(hplotICG,'ICG (\Omega s^{-1})','Color','y');
        set(hplotICG,'XGrid','on');
        if (strcmp(timelim,'RC Interval'))
            set(hplotICG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
            set(hplotECG,'XTick', 0:(limitX2-limitX1)/5:limitX2);
        end
        
    end

%% Notes 

hadd_notes = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x   yPositionButtonsOnset-11.1*highButtons+0.02    2*widthButtons+0.005   highButtons+0.001], ...
    'String', 'Add Notes', ...
    'fontsize',fontsize10,...
    'background',[0.2 0.8 0.6],...
    'TooltipString', ['To add vital information', newline, ...
    'regarding current record.'],...
    'Enable','Off',...
    'Callback', @add_notes);
% set(hadd_notes, 'String', '<html> Add <br> Notes');    % for multi line button text


    function add_notes(~, ~)
        filename = strcat(folder_path_manual,record_name,'_Notes','.txt');
        if  ~exist(filename, 'file' )
            fid = fopen(filename,'w');
            fclose(fid);
        else
            fid = fopen(filename);
            fclose(fid);
        end
        system(filename);
        
        %
    end

%% Hiding and showing ECG plot

hECG_hide = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x   yPositionButtonsOnset-5.3*highButtons+0.01    2*widthButtons+0.005   highButtons], ...
    'String', 'Hide ECG', ...
    'fontsize',fontsize10,...
    'background',[0.2 0.8 0.6],...
    'TooltipString', ['Hide ECG plot and', newline, ...
    'enlarge ICG plot'],...
    'Enable','Off',...
    'Callback', @ECG_hide);

    function ECG_hide(~,~)
        
        ECG_hide_mk=1;
        
        set(hdisp_data_ECG,'Visible','off');set(hplotECG,'Visible','off');
        set(hplotICG, 'Position', [0.04    0.07    0.74   0.62]);
        set(hdel_Rpeak,'Enable','off');set(hadd_Rpeak,'Enable','off');set(hstop_Rpeak,'Enable','off');
        set(hauto_Rpeak,'Enable','off');
        set(hdel_Cpoint,'Enable','on');set(hadd_Cpoint,'Enable','on'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','on');
        set(hdel_Bpoint,'Enable','on');set(hadd_Bpoint,'Enable','on'),set(hstop_Bpoint,'Enable','off');
        set(hdel_Xpoint,'Enable','on');set(hadd_Xpoint,'Enable','on'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','on');
        set(hECG_hide,'Enable','off'); set(hECG_show,'Enable','on');
        set(hinflec_show,'Enable','on'); set(hinflec_clear,'Enable','off');
     
        
        if strcmp(timelim,'Data Length')
            set(hdisp_C_Shape,'visible','off');
            set(hdisp_X_Shape,'visible','off');
            set(hdisp_RC_feature,'visible','off');
            set(hauto_Bpoint, 'Enable', 'off');
            set(hRC_pop,'Enable','off');
            set(hC_pop,'Enable', 'off');
            set(hX_pop,'Enable', 'off');           
        elseif strcmp(timelim,'Beat Length') 
            set(hdisp_C_Shape,'visible','on');
            set(hdisp_X_Shape,'visible','on');
            set(hdisp_RC_feature,'visible','on');
            set(hauto_Bpoint, 'Enable', 'on');
            set(hRC_pop,'Enable','on');
            set(hC_pop,'Enable', 'on');
            set(hX_pop,'Enable', 'on');
        elseif strcmp(timelim,'RC Interval')
            set(hdisp_C_Shape,'visible','on');
            set(hdisp_X_Shape,'visible','off');
            set(hdisp_RC_feature,'visible','on');
            set(hauto_Bpoint, 'Enable', 'on');
            set(hRC_pop,'Enable','on');
            set(hC_pop,'Enable', 'on');
            set(hX_pop,'Enable', 'off');
            
        end      
    end


hECG_show = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x  yPositionButtonsOnset-5.3*highButtons+0.01    2*widthButtons+0.005   highButtons], ...
    'String', 'Show ECG', ...
    'fontsize',fontsize10,...
    'background',[0.2 0.8 0.6],...
    'TooltipString', ['Show ECG plot and', newline, ...
    'resize ICG plot'],...
    'Enable','Off',...
    'Callback', @ECG_show);

    function ECG_show(~,~)
        ECG_hide_mk=0;
        
        set(hRC_pop,'Enable','off');
        set(hC_pop,'Enable', 'off');
        set(hX_pop,'Enable', 'off');
        set(hdisp_data_ECG,'Visible','off');
        
        set(hplotECG,'Visible','on');
        set(hplotICG, 'Position',[0.04    0.07    0.74   0.335]);
        set(hdel_Rpeak,'Enable','on');set(hadd_Rpeak,'Enable','on');set(hstop_Rpeak,'Enable','off');
        set(hauto_Rpeak,'Enable','on');set(hECG_hide,'Enable','on');set(hECG_show,'Enable','off');
        set(hdel_Cpoint,'Enable','off');set(hadd_Cpoint,'Enable','off'),set(hstop_Cpoint,'Enable','off');
        set(hauto_Cpoint,'Enable','on');
        set(hdel_Bpoint,'Enable','off');set(hadd_Bpoint,'Enable','off'),set(hstop_Bpoint,'Enable','off');
        set(hauto_Bpoint, 'Enable', 'off');
        set(hdel_Xpoint,'Enable','off');set(hadd_Xpoint,'Enable','off'),set(hstop_Xpoint,'Enable','off');
        set(hauto_Xpoint,'Enable','on');
       
        set(hinflec_show,'Enable','off');set(hinflec_clear,'Enable','off');
        
        set(hdisp_RC_feature,'visible','off');
        set(hdisp_C_Shape,'visible','off');
        set(hdisp_X_Shape,'visible','off');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Beat Statistics panel

tick_beat_num = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x    0.86   widthButtons   highButtons], ...
    'String', 'Beat No:',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);
tick_segment1 = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x  0.86  widthButtons-0.01  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

tick_RB = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x    0.78   widthButtons    highButtons], ...
    'String', 'PEP (RB) ',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);

tick_RB_text = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x  0.78  widthButtons-0.01  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

tick_RC = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x    0.82   widthButtons    highButtons], ...
    'String', 'ISTI (RC)',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);

tick_RC_text = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x  0.82  widthButtons-0.01  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

ticK_BX = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x    0.74   widthButtons    highButtons], ...
    'String', 'ET (BX)',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);

tick_BX_text = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x  0.74  widthButtons-0.01  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

tick_beat_len = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x-0.005   0.86   widthButtons+0.01    highButtons], ...
    'String', 'Beat length',...
    'HorizontalAlignment','Left',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);

tick_beat_len_text = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x+0.005  0.86  widthButtons  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);


tick_Camp = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x-0.005    0.82   widthButtons+0.01    highButtons], ...
    'String', 'C amplitude',...
    'HorizontalAlignment','Left',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);

tick_Camp_text = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x+0.005  0.82  widthButtons  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

tick_Bamp = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x-0.005   0.78   widthButtons+0.01    highButtons], ...
    'String', 'B amplitude',...
    'HorizontalAlignment','Left',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);

tick_Bamp_text = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x+0.005  0.78  widthButtons  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

tick_Xamp = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x-0.005    0.74   widthButtons+0.01     highButtons], ...
    'String', 'X amplitude',...
    'HorizontalAlignment','Left',...
    'fontweight','bold',...
    'fontsize',fontsize10,...
    'background',[0.2 0.6 0.8]);

tick_Xamp_text = uicontrol(hMainFigure, ...
    'Style', 'edit', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Xnew_st_x+0.005   0.74  widthButtons  highButtons], ...
    'String', '--',...
    'foreground', [1 0 0],...
    'fontsize',fontsize10);

hcomp_param = uicontrol(hMainFigure, ...
    'Style', 'pushbutton', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x   0.69   2*w1    0.04], ...
    'String', 'Compute Parameters', ...
    'fontsize',fontsize10,...
    'background',[0.2 0.8 0.6],....
    'TooltipString', ['Compute parameters', newline, ...
    ' for current beat'],...
    'Enable','Off',...
    'Callback', @comp_param);

    function comp_param(~,~)

        Rpeak_indices_sorted= sort(Rpeak_indices);
        med_rr = median(diff(Rpeak_indices_sorted));
        Cpoint_indices_sorted = sort(Cpoint_indices);
        Bpoint_indices_sorted = sort(Bpoint_indices);
        Xpoint_indices_sorted = sort(Xpoint_indices);

        omeg = string(char(hex2dec('3a9')));
        omeg_sec_inv = strcat(' ', omeg, '/','s');
        
       
 % for RC, C amplitude calculations
        if (length(Rpeak_indices_sorted) ~= length(Cpoint_indices_sorted)) || (length(Rpeak_indices_sorted) <=1) || (length(Cpoint_indices_sorted) <=1)
           errordlg('Number of R peaks are not equal to number of C points:  Please verify and annotate','RC Calculation Error','warn');
        else
            RC_cur = Cpoint_indices_sorted(page_cur) - Rpeak_indices_sorted(page_cur);
            set(tick_RC_text,'String',strcat(num2str(RC_cur), ' ms'))
            set(tick_beat_len_text,'String',strcat(num2str(med_rr), ' ms'));
            icg_mag_C_cur = num2str(icg (Cpoint_indices_sorted(page_cur)),2);
            set(tick_Camp_text,'String',strcat(icg_mag_C_cur,' ',omeg_sec_inv));
 % for RB,and B amplitude calculations          
            rg_B = [Rpeak_indices_sorted(page_cur) Cpoint_indices_sorted(page_cur)];
            Bpt_cur = Bpoint_indices_sorted(Bpoint_indices_sorted >= rg_B(1) & Bpoint_indices_sorted <= rg_B(2));
            rg_X = [Cpoint_indices_sorted(page_cur)+0.1*fs  Cpoint_indices_sorted(page_cur)+0.4*fs];
            Xpt_cur = Xpoint_indices_sorted(Xpoint_indices_sorted >= rg_X(1) & Xpoint_indices_sorted <= rg_X(2));
            if isempty(Bpt_cur)
               set(tick_RB_text,'String','NaN')
               set(tick_Bamp_text,'String','NaN')  
               set(tick_BX_text,'String','NaN')
               msgbox('B point not found in RC interval','Warning Window Name','warn');
               if ~isempty(Xpt_cur) && length(Xpt_cur) == 1
                    icg_mag_X_cur = num2str(icg(Xpt_cur),2);
                    set(tick_Xamp_text,'String',strcat(icg_mag_X_cur,' ',omeg_sec_inv));
               else
                   set(tick_Xamp_text,'String','NaN');
               end
               
            elseif length(Bpt_cur) > 1
               set(tick_RB_text,'String','NaN')
               set(tick_Bamp_text,'String','NaN')  
               set(tick_BX_text,'String','NaN')
               errordlg('More than one B point found in RC interval. Please annotate single B point in RC interval.','Warning Window Name','warn');
            else
                RB_cur = Bpt_cur - Rpeak_indices_sorted(page_cur);
                set(tick_RB_text,'String',strcat(num2str(RB_cur), ' ms'))
                icg_mag_B_cur= num2str(icg(Bpt_cur),2);
                set(tick_Bamp_text,'String',strcat(icg_mag_B_cur,' ',omeg_sec_inv));
 % for BX and  X amplitude

                if isempty(Xpt_cur)
                     set(tick_Xamp_text,'String','NaN');
                     set(tick_BX_text,'String','NaN');
                     msgbox('X point not found in interval [C+150 C+350] msec','Warning Window Name','warn');
                elseif length(Xpt_cur) > 1
                    set(tick_BX_text,'String','NaN')
                    set(tick_Xamp_text,'String','NaN')  
                    set(tick_BX_text,'String','NaN')
                    errordlg('More than one X point found in interval [C+150 C+350] msec. Please annotate single X point in the interval.','Warning Window Name','warn');
                else
                    BX_cur = Xpt_cur -  Bpt_cur ;
                    set(tick_BX_text,'String',strcat(num2str(BX_cur), ' ms'));
                    icg_mag_X_cur = num2str(icg(Xpt_cur),2);
                    set(tick_Xamp_text,'String',strcat(icg_mag_X_cur,' ',omeg_sec_inv));
                end
            end          

        end
    end
          
%% Display ICG amplitudes
hdisp_data_ICG = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.04    0.07    0.12  highButtons], ...
    'String', 'ICG Amplitude',...
    'fontweight','bold',...
    'Visible', 'off',...
    'fontsize',fontsize12);
set(hdisp_data_ICG,'backgroundcolor',get(hplotICG,'color'))     % transparent text box

%% Display ECG amplitudes
hdisp_data_ECG = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.04    0.45    0.12  highButtons], ...
    'String', 'ECG Amplitude',...
    'fontweight','bold',...
    'Visible', 'off',...
    'fontsize',fontsize12);
set(hdisp_data_ECG,'backgroundcolor',get(hplotECG,'color'))     % transparent text box

%% Showing derivatives of ICG
%% Display ICG Derivative amplitudes
hdisp_derivative_ICG = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.04    0.65    0.16  highButtons], ...
    'String', 'Zero Crossing Sign',...
    'fontweight','bold',...
    'Visible', 'off',...
    'fontsize',fontsize12);
set(hdisp_derivative_ICG,'backgroundcolor',get(hplotICG,'color'))     % transparent text box

%% C Shape Selection Panel

tickC_shape_pan = uicontrol(hMainFigure, ...
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [0.781    0.355    0.205   0.04], ...
    'String', 'C & X Shape Selection Panel',...
    'fontweight','bold',...
    'fontsize',13,...
    'Foreground', [1 1 0],...   % yellow colour
    'background',[0.2 0.6 0.8]);

hdisp_C_Shape = uicontrol(hMainFigure, ...       % text box in top right corner of ICG plot 
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x-1.8*w1    0.64    0.12  highButtons], ...
    'String', 'Select C shape',...
    'fontweight','bold',...
    'Visible', 'Off',...
    'fontsize',fontsize12);
set(hdisp_C_Shape,'backgroundcolor',get(hplotICG,'color'))     % transparent text box

hC_pop = uicontrol(hMainFigure, ...          % popup menu for "RC features"
    'Style', 'popupmenu', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Rnew_st_x    yPositionButtonsOnset-8.4*highButtons+0.02       2*widthButtons+0.005    highButtons], ...
    'String', {'Select C shape','Single peak','Double peak (M)','Flat','Inflection close to peak','Valley close to peak',...
    'Inflection after peak','Valley after peak','Other - notes added'}, ...
    'HorizontalAlignment', 'center',...
    'fontsize',fontsize10,...
    'Tag', 'timelim',...
    'Enable','off',...
    'Callback', @C_shape_con);

    function C_shape_con(hObject, ~)
        contents = cellstr(get(hObject,'String'));
        C_shp= contents{get(hObject,'Value')};
        if (contains(C_shp,'Select'))
            C_shape = 'Select C shape';
        elseif (strcmp(C_shp,'Single peak'))
            C_shape = 'Single peak';
        elseif (strcmp(C_shp,'Double peak (M)'))
            C_shape = 'Double peak (M)';
        elseif (strcmp(C_shp,'Flat'))
            C_shape = 'Flat';
        elseif (strcmp(C_shp,'Inflection close to peak'))
            C_shape = 'Inflection close to peak';
        elseif (strcmp(C_shp,'Valley close to peak'))
            C_shape = 'Valley close to peak';
        elseif (strcmp(C_shp,'Inflection after peak'))
            C_shape = 'Inflection after peak';
        elseif (strcmp(C_shp,'Valley after peak'))
            C_shape = 'Valley after peak';
        elseif (strcmp(C_shp,'Other - notes added'))
            C_shape = 'Other - notes added';
        end
        % Camilo
        beatsCshape( page_cur )  = get(hC_pop, 'Value');
        filename = strcat(folder_path_manual,record_name,'_CShape','.txt');
        dlmwrite(filename, beatsCshape);
        set(hdisp_C_Shape,'String',strcat('C: ', C_shape));
    end

%% X Shape Selection Panel

hdisp_X_Shape = uicontrol(hMainFigure, ...       % text box in top right corner of ICG plot 
    'Style', 'text', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Cnew_st_x-1.8*w1    0.5    0.12  highButtons], ...
    'String', 'Select X shape',...
    'fontweight','bold',...
    'Visible', 'off',...
    'fontsize',fontsize12);
set(hdisp_X_Shape,'backgroundcolor',get(hplotICG,'color'))     % transparent text box

hX_pop = uicontrol(hMainFigure, ...          % popup menu for "RC features"
    'Style', 'popupmenu', ...?% can changed text
    'HandleVisibility', 'callback', ...
    'Units', 'normalized',...
    'Position', [Bnew_st_x    yPositionButtonsOnset-8.4*highButtons+0.02       2*widthButtons+0.005    highButtons], ...
    'String', {'Select X shape','Single notch','Double notch','Not visible','Other - notes added'}, ...
    'HorizontalAlignment', 'center',...
    'fontsize',fontsize10,...
    'Tag', 'timelim',...
    'Enable','off',...
    'Callback', @X_shape_con);

    function X_shape_con(hObject, ~)
        contents = cellstr(get(hObject,'String'));
        X_shp= contents{get(hObject,'Value')};
        if (contains(X_shp,'Select'))
            X_shape = 'Select X shape';
         elseif (strcmp(X_shp,'Single notch'))
            X_shape = 'Single notch';
        elseif (strcmp(X_shp,'Double notch'))
            X_shape = 'Double notch';
        elseif (strcmp(X_shp,'Not visible'))
            X_shape = 'Not visible';
        elseif (strcmp(X_shp,'Other - notes added'))
            X_shape = 'Other - notes added';
        end
        % Camilo
        beatsXshape( page_cur )  = get(hX_pop, 'Value');
        filename = strcat(folder_path_manual,record_name,'_XShape','.txt');
        dlmwrite(filename, beatsXshape);
        set(hdisp_X_Shape,'String',strcat('X: ', X_shape));
    end
end
