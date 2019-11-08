% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG"
%    Configured to extract beat by beat and averaged parameters from 
%     Ensemble averaged (EA) ECG and ICG signals and annotaions.

% INPUT:
%   1. EA ECG and ICG signal under neutral and stress conditions.
%   2. Annotations for R peak, B point, C point and X point.

% OUTPUT:
%    Following parameters at beat and record level can be extracted
%    1. Pre-ejection period (RB).
%    2. Intersystolic time interval (RC).
%    3. Left ventircualr ejection time (LVET).
%    4. Ejection velocity index (amplitude of C point)


% DEPENDENCIES & LIBRARIES:
%   ICG Noise Removal Toolbox
%   https://github.com/cliffordlab/ICG_OSToolbox
%   Function files : Bpt_param.m and RBCX_read.m available at 
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_param_extract

% REFERENCE: 
%   Shafa-at Ali Sheikh et al. "An Open Sourc Toolbox for Automated Removal
%   of Noisy Beats for Accurate ICG Analysis" (** Details to be added**) 

%	REPO for code:       
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_param_extract
%
%   REPO for demo data:
%   1. Input data: 
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Sample_Annotations_by_ICMAA
%
%   2. Sample output data:
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Sample_Parameters_Extracted
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information

% This file has been updated on Nov 8, 2019 by Shafa-at Ali Sheikh.

%% 1.  Reading data and manual annotations from designated folders
clc
clear
EA_folder = 'D:\Clifford_Lab\1_for_upload\data_for_upload\EA_ECG_ICG\';   
Ann_folder = 'D:\Clifford_Lab\1_for_upload\data_for_upload\EA_ECG_ICG\EA_ECG_ICG_manual_annotation\';

EA_files = fullfile(EA_folder, '*.mat');          % Reading mat files for Eavg data
EAFiles = dir(EA_files);
Record_avg = struct();                  % deep learning features 
RB = struct();                       % RB based on shapes - features for all records
RC = struct();                       % RC related features for all beats of  records
BX = struct();                       % BC related features for all beats of records
Camp = struct();                     % Ejection velocity C amplitude related features for all beats of records

for k = 1 : length(EAFiles)         
  basename = EAFiles(k).name;                         % Reading the ECG /ICG record
  full_name = fullfile(EA_folder, basename);
  fprintf(1,'Loading %s\n', basename);
  load(full_name);
  EA_icg = EA_ecg_icg(2,:);
   
  Record_avg(k).ID = basename(1:end-4);
  RB(k).ID = basename(1:end-4);
  RC(k).ID = basename(1:end-4);
  BX(k).ID = basename(1:end-4);  
  Camp(k).ID = basename(1:end-4);  

  basename_3s =  basename(1:end-4);      % basename required to access annotaion folders
     
  %% 2. Loading  annotations for Rpeaks, B points, Cpoints and Xpoints (auto generated and manually checked) for three - Stage EA records
   basename_Rpk_man = strcat(basename_3s,'_Rpeak.txt');
   basename_Bpoint_man = strcat(basename_3s,'_Bpoint.txt');
   basename_Cpoint_man = strcat(basename_3s,'_Cpoint.txt'); 
   basename_Xpoint_man = strcat(basename_3s,'_Xpoint.txt'); 

   [Rpk,no_Rpk] = RBCX_read(Ann_folder, basename_Rpk_man,basename_3s);
   RB(k).no_Rpeaks= no_Rpk;
   RC(k).no_Rpeaks= no_Rpk;
   Record_avg(k).no_Rpeaks= no_Rpk;
 
   [Bpoint,no_Bpoint] = RBCX_read(Ann_folder, basename_Bpoint_man,basename_3s);
   BX(k).no_Bpoint = no_Bpoint;
   RB(k).no_Bpoints= no_Bpoint;
   Record_avg(k).no_Bpoints = no_Bpoint;
  
   [Cpoint,no_Cpoint] = RBCX_read(Ann_folder, basename_Cpoint_man,basename_3s);
   RC(k).no_Cpoint = no_Cpoint;
   Camp(k).no_Cpoint = no_Cpoint;
   Record_avg(k).no_Cpoints = no_Cpoint;
   
   [Xpoint,no_Xpoint] = RBCX_read(Ann_folder, basename_Xpoint_man,basename_3s);
   BX(k).no_Xpoints = no_Xpoint;
   Record_avg(k).no_Xpoints = no_Xpoint;
   


   %% 3. RB, average RB, B amplitude, average B amplitude,
  RorCorX = 'R';
  
  if no_Rpk == 0
    RB(k).beats_used = 0;
    RB(k).RB= 'NaN';
    RB(k).RB_Avg= 'NaN';   
    Record_avg(k).RB_Avg= 'NaN';
  else
    [Beats_used, B_amp, Bamp_Avg, RBs, RB_Avg] = Bpt_param(EA_icg,Bpoint,Rpk,Cpoint,Xpoint, RorCorX);
    RB(k).beats_used = Beats_used;
    RB(k).RB= RBs;
    RB(k).RB_Avg= RB_Avg;        
    Record_avg(k).RB_Avg= RB_Avg; 
  end
  
  %% 4.RC, average RC
 if no_Cpoint == 0
      Camp(k).Camp = 'NaN';
      Camp(k).Camp_Avg = 'NaN';
      RC(k).RC = 'NaN'; 
      RC(k).RC_Avg = 'NaN';     
      Record_avg(k).Camp_Avg = 'NaN';
      Record_avg(k).RC_Avg ='NaN'; 
  else
      Camp(k).Camp = EA_icg(Cpoint);
      Camp(k).Camp_Avg = mean(Camp(k).Camp);
      RC(k).RC = Cpoint - Rpk; 
      RC(k).RC_Avg = mean(RC(k).RC);      
      Record_avg(k).Camp_Avg = mean(Camp(k).Camp);
      Record_avg(k).RC_Avg = mean(RC(k).RC ); 
 end
  
    %% 5. BX, X ampltiude, average BX, average X amplitude
  RorCorX = 'X';
  if no_Xpoint == 0
      BX(k).beats_used = 0;
      BX(k).BX = 'NaN'; 
      BX(k).BX_Avg = 'NaN';
      Record_avg(k).BX_Avg ='NaN'; 
  else
      [Beats_used_BX, ~, ~, BXs, BX_Avg] = Bpt_param(EA_icg,Bpoint,Rpk,Cpoint,Xpoint, RorCorX);
      BX(k).beats_used = Beats_used_BX;
      BX(k).BX = BXs;
      BX(k).BX_Avg = BX_Avg;
      Record_avg(k).BX_Avg = BX_Avg;
  end
   
end

 %% 6. saving  parameters in excel sheets
disp('Saving average extracted parameters for records ...')  
writetable(struct2table(Record_avg), strcat(EA_folder, 'Demo_average_record_ parameters.xlsx'))
disp('Saving RB for beats of all records ...')  
writetable(struct2table(RB), strcat(EA_folder, 'Demo_RB_beat_parameters.xlsx'))
disp('Saving RC for beats of all records ...')  
writetable(struct2table(RC), strcat(EA_folder, 'Demo_RC_beat_parameters.xlsx'))
disp('Saving BX for beats of all records ...')  
writetable(struct2table(BX), strcat(EA_folder, 'Demo_BX_beat_parameters.xlsx'))
disp('Saving C amplitudes for beats of all records ...')  
writetable(struct2table(Camp), strcat(EA_folder, 'Demo_Camp_beat_parameters.xlsx'))

 