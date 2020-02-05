function [RBCX_points,no_RBCX_points] = RBCX_read(ann_folder, basename_file,ID)
% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG".
%    Configured to extract sorted indices of R peaks, B, C, or X points
%    based on input annotations.
%
% INPUT:
%    ann_folder : Folder containing annotations.
%    basename_file : File name containing R peaks, B, C, or X points
% OUTPUT:
%    RBCX point :  Sorted  indices of R peaks, B, C, or X points
%    no_RBCX_points : Number of R peaks, B, C or X points
%
% DEPENDENCIES & LIBRARIES:
%   ICG Noise Removal Toolbox
%   https://github.com/cliffordlab/ICG_OSToolbox
%
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
%
%
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information.

% This file has been updated on Nov 8, 2019 by Shafa-at Ali Sheikh.

%%
 full_file_name = fullfile(ann_folder, basename_file);
 name = dir(full_file_name);          % for calculating size of the text file
 Rpeak_pattern = "_Rpeak.txt";
 Bpoint_pattern = "_Bpoint.txt";
 Cpoint_pattern = "_Cpoint.txt";
 Xpoint_pattern = "_Xpoint.txt";

if exist(full_file_name, 'file') & (name.bytes > 0)     % checking file exists and contains data
    RBCX_points = dlmread(full_file_name);
    RBCX_points =  sort (RBCX_points(:,1));              % Manually annotated points
    no_RBCX_points = length(RBCX_points);                % Number of manually annotated points
  else
      RBCX_points =[];
      no_RBCX_points =0;
      if contains(basename_file,Rpeak_pattern)
          fprintf(1, 'Could not find R peaks for record: %s\n',ID);
      elseif contains(basename_file,Bpoint_pattern)
          fprintf(1, 'Could not find B point for record: %s\n',ID);
      elseif contains(basename_file,Cpoint_pattern)
           fprintf(1, 'Could not find C point for record: %s\n',ID);
      elseif contains(basename_file,Xpoint_pattern)
           fprintf(1, 'Could not find X point for record: %s\n',ID);
      end
end
  
end

