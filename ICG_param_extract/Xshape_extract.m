% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG"
%    Configured to extract shapes of X point of ICG beat.

% INPUT:
%   1. EA ECG and ICG signal for record identification.
%   2. Annotations for X shape extraction.
% OUTPUT:
%    X shape types of all beats of selected records.


% DEPENDENCIES & LIBRARIES:
%   ICG Noise Removal Toolbox
%   https://github.com/cliffordlab/ICG_OSToolbox
%   Function files : Cshape_select.m available at 
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

% This file has been updated on Feb 5, 2020 by Shafa-at Ali Sheikh.
%%
clc
clear

%% 1.  Reading data and manual annotations from designated folders

% The users need to indicate the folders (variables) for record ID 
% (EA_folder), X shape annotation (Ann_folder) and output excel file 
%(out_folder) on their local machine.


EA_folder = 'D:\Clifford_Lab\Github\ICG_OSToolbox\ICG_ECG_Demo_Data\Ensemble_Averaged_ECG_ICG\';   
Ann_folder = 'D:\Clifford_Lab\Github\ICG_OSToolbox\ICG_ECG_Demo_Data\Ensemble_Averaged_ECG_ICG\Ensemble_Averaged_ECG_ICG_manual_annotation\';
out_folder = 'D:\Clifford_Lab\Github\ICG_OSToolbox\ICG_ECG_Demo_Data\Sample_Parameters_Extracted\';

EA_files = fullfile(EA_folder, '*.mat');          % Reading mat files for record ID
EAFiles = dir(EA_files);

X_shape = struct();                               % X shapes for all records
Dummy = struct();                                 % Dummy structure to save numeric X shapes

for k = 1 : length(EAFiles)         
  basename = EAFiles(k).name;                     % Reading the ECG /ICG record
  full_name = fullfile(EA_folder, basename);
  X_shape(k).ID = basename(1:end-4);
  basename_3s =  basename(1:end-4);               % basename required to access annotaion folders

%% 2. Loading  annotations for X shapes
  basename_X_shape = strcat(basename_3s,'_XShape.txt');
  Xshape_file  = fullfile(Ann_folder, basename_X_shape);
  name = dir(Xshape_file);          % for calculating size of the text file

  if exist(Xshape_file, 'file') && (name.bytes > 0)     % checking file exists and contains data
      fprintf(1,'Loading X shapes for %s\n', basename_3s);
      data = fileread(Xshape_file);
      f = fopen(Xshape_file);
      data = textscan(f,'%s');
      fclose(f);
      Dummy(k).variable = str2double(data{1}(1:1:end));
      for b = 1: length(Dummy(k).variable)
          Xshape_num = Dummy(k).variable(b);
          [beat_Xshape] = Xshape_read(Xshape_num);

           switch b
               case 1
                   X_shape(k).Xshape_beat_1 = beat_Xshape;            
               case 2
                   X_shape(k).Xshape_beat_2 = beat_Xshape;
               case 3
                    X_shape(k).Xshape_beat_3 = beat_Xshape;
               case 4
                    X_shape(k).Xshape_beat_4 = beat_Xshape;
               case 5
                    X_shape(k).Xshape_beat_5 = beat_Xshape;
               case 6
                    X_shape(k).Xshape_beat_6 = beat_Xshape;
               case 7
                    X_shape(k).Xshape_beat_7 = beat_Xshape;
               case 8
                    X_shape(k).Xshape_beat_8 = beat_Xshape;
               case 9
                    X_shape(k).Xshape_beat_9 = beat_Xshape;
               case 10
                    X_shape(k).Xshape_beat_10 = beat_Xshape;             
               otherwise
                    disp('More than 10 EA beats')   
            end

       end
  else
      fprintf(1, 'Could not find X shapes for record: %s\n',basename_3s);
  end
end
 %% 3. saving  Cshapes in excel sheets

disp('Saving X shape types for beats of all records ...')
out_file = strcat(out_folder, 'Demo_X_Shape.xlsx');

if exist(out_file, 'file')
    delete(out_file)
end

writetable(struct2table( X_shape), out_file)


