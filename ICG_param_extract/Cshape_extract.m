% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG"
%    Configured to extract shapes of C point of ICG beat.

% INPUT:
%   1. EA ECG and ICG signal for record identification.
%   2. Annotations for C shape extraction.
% OUTPUT:
%    C shape types of all beats of selected records.


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
% (EA_folder), C shape annotation (Ann_folder) and output excel file 
%(out_folder) on their local machine.


EA_folder = 'D:\Clifford_Lab\Github\ICG_OSToolbox\ICG_ECG_Demo_Data\Ensemble_Averaged_ECG_ICG\';   
Ann_folder = 'D:\Clifford_Lab\Github\ICG_OSToolbox\ICG_ECG_Demo_Data\Ensemble_Averaged_ECG_ICG\Ensemble_Averaged_ECG_ICG_manual_annotation\';
out_folder = 'D:\Clifford_Lab\Github\ICG_OSToolbox\ICG_ECG_Demo_Data\Sample_Parameters_Extracted\';

EA_files = fullfile(EA_folder, '*.mat');          % Reading mat files for record ID
EAFiles = dir(EA_files);

C_shape = struct();                          % C shape for all records
Dummy = struct();                               % Dummy structure to save numeric C shape

for k = 1 : length(EAFiles)         
  basename = EAFiles(k).name;                   % Reading the ECG /ICG record
  full_name = fullfile(EA_folder, basename);
  C_shape(k).ID = basename(1:end-4);
  basename_3s =  basename(1:end-4);              % basename required to access annotaion folders

%% 2. Loading  annotations for C shapes
  basename_C_shape = strcat(basename_3s,'_CShape.txt');
  Cshape_file  = fullfile(Ann_folder, basename_C_shape);
  name = dir(Cshape_file);          % for calculating size of the text file

  if exist(Cshape_file, 'file') && (name.bytes > 0)     % checking file exists and contains data
      fprintf(1,'Loading C shapes for %s\n', basename_3s);
      data = fileread(Cshape_file);
      f = fopen(Cshape_file);
      data = textscan(f,'%s');
      fclose(f);
      Dummy(k).variable = str2double(data{1}(1:1:end));
      for b = 1: length(Dummy(k).variable)
          Cshape_num = Dummy(k).variable(b);
          [beat_Cshape] = Cshape_read(Cshape_num);

           switch b
               case 1
                   C_shape(k).Cshape_beat_1 = beat_Cshape;            
               case 2
                   C_shape(k).Cshape_beat_2 = beat_Cshape;
               case 3
                    C_shape(k).Cshape_beat_3 = beat_Cshape;
               case 4
                    C_shape(k).Cshape_beat_4 = beat_Cshape;
               case 5
                    C_shape(k).Cshape_beat_5 = beat_Cshape;
               case 6
                    C_shape(k).Cshape_beat_6 = beat_Cshape;
               case 7
                    C_shape(k).Cshape_beat_7 = beat_Cshape;
               case 8
                    C_shape(k).Cshape_beat_8 = beat_Cshape;
               case 9
                    C_shape(k).Cshape_beat_9 = beat_Cshape;
               case 10
                    C_shape(k).Cshape_beat_10 = beat_Cshape;             
               otherwise
                    disp('More than 10 EA beats')   
            end

       end
  else
      fprintf(1, 'Could not find C shapes for record: %s\n',basename_3s);
  end
end
 %% 3. saving  Cshapes in excel sheets

disp('Saving C shape types for beats of all records ...')
out_file = strcat(out_folder, 'Demo_C_Shape.xlsx');

if exist(out_file, 'file')
    delete(out_file)
end
writetable(struct2table( C_shape), out_file)


